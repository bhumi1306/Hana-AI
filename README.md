# 🤖 Hana AI – AI Chatbot App

Hana AI is a cross-platform **AI chatbot application** built with **Flutter**.  
It integrates **Google’s Gemini 1.5 Flash model**, **Firebase Google Authentication**,  
and a **MySQL backend** for chat history and user data.  

With smooth **Flutter animations** and a modern UI, Hana AI delivers a fast, interactive, and secure chat experience.  

---

## ✨ Features

- 🔐 **Firebase Google Auth** – Secure sign-in with Google accounts  
- 🧠 **Gemini 1.5 Flash** – Fast, high-quality AI chatbot responses  
- 💾 **MySQL Database** – Persistent storage of chat history & user data  
- 💬 **Chat History** – View past conversations anytime  
- 🎨 **Flutter Animations** – Smooth, modern, and interactive UI/UX  
- 📱 **Cross-platform** – Works on Android, iOS, macOS, Windows, and Linux  

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)  
- **Backend**: Node.js + Express (API)  
- **Database**: MySQL  
- **Auth**: Firebase Google Authentication  
- **AI Model**: Google Gemini 1.5 Flash (via API)  

---

## ## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK (latest stable)  
- Node.js & npm  
- MySQL server  
- Firebase project (for Google Auth)  
- Gemini API key  

### 2. Clone the Repo
    git clone https://github.com/bhumi1306/Hana-AI.git
    cd Hana-AI
### 3. Install Dependencies:
    flutter pub get
### 4. Backend Setup

Configure your MySQL database
Set up Node.js API with .env:
   
    DB_HOST=localhost
    DB_USER=root
    DB_PASS=yourpassword
    DB_NAME=hana_ai
    GEMINI_API_KEY=your_api_key
    
  ### 5. Start server:
   
    npm install
    npm run start

### 6. Firebase Setup

Create a Firebase project
Enable Google Sign-In in Firebase Auth
Download google-services.json (Android) and GoogleService-Info.plist (iOS)
Place them in the respective android/ and ios/ folders

### 7. Run the App:
   
    flutter run


