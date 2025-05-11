# Creating Required Firestore Indexes for RateMyUstaad

This guide explains how to create the necessary Firestore composite indexes to fix the query issues in the RateMyUstaad app.

## Current Issues

The application is encountering errors because it uses queries that require composite indexes that haven't been created yet:

1. For top-rated teachers: Querying the `teachers` collection with a filter on `reviewCount` and ordering by `reviewCount` and `averageRating`
2. For user reviews: Querying the `reviews` collection with a filter on `userId` and ordering by `timestamp`

## Creating the Required Indexes

### Method 1: Using Error Links (Recommended)

When the app encounters these errors, Firestore generates direct links to create the required indexes. Look for console error messages like these:

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

#### Index 1: Teachers Collection
- Collection: `teachers`
- Fields:
  - Field path: `averageRating`, Order: `Descending`
  - Field path: `reviewCount`, Order: `Descending`
  - Field path: `__name__`, Order: `Descending`
- Query scope: `Collection`
- Filter: `reviewCount > 0`

#### Index 2: Reviews Collection
- Collection: `reviews`
- Fields:
  - Field path: `userId`, Order: `Ascending`
  - Field path: `timestamp`, Order: `Descending`
  - Field path: `__name__`, Order: `Descending`
- Query scope: `Collection`

## After Creating Indexes

After creating the indexes, they'll appear in your Firebase Console with a "Building" status. Wait for the status to change to "Enabled" before using the original queries.

You've applied temporary fixes to the code to allow the app to function without these indexes. Once the indexes are created, you can revert the code to the original versions that use the more efficient queries.

## Areas Using These Indexes

1. HomeScreen's top instructors list 
2. HomeScreen's user reviews list
3. TeacherService's getTopRatedTeachers method

## Reverting Temporary Fixes

Once the indexes are created, you can revert the code by:

1. Restoring the original queries with multiple orderBy clauses
2. Removing client-side filtering for user reviews
3. Removing the "TEMPORARY FIX" comments

Look for "TEMPORARY FIX" and "TODO" comments to find the areas that need to be reverted.
