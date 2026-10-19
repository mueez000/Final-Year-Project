# IVMS Backend (Firebase Architecture)

This directory contains the core backend services, security rules, indexes, and Cloud Functions for the **Intelligent Vehicle Monitoring System (IVMS)**.

---

## 📁 Directory Structure
```
backend/
├── firebase.json              # Firebase project configuration (Firestore, Functions, Storage, Emulators)
├── firestore.rules            # Granular Role-Based Access Control (Admin, Officer, Driver)
├── firestore.indexes.json     # Firestore composite indexes for telemetry and incidents
├── storage.rules              # Storage security rules (Evidence images, profile pictures)
├── functions/                 # Cloud Functions (Node.js)
│   ├── package.json
│   └── index.js               # Automatic custom claims, role management, admin bootstrap
└── scripts/
    └── seed_admin.js          # Admin SDK CLI script to seed the first Administrator
```

---

## 🛡️ Security & Role Architecture
The IVMS backend uses a hybrid **Firebase Auth Custom Claims + Firestore Role Document** pattern:
- **`admin`**: Full access to all telemetry, incidents, e-challans, user profiles, and broadcasts.
- **`officer`**: Access to active incidents, field reporting, e-challan issuance, and nearby driver telemetry.
- **`driver`**: Restricted to reading/writing only their own telemetry, triggering their own incidents/SOS, and viewing their assigned challans.

---

## 🚀 Quick Start & Deployment

### 1. Install Dependencies
Navigate into the `functions` directory:
```bash
cd functions
npm install
```

### 2. Run Local Firebase Emulators (Optional for offline dev)
```bash
npm install -g firebase-tools
firebase emulators:start
```
The Emulator UI will be available at: `http://localhost:4000`

### 3. Deploy to Live Firebase Project
```bash
# Login to Firebase
firebase login

# Set project ID
firebase use <YOUR_FIREBASE_PROJECT_ID>

# Deploy all backend components (Rules, Functions, Storage)
firebase deploy
```

---

## 🔑 Seeding the Super Admin
To initialize the first Admin account:
1. Download `serviceAccountKey.json` from **Firebase Console > Project Settings > Service Accounts**.
2. Place it in `backend/scripts/serviceAccountKey.json`.
3. Run:
   ```bash
   node scripts/seed_admin.js admin@ivms.gov.pk AdminPassword123 "IVMS Super Admin"
   ```
