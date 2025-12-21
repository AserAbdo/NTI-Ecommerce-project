# Quick Fix Guide - Firestore Signup Error

## What Was Changed

✅ **Simplified Architecture** - Removed repository and service layers  
✅ **Direct Firestore Operations** - All operations now in `AuthCubit`  
✅ **Enhanced Error Handling** - Separate handlers for Auth and Firestore errors  
✅ **Detailed Logging** - Console logs show exactly what's happening  
✅ **Automatic Cleanup** - Deletes auth user if Firestore save fails  

## Files Modified

- `lib/features/auth/cubits/auth_cubit.dart` - Simplified with direct Firestore calls

## Files Deleted

- `lib/features/auth/repositories/` - Removed entire folder
- `lib/features/auth/services/` - Removed entire folder

---

## CRITICAL: Configure Firestore Security Rules

The error you're seeing is **99% likely** caused by Firestore security rules blocking writes.

### Step 1: Open Firebase Console

1. Go to https://console.firebase.google.com/
2. Select project: **nti-ecommerce**
3. Click **Firestore Database** in left sidebar
4. Click **Rules** tab

### Step 2: Update Rules

Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to create and read their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow anyone to read products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Step 3: Click "Publish"

---

## How to Test

### 1. Run the app:
```bash
flutter run
```

### 2. Watch the console logs:

You'll see detailed output like:
```
📝 Starting signup process for: test@example.com
🔐 Creating user in Firebase Auth...
✅ User created in Firebase Auth: abc123xyz
📄 User model created: {id: abc123xyz, name: Test, email: test@example.com, ...}
💾 Saving user to Firestore...
✅ User saved to Firestore successfully
🎉 Signup completed successfully for: test@example.com
```

### 3. If you see an error:

**Permission Denied Error:**
```
❌ Firestore error during signup: permission-denied
```
→ **Solution:** Update Firestore security rules (see above)

**Network Error:**
```
❌ Firestore error during signup: unavailable
```
→ **Solution:** Check internet connection

---

## Verify Success

### In Firebase Console:

1. Go to **Firestore Database** → **Data**
2. Look for `users` collection
3. Find document with your user's ID
4. Verify fields: `id`, `name`, `email`, `phone`, `address`

### In Your App:

1. After signup, you should be redirected to home screen
2. No error messages should appear
3. Console shows ✅ success messages

---

## Troubleshooting

### Still getting "Failed to save user" error?

1. **Check console output** - Look for the ❌ error messages
2. **Copy the error code** - It will say something like `permission-denied` or `unavailable`
3. **Update Firestore rules** - This fixes 99% of issues
4. **Check Firestore is enabled** - Go to Firebase Console → Firestore Database → Create database if needed

### Need more help?

Share the console output (the lines with emojis) to see exactly where it's failing.
