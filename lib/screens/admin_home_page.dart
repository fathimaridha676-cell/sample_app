import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Future<void> _deleteUser(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).update({'deleted': true});
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User temporarily deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
      }
    }
  }

  Future<void> _toggleBlockUser(BuildContext context, String docId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).update({'isBlocked': !currentStatus});
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(!currentStatus ? 'User blocked successfully' : 'User unblocked successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update block status: $e')));
      }
    }
  }

  void _confirmDelete(BuildContext context, String docId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete user "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(context, docId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isNotEqualTo: 'Admin')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No other users found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isDeleted = data['deleted'] ?? false;
            return isDeleted != true;
          }).toList();
          
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No other users found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.5),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Role',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Phone',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: users.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final name = data['name'] ?? 'N/A';
                    final email = data['email'] ?? 'N/A';
                    final role = data['role'] ?? 'N/A';
                    final phone = data['phone'] ?? 'N/A';
                    final isBlocked = data['isBlocked'] ?? false;

                    return DataRow(
                      cells: [
                        DataCell(Text(name.toString())),
                        DataCell(Text(email.toString())),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(phone.toString())),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isBlocked ? Icons.lock_open : Icons.block,
                                  color: isBlocked ? Colors.green : Colors.orange,
                                ),
                                tooltip: isBlocked ? 'Unblock User' : 'Block User',
                                onPressed: () => _toggleBlockUser(context, docId, isBlocked),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                tooltip: 'Delete User',
                                onPressed: () =>
                                    _confirmDelete(context, docId, name.toString()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
