# 🚀 IVMS Firebase Setup & Complete End-to-End Testing Guide

Yeh comprehensive guide aapko step-by-step sikhayegi ke **100% Free Firebase (Spark Plan)** kaise connect karna hai aur **Android Studio** mein **Charon Phases (Phase 1 se Phase 4)** ko kaise test karna hai.

---

## 📋 Table of Contents
1. [Firebase Console Setup (Free Spark Tier - Zero Billing)](#1-firebase-console-setup-free-spark-tier---zero-billing)
2. [Android App Register & Configuration](#2-android-app-register--configuration)
3. [Firestore, Authentication & Storage Rules Enablement](#3-firestore-authentication--storage-rules-enablement)
4. [Setting Up First Admin Account](#4-setting-up-first-admin-account)
5. [Running in Android Studio (Emulator / Physical Device)](#5-running-in-android-studio-emulator--physical-device)
6. [Step-by-Step Testing Walkthrough (Phase 1 to Phase 4)](#6-step-by-step-testing-walkthrough-phase-1-to-phase-4)
7. [Troubleshooting & Common FAQs](#7-troubleshooting--common-faqs)

---

## 1. Firebase Console Setup (Free Spark Tier - Zero Billing)

> **Important Note:** Firebase ka **Spark Plan** 100% free hai. Iske liye koi Credit Card ya Bank Account require nahi hota! Isme testing ke liye bohot bari free limits milti hain:
> - **Firebase Auth:** 50,000 monthly active users FREE
> - **Cloud Firestore:** 50,000 reads aur 20,000 writes rozana FREE
> - **Cloud Storage:** 5 GB storage aur 1 GB download rozana FREE

### Step 1.1: Naya Project Banayein
1. Browser mein [Firebase Console](https://console.firebase.google.com/) open karein aur apne Google account se login karein.
2. **"Add project"** ya **"Create a project"** par click karein.
3. Project ka naam rakhein: `ivms-system` (ya koi bhi naam).
4. Google Analytics ko **Disable** kar dein (free testing ke liye zaroorat nahi hai) aur **"Create project"** par click karein.
5. Project create hone ke baad **"Continue"** par click karein.

---

## 2. Android App Register & Configuration

### Option A (Recommended & Fastest): FlutterFire CLI se Auto-Connect

Agar aapke paas Node.js aur Dart installed hain, toh terminal mein yeh 2 commands run karein:

```bash
# 1. FlutterFire CLI activate karein
dart pub global activate flutterfire_cli

# 2. Project directory mein ja kar configure run karein
cd f:\University-Database\1_FYP\3-IMPLIMENTATION\ivms_app
flutterfire configure
```
- Yeh aapse Firebase login puchega aur aapka project select karne ko kahega.
- Platforms mein **Android** aur **Web** select karein (Spacebar se select/deselect, Enter se confirm).
- Yeh command automatically `lib/firebase_options.dart` file ko aapke real keys ke sath update kar degi!

---

### Option B: Firebase Console se Manual Setup

Agar aap manual setup karna chahein:

1. Firebase Console ke Home dashboard par **Android icon** par click karein.
2. **Android package name** mein enter karein:
   ```text
   com.ivms.app.ivms_app
   ```
   *(Yeh wahi package name hai jo `android/app/build.gradle.kts` mein set hai).*
3. **App nickname**: `IVMS App` (optional).
4. **Register app** par click karein.
5. **Download `google-services.json`** button par click kar ke file download karein.
6. Is file ko copy kar ke iss folder mein paste karein:
   👉 `ivms_app/android/app/google-services.json`

7. **Gradle Setup (Only 2 lines):**
   - File: `ivms_app/android/settings.gradle.kts`
     `plugins { ... }` block ke andar yeh line add karein:
     ```kotlin
     id("com.google.gms.google-services") version "4.4.2" apply false
     ```
   - File: `ivms_app/android/app/build.gradle.kts`
     `plugins { ... }` block ke end mein yeh line add karein:
     ```kotlin
     id("com.google.gms.google-services")
     ```

8. **Web Configuration (For Testing Admin Dashboard in Chrome):**
   - Firebase Console mein **Add app** -> **Web (</>)** select karein.
   - App nickname: `IVMS Web Admin`.
   - Diye gaye config object (`apiKey`, `appId`, etc.) ko copy kar ke `ivms_app/lib/firebase_options.dart` mein `web` aur `android` blocks mein replace kar dein!

---

## 3. Firestore, Authentication & Storage Rules Enablement

Firebase Console ke left sidebar se yeh 3 services enable karein:

### A. Authentication Enable Karein:
1. Left menu se **Build > Authentication** par click karein.
2. **Get Started** par click karein.
3. **Sign-in method** tab mein **Email/Password** par click karein.
4. **Enable** switch on karein aur **Save** kar dein.

### B. Cloud Firestore Database Enable Karein:
1. Left menu se **Build > Firestore Database** par click karein.
2. **Create database** par click karein.
3. Database location: `nam5 (us-central)` ya jo bhi default ho select karein.
4. Security Rules: **Start in test mode** select karein (Next > Enable).
5. Database create hone ke baad **Rules** tab mein jayein.
6. Hamari file `ivms_app/firestore.rules` ka sara content copy karein aur Firebase Console ke editor mein paste kar ke **Publish** par click kar dein.
   *(Is se custom role-based security rules active ho jayengi!)*

### C. Cloud Storage (SKIP THIS - NOT NEEDED! 💡):
> **Google Policy Update (Blaze Notice):** Agar Storage par click karne par *"Storage requires a billing account (Blaze)"* nazar aaye toh **pareshan na hon, ise bilkul SKIP kar dein!**
> 
> **Aapko Blaze upgrade karne ya Credit Card lagane ki bilkul zaroorat nahi hai!**
> - Hamare poore IVMS system ka data (Drivers, Officers, Admins, Live GPS Telemetry, AI Incidents, SOS, e-Challans, Raast payment records, aur Field Reports) **Cloud Firestore** mein store hota hai jo **100% FREE** hai!
> - Officer field reports ki evidence photos ke liye hamne direct **Firestore Base64 / Cloud Fallback** integrate kar diya hai, jo bina kisi Cloud Storage bucket ke 100% free chalega!
> 
> 👉 **Khulasa:** Aapko sirf **Authentication** aur **Firestore Database** enable karna hai. Storage ko enable karne ki zaroorat nahi hai!

---

## 4. Setting Up First Admin Account

Admin Dashboard test karne ke liye aapko aik Admin user chahiye:

### Simple Method (Via Firebase Console):
1. App chala kar pehle kisi bhi email se **Driver** ya **Officer** signup kar lein (e.g. `admin@ivms.gov.pk` password: `password123`).
2. Firebase Console -> **Firestore Database** -> `users` collection mein jayein.
3. Us user ke document par click karein aur `role` field ki value ko edit kar ke `"admin"` likh kar save kar dein!
4. Ab aap isi email/password se **Admin Portal** par direct login kar sakte hain.

### Script Method (Optional):
- `ivms_app/scripts/seed_admin.js` ko run kar ke direct service account se bhi admin create kar sakte hain.

---

## 5. Running in Android Studio (Emulator / Physical Device)

1. **Android Studio** open karein aur direct `ivms_app` folder load karein.
2. Terminal mein ya Studio ke top right par **`flutter pub get`** run karein.
3. **Device Select Karein:**
   - **Android Emulator / Phone:** Mobile UI, Driver Mode, aur Officer Mode test karne ke liye.
   - **Chrome (web):** HQ Command Center aur Admin Dashboard test karne ke liye (`flutter run -d chrome`).
4. **Run Button (Green Play ▶️)** press karein!

---

## 6. Step-by-Step Testing Walkthrough (Phase 1 to Phase 4)

App open hote hi aapke samne **Role Selection Screen** aayegi jisme 3 cards honge:
1. 🚗 **Commercial Driver**
2. 👮 **Traffic Officer**
3. 🏢 **Central HQ Administrator**

---

### 🧪 Test Phase 1: Authentication & Role-Based Routing
1. **Driver Signup Test:**
   - Role Selection se **Commercial Driver** select karein.
   - "Don't have an account? Sign Up" par click karein.
   - Details fill karein: Name, Email (`driver1@test.com`), CNIC (`37405-1234567-1`), License No (`ICT-9921`), Vehicle Type (`Heavy Truck`).
   - "Register Driver" press karein.
   - **Verification:** Driver Dashboard khul jayega. Firebase Console mein Authentication tab aur Firestore ke `users` collection mein naya document verify karein!
2. **Officer Signup Test:**
   - Logout karein aur **Traffic Officer** card par click karein.
   - Sign Up form open karein.
   - Details fill karein: Badge No (`NHMP-402`), Rank (`Sub-Inspector`), Station (`Chakri Beat 12`), Phone.
   - Register karein -> Officer Patrol Dashboard load ho jayega!
3. **Admin Login Test:**
   - Role Selection se **HQ Administrator** card select karein.
   - Admin credentials enter karein -> Central HQ Dashboard open ho jayega. Non-admin users par access error show hoga!

---

### 🧪 Test Phase 2: Live Telemetry, GPS Radar & Offline Persistence
1. **Driver Telemetry & Speed Gauge:**
   - Driver account se login karein.
   - Dashboard par **"Start Trip"** toggle on karein.
   - Speedometer activate ho jayega! Agar physical phone par hain toh real GPS speed dikhegi; emulator par hain toh automated M-2 Motorway corridor simulation run hogi.
   - Live location radar display par marker smooth move karega.
2. **Offline Mode Test (Salt Range Zero-Connectivity Zone):**
   - Phone ya emulator ko **Airplane Mode** par kar dein (ya internet disable karein).
   - Speed change karein aur 10 seconds drive run hone dein.
   - App crash nahi hogi! Firestore offline persistence automatically records ko local SQLite cache mein save karta hai.
   - Airplane Mode **OFF** karein -> Sara telemetry data automatically Firebase cloud par sync ho jayega!
3. **Officer Live Patrol Radar:**
   - Officer account se "Patrol Map" tab open karein.
   - Custom Vector Radar canvas par nearby drivers aur active patrols real-time visual pulses ke sath move hote nazar aayenge!

---

### 🧪 Test Phase 3: AI Safety Hub, Fallback Sensors & Officer Dispatch
1. **Driver Safety Hub:**
   - Driver screen par **"Safety Hub"** tab par jayein.
   - Yahan real sensor monitoring (EAR Drowsiness, Accelerometer Jerk) active hai.
2. **Drowsiness Event Trigger:**
   - Button press karein: **"Simulate Drowsy (EAR < 0.21)"**.
   - Red visual alert card aayega aur sound siren trigger hogi.
   - Firestore ke `/incidents` collection mein new incident create ho jayega with `type: 'drowsiness'` aur `severity: 'high'`.
3. **Crash / Collision Trigger:**
   - Button press karein: **"Simulate Crash (Jerk > 4.5G)"**.
   - High-priority SOS dialog trigger hoga jo 15-second countdown dikhayega!
4. **Officer Real-Time Dispatch:**
   - Officer account mein "Incidents" tab par jayein.
   - Bina page refresh kiye, new incident automatically top par appear hoga!
   - Officer **"Accept Dispatch"** par click karega -> Status `pending` se `dispatched` ho jayega aur officer ka badge assign ho jayega!

---

### 🧪 Test Phase 4: HQ Management, e-Challan, Raast Payment & Broadcasts
1. **Officer Issues e-Challan:**
   - Officer Dashboard ke **"Field Report"** tab par jayein.
   - Vehicle Plate (`LED-4589`), Violation Type (`Speeding - Above 120 km/h`), Fine Amount (`Rs. 2,500`), Location (`M-2 KM 184`) enter karein.
   - (Optional) Camera/Gallery se violation ki picture attach karein (Firebase Storage par upload hogi).
   - **"Issue e-Challan & Submit Report"** press karein.
2. **Driver Pays via Raast:**
   - Driver Dashboard ke **"Violations / Challans"** tab par jayein.
   - Abhi issue hua challan `UNPAID` status aur Raast QR code ke sath appear hoga!
   - **"Pay via Raast"** button press karein.
   - Instant settlement simulate hogi aur status `PAID` ho jayega with transaction ID `RAAST-TXN-...`!
3. **HQ Admin Broadcast Console:**
   - Admin account se login karein aur **"Broadcasts"** tab par jayein.
   - New Alert banayein: Title: `Heavy Fog on M-2`, Message: `Visibility below 50m. Speed limit reduced to 60 km/h.`, Priority: `Emergency`.
   - **"Broadcast Alert"** press karein.
   - Sabhi active drivers aur officers ke screens par instant emergency ticker active ho jayega!

---

## 7. Troubleshooting & Common FAQs

| Issue | Solution |
| :--- | :--- |
| **`google-services.json missing` error** | Make sure aapne downloaded file ko `ivms_app/frontend/android/app/` folder ke andar rakha hai. |
| **`minSdkVersion error` (e.g. minSdk < 21)** | `ivms_app/frontend/android/app/build.gradle.kts` mein `minSdk = 21` ya `23` confirm karein. |
| **Permission Denied in Firestore** | Firebase Console -> Firestore -> Rules mein check karein ke hamari `ivms_app/backend/firestore.rules` publish hui hain ya nahi. |
| **Map radar blank dikhai de raha hai** | Hamara vector radar canvas bina kisi expensive Google Maps API key ke smoothly render hota hai. Agar physical device par hain toh GPS Location permission grant karein. |
| **Can I test both Driver and Officer simultaneously?** | Haan! Ek device par Driver open karein aur Chrome Browser (`flutter run -d chrome`) par Admin ya Officer open karein. Real-time sync live dekhein! |

---
**Mubarak ho! Aapka IVMS complete system live Firebase par fully functional aur ready to test hai! 🎯**
