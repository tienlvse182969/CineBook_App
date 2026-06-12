import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  String _verifyMethod = 'otp';

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final _step1FormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE50914),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _birthDate = date);
  }

  void _next() {
    if (_currentStep == 0) {
      if (_step1FormKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else {
      Navigator.pop(context);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Column(
        children: [
          ScreenHeader(title: 'Tạo tài khoản', onBack: _back),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StepIndicator(
              currentStep: _currentStep,
              totalSteps: 3,
              labels: const ['Thông tin', 'Xác thực', 'Mã OTP'],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _buildStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return GlassCard(
      key: const ValueKey(0),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GlassInput(
              label: 'Email',
              hint: 'example@email.com',
              prefixIcon: LucideIcons.mail,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty == true) return 'Vui lòng nhập email';
                if (!v!.contains('@')) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 14),
            GlassInput(
              label: 'Số điện thoại',
              hint: '0xxxxxxxxx',
              prefixIcon: LucideIcons.phone,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập số điện thoại' : null,
            ),
            const SizedBox(height: 14),
            GlassInput(
              label: 'Tên đăng nhập',
              hint: 'username',
              prefixIcon: LucideIcons.user,
              controller: _usernameController,
              validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập tên đăng nhập' : null,
            ),
            const SizedBox(height: 14),
            GlassInput(
              label: 'Mật khẩu',
              hint: '••••••••',
              prefixIcon: LucideIcons.lock,
              obscureText: true,
              controller: _passwordController,
              validator: (v) {
                if (v?.isEmpty == true) return 'Vui lòng nhập mật khẩu';
                if (v!.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 14),
            GlassInput(
              label: 'Xác nhận mật khẩu',
              hint: '••••••••',
              prefixIcon: LucideIcons.lock,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (v) {
                if (v?.isEmpty == true) return 'Vui lòng xác nhận mật khẩu';
                if (v != _passwordController.text) return 'Mật khẩu không khớp';
                return null;
              },
            ),
            const SizedBox(height: 14),
            GlassDateField(value: _birthDate, onTap: _pickDate),
            const SizedBox(height: 24),
            GlassPrimaryButton(label: 'Tiếp theo', onPressed: _next),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return GlassCard(
      key: const ValueKey(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức xác thực',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Chọn cách bạn muốn xác thực tài khoản',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          ),
          const SizedBox(height: 24),
          _VerifyOption(
            icon: LucideIcons.mail,
            title: 'OTP qua Email',
            subtitle: 'Nhận mã 6 số về email đăng ký',
            selected: _verifyMethod == 'otp',
            onTap: () => setState(() => _verifyMethod = 'otp'),
          ),
          const SizedBox(height: 12),
          _VerifyOption(
            icon: LucideIcons.shieldCheck,
            title: 'Captcha',
            subtitle: 'Xác thực bằng hình ảnh captcha',
            selected: _verifyMethod == 'captcha',
            onTap: () => setState(() => _verifyMethod = 'captcha'),
          ),
          const SizedBox(height: 24),
          GlassPrimaryButton(label: 'Tiếp theo', onPressed: _next),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final target = _emailController.text.isNotEmpty ? _emailController.text : 'email của bạn';
    return GlassCard(
      key: const ValueKey(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập mã xác thực',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã OTP đã được gửi đến $target',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          ),
          const SizedBox(height: 32),
          OtpInput(controllers: _otpControllers, focusNodes: _otpFocusNodes),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {},
              child: RichText(
                text: TextSpan(
                  text: 'Không nhận được mã? ',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                  children: const [
                    TextSpan(
                      text: 'Gửi lại',
                      style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          GlassPrimaryButton(label: 'Xác nhận & Đăng ký', onPressed: _next),
        ],
      ),
    );
  }
}

class _VerifyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _VerifyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE50914).withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFFE50914).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? const Color(0xFFE50914).withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.07),
              ),
              child: Icon(icon, color: selected ? const Color(0xFFE50914) : Colors.white54, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 12),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(LucideIcons.checkCircle, color: Color(0xFFE50914), size: 20),
          ],
        ),
      ),
    );
  }
}
