import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_xem_phim/screens/auth/login_screen.dart';
import 'package:ve_xem_phim/screens/auth/register_screen.dart';
import 'package:ve_xem_phim/screens/auth/forgot_password_screen.dart';
import 'package:ve_xem_phim/screens/home/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
