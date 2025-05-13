import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/teacher.dart';
import '../../models/review.dart';
import '../../services/teacher_service.dart';
import '../../services/user_service.dart';
import '../reviews/teacher_detail_screen.dart';
import '../reviews/review_submit_screen.dart';
import '../reviews/review_edit_screen.dart';
import '../search/teacher_search_screen.dart';
import '../admin/admin_dashboard_screen.dart';

// TEMPORARY FIX: Simplified queries to work around missing Firestore composite indexes
// TODO: Once the following indexes are created, revert to original queries:
// 1. collection:teachers / fields: reviewCount (ASC), averageRating (DESC), __name__ (DESC)
// 2. collection:reviews / fields: userId (ASC), timestamp (DESC), __name__ (DESC)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Constants for consistent styling - matching with other screens
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;
  
  // Service instances
  final TeacherService _teacherService = TeacherService();
  final UserService _userService = UserService();
  
  // Text styles for reuse
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.3,
    letterSpacing: -0.02,
    color: darkTextColor,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.3,
    letterSpacing: -0.01,
    color: darkTextColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: darkTextColor,
  );
  
  // User data
  String? _userName;
  bool _isAdmin = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _banCheckTimer;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkIfAdmin();
    _setupBanCheck();
  }
  
  @override
  void dispose() {
    _banCheckTimer?.cancel();
    super.dispose();
  }
  
  // Set up periodic check for banned status
  void _setupBanCheck() {
    // Check immediately
    _checkIfUserBanned();
    
    // Then check every 5 minutes while app is in use
    _banCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkIfUserBanned();
    });
  }
  
  Future<void> _checkIfUserBanned() async {
    try {
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        final isBanned = await authProvider.isUserBanned();
        if (isBanned && mounted) {
          // User has been banned, sign them out and show message
          await authProvider.signOut();
          
          // Show alert dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Account Banned'),
              content: const Text(
                'Your account has been banned due to a violation of our terms of service. '
                'If you believe this is an error, please contact support.'
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Navigate to landing page
                    Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking banned status: $e');
    }
  }
  
  Future<void> _loadUserData() async {
    try {
      if (_auth.currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
            
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['firstName'] != null) {
            setState(() {
              _userName = data['firstName'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }
  
  Future<void> _checkIfAdmin() async {
    try {
      final isAdmin = await _userService.isUserAdmin();
      setState(() {
        _isAdmin = isAdmin;
      });
    } catch (e) {
      debugPrint('Error checking admin status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Rate My Ustaad',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: darkTextColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Admin button (only for admin users)
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: darkTextColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: darkTextColor),
            onPressed: () {
              // Navigate to profile page
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: darkTextColor),
            onPressed: () async {
              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ) ?? false;
              
              if (confirmed && mounted) {
                final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                await authProvider.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/landing');
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          await _loadUserData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome text
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Hi ${_userName ?? 'Student'} 👋',
                    style: headingStyle,
                  ),
                ),
                
                // Search Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherSearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: hintTextColor),
                          const SizedBox(width: 12),
                          Text(
                            'Search for instructors or universities...',
                            style: bodyStyle.copyWith(color: hintTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Top-Rated Instructors Section
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Top-Rated Instructors', style: subheadingStyle),
                ),
                
                // Top-Rated Instructors Horizontal ListView
                SizedBox(
                  height: 220, // Increased from 180 to 220 to accommodate the institution text
                  child: _buildTopInstructorsList(),
                ),
                
                const SizedBox(height: 24),
                
                // Recent Reviews Section
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Recent Reviews', style: subheadingStyle),
                ),
                
                // Recent Reviews ListView
                _buildRecentReviewsList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReviewSubmitScreen(),
            ),
          );
        },
        child: const Icon(Icons.rate_review, color: Colors.white),
      ),
    );
  }
  
  Widget _buildTopInstructorsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teachers')
          .where('reviewCount', isGreaterThan: 0)
          .orderBy('averageRating', descending: true)
          .orderBy('reviewCount', descending: true)
          .orderBy('__name__', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        
        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading top instructors');
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyListWidget('No instructors found');
        }
        
        // Build the list with actual data
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            final teacher = Teacher.fromMap(data, doc.id);
            
            return InstructorCard(
              teacher: teacher,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherDetailScreen(teacher: teacher),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildRecentReviewsList() {
    // Only show reviews for the current user
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return _buildEmptyListWidget('Please sign in to see your reviews');
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(height: 200);
        }
        
        if (snapshot.hasError) {
          return _buildErrorWidget('Error loading your reviews');
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyListWidget('You haven\'t posted any reviews yet');
        }
        
        // Build the list with actual data
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            final review = Review.fromMap(data, doc.id);
            
            // Fetch teacher for this review
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('teachers')
                  .doc(review.teacherId)
                  .get(),
              builder: (context, teacherSnapshot) {
                Teacher? teacher;
                
                if (teacherSnapshot.hasData && teacherSnapshot.data!.exists) {
                  teacher = Teacher.fromMap(
                    teacherSnapshot.data!.data() as Map<String, dynamic>,
                    teacherSnapshot.data!.id,
                  );
                }
                
                return ReviewCard(
                  review: review,
                  teacher: teacher,
                  onTap: () {
                    if (teacher != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherDetailScreen(teacher: teacher!),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildLoadingIndicator({double height = 100}) {
    return SizedBox(
      height: height,
      child: const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: bodyStyle.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyListWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: hintTextColor, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: bodyStyle.copyWith(color: hintTextColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class InstructorCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onTap;
  
  const InstructorCard({
    super.key,
    required this.teacher,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12), // Slightly reduced from 16 to 12
            // Instructor Image
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFEEE5FF),
              backgroundImage: teacher.photoUrl.isNotEmpty ? NetworkImage(teacher.photoUrl) : null,
              child: teacher.photoUrl.isEmpty
                  ? Text(
                      teacher.name.isNotEmpty ? teacher.name[0] : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _HomeScreenState.primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10), // Slightly reduced from 12 to 10
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                teacher.name,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _HomeScreenState.darkTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            // Institution
            if (teacher.institution.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  teacher.institution,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: _HomeScreenState.hintTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 2),
            ],
            // Department
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                teacher.department,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: _HomeScreenState.hintTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < teacher.averageRating.floor() 
                        ? Icons.star 
                        : (index < teacher.averageRating 
                            ? Icons.star_half 
                            : Icons.star_border),
                    color: const Color(0xFFFFD700),
                    size: 16,
                  );
                }),
                const SizedBox(width: 4),
                Text(
                  teacher.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _HomeScreenState.darkTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;
  final Teacher? teacher;
  final VoidCallback onTap;
  
  const ReviewCard({
    super.key,
    required this.review,
    this.teacher,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId != null && currentUserId == review.userId;
    final userService = UserService();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Reviewer and Rating
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEEE5FF),
                    child: Text(
                      review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _HomeScreenState.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.isAnonymous ? 'Anonymous' : review.userName,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _HomeScreenState.darkTextColor,
                          ),
                        ),
                        Text(
                          'About ${review.teacherName}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: _HomeScreenState.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating.floor() 
                              ? Icons.star 
                              : (index < review.rating 
                                  ? Icons.star_half 
                                  : Icons.star_border),
                          color: const Color(0xFFFFD700),
                          size: 14,
                        );
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Review Text
              Text(
                review.text,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: _HomeScreenState.darkTextColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Course info
              if (review.courseCode.isNotEmpty || review.courseName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '${review.courseCode}${review.courseCode.isNotEmpty && review.courseName.isNotEmpty ? ' - ' : ''}${review.courseName}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _HomeScreenState.hintTextColor,
                    ),
                  ),
                ),
              // Timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimestamp(review.timestamp),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: _HomeScreenState.hintTextColor,
                    ),
                  ),
                  // If current user owns this review, show edit/delete buttons
                  if (isOwner)
                    Row(
                      children: [
                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: _HomeScreenState.primaryColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewEditScreen(review: review),
                              ),
                            );
                            
                            if (result == true) {
                              // Need to refresh the parent widget
                              // This is done through the parent's state
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review updated, pull down to refresh'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        // Delete button
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _confirmDeleteReview(context, review, userService);
                          },
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Read more',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _HomeScreenState.primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _confirmDeleteReview(BuildContext context, Review review, UserService userService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                final success = await userService.deleteReview(review.id);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review deleted, pull down to refresh'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete review'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      // Format as date if older than a week
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      // Format as days ago
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      // Format as hours ago
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      // Format as minutes ago
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      // Just now
      return 'Just now';
    }
  }
}
