# AgroVision - Bilingual Crop Disease Detection Android App

AgroVision is an Android application built with **Kotlin**, **Jetpack Compose**, and **Material 3**. It connects to the YOLOv8 FastAPI backend hosted on Render at `https://agrovision-flutter-app.onrender.com/` to detect crop leaf diseases, display confidence scores, and provide actionable chemical & organic remedies in **English** and **Marathi (मराठी)** with Text-to-Speech (TTS) audio narration.

---

## 📱 Features

1. **Upload File / Take Photo**:
   - Pick JPG, JPEG, PNG, WEBP images from device storage/gallery.
   - Capture live leaf photos using device camera.
2. **FastAPI YOLOv8 Backend Integration**:
   - Sends image multipart form data to `https://agrovision-flutter-app.onrender.com/predict`.
3. **Predicted Disease & Confidence Meter**:
   - Displays prediction name in both English and Marathi.
   - Visual score bar and confidence accuracy badge (High / Moderate / Low).
4. **Recommended Remedies**:
   - Detailed chemical treatments, organic remedies, and prevention tips.
   - Supports 63 crop disease classes across Corn, Cotton, Grape, Groundnut, Lemon, Potato, Soyabean, Sugarcane, Tomato, and Wheat.
5. **Bilingual Engine (English & मराठी)**:
   - Instant language toggle switch in the top bar.
   - Text-to-Speech audio button ("Read Aloud / ऐका") to listen to remedy instructions.

---

## 🛠️ How to Open and Run in Android Studio

1. Launch **Android Studio**.
2. Click **Open** (or `File -> Open`).
3. Select this folder (`Agrovision_Flutter_App`).
4. Allow Android Studio to sync Gradle automatically (`build.gradle.kts` & `app/build.gradle.kts`).
5. Select an **Android Emulator** or connect a physical Android phone via USB debugging.
6. Click **Run App** (or press `Shift + F10`).

---

## 📁 File Structure

```
Agrovision_Flutter_App/
├── build.gradle.kts                   # Root Gradle build script
├── settings.gradle.kts                # Project settings & repositories
├── gradle.properties                  # JVM & AndroidX settings
├── gradle/wrapper/                    # Gradle wrapper binaries
├── README.md                          # Project documentation
└── app/
    ├── build.gradle.kts               # App module dependencies (Compose, Retrofit, Coil)
    ├── proguard-rules.pro             # ProGuard configuration
    └── src/
        └── main/
            ├── AndroidManifest.xml    # Permissions (Camera, Internet, FileProvider)
            ├── res/                   # Drawables, colors, strings, themes, file paths
            └── java/com/agrovision/app/
                ├── MainActivity.kt                      # Main activity & state orchestration
                ├── model/
                │   └── PredictionModels.kt              # API data models & language enum
                ├── network/
                │   ├── AgroVisionApiService.kt         # Retrofit API interface
                │   └── NetworkClient.kt                # OkHttp & Retrofit instance
                ├── repository/
                │   └── RemediesRepository.kt           # 63 disease classes & remedies (EN/MR)
                ├── util/
                │   └── TextToSpeechHelper.kt           # Android Text-To-Speech engine
                └── ui/
                    ├── theme/                          # Colors, Typography, Material Theme
                    └── components/
                        ├── TopBar.kt                   # Header & language toggle switch
                        ├── ImagePickerSection.kt       # Upload file & Take Photo options
                        ├── ResultCard.kt               # Predicted disease & confidence score
                        └── RemediesCard.kt             # Recommended remedies & audio readout
```
