# intelli_chat

Intelli-Chat is a real-time messaging application built using Flutter and Firebase. The app offers a seamless communication experience with features like read status, last seen, and smart reply generation using on-device machine learning.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Set up android studio for flutter environment](https://www.youtube.com/watch?v=hfz_AraTk_k&feature=youtu.be&ab_channel=GeeksforGeeks)
- [Integrate Firebase in the app](https://www.youtube.com/watch?v=sz4slPFwEvs)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# intelli_chat (Android App)

## Setting up the project in your local environment💻

1. Clone this repository.
2. After Cloning, open the project in android studio
3. Create a new project on [Firebase Console](https://console.firebase.google.com/)
4. Activate Email SignIn in Firebase auth, and activate Firebase Firestore and Firebase Storage in **test mode**.
5. Integrate firebase using the tutorial mentioned above to use your own database (Necessary step else the app wont work)
6. Run `flutter pub get` to get the dependencies.
7. Finally, run the app:

```
flutter run
```
7. To build the apk of the app, you can use the following command
```
flutter build apk --release
```
You can find the apk in build/app/outputs/flutter-apk folder
You can refer the following video for more [details](https://youtu.be/TOgfbyw6-Mw)

## Features

- **Real-Time Messaging:** Send and receive messages instantly with Firebase Firestore.
- **Google Sign-In:** Sign in using Google accounts without the need for mobile numbers.
- **Adding Users:** Add other users to your contact list using their email addresses.
- **User Profiles:** Simple profiles with photo, about, last-seen status, and account creation date.
- **Message Read Status:** See if your messages have been read by the recipient.
- **Message Delete & Edit:** Delete and edit sent messages.
- **Smart Reply Generation:** Generate intelligent replies based on received messages using on-device ML.

## Tech Stack

- **Flutter:** For building the user interface.
- **Firebase:** For real-time messaging, authentication, and data storage.
- **Firestore:** For storing chat messages and user data.
- **MLKit (TensorFlow Lite):** For generating smart replies using on-device machine learning.
