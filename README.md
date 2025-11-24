# Novatalk 🤖💬

**Novatalk** is a modern, AI-powered chat application built with Flutter. It leverages Google's Gemini AI to provide intelligent conversational capabilities, coupled with a robust authentication system using Firebase and local storage management via Hive.

## 🚀 Features

### 🤖 AI Chat Integration
* **Powered by Google Gemini**: Seamless integration with the Gemini API for generative AI responses.
* **Real-time Streaming**: Chat responses are streamed in real-time for a natural conversational experience.
* **Code Detection**: Built-in logic to detect and handle code snippets within chat responses.
* **Chat History**: Automatically saves chat sessions locally using Hive, allowing users to revisit previous conversations.
* **Multi-Session Support**: Create new chat sessions and switch between them easily.

### 🔐 Authentication & User Management
* **Email & Password**: Secure Sign-Up and Sign-In functionality using Firebase Authentication.
* **Google Sign-In**: Integrated social login with Google.
* **User Persistence**: User credentials and profile details are stored in Cloud Firestore and locally for quick access.
* **Secure Storage**: Uses Hive boxes to store sensitive session data.

### 📱 User Interface
* **Modern Design**: Clean, gradient-based UI with custom text fields and buttons.
* **Dash Chat UI**: Utilizes the `dash_chat_2` package for a polished, feature-rich chat interface.
* **Navigation**: Easy navigation between the Chat interface and Profile settings via a bottom navigation bar.

## 🛠️ Tech Stack

* **Framework**: [Flutter](https://flutter.dev/) (Dart)
* **AI Model**: [Google Gemini](https://ai.google.dev/) (`flutter_gemini`, `google_generative_ai`)
* **Backend (BaaS)**: [Firebase](https://firebase.google.com/)
    * Firebase Authentication
    * Cloud Firestore
    * Firebase Core
* **Local Database**: [Hive](https://pub.dev/packages/hive) (NoSQL database)
* **UI Components**:
    * `dash_chat_2`: Chat UI
    * `salomon_bottom_bar`: Navigation styling
    * `google_fonts`: Typography

## 📂 Project Structure
lib/ ├── Models/ # Data models (if any) ├── Screens/ │ ├── SignInScreen.dart # Login UI and Logic │ ├── SignUpScreen.dart # Registration UI and Logic │ └── bottom_bar.dart # Main Navigation Controller ├── Widgets/ │ ├── chat_widget.dart # Core Gemini Chat implementation │ ├── chat_history.dart # List of saved chat sessions │ └── chat_profile.dart # User profile display ├── Services/ # API and Service logic ├── consts.dart # API Keys and Constants ├── firebase_options.dart# Firebase Configuration └── main.dart # App Entry point & Initialization


## ⚙️ Installation & Setup

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/rabnawaz73/novatalk.git](https://github.com/rabnawaz73/novatalk.git)
    cd novatalk
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    * Ensure you have a Firebase project set up.
    * Replace `firebase_options.dart` with your specific project configuration (generated via `flutterfire configure`).
    * Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are placed in their respective directories.

4.  **Gemini API Key**
    * Obtain an API key from [Google AI Studio](https://aistudio.google.com/).
    * Add your key to `lib/consts.dart`:
        ```dart
        const String Gemini_KEY = 'YOUR_API_KEY_HERE';
        ```

5.  **Run the App**
    ```bash
    flutter run
    ```

## 🔄 Status & Roadmap

* ✅ Email/Password Authentication
* ✅ Google Sign-In
* ✅ Gemini AI Chat Streaming
* ✅ Local Chat History (Hive)
* 🚧 Facebook Authentication (Under Development)
* 🚧 Forgot Password Functionality (UI implemented)
