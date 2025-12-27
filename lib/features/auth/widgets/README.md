# Auth Widgets - Reusable Components

This document describes the reusable widgets created for the authentication features.

## Created Widgets

### 1. **AuthTextField** (`auth_text_field.dart`)
A themed text input field with consistent styling across login and signup screens.

**Features:**
- Theme-aware (dark/light mode support)
- Built-in label and hint text
- Icon support
- Password visibility toggle support
- Form validation support
- Responsive sizing

**Usage:**
```dart
AuthTextField(
  controller: _emailController,
  label: 'Email',
  hint: 'Enter your email',
  icon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)
```

### 2. **AuthButton** (`auth_button.dart`)
A primary action button with loading state support.

**Features:**
- Loading indicator
- Consistent styling
- Responsive sizing
- Disabled state when loading

**Usage:**
```dart
AuthButton(
  text: 'Login',
  onPressed: _handleLogin,
  isLoading: _isLoading,
)
```

### 3. **SocialLoginButton** (`social_login_button.dart`)
A button for social login options (Google, Facebook, etc.).

**Features:**
- Theme-aware borders and backgrounds
- Icon + text layout
- Consistent styling
- Responsive sizing

**Usage:**
```dart
SocialLoginButton(
  text: 'Continue with Google',
  iconPath: 'assets/icons/google.png',
  onPressed: _handleGoogleLogin,
)
```

### 4. **AuthDivider** (`auth_divider.dart`)
A divider with text in the middle (e.g., "Or continue with").

**Features:**
- Theme-aware divider color
- Customizable text
- Consistent spacing

**Usage:**
```dart
AuthDivider(text: 'Or continue with')
```

### 5. **AuthHeader** (`auth_header.dart`)
A header section with title and subtitle.

**Features:**
- Theme-aware text colors
- Responsive font sizes
- Consistent spacing

**Usage:**
```dart
AuthHeader(
  title: 'Welcome Back!',
  subtitle: 'Sign in to continue shopping',
)
```

### 6. **AuthTextLink** (`auth_text_link.dart`)
A text link for navigation between auth screens.

**Features:**
- Two-part text (normal + link)
- Tap handling
- Consistent styling

**Usage:**
```dart
AuthTextLink(
  text: "Don't have an account?",
  linkText: 'Sign Up',
  onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
)
```

## Benefits

### Code Reusability
- ✅ Shared components between login and signup screens
- ✅ Consistent UI/UX across all auth screens
- ✅ Easier maintenance and updates

### Theme Support
- ✅ All widgets support dark and light modes
- ✅ Automatic color adaptation
- ✅ Consistent theming

### Responsive Design
- ✅ All widgets adapt to different screen sizes
- ✅ Uses ResponsiveHelper for sizing
- ✅ Works on small and large devices

### Clean Code
- ✅ Separation of concerns
- ✅ Single responsibility principle
- ✅ Easy to test and modify

## How to Use in Screens

Import all widgets at once:
```dart
import '../widgets/widgets.dart';
```

Then use them in your login/signup screens to replace repetitive code.

## Example Refactoring

**Before:**
```dart
TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    // ... 20+ lines of styling code
  ),
)
```

**After:**
```dart
AuthTextField(
  controller: _emailController,
  label: 'Email',
  hint: 'Enter your email',
  icon: Icons.email_outlined,
)
```

## File Structure

```
lib/features/auth/
├── widgets/
│   ├── auth_text_field.dart
│   ├── auth_button.dart
│   ├── social_login_button.dart
│   ├── auth_divider.dart
│   ├── auth_header.dart
│   ├── auth_text_link.dart
│   └── widgets.dart (exports all)
├── screens/
│   ├── login_screen.dart
│   └── signup_screen.dart
└── cubits/
    ├── auth_cubit.dart
    └── auth_state.dart
```

## Next Steps

To refactor the existing login and signup screens:
1. Import the widgets: `import '../widgets/widgets.dart';`
2. Replace repetitive TextField code with AuthTextField
3. Replace button code with AuthButton
4. Replace social buttons with SocialLoginButton
5. Use AuthHeader for titles
6. Use AuthDivider for separators
7. Use AuthTextLink for navigation links

This will significantly reduce code duplication and improve maintainability!
