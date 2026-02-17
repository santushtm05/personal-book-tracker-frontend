# Update User Details Screen Design

## Layout (ASCII)

```
+---------------------------------------+
| [<-] Update Profile                   |
+---------------------------------------+
|                                       |
|  ( Profile Icon )                     |
|                                       |
|  Full Name                            |
|  [ Jill Doe                      ]    |
|                                       |
|  Username                             |
|  [ jill                          ]    |
|  (v) Username available                |
|                                       |
|  New Password (optional)              |
|  [ ************                  ]    |
|                                       |
|  Confirm New Password                 |
|  [ ************                  ]    |
|                                       |
|  +---------------------------------+  |
|  |       UPDATE PROFILE            |  |
|  +---------------------------------+  |
|                                       |
|  [ Logout ]                           |
|                                       |
+---------------------------------------+
```

## Logic & Behavior

1. **Initialization**:
   - Fetch current user details via `GET /api/auth/get-authenticated-user-details`.
   - Pre-fill Full Name and Username fields.

2. **Validation**:
   - Full Name: Required.
   - Username: Required, checked for availability via `GET /api/auth/username-available?username=...` if changed.
   - Password: Optional. If provided, must match Confirm Password and satisfy length requirements (if any).

3. **API Integration**:
   - Call `PATCH /api/users/update/:id` on Save.
   - Update local `AuthProvider` state with new user info.
   - Show success/failure feedback via SnackBar.

## Components

- `CustomTextField` for inputs.
- `PrimaryButton` for submission.
- Circular progress indicators during loading.
- Error/Success messages.
