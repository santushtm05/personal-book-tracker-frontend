# Book List Screen Design

## Layout / Visual Structure

```text
+----------------------------------------------------------+
|  [Status Bar]                                            |
|----------------------------------------------------------|
|  [<=]  Book Library                [Icon: Logout]        |
|----------------------------------------------------------|
|                                                          |
|  [ Search books by title or author...             (X) ]  |
|  (TextField in AppBar or below it)                       |
|                                                          |
|----------------------------------------------------------|
|  (List View)                                             |
|                                                          |
|  +----------------------------------------------------+  |
|  | [ THUMBNAIL ]  **Harry Potter**                    |  |
|  | [  IMAGE    ]  by JK Rowling                       |  |
|  |             |  Rating: 4.9 ⭐ | Pages: 530         |  |
|  |             |  Status: CREATED                     |  |
|  +----------------------------------------------------+  |
|                                                          |
|  +----------------------------------------------------+  |
|  | [ THUMBNAIL ]  **Clean Code**                      |  |
|  | [  IMAGE    ]  by Robert C. Martin                 |  |
|  |             |  Rating: 4.8 ⭐ | Pages: 464         |  |
|  |             |  Status: READING                     |  |
|  +----------------------------------------------------+  |
|                                                          |
|          ( ... Loading Indicator at bottom ... )         |
|                                                          |
|----------------------------------------------------------|
|                                           [  Ag. FAB  ]  |
|                                           [    (+)    ]  |
+----------------------------------------------------------+
```

## Logic & Behavior

### 1. Data Loading (Provider)
- **On Init**: Call `BookProvider.fetchBooks(page=0)`.
- **Pagination**:
  - ScrollController listener.
  - When reaching bottom (70%), call `BookProvider.loadMore()`.
  - Show small spinner at bottom if `isLoadingMore`.

### 2. Search
- **Input**: TextField.
- **Debounce**: 500ms debounce to avoid API spam.
- **Action**: Call `BookProvider.searchBooks(query)`.
- **Clear**: 'X' button clears query and re-fetches default list.

### 3. Navigation
- **Tap Book Item**: Navigate to `BookDetailScreen(bookId)`.
- **Tap FAB (+)**: Navigate to `AddEditBookScreen()`.
- **Tap Logout**: Call `AuthProvider.logout()`, navigate to `LoginScreen` (Replacement).

### 4. Components
- `BookListItemWidget`: Card displaying Thumbnail, Title, Author, Rating, Status.
- `SearchBarWidget`: Separate widget or inside AppBar.
