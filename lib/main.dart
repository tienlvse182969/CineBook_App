import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ve_xem_phim/screens/admin/admin_home_screen.dart';
import 'package:ve_xem_phim/screens/auth/login_screen.dart';
import 'package:ve_xem_phim/screens/auth/register_screen.dart';
import 'package:ve_xem_phim/screens/auth/forgot_password_screen.dart';
import 'package:ve_xem_phim/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nạp cấu hình từ .env (chứa API_BASE_URL). Không chặn app nếu thiếu file.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Bỏ qua: ApiService.baseUrl sẽ dùng giá trị mặc định.
  }
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
        '/admin': (context) => const AdminHomeScreen(),
      },
    );
  }
}
