# Firestore Indexes for RateMyUstaad

This document provides information about the Firestore composite indexes used in the RateMyUstaad app.

## ✅ Required Indexes (Implemented)

The following indexes have been created and are now active:

1. For top-rated teachers: Querying the `teachers` collection with a filter on `reviewCount` and ordering by `averageRating`, `reviewCount`, and `__name__`
2. For user reviews: Querying the `reviews` collection with a filter on `userId` and ordering by `timestamp` and `__name__`

## Index Details

### Index 1: Teachers Collection (✅ CREATED)
- Collection: `teachers`
- Fields:
  - Field path: `averageRating`, Order: `Descending`
  - Field path: `reviewCount`, Order: `Descending`
  - Field path: `__name__`, Order: `Descending`
- Query scope: `Collection`
- Filter: `reviewCount > 0`

### Index 2: Reviews Collection (✅ CREATED)
- Collection: `reviews`
- Fields:
  - Field path: `userId`, Order: `Ascending`
  - Field path: `timestamp`, Order: `Descending`
  - Field path: `__name__`, Order: `Descending`
- Query scope: `Collection`
## Areas Using These Indexes

1. HomeScreen's top instructors list 
2. HomeScreen's user reviews list
3. TeacherService's getTopRatedTeachers method

## Creating New Indexes (if needed)

If you need to create additional indexes in the future:

### Method 1: Using Error Links (Recommended)

When the app encounters query errors, Firestore generates direct links to create the required indexes. Look for console error messages like these:

```
Error: [core/failed-precondition] The query requires an index.
You can create it here: https://console.firebase.google.com/v1/r/project/rate-my-ustaad/firestore/indexes?create_composite=...
```

1. Click the link in the error message
2. Confirm the index creation in the Firebase Console
3. Wait for the index to be created (may take a few minutes)

### Method 2: Manual Creation

If you can't access the error links, follow these steps:

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project ("rate-my-ustaad")
3. Navigate to Firestore Database > Indexes tab
4. Click "Add Index"
5. Fill in the collection name and fields as specified above
