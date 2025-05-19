# RateMyUstaad - Technical Documentation

## Code Flow Diagram
```
UI Components ◄────► State Providers ◄────► Service Classes
      ▲                    ▲                      │
      │                    │                      ▼
Route System   ◄────► Data Models    ◄────► Firebase (Backend)
```

**Data Flow Example:**
1. User interacts with UI Component (e.g., submits a review)
2. UI calls Provider method (updates state)
3. Provider calls Service method (business logic)
4. Service transforms data using Data Models
5. Service communicates with Firebase (external data storage)
6. Results flow back through Service → Provider → UI
7. UI updates to reflect changes

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Core Technologies](#core-technologies)
4. [Data Models](#data-models)
5. [Services](#services)
6. [State Management](#state-management)
7. [UI Components](#ui-components)
8. [Navigation Flow](#navigation-flow)
9. [Firebase Integration](#firebase-integration)
10. [Custom UI Elements](#custom-ui-elements)
11. [Form Validation](#form-validation)
12. [Search and Filtering](#search-and-filtering)
13. [Authentication Flow](#authentication-flow)
14. [Review Submission Process](#review-submission-process)
15. [Error Handling](#error-handling)
16. [Performance Considerations](#performance-considerations)

## What is RateMyUstaad?

RateMyUstaad is a mobile app that lets university students in Pakistan search for, view ratings of, and submit reviews for their professors. Students can rate teachers on different criteria like teaching quality, clarity, and helpfulness. The app helps students make informed choices about which professors to take classes with.

## Architecture Overview

RateMyUstaad is built using Flutter, a framework for creating apps that work on both Android and iOS from a single codebase. The app follows a "layered architecture pattern," which means the code is organized into distinct sections that each handle different responsibilities.

### Architectural Layers

1. **Presentation Layer**: Contains all UI components including screens, widgets, and theme definitions
2. **State Management Layer**: Uses Provider pattern for app-wide state management
3. **Service Layer**: Handles communication with external services like Firebase
4. **Data Layer**: Contains data models and repositories for data manipulation

### Key Architectural Decisions

- **Flutter & Dart**: Used to build the app so it works on both iPhone and Android phones
- **Firebase Backend**: A cloud service that handles user accounts, stores reviews and teacher information
- **Provider Pattern**: A way to share information between different parts of the app
- **Repository Pattern**: Data access is abstracted through repository services
- **Component-Based UI**: Building the interface using reusable components

## Project Structure

The code is organized by feature rather than by type. This means related files are grouped together based on what part of the app they help create.

```
lib/
├── firebase_options.dart         # Firebase setup information
├── main.dart                     # The starting point of the app
├── models/                       # Definitions of data objects
├── providers/                    # State management classes
├── screens/                      # App screens organized by feature
│   ├── auth/                     # Login and signup screens
│   ├── home/                     # Main screen
│   ├── profile/                  # User profile screens
│   ├── reviews/                  # Review-related screens
│   ├── search/                   # Search-related screens
│   └── splash/                   # Loading screen shown at startup
├── services/                     # Classes that talk to external services
└── utils/                        # Helper functions used throughout the app
```

## Core Technologies

### Flutter & Dart

Flutter is an open-source framework by Google that lets developers build apps for multiple platforms from a single codebase. Dart is the programming language used to write Flutter apps.

**Key Flutter Concepts:**
- **Widgets**: Everything in Flutter is a widget. Widgets are immutable declarations of the UI.
- **Stateless vs. Stateful Widgets**: Stateless widgets don't change over time, while stateful widgets can.
- **BuildContext**: An object that holds the location of a widget in the widget tree.
- **Widget Tree**: Hierarchical structure of widgets that makes up the UI.

**Key Dart Features Used:**
- **Async/Await**: Syntactic sugar that makes asynchronous code easier to write and understand.
- **Futures**: Objects representing a potential value or error that will be available at some time in the future.
- **Streams**: Sequence of asynchronous events, like a pipe where data flows through.
- **Null Safety**: Ensures variables only contain non-null values unless explicitly declared nullable.

### Firebase Services

Firebase is a platform by Google that provides ready-made backend services:

- **Authentication**: Handles user sign-up, login, and account management
- **Firestore**: A NoSQL database that stores all the app's information
- **Analytics**: Tracks how people use the app (optional)

### Key Packages

These are the main Flutter packages used in the application:

- `provider`: For state management
- `cloud_firestore`: Firebase Firestore integration
- `firebase_auth`: Firebase Authentication integration
- `flutter_rating_bar`: UI component for rating inputs

## Data Models

Data models are Dart classes that define the structure of data used in the application. They provide type safety and encapsulate data transformation logic.

### Teacher Model

The `Teacher` class represents a professor/teacher entity:

```dart
class Teacher {
  final String id;
  final String name;
  final String department;
  final String institution;
  final String photoUrl;
  final double averageRating;
  final int reviewCount;
  final Map<String, dynamic> ratingBreakdown;
  final bool isVerified;

  // Constructor and methods...
}
```

The `Teacher` model includes these important methods:

```dart
// Creates a Teacher object from Firestore document data
factory Teacher.fromMap(Map<String, dynamic> map, String documentId) {
  // This code converts a raw Firestore document into a structured Teacher object
  // The 'factory' keyword means this constructor returns an instance that might be cached or pre-computed
  return Teacher(
    id: documentId,
    name: map['name'] ?? '',
    // ... other fields
  );
}

// Converts a Teacher object to a Map for Firestore storage
Map<String, dynamic> toMap() {
  // This transforms the structured object back to a raw map for database storage
  return {
    'name': name,
    // ... other fields
  };
}
```

### Review Model

Reviews are represented by the `Review` class, capturing student feedback:

```dart
class Review {
  final String id;
  final String teacherId;
  final String teacherName;
  // ... other fields ...
  final Map<String, double> ratingBreakdown;
  final List<String> tags;
  final DateTime timestamp;
  // ... more fields ...

  // Constructor and methods...
}
```

The model follows a similar pattern to the `Teacher` model, with `fromMap` and `toMap` methods for Firebase integration.

## Services

Service classes are specialized components that handle communication with external systems and complex business logic. They act as bridges between the app's interface and data storage.

### TeacherService

The `TeacherService` manages teacher data and reviews:

```dart
class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references for database access
  final CollectionReference _teachersCollection;
  final CollectionReference _reviewsCollection;
  
  // More code...
}
```

Key methods include:

```dart
// This is an async method that returns a Future
// A Future represents a value that will be available at some point in the future
Future<Teacher?> findTeacher(String name, String department) async {
  try {
    // The 'await' keyword pauses execution until the Future completes
    // This makes asynchronous code look synchronous
    final docSnapshot = await _teachersCollection.doc(teacherId).get();
    
    // More code...
    
    // The method returns a Future<Teacher?> which means it might return null
    return Teacher.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
  } catch (e) {
    // Error handling
    print('Error finding teacher: $e');
    return null;
  }
}
```

The `async` and `await` keywords are fundamental to Flutter's asynchronous programming model. They allow operations like network requests to run without blocking the UI thread.

### AuthService

The `AuthService` handles user authentication:

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // This method returns a Future<UserCredential> - an asynchronous result
  // containing user authentication information
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      // Firebase authentication call - returns when completed
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      // Error handling with rethrow to propagate error up the call stack
      print('Sign in error: $e');
      rethrow;
    }
  }
  
  // More authentication methods...
}
```

## State Management

State management is how the app keeps track of changes and shares information between different screens and components. The application uses the Provider pattern for state management.

### AuthProvider

Manages authentication state:

```dart
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;  // Nullable using Dart's null safety feature
  bool _isLoading = false;
  
  // Getter methods allow controlled access to private fields
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  
  // This method modifies state and notifies listeners (UI components)
  Future<void> login(String email, String password) async {
    _isLoading = true;
    // notifyListeners() is a key Provider method that tells all
    // listening widgets to rebuild with the new state
    notifyListeners();
    
    try {
      final credential = await _authService.signInWithEmail(email, password);
      _user = credential.user;
      _isLoading = false;
      // This call makes all UI components using this provider rebuild
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;  // Propagate the error to the UI for display
    }
  }
  
  // More methods...
}
```

The `ChangeNotifier` class is part of Flutter's foundation library and implements the Observer pattern. When state changes, it notifies all listening widgets to rebuild with the new state.

## UI Components

UI components in Flutter are built using widgets, which are immutable descriptions of part of the user interface. Flutter uses a composition-over-inheritance approach to UI building.

### Flutter Widget Types

1. **StatelessWidget**: Immutable widgets that don't change over time
2. **StatefulWidget**: Widgets that can change over time (have mutable state)

Example of a StatefulWidget from the app:

```dart
class ReviewSubmitScreen extends StatefulWidget {
  const ReviewSubmitScreen({super.key});

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teacherNameController = TextEditingController();
  bool _isSubmitting = false;

  // The build method describes the part of the user interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Review')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // UI components
          ],
        ),
      ),
    );
  }

  // This mutates state and triggers a UI rebuild
  void _submitForm() {
    setState(() {  // Important Flutter method for updating UI
      _isSubmitting = true;
    });
    
    // More code...
  }
}
```

The `setState` method is crucial in Flutter's StatefulWidgets. It tells Flutter that something has changed in the state, and the UI needs to be rebuilt.

### Custom Widget Example

```dart
Widget _buildSearchableDropdown<T>({
  required String label,
  required String hint,
  required List<T> items,
  required bool isLoading,
  required T? selectedValue,
  required String Function(T item) getLabel,
  required TextEditingController searchController,
  required Function(T) onItemSelected,
  bool enabled = true,
  String? emptyMessage,
}) {
  // Implementation...
  
  // The widget uses a generic type T, allowing it to work with
  // different data types (Teacher, Department, etc.)
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      Container(
        // ... UI implementation
      )
    ],
  );
}
```

This is a generic widget (note the `<T>` type parameter) that can work with different data types. Generic programming in Dart allows for type-safe, reusable components.

## Review Submission Process

The review submission process shows how different components of the application work together:

```dart
Future<void> _submitReview() async {
  // Form validation
  if (_validateForm()) {
    // Update UI state to show loading
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Content moderation check (shows service layer call)
      final reviewText = _reviewTextController.text;
      final censorship = await _userService.checkReviewContent(reviewText);

      // Conditional logic based on service response
      if (censorship['accepted'] != true) {
        // Store rejected review
        await _userService.storeRejectedReview(
          // Review data...
        );
        
        // Show user feedback
        _showError("Your review contains inappropriate language...");
        return;  // Early return to stop execution
      }

      // If accepted, submit the review (another service call)
      await _teacherService.addReview(
        teacherName: _teacherNameController.text,
        teacherDepartment: _departmentController.text,
        // ... other data
      );

      // Success handling
      _showSuccessMessage();
    } catch (e) {
      // Error handling with typed errors
      if (e is FirebaseException) {
        _showError("Firebase Error: ${e.message}");
      } else {
        _showError("An error occurred: $e");
      }
    } finally {
      // Reset UI state regardless of success/failure
      // 'finally' always executes after try/catch blocks
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
```

This example demonstrates:
- Asynchronous programming with `async`/`await`
- Error handling with try/catch/finally
- UI state updates with `setState()`
- Service layer calls for data operations
- Conditional logic for business rules

## Search and Filtering

The application includes search functionality with multiple approaches:

### Simple Search

Basic search by teacher name:

```dart
// This method is a wrapper around advancedSearch with fewer parameters
// It returns a Future<List<Teacher>>, which is a promise of a teacher list to come
Future<List<Teacher>> searchTeachers(String query, {int limit = 20}) {
  return advancedSearch(query: query, limit: limit);
}
```

### Advanced Search

Complex search with multiple filter criteria:

```dart
// Named parameters in Dart are enclosed in curly braces
// Default values are assigned with the = operator
Future<List<Teacher>> advancedSearch({
  String query = '',
  String? department,
  String? institution,
  double? minRating,
  List<String>? tags,
  String sortBy = 'rating',
  bool descending = true,
  int limit = 20,
}) async {
  try {
    // Logging with string interpolation
    print('SEARCH: Starting advanced search with params:');
    print('SEARCH: query="$query", department="$department", institution="$institution"');
    
    // Delegate to a utility class
    return await SearchUtils.enhancedSearch(
      teachersCollection: _teachersCollection,
      reviewsCollection: _reviewsCollection,
      query: query.trim(),
      department: department?.trim(),  // Null-aware operation
      institution: institution?.trim(),  // Call trim only if not null
      minRating: minRating,
      tags: tags,
      sortBy: sortBy,
      descending: descending,
      limit: limit,
    );
  } catch (e) {
    print('Error in advanced search: $e');
    return [];  // Return empty list on error
  }
}
```

The method demonstrates:
- Named parameters with default values
- Null safety with the `?` operator
- Delegation to utility classes
- Error handling with fallback values

## Firebase Integration

Firebase is the backend platform for the application, providing authentication, database, and other services.

### Firestore Database Structure

The application uses a Firestore database with the following collections:

- **users**: User profiles
- **teachers**: Teacher profiles
- **reviews**: User reviews of teachers
- **rejectedReviews**: Moderated reviews that were rejected

### Database Query Example

```dart
// This method demonstrates complex Firestore querying with chained methods
Future<List<Teacher>> getTopRatedTeachers({int limit = 10, DocumentSnapshot? startAfter}) async {
  try {
    // Start with a basic query
    Query query = _teachersCollection
        // Where clause for filtering
        .where('reviewCount', isGreaterThan: 0)
        // Multiple orderBy calls for sorting
        .orderBy('averageRating', descending: true)
        .orderBy('reviewCount', descending: true)
        .orderBy('__name__', descending: true);
    
    // Conditional query modification for pagination
    if (startAfter != null) {
      // Add pagination when a document is provided
      query = query.startAfterDocument(startAfter);
    }
    
    // Execute the query with a limit
    final querySnapshot = await query.limit(limit).get();
        
    // Transform documents to Teacher objects using list mapping
    return querySnapshot.docs
        .map((doc) => Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  } catch (e) {
    print('Error getting top rated teachers: $e');
    return [];  // Return empty list on error
  }
}
```

This code demonstrates:
- Firestore query building with chained methods
- Optional pagination with `startAfterDocument`
- Transforming query results with the `map()` function
- Error handling with empty list fallback

## Performance Considerations

### Data Pagination

The application uses pagination for data-heavy screens to improve performance:

```dart
// The startAfter parameter enables pagination
Future<List<Review>> getTeacherReviews(
  String teacherId, 
  {int limit = 20, DocumentSnapshot? startAfter}
) async {
  try {
    // Query setup
    Query query = _reviewsCollection
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('timestamp', descending: true);
        
    // Conditional pagination
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    // Execute query with limit
    final querySnapshot = await query.limit(limit).get();
    
    // Transform results to Review objects
    final reviews = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Review.fromMap(data, doc.id);
    }).toList();
    
    return reviews;
  } catch (e) {
    print('Error getting teacher reviews: $e');
    return [];
  }
}
```

The pagination pattern allows the app to:
1. Load only a small batch of data initially
2. Load more data when the user scrolls
3. Maintain smooth UI performance with large datasets

### Search Optimization

The `SearchUtils` class implements efficient search algorithms:

```dart
static Future<List<Teacher>> enhancedSearch({
  required CollectionReference teachersCollection,
  required CollectionReference reviewsCollection,
  required String query,
  // Other parameters...
}) async {
  // Implementation with optimized search logic
}
```

## Conclusion

RateMyUstaad is a feature-rich Flutter application with a well-structured architecture. It leverages Firebase services for backend functionality and follows best practices for state management and code organization. The application's modular design allows for easy maintenance and future enhancements.