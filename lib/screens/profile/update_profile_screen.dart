import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'dart:async';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _usernameController.text = user.username;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _checkUsernameAvailability(String username) async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    if (username == currentUser?.username) {
      setState(() => _isUsernameAvailable = true);
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isCheckingUsername = true);
      final available = await Provider.of<AuthProvider>(context, listen: false)
          .checkUsernameAvailability(username);
      setState(() {
        _isUsernameAvailable = available;
        _isCheckingUsername = false;
      });
    });
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate() && _isUsernameAvailable) {
      final Map<String, dynamic> data = {
        'full_name': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      final success = await Provider.of<AuthProvider>(context, listen: false).updateUserDetails(data);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        } else {
          final error = Provider.of<AuthProvider>(context, listen: false).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Update failed')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Full Name',
                controller: _fullNameController,
                prefixIcon: Icons.badge,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Username',
                controller: _usernameController,
                prefixIcon: Icons.alternate_email,
                onChanged: _checkUsernameAvailability,
                validator: (v) {
                  if (v!.isEmpty) return 'Username is required';
                  if (!_isUsernameAvailable) return 'Username is not available';
                  return null;
                },
              ),
              if (_isCheckingUsername)
                const Padding(
                  padding: EdgeInsets.only(top: 4, left: 12),
                  child: Text('Checking availability...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const Text('Change Password (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'New Password',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                prefixIcon: Icons.lock_clock_outlined,
                isPassword: true,
                validator: (v) {
                  if (_passwordController.text.isNotEmpty && v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'UPDATE PROFILE',
                onPressed: _updateProfile,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
