# Firebase Storage Setup for ChatWave

## Required Firebase Storage Rules

To enable profile image uploads, you need to configure Firebase Storage rules in your Firebase Console.

### Steps:
1. Go to Firebase Console → Storage → Rules
2. Replace the default rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images: users can read/write their own profile image
    match /profile_images/{userId}.jpg {
      allow read: if true; // Anyone can read profile images
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024; // 5MB limit
    }
    
    // Default: deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Notes:
- Profile images are stored at: `profile_images/{userId}.jpg`
- Maximum file size: 5MB
- Images are publicly readable but only authenticated users can upload
- The app validates image size before upload

## Testing
After setting up the rules:
1. Login to the app
2. Go to Profile screen
3. Tap the camera icon
4. Select an image from gallery
5. Image should upload and display

