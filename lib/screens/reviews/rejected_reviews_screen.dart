import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RejectedReviewsScreen extends StatefulWidget {
  const RejectedReviewsScreen({super.key});

  @override
  State<RejectedReviewsScreen> createState() => _RejectedReviewsScreenState();
}

class _RejectedReviewsScreenState extends State<RejectedReviewsScreen> {
  // Constants for consistent styling - matching with home screen
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<QuerySnapshot>? _rejectedReviewsStream;
  
  @override
  void initState() {
    super.initState();
    _loadRejectedReviews();
  }
  
  void _loadRejectedReviews() {
    final user = _auth.currentUser;
    if (user != null) {
      _rejectedReviewsStream = _firestore
          .collection('rejectedReviews')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
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
      body: SafeArea(
        child: _rejectedReviewsStream == null
            ? _buildEmptyState('Please sign in to view your rejected reviews')
            : StreamBuilder<QuerySnapshot>(
                stream: _rejectedReviewsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator();
                  }
                  
                  if (snapshot.hasError) {
                    return _buildErrorState('Error loading rejected reviews');
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState('You don\'t have any rejected reviews');
                  }
                  
                  // Build list of rejected reviews
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      return _buildRejectedReviewCard(data, doc.id);
                    },
                  );
                },
              ),
      ),
    );
  }
  
  Widget _buildRejectedReviewCard(Map<String, dynamic> data, String id) {
    final timestamp = data['timestamp'] != null 
        ? (data['timestamp'] as Timestamp).toDate() 
        : DateTime.now();
        
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with teacher info and timestamp
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['teacherName'] ?? 'Unknown Teacher',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkTextColor,
                        ),
                      ),
                      Text(
                        '${data['teacherDepartment'] ?? ''} ${(data['institution'] as String?)?.isNotEmpty == true ? ' - ${data['institution']}' : ''}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: hintTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(timestamp),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: hintTextColor,
                  ),
                ),
              ],
            ),
            
            // Course info (if available)
            if ((data['courseCode'] as String?)?.isNotEmpty == true || 
                (data['courseName'] as String?)?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${data['courseCode'] ?? ''} ${(data['courseCode'] as String?)?.isNotEmpty == true && (data['courseName'] as String?)?.isNotEmpty == true ? ' - ' : ''} ${data['courseName'] ?? ''}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hintTextColor,
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Rating
            Row(
              children: [
                ...List.generate(5, (index) {
                  final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
                  return Icon(
                    index < rating.floor() 
                        ? Icons.star 
                        : (index < rating 
                            ? Icons.star_half 
                            : Icons.star_border),
                    color: const Color(0xFFFFD700),
                    size: 16,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${(data['rating'] as num?)?.toDouble() ?? 0.0}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: darkTextColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Review text
            Text(
              data['text'] ?? 'No review text',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: darkTextColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Rejection reason
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Rejection Reason:',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['rejectionReason'] ?? 'Content flagged by AI content checker',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Try Again button
                ElevatedButton.icon(
                  onPressed: () {
                    // Pre-fill the review form with this rejected review's data
                    Navigator.of(context).pop({
                      'action': 'edit',
                      'data': data,
                    });
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Delete button
                OutlinedButton.icon(
                  onPressed: () {
                    _confirmDeleteRejectedReview(context, id);
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDeleteRejectedReview(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rejected Review'),
        content: const Text('Are you sure you want to delete this rejected review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                // Delete the rejected review
                await _firestore.collection('rejectedReviews').doc(id).delete();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rejected review deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('Error deleting rejected review: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting review: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
  
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }
  
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: darkTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: hintTextColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: hintTextColor,
            ),
            textAlign: TextAlign.center,
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
