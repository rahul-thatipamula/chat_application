import 'package:chat_app/providers/auth_state_provider.dart';
import 'package:chat_app/screen/auth_screen.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'login_page.dart';
// import 'home_page.dart'; // Home page where authenticated users land
// import 'auth_provider.dart'; // Your provider files

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(); // Initialize Firebase
  
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
          primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
    );
  }
}
class AuthWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider); // Watch the authentication state

    return authState.when(
      data: (user) {
        // Check if user is not null
        if (user != null) {
          // If user is logged in, show the Home Page
          return HomeScreen(userData: user,); // Ensure user.id is accessed safely
        } else {
          // If no user is logged in, show the Login Page
          return AuthScreen();
        }
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
