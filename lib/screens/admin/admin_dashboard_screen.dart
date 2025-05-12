import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import './admin_management_screen.dart';
import './rejected_reviews_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Constants for consistent styling - matching with home screen
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;

  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  int _rejectedReviewsCount = 0;
  int _adminsCount = 0;
  
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }
  
  // Check if the current user is actually an admin
  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _userService.isUserAdmin();
      if (!isAdmin) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are not authorized to access the admin dashboard'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        _loadDashboardData();
      }
    } catch (e) {
      print('Error checking admin status: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get count of rejected reviews
      final rejectedReviewsSnapshot = await FirebaseFirestore.instance
          .collection('rejectedReviews')
          .get();
      
      // Get count of admins
      final adminsSnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .get();
      
      setState(() {
        _rejectedReviewsCount = rejectedReviewsSnapshot.docs.length;
        _adminsCount = adminsSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Show a message for features that are not yet implemented
  void _showFeatureNotAvailable(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  // Navigation functions for each admin feature
  void _navigateToAdminManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminManagementScreen(),
      ),
    ).then((_) => _loadDashboardData());
  }
  
  void _navigateToRejectedReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RejectedReviewsScreen(),
      ),
    ).then((_) => _loadDashboardData());
  }
  
  // Function card widget for dashboard
  Widget _buildFunctionCard(
    String title, 
    IconData icon, 
    Color color, 
    String description,
    VoidCallback onTap,
    {int? count}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  if (count != null && count > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: hintTextColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
          'Admin Dashboard',
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
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Dashboard Intro
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Admin Control Panel',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome to the admin dashboard. As an admin, you have access to additional '
                              'features to help manage the Rate My Ustaad platform. Select a function below to get started.',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Admin Functions Grid
                    const Text(
                      'Admin Functions',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Grid of admin functions
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95, // Increased size by making aspect ratio smaller
                      children: [
                        // Admin Management Card
                        _buildFunctionCard(
                          'Admin Management',
                          Icons.people,
                          Colors.indigo,
                          'Manage admin users who can access this dashboard',
                          () => _navigateToAdminManagement(context),
                          count: _adminsCount,
                        ),
                        
                        // Rejected Reviews Card
                        _buildFunctionCard(
                          'Rejected Reviews',
                          Icons.report_problem,
                          Colors.orange,
                          'View reviews that were rejected by AI moderation',
                          () => _navigateToRejectedReviews(context),
                          count: _rejectedReviewsCount,
                        ),
                        
                        // User Management Card (future)
                        _buildFunctionCard(
                          'User Management',
                          Icons.manage_accounts,
                          Colors.green,
                          'Manage users and handle user reports',
                          () => _showFeatureNotAvailable(context, 'User Management'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}