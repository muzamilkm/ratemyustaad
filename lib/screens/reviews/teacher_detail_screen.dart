import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/teacher.dart';
import '../../models/review.dart';
import '../../services/teacher_service.dart';
import 'review_submit_screen.dart';

class TeacherDetailScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherDetailScreen({Key? key, required this.teacher}) : super(key: key);

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;
  static const accentColor = Color(0xFFE91E63); // Pink accent for some UI elements
  
  final TeacherService _teacherService = TeacherService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }
  
  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final reviews = await _teacherService.getTeacherReviews(widget.teacher.id);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.teacher.name,
          style: const TextStyle(
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
      body: RefreshIndicator(
        onRefresh: _loadReviews,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teacher Header Card
                _buildTeacherHeader(),
                
                const SizedBox(height: 24),
                
                // Rating Breakdown Card
                _buildRatingBreakdown(),
                
                const SizedBox(height: 24),
                
                // Reviews Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.teacher.reviewCount} Reviews',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkTextColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewSubmitScreen(
                              teacher: widget.teacher,
                            ),
                          ),
                        );
                        
                        if (result == true) {
                          _loadReviews();
                        }
                      },
                      icon: const Icon(Icons.add, color: primaryColor),
                      label: const Text(
                        'Add Review',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Reviews List
                _isLoading 
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  : _reviews.isEmpty
                    ? _buildEmptyReviews()
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _reviews.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildReviewCard(_reviews[index]);
                        },
                      ),
                      
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewSubmitScreen(
                teacher: widget.teacher,
              ),
            ),
          );
          
          if (result == true) {
            _loadReviews();
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.rate_review, color: Colors.white),
      ),
    );
  }
  
  Widget _buildTeacherHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Teacher Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: widget.teacher.photoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.teacher.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 60,
                        color: primaryColor,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 60,
                    color: primaryColor,
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Teacher Name
          Text(
            widget.teacher.name,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // Teacher Department
          Text(
            widget.teacher.department,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: hintTextColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (widget.teacher.institution.isNotEmpty) ...[
            const SizedBox(height: 4),
            // Institution
            Text(
              widget.teacher.institution,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: hintTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Rating Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Star Rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.teacher.averageRating.floor()
                        ? Icons.star
                        : index < widget.teacher.averageRating
                            ? Icons.star_half
                            : Icons.star_border,
                    color: primaryColor,
                    size: 28,
                  );
                }),
              ),
              
              const SizedBox(width: 12),
              
              // Rating Value
              Text(
                widget.teacher.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: darkTextColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Review Count
          Text(
            '${widget.teacher.reviewCount} ${widget.teacher.reviewCount == 1 ? 'review' : 'reviews'}',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: hintTextColor,
            ),
          ),
          
          // Verified Badge (if applicable)
          if (widget.teacher.isVerified) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.verified,
                    color: Colors.green,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Verified Professor',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRatingBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rating Breakdown",
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkTextColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Generate each rating category
          ...widget.teacher.ratingBreakdown.entries.map((entry) {
            final categoryName = entry.key[0].toUpperCase() + entry.key.substring(1);
            final rating = entry.value is num ? (entry.value as num).toDouble() : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkTextColor,
                        ),
                      ),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rating / 5,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildReviewCard(Review review) {
    final formattedDate = DateFormat.yMMMd().format(review.timestamp);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header (user info, rating, date)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar/Initial
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // User info and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Star rating
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: primaryColor,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: darkTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Date
              Text(
                formattedDate,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: hintTextColor,
                ),
              ),
            ],
          ),
          
          // Course info (if available)
          if (review.courseCode.isNotEmpty || review.courseName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${review.courseCode}${review.courseCode.isNotEmpty && review.courseName.isNotEmpty ? ' - ' : ''}${review.courseName}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: darkTextColor,
                ),
              ),
            ),
          ],
          
          // Review text
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.text,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: darkTextColor,
                height: 1.4,
              ),
            ),
          ],
          
          // Tags
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Helpful button
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  // Get current user
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await _teacherService.markReviewAsHelpful(review.id, user.uid);
                    _loadReviews(); // Refresh to show updated count
                  } else {
                    // Show sign-in prompt
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in to mark reviews as helpful'),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 16,
                      color: review.helpfulCount > 0 ? accentColor : hintTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Helpful${review.helpfulCount > 0 ? ' (${review.helpfulCount})' : ''}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: review.helpfulCount > 0 ? accentColor : hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Reviews Yet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to share your experience with this teacher',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: hintTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewSubmitScreen(
                    teacher: widget.teacher,
                  ),
                ),
              );
              
              if (result == true) {
                _loadReviews();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Write a Review',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
