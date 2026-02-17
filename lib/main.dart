import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/books/book_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: MaterialApp(
        title: 'Secure Book Library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // home: const LoginScreen(), // Removing home
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/book_list': (context) => const BookListScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
