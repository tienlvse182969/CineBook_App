import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đăng nhập',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),
                      GlassInput(
                        label: 'Email / SĐT / Tên đăng nhập',
                        hint: 'Nhập thông tin đăng nhập',
                        prefixIcon: LucideIcons.user,
                        controller: _identifierController,
                        validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập thông tin' : null,
                      ),
                      const SizedBox(height: 10),
                      GlassInput(
                        label: 'Mật khẩu',
                        hint: '••••••••',
                        prefixIcon: LucideIcons.lock,
                        obscureText: true,
                        controller: _passwordController,
                        validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập mật khẩu' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          ),
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(color: Color(0xFFE50914), fontSize: 12),
                          ),
                        ),
                      ),
                      GlassPrimaryButton(
                        label: 'Đăng nhập',
                        onPressed: _login,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 12),
                      _GoogleButton(onPressed: () {}),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GlassOutlineButton(
                              label: 'OTP Email',
                              icon: LucideIcons.mail,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GlassOutlineButton(
                              label: '2FA',
                              icon: LucideIcons.shield,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GlassOutlineButton(
                        label: 'Đăng nhập bằng vân tay',
                        icon: LucideIcons.fingerprint,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chưa có tài khoản? ',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  'Đăng ký ngay',
                  style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE50914).withValues(alpha: 0.12),
            border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.4), width: 1.5),
          ),
          child: const Icon(LucideIcons.clapperboard, color: Color(0xFFE50914), size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CineBook',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
            Text(
              'Đặt vé xem phim dễ dàng',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.13))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'hoặc đăng nhập bằng',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.13))),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _GoogleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GoogleLogoIcon(size: 20),
                SizedBox(width: 10),
                Text('Tiếp tục với Google', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
