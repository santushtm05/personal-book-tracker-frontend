# Book Detail Screen Design

## Layout / Visual Structure

```text
+----------------------------------------------------------+
|  [<=]  Book Details                                      |
|----------------------------------------------------------|
|                                                          |
|      [        LARGE THUMBNAIL IMAGE        ]             |
|      [           (Placeholder)             ]             |
|                                                          |
|   Harry Potter and the Goblet of Fire                    |
|   (Headline Style)                                       |
|                                                          |
|   by JK Rowling                                          |
|   (Subtitle Style)                                       |
|                                                          |
|   Rating: 4.9 ⭐    |    Pages: 530                      |
|                                                          |
|   Status: [ CREATED ] (Chip/Badge)                       |
|                                                          |
|   Tags:                                                  |
|   [ Horror ] [ Thriller ] [ Sci-Fi ]                     |
|                                                          |
|----------------------------------------------------------|
|                                                          |
|            [ Edit Book ]    [ Delete Book ]              |
|            (OutlinedBtn)    (Red TextBtn)                |
|                                                          |
+----------------------------------------------------------+
```

## Logic & Behavior

### 1. Data Loading
- **Input**: `bookId` passed via constructor or arguments.
- **Provider**: Call `BookProvider.books.firstWhere((b) => b.id == bookId)`.
  - *Optional*: Fetch fresh details via API `BookService.getBook(id)`.

### 2. Actions
- **Edit Book**: Navigate to `AddEditBookScreen(book: currentBook)`.
- **Delete Book**:
  - Show Confirmation Dialog ("Are you sure?").
  - On Confirm: Call `BookProvider.deleteBook(id)`.
  - On Success: Pop back to `BookListScreen`, Show SnackBar.

## Components
- `DetailItemWidget`: For consistent display of label/value.
- `ActionButtons`: Row with Edit/Delete.
