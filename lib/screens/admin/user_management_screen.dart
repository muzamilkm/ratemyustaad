import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const backgroundColor = Color(0xFFF0F8FF);
  static const cardColor = Colors.white;

  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _usersList = [];
  List<Map<String, dynamic>> _bannedUsersList = [];
  Set<String> _bannedUserIds = {}; // For quick lookup
  
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadBannedUsers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Check if the current user is actually an admin
  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _userService.isUserAdmin();
      if (!isAdmin && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not authorized to access user management'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error checking admin status: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _loadBannedUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bannedUsers = await _userService.getBannedUsers();
      
      final Set<String> bannedIds = bannedUsers.map((user) => user['userId'] as String).toSet();
      
      setState(() {
        _bannedUsersList = bannedUsers;
        _bannedUserIds = bannedIds;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading banned users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchUsers(String query) async {
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    
    try {
      final results = await _userService.searchUsers(query);
      
      setState(() {
        _usersList = results;
        _isSearching = false;
      });
      
      // If search returned no results and has at least 3 characters, show a message
      if (results.isEmpty && query.length >= 3) {
        _showSnackBar('No users found matching "$query". Try different search terms.', Colors.orange);
      }
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        _isSearching = false;
      });
      _showSnackBar('Error searching users: $e', Colors.red);
    }
  }
  
  Future<void> _banUser(String userId, String userEmail, String userName) async {
    final TextEditingController reasonController = TextEditingController();
    
    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to ban $userName?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for ban (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(reasonController.text),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
    
    // User cancelled the dialog
    if (reason == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await _userService.banUser(userId, reason);
      
      if (success) {
        // Get user details to update the UI
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data() ?? {};
        
        final currentUser = FirebaseAuth.instance.currentUser;
        final adminEmail = currentUser?.email ?? 'Unknown Admin';
        
        // Update local lists
        setState(() {
          _bannedUserIds.add(userId);
          _usersList = _usersList.map((user) {
            if (user['userId'] == userId) {
              user['isBanned'] = true;
            }
            return user;
          }).toList();
          
          // Add to banned users list
          _bannedUsersList.add({
            'userId': userId,
            'email': userEmail,
            'firstName': userData['firstName'] ?? '',
            'lastName': userData['lastName'] ?? '',
            'banReason': reason.isNotEmpty ? reason : 'Violation of terms',
            'bannedBy': adminEmail,
            'bannedAt': Timestamp.now(),
          });
        });
        
        _showSnackBar('User has been banned', Colors.green);
      } else {
        _showSnackBar('Failed to ban user', Colors.red);
      }
    } catch (e) {
      print('Error banning user: $e');
      _showSnackBar('Error banning user: $e', Colors.red);
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _unbanUser(String userId, String userName) async {
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unban User'),
        content: Text('Are you sure you want to unban $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Unban User'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirm) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await _userService.unbanUser(userId);
      
      if (success) {
        // Update local lists
        setState(() {
          _bannedUserIds.remove(userId);
          _usersList = _usersList.map((user) {
            if (user['userId'] == userId) {
              user['isBanned'] = false;
            }
            return user;
          }).toList();
          
          // Remove from banned users list
          _bannedUsersList.removeWhere((user) => user['userId'] == userId);
        });
        
        _showSnackBar('User has been unbanned', Colors.green);
      } else {
        _showSnackBar('Failed to unban user', Colors.red);
      }
    } catch (e) {
      print('Error unbanning user: $e');
      _showSnackBar('Error unbanning user: $e', Colors.red);
    }
    
    setState(() {
      _isLoading = false;
    });
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
          'User Management',
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
              onRefresh: _loadBannedUsers,
              color: primaryColor,
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Search Users',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by name or email',
                            hintStyle: const TextStyle(
                              fontFamily: 'Manrope',
                              color: hintTextColor,
                            ),
                            helperText: 'Type at least 2 characters to search by partial match',
                            helperStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchUsers('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            // Auto-search if value is empty (to clear results)
                            // or if value has 3+ characters (for better UX)
                            if (value.isEmpty || value.length >= 3) {
                              _searchUsers(value);
                            }
                          },
                          onSubmitted: _searchUsers,
                          textInputAction: TextInputAction.search,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _searchUsers(_searchController.text);
                              },
                              icon: const Icon(Icons.search, size: 16),
                              label: const Text('Search'),
                              style: TextButton.styleFrom(
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Results section
                  Expanded(
                    child: _isSearching
                        ? const Center(child: CircularProgressIndicator(color: primaryColor))
                        : _usersList.isEmpty && _searchQuery.isNotEmpty
                            ? _buildNoResultsFound()
                            : _usersList.isEmpty
                                ? _buildBannedUsersList()
                                : _buildSearchResults(),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No users found matching "$_searchQuery"',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: hintTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Text(
                  'Try a different search term or check the spelling',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: hintTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Search tips:',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Search by full or partial name\n• Search by partial or complete email\n• Names are case-sensitive\n• Email searches are case-insensitive',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: hintTextColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBannedUsersList() {
    if (_bannedUsersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Banned Users',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'There are currently no banned users. Search for a user above to manage their account status.',
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Banned Users',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bannedUsersList.length,
            itemBuilder: (context, index) {
              final user = _bannedUsersList[index];
              final userName = '${user['firstName']} ${user['lastName']}';
              final userEmail = user['email'];
              final userId = user['userId'];
              final banReason = user['banReason'];
              final timestamp = user['bannedAt'] as Timestamp;
              final banDate = DateFormat('MMM d, yyyy').format(timestamp.toDate());
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[100],
                    child: const Icon(Icons.block, color: Colors.red),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Chip(
                        label: Text(
                          'Banned',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Reason: $banReason',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: Colors.red[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Text(
                            'Since: $banDate',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize:.11,
                              color: hintTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green),
                    onPressed: () => _unbanUser(userId, userName),
                    tooltip: 'Unban User',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSearchResults() {
    // Sort the users - banned users first, then alphabetically by name
    _usersList.sort((a, b) {
      // First sort by ban status (banned users first)
      if (a['isBanned'] != b['isBanned']) {
        return a['isBanned'] ? -1 : 1;
      }
      
      // Then sort alphabetically by name
      final nameA = '${a['firstName']} ${a['lastName']}'.toLowerCase();
      final nameB = '${b['firstName']} ${b['lastName']}'.toLowerCase();
      return nameA.compareTo(nameB);
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Results for "$_searchQuery"',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              Text(
                '${_usersList.length} ${_usersList.length == 1 ? 'user' : 'users'} found',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: hintTextColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _usersList.length,
            itemBuilder: (context, index) {
              final user = _usersList[index];
              final userName = '${user['firstName']} ${user['lastName']}';
              final userEmail = user['email'];
              final userId = user['userId'];
              final isBanned = user['isBanned'];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isBanned ? Colors.red.shade50 : cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isBanned ? Colors.red[100] : primaryColor.withOpacity(0.1),
                    child: user['photoURL'] != null && user['photoURL'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              user['photoURL'],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isBanned ? Colors.red : primaryColor,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBanned ? Colors.red : primaryColor,
                            ),
                          ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isBanned) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text(
                            'Banned',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                        ),
                      ),
                      if (isBanned) ...[
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _getBanReason(userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text(
                                'Loading ban reason...',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red,
                                ),
                              );
                            }
                            
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            
                            return Text(
                              'Reason: ${snapshot.data}',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.red[700],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  trailing: isBanned
                      ? IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          onPressed: () => _unbanUser(userId, userName),
                          tooltip: 'Unban User',
                        )
                      : IconButton(
                          icon: const Icon(Icons.block, color: Colors.red),
                          onPressed: () => _banUser(userId, userEmail, userName),
                          tooltip: 'Ban User',
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Helper method to get ban reason for a specific user
  Future<String> _getBanReason(String userId) async {
    try {
      // First check our local cache
      for (final bannedUser in _bannedUsersList) {
        if (bannedUser['userId'] == userId) {
          return bannedUser['banReason'] ?? 'No reason provided';
        }
      }
      
      // If not found in cache, fetch from Firestore
      final doc = await _firestore.collection('bannedUsers').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['banReason'] ?? 'No reason provided';
      }
      
      return 'No reason provided';
    } catch (e) {
      print('Error getting ban reason: $e');
      return 'No reason provided';
    }
  }
}
