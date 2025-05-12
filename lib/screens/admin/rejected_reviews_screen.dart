import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';

class RejectedReviewsScreen extends StatefulWidget {
  const RejectedReviewsScreen({super.key});

  @override
  State<RejectedReviewsScreen> createState() => _RejectedReviewsScreenState();
}

class _RejectedReviewsScreenState extends State<RejectedReviewsScreen> {
  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;

  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _rejectedReviews = [];
  
  @override
  void initState() {
    super.initState();
    _loadRejectedReviews();
  }
  
  Future<void> _loadRejectedReviews() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if user is admin first
      final isAdmin = await _userService.isUserAdmin();
      if (!isAdmin) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized to view rejected reviews'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Get rejected reviews from Firestore
      final snapshot = await _firestore
          .collection('rejectedReviews')
          .orderBy('timestamp', descending: true)
          .get();
      
      final reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'teacherName': data['teacherName'] ?? 'Unknown Teacher',
          'teacherDepartment': data['teacherDepartment'] ?? 'Unknown Department',
          'institution': data['institution'] ?? '',
          'userName': data['userName'] ?? 'Anonymous',
          'userEmail': data['userEmail'] ?? '',
          'text': data['text'] ?? '',
          'rating': (data['rating'] ?? 0.0).toDouble(),
          'timestamp': data['timestamp'] != null 
              ? (data['timestamp'] as Timestamp).toDate() 
              : DateTime.now(),
          'courseCode': data['courseCode'] ?? '',
          'courseName': data['courseName'] ?? '',
          'isAnonymous': data['isAnonymous'] ?? false,
          'rejectionReason': data['rejectionReason'] ?? 'Content flagged by AI',
          'reviewedByModerator': data['reviewedByModerator'] ?? false,
        };
      }).toList();
      
      setState(() {
        _rejectedReviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading rejected reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, h:mm a');
    return formatter.format(timestamp);
  }
  
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < rating.ceil() && index >= rating.floor()) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_outline, color: Colors.amber, size: 16);
        }
      }),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Rejected Reviews',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadRejectedReviews,
              color: primaryColor,
              child: _rejectedReviews.isEmpty
                  ? _buildEmptyState()
                  : _buildReviewsList(),
            ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Rejected Reviews',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are currently no reviews that have been rejected by the AI moderation system.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: hintTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReviewsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rejectedReviews.length,
      itemBuilder: (context, index) {
        final review = _rejectedReviews[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with teacher info and rating
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['teacherName'],
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkTextColor,
                            ),
                          ),
                          Text(
                            '${review['teacherDepartment']}${review['institution'].isNotEmpty ? ' • ${review['institution']}' : ''}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: hintTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRatingStars(review['rating']),
                  ],
                ),
                const Divider(height: 24),
                
                // Review text
                const Text(
                  'Review Content:',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review['text'],
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Course info if available
                if (review['courseCode'].isNotEmpty || review['courseName'].isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.school, size: 16, color: hintTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${review['courseCode']} ${review['courseName']}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: hintTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Rejection reason
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rejection Reason:',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              review['rejectionReason'],
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Footer with user and timestamp info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'By: ${review['isAnonymous'] ? 'Anonymous' : review['userName']}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: hintTextColor,
                          ),
                        ),
                        if (!review['isAnonymous']) 
                          Text(
                            review['userEmail'],
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: hintTextColor,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      _formatTimestamp(review['timestamp']),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: hintTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
