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
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRegistering = ref.watch(authScreenProvider);
    final isLoading = ref.watch(isLoadingProvider);
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
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            // Show the trying to login message
                                          if (_formKey.currentState?.validate() != true) {
                                           ref.read(isLoadingProvider.notifier).state = false;
                                            return;
                                          }
                                          
                                            ref.read(isLoadingProvider.notifier).state = true;
                                            ScaffoldMessenger.of(context).clearSnackBars();
 ScaffoldMessenger.of(context).showSnackBar(

                                              SnackBar(
                                                content: const Text('Please Wait...'),
                                              ),
                                            );
                                            bool success = false; // Flag to check if login/register was successful

                                            if (isRegistering) {
                                              success = await ref
                                                  .read(authProvider.notifier)
                                                  .register(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                    _usernameController.text,
                                                    _mobileNumberController.text,
                                                    context,
                                                  );
                                            } else {
                                              success = await ref
                                                  .read(authProvider.notifier)
                                                  .signIn(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                    context,
                                                  );
                                            }

                                            ref.read(isLoadingProvider.notifier).state = false;

                                            if (success) {
                                              // Handle successful login or registration
                                            } else {
                                              // Handle unsuccessful login or registration
                                                 ScaffoldMessenger.of(context).clearSnackBars();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Incorrect email or password'),
                                                ),
                                              );
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
                                        ? SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
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
                                        ref.read(authScreenProvider.notifier).state = !isRegistering;
                                      },
                                      child: Text(
                                        isRegistering ? 'Login' : 'Register',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoTheme.of(context).primaryColor,
                                        ),
                                      ),
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
