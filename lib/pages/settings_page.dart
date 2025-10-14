import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onlyfunds_v1/auth_service.dart';
import 'package:onlyfunds_v1/pages/account_page.dart';
import 'package:onlyfunds_v1/pages/notifications_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoading = false;

  void _signout() async {
    setState(() => isLoading = true);
    try {
      await authService.value.signOut();
      Navigator.pushReplacementNamed(context, '/signin');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _deleteAccount(String password) async {
    setState(() => isLoading = true);
    try {
      await authService.value.deleteAccount(password: password);
      Navigator.pushReplacementNamed(context, '/signin');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully.")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _confirmDeleteAccount() {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorText; // store error message

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder( // allows updating UI inside dialog
        builder: (ctx, setState) => AlertDialog(
          title: const Text(
            "Delete Account",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter your password to confirm"),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  errorText: errorText, // shows red text below if not null
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                final password = passwordController.text.trim();

                // ✅ Validate password field
                if (password.isEmpty) {
                  setState(() {
                    errorText = "Password is required";
                  });
                  return;
                }

                Navigator.pop(ctx); // close dialog if password valid
                _deleteAccount(
                  password
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _settingsItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _settingsItem(Icons.account_circle_rounded, 
            "Account Information",
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => AccountPage()),
              );
            }
            ),
            const SizedBox(height: 12),
            _settingsItem(Icons.notifications_rounded, 
            "Notifications",
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );  
            },
            ),
            const SizedBox(height: 12),

            const Spacer(),

            // Delete Account button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isLoading ? null : _confirmDeleteAccount,
                child: Text(
                  isLoading ? "Processing..." : "Delete Account",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sign Out button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isLoading ? null : _signout,
                child: Text(
                  isLoading ? "Processing..." : "Sign Out",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
