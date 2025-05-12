import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/review.dart';
import '../../services/user_service.dart';

class ReviewEditScreen extends StatefulWidget {
  final Review review;

  const ReviewEditScreen({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  State<ReviewEditScreen> createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {
  // Constants for consistent styling - matching with home screen
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;

  // Form controllers
  final _teacherNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _institutionController = TextEditingController();
  final _reviewTextController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();

  // Rating values
  double _overallRating = 0;
  final Map<String, double> _ratingBreakdown = {
    'teaching': 0.0,
    'knowledge': 0.0,
    'approachability': 0.0,
    'grading': 0.0,
  };

  // Tags
  final List<String> _availableTags = [
    'Helpful',
    'Clear Explanations',
    'Difficult',
    'Easy Grader',
    'Tough Grader',
    'Project-Based',
    'Engaging',
    'Lots of Assignments',
    'Inspiring',
    'Fair',
  ];

  final List<String> _selectedTags = [];

  bool _isAnonymous = false;
  bool _isSubmitting = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    // Pre-populate fields from the existing review
    _teacherNameController.text = widget.review.teacherName;
    _departmentController.text = widget.review.teacherDepartment;
    _reviewTextController.text = widget.review.text;
    _courseCodeController.text = widget.review.courseCode;
    _courseNameController.text = widget.review.courseName;
    _overallRating = widget.review.rating;

    // Copy rating breakdown
    _ratingBreakdown.clear();
    for (final entry in widget.review.ratingBreakdown.entries) {
      _ratingBreakdown[entry.key] = entry.value;
    }

    // Copy tags
    _selectedTags.addAll(widget.review.tags);

    // Set anonymous status (but don't allow changing it)
    _isAnonymous = widget.review.isAnonymous;
  }

  @override
  void dispose() {
    _teacherNameController.dispose();
    _departmentController.dispose();
    _institutionController.dispose();
    _reviewTextController.dispose();
    _courseCodeController.dispose();
    _courseNameController.dispose();
    super.dispose();
  }

  Future<void> _updateReview() async {
    if (_validateForm()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Check the review content first
        final reviewText = _reviewTextController.text;        try {
          final censorship = await _userService.checkReviewContent(reviewText);

          // Check if the review was accepted
          if (censorship['accepted'] != true) {
            // Store the rejected edit in the rejectedReviews collection
            await _userService.storeRejectedReview(
              reviewText: reviewText,              teacherName: widget.review.teacherName,
              teacherDepartment: widget.review.teacherDepartment,
              rating: _overallRating,
              ratingBreakdown: _ratingBreakdown,
              courseCode: _courseCodeController.text,
              courseName: _courseNameController.text,
              tags: _selectedTags,
              isAnonymous: widget.review.isAnonymous,
              rejectionReason: censorship['reason'],
            );
            
            // Review was rejected by the AI, show the appropriate message
            _showError(
                "Your review contains inappropriate language as detected by our AI. Please rewrite your review and try again.");
            setState(() {
              _isSubmitting = false;
            });
            return;
          }

          // If we get here, the review content was accepted, so continue with update
          final updatedData = {
            'text': reviewText,
            'rating': _overallRating,
            'ratingBreakdown': _ratingBreakdown,
            'courseCode': _courseCodeController.text,
            'courseName': _courseNameController.text,
            'tags': _selectedTags,
          };

          final success =
              await _userService.updateReview(widget.review.id, updatedData);

          if (mounted) {
            if (success) {
              _showSuccessMessage();

              // Go back after success
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context)
                      .pop(true); // Return true for successful update
                }
              });
            } else {
              _showError('Failed to update review. Please try again.');
            }
          }
        } catch (e) {
          // Handle specific error messages from the censorship check
          if (e.toString().contains('validation_connectivity_error')) {
            _showError(
                "Unable to connect to the server to validate the review language. Please try again later.");
          } else if (e.toString().contains('validation_server_error')) {
            _showError(
                "Unable to connect to the server to validate the review language. Please try again later.");
          } else {
            _showError("Error validating review: ${e.toString()}");
          }
          setState(() {
            _isSubmitting = false;
          });
        }
      } catch (e) {
        print('Error updating review: $e');
        if (mounted) {
          _showError('Error updating review: ${e.toString()}');
        }
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _validateForm() {
    // Basic validation
    if (_reviewTextController.text.isEmpty) {
      _showError('Please write a review');
      return false;
    }

    if (_overallRating == 0) {
      _showError('Please provide an overall rating');
      return false;
    }

    // Check if any rating is 0
    for (final key in _ratingBreakdown.keys) {
      if (_ratingBreakdown[key] == 0) {
        _showError('Please rate $key');
        return false;
      }
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Edit Review',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                      "Teacher Information",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _teacherNameController,
                      label: "Teacher Name",
                      hint: "Teacher name",
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _departmentController,
                      label: "Department",
                      hint: "Department",
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _courseCodeController,
                      label: "Course Code (optional)",
                      hint: "e.g., CS101, ECON202",
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _courseNameController,
                      label: "Course Name (optional)",
                      hint: "e.g., Introduction to Programming",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Overall Rating
              Container(
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
                      "Overall Rating",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RatingBar.builder(
                        initialRating: _overallRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: primaryColor,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _overallRating = rating;
                          });
                        },
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _overallRating.toString(),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            color: darkTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Detailed Ratings
              Container(
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
                      "Rate Specifically",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Generate rating bars for each category
                    ...['teaching', 'knowledge', 'approachability', 'grading']
                        .map((category) {
                      String displayName =
                          category[0].toUpperCase() + category.substring(1);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: darkTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RatingBar.builder(
                                    initialRating:
                                        _ratingBreakdown[category] ?? 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 30,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: primaryColor,
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        _ratingBreakdown[category] = rating;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  (_ratingBreakdown[category] ?? 0).toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: darkTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tags
              Container(
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
                      "Add Tags (Optional)",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Select tags that describe this teacher",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: hintTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTags.remove(tag);
                              } else {
                                _selectedTags.add(tag);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? primaryColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected ? Colors.white : darkTextColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Review Text
              Container(
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
                      "Your Review",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reviewTextController,
                      maxLines: 5,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        color: darkTextColor,
                      ),
                      decoration: InputDecoration(
                        hintText: "Share your experience with this teacher...",
                        hintStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          color: hintTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Anonymous indicator (not editable)
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAnonymous
                                ? "Posted Anonymously"
                                : "Posted with Your Name",
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isAnonymous
                                ? "Your name isn't visible with this review"
                                : "Your name is visible with this review",
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: hintTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isAnonymous ? Icons.visibility_off : Icons.visibility,
                      color: _isAnonymous ? Colors.grey : primaryColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Update Review",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkTextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            color: darkTextColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Manrope',
              color: hintTextColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
