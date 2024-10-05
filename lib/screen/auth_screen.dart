import 'package:chat_app/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for managing isRegistering and isLoading states
final authScreenProvider = StateProvider<bool>((ref) => false); // Manage isRegistering
final isLoadingProvider = StateProvider<bool>((ref) => false);  // Manage isLoading

class AuthScreen extends ConsumerStatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _mobileNumberController.dispose();
    super.dispose(); // Always call super.dispose()
  }

  @override
  Widget build(BuildContext context) {
    final isRegistering = ref.watch(authScreenProvider); // Watch the registration state
    final isLoading = ref.watch(isLoadingProvider); // Watch the loading state
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ChatApp Logo with text
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Text(
                  'ChatApp',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoTheme.of(context).primaryColor,
                      CupertinoTheme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRegistering ? 'Create Account' : 'Welcome Back!',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters long';
                                    }
                                    return null;
                                  },
                                ),
                                if (isRegistering) ...[
                                  const SizedBox(height: 16),
                                  // Username field (for registration only)
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.person),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a username';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Mobile number field (for registration only)
                                  TextFormField(
                                    controller: _mobileNumberController,
                                    decoration: InputDecoration(
                                      labelText: 'Mobile Number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.phone),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a mobile number';
                                      }
                                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                        return 'Enter a valid 10-digit mobile number';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                const SizedBox(height: 30),
                                // Login/Register button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Store the reference locally to avoid using after dispose
                                        final currentRef = ref; 

                                        // Set loading state to true
                                        currentRef.read(isLoadingProvider.notifier).state = true;

                                        bool success = false; // Flag to check if login/register was successful

                                        try {
                                          if (isRegistering) {
                                            success = await currentRef
                                                .read(authProvider.notifier)
                                                .register(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                  _usernameController.text,
                                                  _mobileNumberController.text,
                                                );
                                          } else {
                                            success = await currentRef
                                                .read(authProvider.notifier)
                                                .signIn(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                );
                                          }
                                        } catch (e) {
                                          // Handle exceptions and possibly show error messages
                                          print(e);
                                          // Show error message using ScaffoldMessenger
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } finally {
                                          // Set loading state to false
                                          currentRef.read(isLoadingProvider.notifier).state = false;
                                        }

                                        // If the login or registration was successful, do something
                                        if (success) {
                                          // Optionally, navigate to another screen or show a success message
                                        } else {
                                          // If the email is already in use, show a snackbar
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Email is already in use.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: CupertinoTheme.of(context).primaryColor,
                                    ),
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            isRegistering ? 'Register' : 'Login',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                // Toggle between Login/Register
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(isRegistering
                                        ? 'Already have an account? '
                                        : 'Don\'t have an account? '),
                                    TextButton(
                                      onPressed: () {
                                        // Toggle the registration state
                                        ref.read(authScreenProvider.notifier).state = !isRegistering;
                                      },
                                      child: Text(
                                          isRegistering ? 'Login' : 'Register'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
