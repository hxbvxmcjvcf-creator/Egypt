# EduPlatform — Flutter Firebase Auth

**Package:** `com.example.edu_auth_31` · **Bundle:** `com.example.eduAuth31`  
**Firebase Project:** `maxstall` · **Architecture:** Clean Architecture + Riverpod + GetIt

---

## 🗂️ هيكل الملفات المهمة

```
edu_auth_firebase_final/
├── android/
│   ├── app/
│   │   ├── google-services.json          ← ⚠️ ملف Firebase Android (موجود)
│   │   ├── build.gradle                  ← applicationId + multidex + google-services
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/example/edu_auth_31/MainActivity.kt
│   │       └── res/values/styles.xml
│   ├── build.gradle                      ← kotlin_version + google-services plugin
│   └── gradle.properties
├── ios/
│   └── Runner/
│       ├── GoogleService-Info.plist      ← ⚠️ ملف Firebase iOS (موجود)
│       ├── Info.plist                    ← Bundle ID + URL schemes
│       └── AppDelegate.swift             ← FirebaseApp.configure()
├── lib/
│   ├── main.dart                         ← Firebase.initializeApp() هنا
│   ├── firebase_options.dart             ← القيم من كلا ملفَي Firebase
│   ├── services/
│   │   ├── firebase/firebase_auth_service.dart   ← التطبيق الحقيقي
│   │   ├── mock/mock_auth_service.dart            ← للتطوير
│   │   └── interfaces/i_auth_service.dart
│   └── core/di/injection_container.dart  ← اختر Firebase أو Mock هنا
└── .idx/dev.nix                          ← إعداد بيئة IDX
```

---

## 🚀 خطوات التشغيل في Google IDX

### 1. افتح المشروع في IDX
```
File → Open Workspace → اختر مجلد المشروع
```
IDX سيقرأ `.idx/dev.nix` تلقائياً ويثبّت كل الأدوات.

### 2. تثبيت الحزم
```bash
flutter pub get
```

### 3. تشغيل مع Firebase (الإنتاج)
```bash
flutter run --dart-define=USE_MOCK=false
```

### 4. تشغيل مع Mock (التطوير — بدون Firebase)
```bash
flutter run --dart-define=USE_MOCK=true
```

### 5. Web Preview في IDX
IDX يشغّل Web Preview تلقائياً. أو يدوياً:
```bash
flutter run -d web-server --web-port 3000 --dart-define=USE_MOCK=false
```

---

## ⚙️ Android — نقاط مهمة

| الإعداد | القيمة |
|---|---|
| `applicationId` | `com.example.edu_auth_31` |
| `minSdkVersion` | `21` |
| `targetSdkVersion` | `34` |
| `compileSdkVersion` | `34` |
| `multiDexEnabled` | `true` ✅ |
| `kotlin_version` | `1.9.10` |
| Google Services Plugin | `4.4.2` |

---

## 🍎 iOS — خطوات إضافية في Xcode (إذا بنيت على Mac)

1. افتح `ios/Runner.xcworkspace` في Xcode (ليس `.xcodeproj`)
2. تأكد أن `GoogleService-Info.plist` ظاهر في Runner group
3. في **Signing & Capabilities** → Bundle Identifier: `com.example.eduAuth31`
4. شغّل `pod install` في مجلد `ios/`

---

## 🔄 التبديل بين Firebase والـ Mock

في `lib/core/di/injection_container.dart`:
```dart
// Firebase (production)
flutter run --dart-define=USE_MOCK=false

// Mock (development — no network)
flutter run --dart-define=USE_MOCK=true
```

---

## 🏗️ Clean Architecture — طبقات المشروع

```
Presentation  →  Controllers (Riverpod)  →  Screens
                      ↓
Domain        →  Use Cases  →  Repository Interface
                      ↓
Data          →  Repository Impl  →  DataSource  →  IAuthService
                                                         ↓
Services      →  FirebaseAuthService  OR  MockAuthService
```
