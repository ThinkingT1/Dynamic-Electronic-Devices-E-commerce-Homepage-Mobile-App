Dynamic Electronic Devices E-commerce App 📱

A dynamic e-commerce homepage for a mobile app, developed using Flutter and connected to a Cloud Firestore backend. This project showcases features like image sliders, filterable product sections by brand, and a favorites management system.

✨ Features

Dynamic Homepage: Real-time data fetching from Cloud Firestore.

Interactive UI: Image sliders and brand category filters.

State Management: Efficient management of product states and user favorites.

Responsive Design: Optimized for mobile devices.

🛠 Prerequisites

Before you begin, ensure you have the following installed:

Flutter SDK

Android Studio (recommended) or VS Code.

Git

🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

1. Download the Project

You can download the source code via Git or directly as a ZIP file.

Option A: Clone via Git (Recommended)
Open your terminal or command prompt and run:

git clone [https://github.com/ThinkingT1/Dynamic-Electronic-Devices-E-commerce-Homepage-Mobile-App.git](https://github.com/ThinkingT1/Dynamic-Electronic-Devices-E-commerce-Homepage-Mobile-App.git)



Option B: Download ZIP

Click on the green Code button at the top of this repository.

Select Download ZIP.

Extract the file to your desired folder.

2. Open in Android Studio

Launch Android Studio.

Select File > Open.

Navigate to the folder where you cloned/extracted the project and click OK.

Wait for Android Studio to index the project.

3. Install Dependencies

Open the terminal within Android Studio (usually at the bottom) or your system terminal, navigate to the project root, and run:

flutter pub get



4. Firebase Configuration ⚠️ (Crucial Step)

This project relies on Firebase Cloud Firestore. For security reasons, the google-services.json file is not included in this repository. You must add your own to run the app.

Go to the Firebase Console.

Create a new project.

Add an Android App to your Firebase project.

Package Name: You can find this in android/app/build.gradle (usually com.example.ecmobile or similar).

Download the google-services.json file provided by Firebase.

Move this file into the android/app/ directory of this project.

Enable Cloud Firestore: In the Firebase Console, go to Build > Firestore Database and click Create Database. Start in Test Mode for easy setup.

5. Database Setup (Schema) 🗄️

For the app to display data, you must populate your Firestore Database with a collection named products.

In your Firestore Database, create a collection named: products

Add documents with the following fields (check lib/models/product_model.dart for exact field names):


6. Running the App

Start an Emulator: In Android Studio, go to Device Manager and launch a Virtual Device (AVD), or connect a physical Android device via USB.

Run: Click the green Play (Run) icon in the top toolbar, or run this command in the terminal:

flutter run



📂 Project Structure

lib/
├── models/         # Data models (Product, etc.)
├── screens/        # UI Screens (Homepage, Details, etc.)
├── widgets/        # Reusable custom widgets
├── services/       # Firebase service logic
└── main.dart       # Entry point of the application
assets/             # Images and icons



🤝 Contributing

Contributions are welcome! If you have suggestions for improvements or bug fixes:

Fork the repository.

Create a new branch (git checkout -b feature/YourFeature).

Commit your changes.

Push to the branch and open a Pull Request.

📄 License

This project is open-source and available for use and modification.
