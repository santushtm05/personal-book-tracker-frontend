# Add/Edit Book Screen Design

## Layout / Visual Structure

```text
+----------------------------------------------------------+
|  [<=]  {Add New / Edit} Book                             |
|----------------------------------------------------------|
|  (Form)                                                  |
|                                                          |
|  Title *                                                 |
|  [ Enter book title...                             ]     |
|                                                          |
|  Author *                                                |
|  [ Enter author name...                            ]     |
|                                                          |
|  Status *                                                |
|  [ Dropdown: CREATED / READING / COMPLETED         ]     |
|                                                          |
|  Rating (0.0 - 5.0)                                      |
|  [ 4.5                                             ]     |
|                                                          |
|  Pages                                                   |
|  [ 120                                             ]     |
|                                                          |
|  Thumbnail URL                                           |
|  [ https://...                                     ]     |
|                                                          |
|  Tags (Multi-select)                                     |
|  [ ] Horror  [x] Thriller  [ ] Romance                   |
|  (Checkbox List or Chips)                                |
|                                                          |
|----------------------------------------------------------|
|                                                          |
|           [      SAVE BOOK      ]                        |
|           (Primary Button)                               |
|                                                          |
+----------------------------------------------------------+
```

## Logic & Behavior

### 1. Initialization
- **Add Mode**: Empty fields.
- **Edit Mode**: Pre-fill fields with `book` data.

### 2. Validation
- **Title**: Required.
- **Author**: Required.
- **Rating**: numeric, 0-5.
- **Pages**: numeric, > 0.
- **Thumbnail URL**: Optional, valid URL regex (optional).

### 3. API Integration
- **Save**:
  - If Add: Call `BookProvider.addBook(bookData)`.
  - If Edit: Call `BookProvider.updateBook(id, bookData)`.
- **Tags**: Need to fetch available tags first? Or just allow selecting IDs? 
  - *Assumption*: We will fetch tags via `BookService.getTags()` (added in API collection) if available, or just hardcode for now/mock.
  - *Refinement*: API collection shows `GET /api/tags/`. I should implement `fetchTags` in `BookProvider`.

### 4. Navigation
- **On Success**: Pop screen, Show SnackBar.
