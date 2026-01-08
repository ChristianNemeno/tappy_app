import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('[INFO] ProfileScreen: Building screen');
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.authData;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      user?.userName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.userName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (user?.roles.isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: user!.roles.map((role) {
                        return Chip(
                          label: Text(role),
                          backgroundColor: Colors.blue.shade100,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('My Quizzes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to My Quizzes
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              print('[DEBUG] ProfileScreen: Logout button tapped');
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authProvider.logout();
              }
            },
          ),
        ],
      ),
    );
  }
}