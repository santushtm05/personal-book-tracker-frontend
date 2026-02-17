# Register Screen Design

## Layout / Visual Structure
Similar to Login, centered form.

```text
+----------------------------------------------------------+
|  [Status Bar]                                            |
|----------------------------------------------------------|
|                                                          |
|                      (Icon/Logo)                         |
|                  Create an Account                       |
|             (Text: HeadlineStyle)                        |
|                                                          |
|  +----------------------------------------------------+  |
|  | [Icon: Badge]  Full Name                           |  |
|  +----------------------------------------------------+  |
|   (Required)                                             |
|                                                          |
|  +----------------------------------------------------+  |
|  | [Icon: Person] Username                            |  |
|  +----------------------------------------------------+  |
|   (Async Validation: Check availability?)                |
|   (Required)                                             |
|                                                          |
|  +----------------------------------------------------+  |
|  | [Icon: Lock]   Password                [Icon: Eye] |  |
|  +----------------------------------------------------+  |
|   (Min 8 chars, maybe match Confirm Password?)           |
|                                                          |
|  +----------------------------------------------------+  |
|  | [Icon: Lock]   Confirm Password        [Icon: Eye] |  |
|  +----------------------------------------------------+  |
|   (Must match Password)                                  |
|                                                          |
|           [      REGISTER BUTTON     ]                   |
|           (Full Width, Primary Color)                    |
|                                                          |
|                                                          |
|       Already have an account? [ Login ]                 |
|       (Text with TextButton)                             |
|                                                          |
|----------------------------------------------------------|
```

## Logic & Behavior

### 1. Form Validation
- **Full Name**: Required.
- **Username**: Required.
- **Password**: Min 8 chars.
- **Confirm Password**: Must match Password.

### 2. State Management (Provider)
- Call `AuthProvider.register(username, password, fullName)`.
- Show `CircularProgressIndicator` on button while loading.

### 3. Navigation
- **On Success**:
  - Show SnackBar "Registration Successful! Please Login".
  - Navigate back to `LoginScreen` (Pop).
- **On Login Click**: Pop (return to Login).

## Components
- Reuse `CustomTextField`.
- Reuse `PrimaryButton`.
