# SynapseAI iOS

A sophisticated social media iOS application powered by AI, featuring advanced face detection, smile recognition, and AI-powered content generation capabilities.

## 🚀 Features

### 🎯 Core Features
- **Social Media Platform**: Share posts, images, and videos with your network
- **Real-time Chat**: WebSocket-based messaging system with live communication
- **AI-Powered Content**: Generate images and videos using AI prompts
- **Advanced Authentication**: Google Sign-In and Apple Sign-In integration
- **Profile Management**: Customizable profiles with circular image cropping

### 🧠 AI & Computer Vision
- **Face Detection**: MediaPipe-powered face landmark detection
- **Smile Recognition**: Real-time smile detection with advanced algorithms
- **Smile Unlock**: Unlock features by smiling at the camera
- **Image Processing**: Apply filters and effects to images
- **AI Content Generation**: Create images and videos from text prompts

### 📱 User Experience
- **Modern UI**: SwiftUI-based interface with smooth animations
- **Media Editor**: Comprehensive image and video editing tools
- **Story Features**: Share temporary stories with your followers
- **Explore Feed**: Discover new content and users
- **Background Animations**: Lottie animations for enhanced UX

## 🛠 Technical Stack

### Languages & Frameworks
- **Swift**: Primary programming language
- **SwiftUI**: Modern UI framework
- **MediaPipe**: Google's ML framework for face detection
- **AVFoundation**: Camera and media processing
- **WebSocket**: Real-time communication via SwiftStomp

### Dependencies (CocoaPods)
- `MediaPipeTasksCommon` & `MediaPipeTasksVision` - Face detection and landmarks
- `GoogleSignIn` & `GoogleSignInSwift` - Google authentication
- `lottie-ios` - Animations
- `SwiftStomp` - WebSocket communication
- `Kingfisher` - Image loading and caching

### Architecture
- **MVVM Pattern**: Model-View-ViewModel architecture
- **Service Layer**: Dedicated services for API calls and business logic
- **Keychain Integration**: Secure storage for user credentials
- **Environment Configuration**: Support for Debug and Release configurations

## 📋 Requirements

- iOS 18.0+
- Xcode 15.0+
- Swift 5.5+
- CocoaPods

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/BerkantGC/SynapseAI-IOS.git
   cd SynapseAI-IOS
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Open the workspace**
   ```bash
   open "Synapse AI.xcworkspace"
   ```

4. **Configure environment variables**
   - Add your `GOOGLE_CLIENT_ID` to the project configuration
   - Set your `BASE_URL`, `SOCKET_URL` for backend API communication

5. **Add required assets**
   - Ensure `face_landmarker.task` model file is in the project
   - Add `unlock_animation.json` Lottie animation file

## ⚙️ Configuration

### Environment Variables
The app uses environment variables for configuration:
- `GOOGLE_CLIENT_ID`: Google Sign-In client ID
- `BASE_URL`: Backend API base URL
- `SOCKET_URL`: SOCKET base 

### Permissions
Add these permissions to your `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for face detection and smile recognition</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos to your library</string>
```

## 🏗 Project Structure

```
Synapse AI/
├── Components/           # Reusable UI components
│   ├── SmileDetection/   # Face detection and smile recognition
│   ├── MediaEditor/      # Image and video editing tools
│   ├── Post/            # Social media post components
│   └── ...
├── View/                # Main app views
│   ├── Auth/            # Authentication screens
│   ├── Home/            # Home feed
│   ├── Profile/         # User profiles
│   ├── Chat/            # Messaging interface
│   └── ...
├── ViewModel/           # View models (MVVM)
├── Service/             # API and business logic services
├── Model/               # Data models
├── Helpers/             # Utility functions
└── Assets.xcassets/     # App assets and resources
```

## 🎭 Key Components

### Smile Detection System
- **CameraManager**: Handles camera setup and face detection
- **SmileUnlockCameraView**: UI for smile-based unlocking
- **Advanced Algorithm**: Analyzes facial landmarks for realistic smile detection
- **Stability Features**: Prevents false positives with consecutive frame analysis

### AI Content Generation
- **ImageGeneratorView**: Generate images from text prompts
- **Video Generation**: Create videos using AI
- **Media Editor**: Edit and enhance generated content

### Social Features
- **Real-time Chat**: WebSocket-based messaging
- **Post Sharing**: Share images, videos, and stories
- **User Discovery**: Explore and follow other users

## 📱 Usage

### Authentication
1. Launch the app
2. Choose Google Sign-In or Apple Sign-In
3. Grant necessary permissions

### Face Detection
1. Navigate to smile unlock feature
2. Position face in camera view
3. Smile naturally to unlock content

### AI Content Generation
1. Go to Media Editor
2. Enter a text prompt
3. Generate image or video
4. Edit and share your creation

### Social Interaction
1. Browse the home feed
2. Like, comment, and share posts
3. Start conversations in chat
4. Follow interesting users

### Debugging
- Enable debug mode in `Debug.xcconfig`
- Use Xcode's built-in debugging tools
- Check console logs for detailed error messages

## 📄 License

SYNAPSE-AI is Yaşar University Computer Engineering Gradutation Project.

## 👥 Contributors

- **Berkant Gürcan** - Full-stack Developer
- **Bedirhan Kırtan** - Generative AI Developer
- **Uğur Günal** - Recommender AI Developer

---
## Application Screenshots

![WhatsApp Image 2025-06-18 at 02 22 01-portrait](https://github.com/user-attachments/assets/28520f02-fc62-4b13-bde0-06efc337fc78)
![Simulator Screenshot - iPhone 16 Pro Max - 2025-06-11 at 20 57 32-portrait](https://github.com/user-attachments/assets/d7a4df18-6715-4123-9002-8ba3a082f1d4)
![Simulator Screenshot - iPhone 16 Pro Max - 2025-06-11 at 21 00 26-portrait](https://github.com/user-attachments/assets/fa12871b-8636-4cdb-b0c8-24aa47f5b288)


**Note**: This project requires a backend API server for full functionality. Make sure to set up the corresponding backend service and configure the `BASE_URL` accordingly.
