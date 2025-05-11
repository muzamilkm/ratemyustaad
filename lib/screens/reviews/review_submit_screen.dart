import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/teacher_service.dart';
import '../../models/teacher.dart';

class ReviewSubmitScreen extends StatefulWidget {
  final Teacher? teacher;
  final String? teacherName;
  final String? department;

  const ReviewSubmitScreen({
    Key? key, 
    this.teacher,
    this.teacherName,
    this.department,
  }) : super(key: key);

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
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
  final TeacherService _teacherService = TeacherService();
  
  @override
  void initState() {
    super.initState();
    // Pre-populate fields if teacher is provided
    if (widget.teacher != null) {
      _teacherNameController.text = widget.teacher!.name;
      _departmentController.text = widget.teacher!.department;
      _institutionController.text = widget.teacher!.institution;
    } else if (widget.teacherName != null && widget.department != null) {
      _teacherNameController.text = widget.teacherName!;
      _departmentController.text = widget.department!;
    }
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
  
  Future<void> _submitReview() async {
    if (_validateForm()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        await _teacherService.addReview(
          teacherName: _teacherNameController.text,
          teacherDepartment: _departmentController.text,
          text: _reviewTextController.text,
          rating: _overallRating,
          ratingBreakdown: _ratingBreakdown,
          institution: _institutionController.text,
          courseCode: _courseCodeController.text,
          courseName: _courseNameController.text,
          tags: _selectedTags,
          isAnonymous: _isAnonymous,
        );
        
        if (mounted) {
          _showSuccessMessage();
          // Go back after success
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop(true); // Return true for successful submission
            }
          });
        }
      } catch (e) {
        print('Error submitting review: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting review. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
  
  bool _validateForm() {
    // Basic validation
    if (_teacherNameController.text.isEmpty) {
      _showError('Please enter teacher name');
      return false;
    }
    
    if (_departmentController.text.isEmpty) {
      _showError('Please enter department');
      return false;
    }
    
    if (_institutionController.text.isEmpty) {
      _showError('Please enter university/institution');
      return false;
    }
    
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
        content: Text('Review submitted successfully!'),
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
          'Write a Review',
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
                      hint: "Enter teacher's full name",
                      readOnly: widget.teacher != null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _departmentController,
                      label: "Department",
                      hint: "e.g., Computer Science, Electrical Engineering",
                      readOnly: widget.teacher != null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _institutionController,
                      label: "University/Institution",
                      hint: "e.g., Harvard University, MIT",
                      readOnly: widget.teacher != null,
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
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                          _overallRating > 0
                              ? _overallRating.toString()
                              : "Select a rating",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            color: _overallRating > 0 ? darkTextColor : hintTextColor,
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
                    ...['teaching', 'knowledge', 'approachability', 'grading'].map((category) {
                      String displayName = category[0].toUpperCase() + category.substring(1);
                      
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
                                    initialRating: _ratingBreakdown[category] ?? 0,
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
                                  (_ratingBreakdown[category] ?? 0) > 0
                                      ? (_ratingBreakdown[category] ?? 0).toString()
                                      : "-",
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: (_ratingBreakdown[category] ?? 0) > 0
                                        ? darkTextColor
                                        : hintTextColor,
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
                              color: isSelected ? primaryColor : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : darkTextColor,
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
                      "Write Your Review",
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
              
              // Anonymous Option
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
                        children: const [
                          Text(
                            "Post Anonymously",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkTextColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Your name won't be displayed with the review",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: hintTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Submit Review",
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
