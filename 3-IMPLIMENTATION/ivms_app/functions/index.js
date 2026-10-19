const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggered whenever a new document is written to /users/{userId}.
 * Automatically sets the custom claim 'role' on Firebase Auth user record.
 * This ensures security rules and frontends can inspect request.auth.token.role.
 */
exports.onUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const userData = snap.data();
    const role = userData.role || "driver";

    try {
      await admin.auth().setCustomUserClaims(userId, { role: role });
      console.log(`Successfully assigned custom claim 'role: ${role}' to user: ${userId}`);
      
      // Update user document to indicate role claim has been synced
      await snap.ref.update({
        claims_synced: true,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      console.error(`Error setting custom claims for user ${userId}:`, error);
    }
  });

/**
 * Triggered whenever an incident is logged in /incidents/{incidentId}.
 * Fams out FCM push notifications to all active Patrol Officers.
 */
exports.onIncidentCreated = functions.firestore
  .document("incidents/{incidentId}")
  .onCreate(async (snap, context) => {
    const incidentId = context.params.incidentId;
    const incident = snap.data();

    const type = incident.type || "incident";
    const vehicleReg = incident.vehicle_reg || "Unknown Vehicle";
    const severity = (incident.severity || "high").toUpperCase();
    const description = incident.description || "Emergency event detected.";

    console.log(`Processing new incident ${incidentId}: ${type} [${severity}] for ${vehicleReg}`);

    try {
      // 1. Fetch active officers with registered FCM push tokens
      const officerSnapshot = await admin
        .firestore()
        .collection("users")
        .where("role", "==", "officer")
        .where("status", "==", "active")
        .get();

      const tokens = [];
      officerSnapshot.forEach((doc) => {
        const data = doc.data();
        if (data.fcm_token && typeof data.fcm_token === "string") {
          tokens.push(data.fcm_token);
        }
      });

      console.log(`Found ${officerSnapshot.size} active officers (${tokens.length} with FCM tokens).`);

      if (tokens.length > 0) {
        // 2. Build FCM Multicast Payload
        const messagePayload = {
          tokens: tokens,
          notification: {
            title: `🚨 ${severity} ALERT: ${type.toUpperCase()}`,
            body: `Vehicle ${vehicleReg}: ${description}`,
          },
          data: {
            incidentId: incidentId,
            type: type,
            severity: severity,
            vehicleReg: vehicleReg,
            latitude: String(incident.latitude || 0),
            longitude: String(incident.longitude || 0),
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
              channelId: "ivms_emergency_alerts",
              priority: "max",
            },
          },
        };

        const response = await admin.messaging().sendEachForMulticast(messagePayload);
        console.log(`FCM Notification dispatched: ${response.successCount} successful, ${response.failureCount} failed.`);
      }

      // 3. Mark incident notification status
      await snap.ref.update({
        officers_notified_count: tokens.length,
        notification_dispatched_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      console.error(`Error fanning out incident ${incidentId}:`, error);
    }
  });

/**
 * Triggered whenever a broadcast is posted to /broadcasts/{broadcastId}.
 * Dispatches an FCM topic message to 'all_users', 'drivers', or 'officers'.
 */
exports.onBroadcastCreated = functions.firestore
  .document("broadcasts/{broadcastId}")
  .onCreate(async (snap, context) => {
    const broadcastId = context.params.broadcastId;
    const broadcast = snap.data();

    const title = broadcast.title || "Highway Bulletin";
    const message = broadcast.message || "";
    const targetRole = broadcast.target_role || "all";
    const topic = targetRole === "all" ? "all_users" : (targetRole === "drivers" ? "drivers" : "officers");

    console.log(`Sending broadcast ${broadcastId} to topic: ${topic}`);

    try {
      const payload = {
        topic: topic,
        notification: {
          title: `📢 ${title}`,
          body: message,
        },
        data: {
          broadcastId: broadcastId,
          severity: broadcast.severity || "info",
        },
      };

      await admin.messaging().send(payload);
      console.log(`Broadcast ${broadcastId} sent successfully to topic ${topic}`);
    } catch (error) {
      console.error(`Error sending broadcast notification:`, error);
    }
  });

/**
 * Callable Function: Set or update user role (Admin only).
 * Allows admins to change user status (e.g. approve officer) or assign roles.
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
  // Check if caller is authenticated and has admin claim
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Only authenticated users can call this function."
    );
  }

  // Verify the caller is an Admin
  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection("users").doc(callerUid).get();
  const callerData = callerDoc.data();

  if (!callerData || callerData.role !== "admin") {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only administrators can set user roles."
    );
  }

  const { targetUid, newRole } = data;
  if (!targetUid || !["admin", "officer", "driver"].includes(newRole)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Valid targetUid and newRole ('admin', 'officer', 'driver') are required."
    );
  }

  try {
    // 1. Update Firebase Auth Custom Claims
    await admin.auth().setCustomUserClaims(targetUid, { role: newRole });

    // 2. Update Firestore User Document
    await admin.firestore().collection("users").doc(targetUid).update({
      role: newRole,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      message: `User ${targetUid} role successfully updated to ${newRole}.`,
    };
  } catch (error) {
    console.error("Error setting user role:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

/**
 * Callable Function: Bootstrap initial Admin account.
 * Only works if there are NO existing admins in the system.
 */
exports.bootstrapAdmin = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required to bootstrap admin."
    );
  }

  const callerUid = context.auth.uid;

  // Check if any admin already exists in the system
  const adminSnapshot = await admin
    .firestore()
    .collection("users")
    .where("role", "==", "admin")
    .limit(1)
    .get();

  if (!adminSnapshot.empty) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "System already has an initialized admin. Request role escalation from current admin."
    );
  }

  // Grant admin rights to caller
  try {
    await admin.auth().setCustomUserClaims(callerUid, { role: "admin" });
    await admin.firestore().collection("users").doc(callerUid).set(
      {
        role: "admin",
        status: "active",
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      success: true,
      message: `User ${callerUid} successfully initialized as Super Admin.`,
    };
  } catch (error) {
    console.error("Error bootstrapping admin:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
