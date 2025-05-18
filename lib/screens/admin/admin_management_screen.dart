import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  // Constants for consistent styling - matching with home screen
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;

  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _adminsList = [];
  
  final TextEditingController _emailController = TextEditingController();
  bool _isAddingAdmin = false;
  
  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAdmins() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final admins = await _userService.getAllAdmins();
      
      setState(() {
        _adminsList = admins;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading admins: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addAdmin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enter a valid email address', Colors.red);
      return;
    }
    
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Please enter a valid email address', Colors.red);
      return;
    }
    
    setState(() {
      _isAddingAdmin = true;
    });
    
    try {
      // Find user with this email
      final userId = await _userService.findUserIdByEmail(email);
      
      if (userId == null) {
        _showSnackBar('No user found with this email address', Colors.red);
        setState(() {
          _isAddingAdmin = false;
        });
        return;
      }
      
      // Check if the user is already an admin
      final adminDoc = await _firestore.collection('admins').doc(userId).get();
      if (adminDoc.exists) {
        _showSnackBar('User is already an admin', Colors.orange);
        setState(() {
          _isAddingAdmin = false;
        });
        return;
      }
      
      final success = await _userService.addAdmin(userId);
      
      if (success) {
        _showSnackBar('Admin added successfully', Colors.green);
        _emailController.clear();
        _loadAdmins();
      } else {
        _showSnackBar('Failed to add admin', Colors.red);
      }
    } catch (e) {
      print('Error adding admin: $e');
      _showSnackBar('Error adding admin: $e', Colors.red);
    }
    
    setState(() {
      _isAddingAdmin = false;
    });
  }
  
  Future<void> _removeAdmin(String userId) async {
    try {
      // Don't allow removing yourself
      if (userId == _auth.currentUser?.uid) {
        _showSnackBar('You cannot remove yourself as admin', Colors.orange);
        return;
      }
      
      final success = await _userService.removeAdmin(userId);
      
      if (success) {
        _showSnackBar('Admin removed successfully', Colors.green);
        _loadAdmins();
      } else {
        _showSnackBar('Failed to remove admin', Colors.red);
      }
    } catch (e) {
      print('Error removing admin: $e');
      _showSnackBar('Error removing admin: $e', Colors.red);
    }
  }
  
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
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
          'Admin Management',
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
              onRefresh: _loadAdmins,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add Admin Section
                    _buildAddAdminSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Current Admins List
                    const Text(
                      'Current Admins',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAdminsList(),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildAddAdminSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Admin',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter the email address of the person you want to make an admin:',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  color: hintTextColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addAdmin(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAddingAdmin ? null : _addAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isAddingAdmin
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Add Admin',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdminsList() {
    if (_adminsList.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.grey[100],
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No admins found',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: hintTextColor,
              ),
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _adminsList.length,
      itemBuilder: (context, index) {
        final admin = _adminsList[index];
        final isCurrentUser = admin['userId'] == _auth.currentUser?.uid;
        
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(
                (admin['firstName'] as String).isNotEmpty
                    ? (admin['firstName'] as String)[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${admin['firstName']} ${admin['lastName']}',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin['email'] ?? 'No email',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Added: ${admin['addedOn'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: hintTextColor,
                  ),
                ),
              ],
            ),
            trailing: isCurrentUser
                ? const Chip(
                    label: Text(
                      'You',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showRemoveAdminDialog(admin['userId']),
                  ),
          ),
        );
      },
    );
  }
  
  void _showRemoveAdminDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin'),
        content: const Text('Are you sure you want to remove this user as an admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeAdmin(userId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
