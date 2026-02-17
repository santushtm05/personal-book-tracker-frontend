#  Personal Book Tracker - Frontend

A professional, production-grade Flutter application built for the **Internship Assessment**. This application provides a secure and intuitive interface for managing a personal book library, featuring robust authentication, CRUD operations, and optimized data fetching.

---

## Project Overview

The **Secure Book Library** is designed to provide users with a safe environment to track their reading progress. The app enforces strict JWT-based authentication to protect user data and offers a seamless experience across multiple screens.

### Mandatory Features:
*   **Secure Authentication**: JWT-based login and registration.
*   **Book Management**: Full CRUD (Create, Read, Update, Delete) for books.
*   **Rich Details**: Deep-dive view for every book, including tags and thumbnails.
*   **Interactive UI**: Smooth transitions and beginner-friendly forms with real-time validation.

---

## Technology Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI)
*   **State Management**: [Provider](https://pub.dev/packages/provider) (Separation of concerns)
*   **Networking**: [http](https://pub.dev/packages/http) (REST API integration)
*   **Persistence**: [SharedPreferences](https://pub.dev/packages/shared_preferences) (JWT Token storage)
*   **Design**: Material 3 with Custom Reusable Widgets.

---

## Folder Structure

The project follows a modular architecture to ensure scalability and maintainability:

```text
lib/
├── models/         # Data blueprints (User, Book, Tag, AuthResponse)
├── providers/      # Application state management (Logic layer)
├── services/       # Raw API communication (Static URLs & Headers)
├── screens/        # UI Layer (Separated by modules)
│   ├── auth/       # Login & Register
│   ├── books/      # Book List, Details, Add/Edit
│   └── profile/    # User Profile management
├── widgets/        # Reusable UI components (CustomTextField, PrimaryButton)
├── utils/          # Global constants and utilities
└── main.dart       # App entry point & Route configuration
```

---

## API Integration Notes

The app integrates with a Spring Boot backend. All secured requests use a **JWT (JSON Web Token)** passed via the `Authorization` header.

### Authentication & Headers
*   **Token Storage**: JWT is stored securely using `SharedPreferences`.
*   **Header Format**: `Authorization: Bearer <JWT_TOKEN>`
*   **Content-Type**: `application/json`

### Endpoint Mapping
| Feature | Screen | Method | Endpoint |
| :--- | :--- | :--- | :--- |
| **Login** | Login | POST | `/api/auth/login` |
| **Register** | Register | POST | `/api/auth/register` |
| **List Books** | Book List | GET | `/api/books/?page=0&size=10` |
| **Search** | Book List | GET | `/api/books/search/?query={query}` |
| **Add Book** | Add/Edit | POST | `/api/books/create` |
| **Update Book** | Add/Edit | PATCH | `/api/books/update/{id}` |
| **Delete Book** | Details | DELETE | `/api/books/delete/{id}` |
| **User Info** | Profile | GET | `/api/auth/get-authenticated-user-details` |

---

## Screen Flow & Logic

1.  **Login/Register**: Initial entry point. Forms include regex-based email/username validation.
2.  **Book List (Home)**: Displays a paginated list of books. Features a real-time **debounced search** bar.
3.  **Book Detail**: Shows comprehensive info. Options to Edit or Delete are present here.
4.  **Add/Edit Book**: Unified form for adding or updating book metadata including multiple **Tags**.
5.  **Logout**: Accessible from the main dashboard and profile page, safely clears the token and redirects to authentication.

### ** Bonus Features Implemented**
*   **Pagination**: Infinite scroll support for the book list.
*   **Real-time Search**: Debounced search requests to minimize API calls.
*   **Tag Management**: Dynamic creation and selection of custom tags.
*   **Profile Management**: Dedicated screen to update user details.

---

## App Setup Guide

### Prerequisites
*   Flutter SDK (v3.0.0+)
*   Dart SDK (v3.0.0+)
*   Android Studio / VS Code with Flutter Extension
*   Running Backend API

### Installation
1.  **Clone the Repository**:
    ```bash
    git clone <repository_url>
    cd fluter-frontend
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure API URL**:
    Open `lib/utils/constants.dart` and update the `apiBaseUrl` to match your backend IP (e.g., `10.0.2.2` for Android Emulator).
    ```dart
    static const String apiBaseUrl = 'http://localhost:8080/api';
    ```
4.  **Run the Application**:
    ```bash
    flutter run
    ```
