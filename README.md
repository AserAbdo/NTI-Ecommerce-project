# 🛍️ Vendora - AI E-Commerce Mobile Application

<p align="center">
  <img src="screenshots/banner.gif" alt="Vendora Banner" width="100%"/>
</p>

<p align="center">
  <strong>A Modern E-Commerce Experience Built with Flutter</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#installation">Installation</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#team">Team</a>
</p>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Configuration](#configuration)
- [Team](#team)
- [License](#license)

---

## 🎯 Overview

**Vendora** is a feature-rich, production-ready e-commerce mobile application built with Flutter. It provides a seamless shopping experience with modern UI/UX, real-time updates, offline support, and comprehensive admin capabilities.

### Key Highlights

- 🎨 **Beautiful UI** - Modern design with dark/light theme support
- ⚡ **Fast Performance** - Optimized with caching and lazy loading
- 📱 **Cross-Platform** - Works on Android and iOS
- 🔒 **Secure** - Firebase Authentication with input validation
- 📴 **Offline Support** - Browse products without internet
- 🔔 **Notifications** - Local notifications for coupons and orders
- 🤖 **AI Chatbot** - Intelligent assistant for shopping help

---

## ✨ Features

### 🛒 Shopping Experience
- Browse products by categories
- Advanced search with filters
- Product details with reviews and ratings
- Add to cart with quantity management
- Wishlist/Favorites functionality
- Apply coupon codes for discounts

### 👤 User Management
- User registration and login
- Profile management
- Multiple shipping addresses
- Payment methods management
- Order history and tracking
- Password change functionality

### 🎟️ Coupon System
- Welcome coupon for new users (50% off)
- Automatic coupon validation
- Expiration date tracking
- Single-use enforcement
- Real-time coupon count display

### 📦 Order Management
- Seamless checkout process
- Multiple payment options
- Order confirmation with confetti animation
- Real-time order status updates
- Order tracking

### 🔔 Notifications
- Welcome coupon notifications
- Order status updates
- Coupon usage celebrations

### 🌙 Theming
- Light and dark mode support
- Smooth theme transitions
- Persistent theme preference

### 👨‍💼 Admin Panel
- Dashboard with real-time statistics
- Product management (CRUD)
- Order management
- Status updates

### 🤖 AI Chatbot
- Intelligent shopping assistant
- Product recommendations
- Order inquiries
- General support

### 📴 Offline & Caching
- Offline product browsing
- Cache management for better performance
- Hive local database storage
- Network-aware functionality

### 🔐 Security
- Secure credentials storage
- Firebase Authentication
- Input validation

---

## 📱 Screenshots

### 🚀 Onboarding & Authentication

| Splash Screen | Onboarding | Login | Sign Up |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/splash.gif" alt="Splash" width="150"/> | <img src="screenshots/onboarding.gif" alt="Onboarding" width="150"/> | <img src="screenshots/login.jpg" alt="Login" width="150"/> | <img src="screenshots/create-account.jpg" alt="Sign Up" width="150"/> |

### 🏠 Home & Products

| Home | Product Details |
|:---:|:---:|
| <img src="screenshots/home.gif" alt="Home" width="150"/> | <img src="screenshots/product-details.gif" alt="Product Details" width="150"/> |

### 🛒 Shopping

| Cart | Checkout | Order Checkout |
|:---:|:---:|:---:|
| <img src="screenshots/cart.gif" alt="Cart" width="150"/> | <img src="screenshots/checkout.gif" alt="Checkout" width="150"/> | <img src="screenshots/orderchechout.gif" alt="Order Checkout" width="150"/> |

### ❤️ Favorites & Orders

| Favorites | Orders |
|:---:|:---:|
| <img src="screenshots/favourites.jpg" alt="Favorites" width="150"/> | <img src="screenshots/orders.gif" alt="Orders" width="150"/> |

### 👤 Profile & Settings

| Profile | Edit Profile | Addresses |
|:---:|:---:|:---:|
| <img src="screenshots/profile.gif" alt="Profile" width="150"/> | <img src="screenshots/edit-profile.jpg" alt="Edit Profile" width="150"/> | <img src="screenshots/addresses.jpg" alt="Addresses" width="150"/> |

| Change Password | Payment Methods | Privacy Policy |
|:---:|:---:|:---:|
| <img src="screenshots/change-password.jpg" alt="Change Password" width="150"/> | <img src="screenshots/payment-methods.jpg" alt="Payment Methods" width="150"/> | <img src="screenshots/privacy-policy.jpg" alt="Privacy Policy" width="150"/> |

| About |
|:---:|
| <img src="screenshots/about .gif" alt="About" width="150"/> |

### 📞 Support & Help

| Help Center | Contact Us | Rate App |
|:---:|:---:|:---:|
| <img src="screenshots/help-center.jpg" alt="Help Center" width="150"/> | <img src="screenshots/contact-us.jpg" alt="Contact Us" width="150"/> | <img src="screenshots/rate.jpg" alt="Rate App" width="150"/> |

### 🤖 AI Chatbot

| Chatbot 1 | Chatbot 2 |
|:---:|:---:|
| <img src="screenshots/chatbot1.jpg" alt="Chatbot 1" width="150"/> | <img src="screenshots/chatbot2.jpg" alt="Chatbot 2" width="150"/> |

---

## 🏗️ Architecture

The application follows **Feature-First Architecture** with a clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                      CORE LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │     App     │  │  Constants  │  │   Theme     │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
│  ┌─────────────┐  ┌─────────────┐                           │
│  │    Utils    │  │   Widgets   │                           │
│  └─────────────┘  └─────────────┘                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    FEATURES LAYER                            │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐            │
│  │  Auth   │ │Products │ │  Cart   │ │ Orders  │            │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘            │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐            │
│  │ Profile │ │Favorites│ │ Search  │ │ Chatbot │            │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘            │
│  Each feature contains: screens/, cubits/, widgets/, models/│
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ Repositories│  │ DataSources │  │     DI      │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICES LAYER                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  Firebase   │  │    Hive     │  │Notifications│          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### State Management

We use **BLoC/Cubit** pattern for predictable state management:

```dart
// Cubit with Equatable states
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  
  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? ServiceLocator.instance.authRepository,
        super(AuthInitial());
}
```

### Dependency Injection

Centralized dependency management via **Service Locator**:

```dart
// Access dependencies anywhere
final user = await authRepository.signIn(email, password);
final products = await productRepository.getProducts();
```

---

## 📁 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── app/                       # App configuration
│   │   ├── app_initializer.dart   # Service initialization
│   │   ├── app_router.dart        # Navigation routes
│   │   └── nti_app.dart           # Root widget
│   ├── constants/                 # App constants
│   │   ├── app_colors.dart
│   │   ├── app_routes.dart
│   │   └── app_strings.dart
│   ├── firebase/                  # Firebase configuration
│   ├── theme/                     # Theming
│   │   ├── app_theme.dart
│   │   ├── theme_cubit.dart
│   │   └── theme_state.dart
│   ├── utils/                     # Utilities
│   │   └── validators.dart
│   └── widgets/                   # Shared widgets
│
├── data/                          # Data layer
│   ├── datasources/
│   │   ├── local_data_source.dart    # Hive caching
│   │   └── remote_data_source.dart   # Firebase operations
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── product_repository.dart
│   └── di/
│       └── service_locator.dart      # Dependency injection
│
├── features/                      # Feature modules
│   ├── admin/                     # Admin panel
│   ├── auth/                      # Authentication
│   ├── cache/                     # Cache management
│   │   └── cache_manager.dart
│   ├── cart/                      # Shopping cart
│   ├── chatbot/                   # AI Chatbot
│   ├── coupons/                   # Coupon system
│   │   ├── models/
│   │   └── services/
│   ├── favorites/                 # Wishlist
│   ├── home/                      # Home screen
│   ├── main/                      # Main navigation
│   ├── notifications/             # Notifications
│   ├── onboarding/                # Onboarding
│   ├── orders/                    # Order management
│   ├── products/                  # Product catalog
│   ├── profile/                   # User profile
│   ├── reviews/                   # Product reviews
│   │   └── models/
│   └── search/                    # Search functionality
│
├── services/                      # App services
│   ├── credentials_storage_service.dart  # Secure storage
│   ├── firebase_service.dart
│   ├── hive_service.dart
│   ├── local_notification_service.dart
│   ├── network_service.dart
│   └── seed_service.dart          # Data seeding
│
├── widgets/                       # Global widgets
│
└── main.dart                      # Entry point
```

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart** | Programming language |
| **flutter_bloc** | State management |
| **Equatable** | Value equality for states |

### Backend & Database
| Technology | Purpose |
|------------|---------|
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | NoSQL database |
| **Firebase Storage** | File storage |

### Local Storage
| Technology | Purpose |
|------------|---------|
| **Hive** | Offline data caching |
| **SharedPreferences** | Settings persistence |

### UI/UX
| Technology | Purpose |
|------------|---------|
| **Google Fonts** | Typography |
| **Shimmer** | Loading animations |
| **Cached Network Image** | Image caching |
| **Confetti** | Celebration animations |

### Utilities
| Technology | Purpose |
|------------|---------|
| **connectivity_plus** | Network monitoring |
| **flutter_local_notifications** | Local notifications |
| **intl** | Date/number formatting |

---

## 🚀 Installation

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Firebase project

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/vendora.git
   cd vendora
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Create Cloud Firestore database
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## ⚙️ Configuration

### Firebase Setup

1. **Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can read/write their own data
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Products are publicly readable
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null; // Admin only in production
       }
       
       // Orders
       match /orders/{orderId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

2. **Firestore Indexes**
   - Create composite indexes for queries with multiple conditions

### Environment Variables

Create `lib/config/env.dart`:
```dart
class Env {
  static const String environment = 'development'; // or 'production'
  static const bool enableLogging = true;
}
```

---

## 👥 Team

| Role | Name | Contribution |
|------|------|--------------|
| **Team Lead & Mobile Development** | Aser | Architecture, Features, Code Review |
| **UI/UX Designer** | Bassant | User Interface, User Experience, Figma Design |
| **Backend & n8n Automation** | Zeyad | API Integration, Automation Workflows |
| **Software Testing** | Yassen | Quality Assurance, Testing, Bug Tracking |

### Tech Stack Credits
- Flutter & Dart
- Firebase (Auth, Firestore)
- Hive (Local Storage)
- Figma (UI Design)

---

## 📊 Project Statistics

| Metric | Value |
|--------|-------|
| **Total Screens** | 33+ |
| **Cubits/State Managers** | 10+ |
| **Code Lines** | 50,000+ |
| **Features** | 20+ |

---

## 🔮 Future Roadmap

- [ ] Push notifications via FCM
- [ ] Social login (Google, Apple)
- [ ] Payment gateway integration
- [ ] Product reviews with images
- [ ] Multi-language support (i18n)
- [ ] Unit & integration tests
- [ ] CI/CD pipeline

---

## 🐛 Known Issues

- `withOpacity` deprecation warnings (cosmetic, no functional impact)
- Some screens still use direct Firebase calls (being migrated to repositories)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

<p align="center">
  Made with ❤️ by the Vendora Team
</p>

<p align="center">
  <a href="#top">⬆️ Back to Top</a>
</p>
