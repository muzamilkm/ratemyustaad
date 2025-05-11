import 'package:flutter/material.dart';
import '../../services/teacher_service.dart';
import 'department_filter_screen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  
  final TeacherService _teacherService = TeacherService();
  List<String> _departments = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }
  
  Future<void> _loadDepartments() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final departments = await _teacherService.getAllDepartments();
      setState(() {
        _departments = departments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading departments: $e');
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
        title: const Text(
          'Departments',
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
      body: RefreshIndicator(
        onRefresh: _loadDepartments,
        color: primaryColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : _departments.isEmpty
                ? _buildEmptyState()
                : _buildDepartmentsList(),
      ),
    );
  }
  
  Widget _buildEmptyState() {
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
            'No Departments Found',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'There are no departments available yet',
              style: TextStyle(
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
  
  Widget _buildDepartmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _departments.length,
      itemBuilder: (context, index) {
        final department = _departments[index];
        
        return DepartmentCard(
          department: department,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DepartmentFilterScreen(department: department),
              ),
            );
          },
        );
      },
    );
  }
}

class DepartmentCard extends StatelessWidget {
  final String department;
  final VoidCallback onTap;

  const DepartmentCard({
    Key? key,
    required this.department,
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
            // Department icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEEE5FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Icon(
                  Icons.school,
                  color: const Color(0xFF5E17EB),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Department name
            Expanded(
              child: Text(
                department,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _DepartmentsScreenState.darkTextColor,
                ),
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: _DepartmentsScreenState.hintTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
