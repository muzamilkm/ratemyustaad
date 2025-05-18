import 'package:flutter/material.dart';
import '../../models/teacher.dart';
import '../../services/teacher_service.dart';
import '../reviews/teacher_detail_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  
  final TextEditingController _searchController = TextEditingController();
  final TeacherService _teacherService = TeacherService();
  
  String _searchQuery = '';
  List<Teacher> _searchResults = [];
  bool _isLoading = false;
  bool _showFilters = false;
  
  // Filter state
  String? _selectedDepartment;
  String? _selectedInstitution;
  double _minRating = 0.0;
  final List<String> _selectedTags = [];
  String _sortBy = 'rating';
  bool _sortDescending = true;

  // Available options for filters
  List<String> _availableDepartments = [];
  List<String> _availableInstitutions = [];
  List<String> _filteredDepartments = []; // Departments filtered by institution
  List<String> _availableTags = [];
  final List<String> _sortOptions = ['rating', 'name', 'reviewCount'];
  final Map<String, String> _sortLabels = {
    'rating': 'Rating',
    'name': 'Name',
    'reviewCount': 'Number of Reviews'
  };
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadFilterOptions();
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadFilterOptions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load departments, institutions, and tags in parallel
      final departmentsFuture = _teacherService.getAllDepartments();
      final institutionsFuture = _teacherService.getAllInstitutions();
      final tagsFuture = _teacherService.getAllTags();
      
      final departments = await departmentsFuture;
      final institutions = await institutionsFuture;
      final tags = await tagsFuture;
      
      setState(() {
        _availableDepartments = departments;
        _filteredDepartments = departments; // Initially all departments
        _availableInstitutions = institutions;
        _availableTags = tags;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading filter options: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Load departments for selected institution
  Future<void> _loadDepartmentsForInstitution(String institution) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final departments = await _teacherService.getDepartmentsByInstitution(institution);
      
      setState(() {
        _filteredDepartments = departments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading departments for institution: $e');
      setState(() {
        _filteredDepartments = [];
        _isLoading = false;
      });
    }
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
      print('ADV_SEARCH: Performing search with params:');
      print('ADV_SEARCH: query=$_searchQuery, department=$_selectedDepartment, institution=$_selectedInstitution');
      print('ADV_SEARCH: minRating=$_minRating, tags=$_selectedTags, sortBy=$_sortBy, descending=$_sortDescending');
      
      if (_searchQuery.length < 2 && _selectedDepartment == null && 
          _selectedInstitution == null && _minRating == 0 && _selectedTags.isEmpty) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        print('ADV_SEARCH: No search params, returning empty results');
        return;
      }
      
      final results = await _teacherService.advancedSearch(
        query: _searchQuery,
        department: _selectedDepartment?.trim(),
        institution: _selectedInstitution,
        minRating: _minRating > 0 ? _minRating : null,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
        sortBy: _sortBy,
        descending: _sortDescending,
      );
      
      print('ADV_SEARCH: Search returned ${results.length} results');
      if (results.isEmpty) {
        print('ADV_SEARCH: No results found');
      } else {
        print('ADV_SEARCH: First result: ${results[0].name}, department: "${results[0].department}", institution: "${results[0].institution}"');
      }
      
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
  void _resetFilters() {
    setState(() {
      _selectedDepartment = null;
      _selectedInstitution = null;
      _filteredDepartments = _availableDepartments;
      _minRating = 0.0;
      _selectedTags.clear();
      _sortBy = 'rating';
      _sortDescending = true;
    });
    _performSearch();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Advanced Search',
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
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
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

          // Filter section - only visible when _showFilters is true
          if (_showFilters) _buildFilterSection(),
          
          // Active filters chips
          if (_hasActiveFilters()) _buildActiveFiltersSection(),
          
          // Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedDepartment != null || 
           _selectedInstitution != null ||
           _minRating > 0 || 
           _selectedTags.isNotEmpty || 
           _sortBy != 'rating' ||
           !_sortDescending;
  }
  
  Widget _buildFilterSection() {
    // Calculate a safe height that accounts for the app bar and some padding
    final screenHeight = MediaQuery.of(context).size.height;
    // Reduce maximum height to prevent overflow
    final safeHeight = screenHeight * 0.5; // Reduced to 50% to prevent overflow
    
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(
        maxHeight: safeHeight,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Always allow scrolling
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Take minimum required space
          children: [
          // Institution dropdown (moved before department)
          const Text(
            'Institution/University',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedInstitution,
                hint: const Text('Select Institution'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: darkTextColor,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedInstitution = newValue;
                    // Reset department when institution changes
                    _selectedDepartment = null;
                    
                    // Load departments for this institution if selected
                    if (newValue != null) {
                      _loadDepartmentsForInstitution(newValue);
                    } else {
                      // If no institution selected, show all departments
                      _filteredDepartments = _availableDepartments;
                    }
                  });
                  _performSearch();
                },
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Institutions'),
                  ),
                  ..._availableInstitutions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Department dropdown (now after institution)
          const Text(
            'Department',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedDepartment,
                hint: Text(_selectedInstitution == null 
                  ? 'Select Institution First' 
                  : 'Select Department'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: darkTextColor,
                ),
                onChanged: _selectedInstitution == null 
                  ? null // Disable if no institution is selected
                  : (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                      });
                      _performSearch();
                    },
                items: _selectedInstitution == null
                  ? null  // No items if institution not selected
                  : [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Departments'),
                      ),
                      ..._filteredDepartments
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Minimum rating slider
          const Text(
            'Minimum Rating',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  activeColor: primaryColor,
                  inactiveColor: Colors.grey.shade300,
                  label: _minRating.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _minRating = value;
                    });
                  },
                  onChangeEnd: (double value) {
                    _performSearch();
                  },
                ),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_minRating.toStringAsFixed(1)}★',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tags wrap
          const Text(
            'Tags',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                selectedColor: primaryColor.withOpacity(0.2),
                checkmarkColor: primaryColor,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  fontFamily: 'Manrope',
                  color: isSelected ? primaryColor : darkTextColor,
                  fontSize: 12,
                ),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                  _performSearch();
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Sort options
          Row(
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
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
                          _performSearch();
                        }
                      },
                      items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(_sortLabels[value] ?? value),
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
                  _performSearch();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Apply/Reset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _resetFilters,
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _performSearch();
                  setState(() {
                    _showFilters = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildActiveFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Active Filters:',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: hintTextColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _resetFilters,
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Department filter chip
              if (_selectedDepartment != null)
                Chip(
                  label: Text('Department: $_selectedDepartment'),
                  backgroundColor: primaryColor.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: primaryColor,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14, color: primaryColor),
                  onDeleted: () {
                    setState(() {
                      _selectedDepartment = null;
                    });
                    _performSearch();
                  },
                ),
              
              // Institution filter chip
              if (_selectedInstitution != null)
                Chip(
                  label: Text('Institution: $_selectedInstitution'),
                  backgroundColor: primaryColor.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: primaryColor,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14, color: primaryColor),
                  onDeleted: () {
                    setState(() {
                      _selectedInstitution = null;
                    });
                    _performSearch();
                  },
                ),
              
              // Min rating filter chip
              if (_minRating > 0)
                Chip(
                  label: Text('Min Rating: ${_minRating.toStringAsFixed(1)}★'),
                  backgroundColor: primaryColor.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: primaryColor,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14, color: primaryColor),
                  onDeleted: () {
                    setState(() {
                      _minRating = 0;
                    });
                    _performSearch();
                  },
                ),
              
              // Sort filter chip
              if (_sortBy != 'rating' || !_sortDescending)
                Chip(
                  label: Text(
                    'Sort: ${_sortLabels[_sortBy]} ${_sortDescending ? '↓' : '↑'}',
                  ),
                  backgroundColor: primaryColor.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: primaryColor,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14, color: primaryColor),
                  onDeleted: () {
                    setState(() {
                      _sortBy = 'rating';
                      _sortDescending = true;
                    });
                    _performSearch();
                  },
                ),
              
              // Tag filter chips
              ..._selectedTags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: primaryColor.withOpacity(0.1),
                labelStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: primaryColor,
                ),
                deleteIcon: const Icon(Icons.close, size: 14, color: primaryColor),
                onDeleted: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                  _performSearch();
                },
              )),
            ],
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
    
    if (_searchQuery.isEmpty && 
        _selectedDepartment == null && 
        _selectedInstitution == null &&
        _minRating == 0 && 
        _selectedTags.isEmpty) {
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
            ).then((_) {
              // Refresh results when returning from teacher details
              _performSearch();
            });
          },
        );
      },
    );
  }
  
  Widget _buildInitialState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Use the search bar or filters to find teachers',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: hintTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = true;
                        });
                      },
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      label: const Text(
                        'Show Filters',
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNoResults() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                        _selectedDepartment != null || _selectedInstitution != null || _minRating > 0 || _selectedTags.isNotEmpty
                            ? 'Try adjusting your filters for more results'
                            : 'No teachers found matching "$_searchQuery"',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: hintTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          'Reset Filters',
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
                ),
              ),
            ),
          ),
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
                      color: _AdvancedSearchScreenState.primaryColor,
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
                      color: _AdvancedSearchScreenState.darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (teacher.institution.isNotEmpty) ...[
                    Text(
                      teacher.institution,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: _AdvancedSearchScreenState.hintTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    teacher.department,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: _AdvancedSearchScreenState.hintTextColor,
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
                          color: _AdvancedSearchScreenState.darkTextColor,
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
              color: _AdvancedSearchScreenState.hintTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
