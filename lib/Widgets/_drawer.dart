import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:novatalk/Screens/SettingsScreen.dart';
import 'package:novatalk/Screens/bottom_bar.dart';
import 'package:novatalk/Widgets/chat_profile.dart';

class CustomDrawer extends StatelessWidget {
  final ChatUser? currentUser;
  
  const CustomDrawer({
    super.key,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = currentUser?.profileImage;
    return Drawer(
      child: Column(
        children: [

            UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            currentAccountPicture: Center(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: profileImage != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: profileImage,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.person),
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        ),
                      )
                    : const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
            accountName: Text(
              currentUser?.firstName ?? 'Guest User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              currentUser?.lastName ?? 'guest@example.com',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        
          // Drawer Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BottomBar()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatProfile()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),

          const Divider(),

          const Spacer(), // Pushes the logout button to the bottom

          const Divider(),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}