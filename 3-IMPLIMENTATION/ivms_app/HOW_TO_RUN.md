# IVMS Project - Step-by-Step Guide for FYP Mates

Asalam-o-Alaikum team! 👋 
Ye guide aapko batayegi ke iss project ko extract karne ke baad Android Studio mein kaise run karna hai. Iss guide ko bilkul step-by-step follow karein.

## Step 1: Zaroori Software Install Karein (Prerequisites)
Agar aapke paas ye softwares nahi hain, toh sab se pehle inhein install karein:
1. **Android Studio:** (Yahan se download karein: https://developer.android.com/studio)
2. **Flutter SDK:** (Yahan se download karein: https://docs.flutter.dev/get-started/install/windows)
   * *Note: Make sure aapne Flutter ko apne system environment variables (Path) mein add kiya hua hai.*

## Step 2: ZIP File Extract Karein
1. Jo ZIP file aapko mili hai, usay apne computer mein kisi bhi folder mein extract (unzip) karein (e.g., `Documents` ya `D:` drive mein).
2. Extract hone ke baad aapko `1_FYP` naam ka folder milega.

## Step 3: Android Studio Mein Project Open Karein
1. Apna **Android Studio** open karein.
2. Screen par **"Open"** ke button par click karein.
3. Ab us folder mein jayen jahan aapne file extract ki thi aur direct iss folder ko select karein:
   👉 `1_FYP` -> `3-IMPLIMENTATION` -> **`ivms_app`**
4. **"OK"** par click karein. Android Studio automatically isay standard Flutter + Firebase project ke tor par detect kar lega!

## Step 4: Dependencies (Packages) Download Karein
1. Jab project open ho jaye, toh Android Studio thora time lega loading mein (neeche loading bar chal rahi hogi).
2. Left side par `Project` window mein `pubspec.yaml` file par double click karein.
3. Screen ke top right corner par aapko ek button nazar aayega jis par **"Pub get"** likha hoga. Uss par click karein.
4. (Ya phir terminal mein neeche `flutter pub get` type kar ke enter press karein).
5. Is se project ki saari zaroori files internet se download ho jayengi.

## Step 5: Device Select Karein (Web ya Mobile)
Kyunki hamara project Cross-Platform hai, aap isko Web aur Mobile dono par chala sakte hain:
1. Android Studio ke sab se oopar (top bar) mein ek dropdown menu hoga jahan "No Device Selected" ya aapke PC ka naam likha hoga.
2. Uss par click karein.
3. **Web ke liye:** List mein se **"Chrome (web)"** ya "Edge (web)" select karein (Admin panel dekhne ke liye ye best hai).
4. **Mobile ke liye:** Agar aapne Emulator banaya hua hai toh usay select karein, ya apna physical Android phone data cable se connect karein aur usay select karein.

## Step 6: Project Run Karein! 🚀
1. Oopar top bar mein ek **Green Play Button (Run)** ▶️ hoga. Uss par click karein.
2. Pehli dafa run hone mein thora time (2-5 minutes) lag sakta hai. Wait karein.
3. Jaise hi process complete hoga, aapke saamne **IVMS Role Selection Screen** open ho jayegi!

---
**Tip:** Agar koi error aaye "SDK not configured" ka, toh top bar mein "File > Project Structure" mein ja kar Flutter aur Dart ka SDK path sahi se set kar dein.

Best of luck with the testing! 👍
