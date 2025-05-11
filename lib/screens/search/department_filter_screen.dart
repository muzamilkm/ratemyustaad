import 'package:flutter/material.dart';
import '../../models/teacher.dart';
import '../../services/teacher_service.dart';
import '../reviews/teacher_detail_screen.dart';

class DepartmentFilterScreen extends StatefulWidget {
  final String department;
  
  const DepartmentFilterScreen({
    Key? key, 
    required this.department,
  }) : super(key: key);

  @override
  State<DepartmentFilterScreen> createState() => _DepartmentFilterScreenState();
}

class _DepartmentFilterScreenState extends State<DepartmentFilterScreen> {
  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;
  
  final TeacherService _teacherService = TeacherService();
  
  List<Teacher> _teachers = [];
  bool _isLoading = true;
  String _sortBy = 'rating';
  bool _sortDescending = true;
  
  final Map<String, String> _sortLabels = {
    'rating': 'Rating',
    'name': 'Name',
    'reviewCount': 'Number of Reviews'
  };
  
  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }
  
  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('DEPT_FILTER: Loading teachers for department: "${widget.department}"');
      
      // First, let's analyze all available departments to debug any case issues
      final allDepts = await _teacherService.getAllDepartments();
      print('DEPT_FILTER: All available departments: $allDepts');
      
      // Check for exact match or case-insensitive match
      final exactMatch = allDepts.contains(widget.department);
      final caseInsensitiveMatch = allDepts.any(
        (dept) => dept.toLowerCase() == widget.department.toLowerCase()
      );
      
      print('DEPT_FILTER: Exact department match found: $exactMatch');
      print('DEPT_FILTER: Case-insensitive match found: $caseInsensitiveMatch');
      
      if (caseInsensitiveMatch && !exactMatch) {
        // Find the correctly cased version
        final correctCase = allDepts.firstWhere(
          (dept) => dept.toLowerCase() == widget.department.toLowerCase()
        );
        print('DEPT_FILTER: Found correctly cased version: "$correctCase"');
      }
      
      final results = await _teacherService.advancedSearch(
        department: widget.department.trim(),
        sortBy: _sortBy,
        descending: _sortDescending,
        limit: 50, // Larger limit for department filtering
      );
      
      print('DEPT_FILTER: Received ${results.length} teachers for department: "${widget.department}"');
      if (results.isEmpty) {
        print('DEPT_FILTER: No teachers found for department: "${widget.department}"');
      } else {
        // Print first teacher for debugging
        print('DEPT_FILTER: First teacher found: ${results[0].name}, department: "${results[0].department}"');
      }
      
      setState(() {
        _teachers = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading teachers: $e');
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
          widget.department,
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
      body: Column(
        children: [
          // Sorting options
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Sort by:',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: darkTextColor,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sortBy = newValue;
                            });
                            _loadTeachers();
                          }
                        },
                        items: _sortLabels.entries.map<DropdownMenuItem<String>>((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    color: primaryColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _sortDescending = !_sortDescending;
                    });
                    _loadTeachers();
                  },
                ),
              ],
            ),
          ),
          
          // Teacher count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            alignment: Alignment.centerLeft,
            child: Text(
              '${_teachers.length} Teachers',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: hintTextColor,
              ),
            ),
          ),
          
          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }
    
    if (_teachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Teachers Found',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No teachers found in the ${widget.department} department',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: hintTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _teachers.length,
      itemBuilder: (context, index) {
        final teacher = _teachers[index];
        
        return TeacherResultCard(
          teacher: teacher,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherDetailScreen(teacher: teacher),
              ),
            ).then((_) {
              // Refresh results when returning from teacher details
              _loadTeachers();
            });
          },
        );
      },
    );
  }
}

class TeacherResultCard extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onTap;

  const TeacherResultCard({
    Key? key,
    required this.teacher,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Teacher avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFEEE5FF),
              backgroundImage: teacher.photoUrl.isNotEmpty ? NetworkImage(teacher.photoUrl) : null,
              child: teacher.photoUrl.isEmpty
                ? Text(
                    teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _DepartmentFilterScreenState.primaryColor,
                    ),
                  )
                : null,
            ),
            const SizedBox(width: 16),
            // Teacher info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.name,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _DepartmentFilterScreenState.darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
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
                        '${teacher.averageRating.toStringAsFixed(1)} (${teacher.reviewCount})',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _DepartmentFilterScreenState.darkTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: _DepartmentFilterScreenState.hintTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
