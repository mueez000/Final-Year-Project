/**
 * Seed Script: Create or escalate an account to Administrator
 * Usage:
 *   1. Download your Firebase Service Account JSON from Firebase Console -> Project Settings -> Service accounts
 *   2. Save it as 'serviceAccountKey.json' in this folder
 *   3. Run: node seed_admin.js <admin_email> <password> <displayName>
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

const serviceAccountPath = path.join(__dirname, "serviceAccountKey.json");

if (!fs.existsSync(serviceAccountPath)) {
  console.log("----------------------------------------------------------------");
  console.log("NOTE: 'serviceAccountKey.json' not found in backend/scripts/.");
  console.log("To run this seed script against your live Firebase project:");
  console.log("1. Go to Firebase Console -> Project Settings -> Service Accounts");
  console.log("2. Click 'Generate new private key'");
  console.log("3. Save it as 'serviceAccountKey.json' in backend/scripts/");
  console.log("----------------------------------------------------------------");
}

const email = process.argv[2] || "admin@ivms.gov.pk";
const password = process.argv[3] || "AdminIVMS@2026";
const displayName = process.argv[4] || "IVMS Central Admin";

async function createOrPromoteAdmin() {
  if (!fs.existsSync(serviceAccountPath)) {
    console.error("Exiting: Service account key is required for local Admin SDK execution.");
    process.exit(1);
  }

  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  try {
    let userRecord;
    try {
      userRecord = await admin.auth().getUserByEmail(email);
      console.log(`Found existing user with email ${email} (UID: ${userRecord.uid})`);
    } catch (err) {
      if (err.code === "auth/user-not-found") {
        console.log(`Creating new user with email ${email}...`);
        userRecord = await admin.auth().createUser({
          email: email,
          password: password,
          displayName: displayName,
        });
        console.log(`Created user: ${userRecord.uid}`);
      } else {
        throw err;
      }
    }

    // Set custom claims
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: "admin" });
    console.log(`Assigned role: 'admin' custom claim to UID: ${userRecord.uid}`);

    // Update or create Firestore document in users collection
    await admin.firestore().collection("users").doc(userRecord.uid).set(
      {
        uid: userRecord.uid,
        name: displayName,
        email: email,
        role: "admin",
        status: "active",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    console.log(`Successfully updated Firestore document /users/${userRecord.uid}`);
    console.log("Admin setup complete!");
    process.exit(0);
  } catch (error) {
    console.error("Error setting up admin:", error);
    process.exit(1);
  }
}

createOrPromoteAdmin();
