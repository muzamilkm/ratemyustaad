import 'package:flutter/material.dart';
import '../../models/teacher.dart';
import '../../services/teacher_service.dart';
import '../reviews/teacher_detail_screen.dart';
import 'advanced_search_screen.dart';

class TeacherSearchScreen extends StatefulWidget {
  const TeacherSearchScreen({Key? key}) : super(key: key);

  @override
  State<TeacherSearchScreen> createState() => _TeacherSearchScreenState();
}

class _TeacherSearchScreenState extends State<TeacherSearchScreen> {
  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;
  
  final TextEditingController _searchController = TextEditingController();
  final TeacherService _teacherService = TeacherService();
  
  String _searchQuery = '';
  List<Teacher> _searchResults = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    
    if (_searchQuery.length >= 2) {
      _performSearch();
    }
  }
  
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_searchQuery.length < 2) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        return;
      }
      
      final results = await _teacherService.searchTeachers(_searchQuery);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching teachers: $e');
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
          'Find Teachers',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Advanced Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSearchScreen(),
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search box
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontFamily: 'Manrope', 
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Search for teachers or departments...',
                hintStyle: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Manrope',
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                ),
              ),
              onSubmitted: (value) {
                _performSearch();
              },
            ),
          ),
          
          // Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }
    
    if (_searchQuery.length < 2) {
      return _buildInitialState();
    }
    
    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final teacher = _searchResults[index];
        
        return TeacherResultCard(
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
  }
  
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Search for Teachers',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter at least 2 characters to search',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: hintTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.tune, color: Colors.white),
            label: const Text(
              'Advanced Search',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No teachers found matching "$_searchQuery"',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: hintTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.tune, color: Colors.white),
            label: const Text(
              'Advanced Search',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
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
                      color: _TeacherSearchScreenState.primaryColor,
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
                      color: _TeacherSearchScreenState.darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (teacher.institution.isNotEmpty) ...[
                    Text(
                      teacher.institution,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: _TeacherSearchScreenState.hintTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    teacher.department,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: _TeacherSearchScreenState.hintTextColor,
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
                          color: _TeacherSearchScreenState.darkTextColor,
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
              color: _TeacherSearchScreenState.hintTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}