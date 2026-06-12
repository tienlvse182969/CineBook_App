import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0;

  final _identifierController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final _step1FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identifierController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  void _next() {
    if (_currentStep == 0) {
      if (_step1FormKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else {
      if (_step3FormKey.currentState?.validate() ?? false) {
        _showSuccessDialog();
      }
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.checkCircle, color: Color(0xFF4CAF50), size: 24),
            SizedBox(width: 10),
            Text('Thành công', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Mật khẩu đã được đặt lại thành công. Vui lòng đăng nhập lại.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Đăng nhập', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Column(
        children: [
          ScreenHeader(title: 'Khôi phục mật khẩu', onBack: _back),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StepIndicator(
              currentStep: _currentStep,
              totalSteps: 3,
              labels: const ['Email/SĐT', 'Mã OTP', 'Mật khẩu mới'],
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE50914).withValues(alpha: 0.12),
              ),
              child: const Icon(LucideIcons.keyRound, color: Color(0xFFE50914), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quên mật khẩu?',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập email hoặc số điện thoại đã đăng ký, chúng tôi sẽ gửi mã khôi phục về cho bạn.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 24),
            GlassInput(
              label: 'Email / Số điện thoại',
              hint: 'Nhập email hoặc SĐT',
              prefixIcon: LucideIcons.mail,
              controller: _identifierController,
              validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập thông tin' : null,
            ),
            const SizedBox(height: 24),
            GlassPrimaryButton(label: 'Gửi mã khôi phục', onPressed: _next),
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE50914).withValues(alpha: 0.12),
            ),
            child: const Icon(LucideIcons.mailCheck, color: Color(0xFFE50914), size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nhập mã xác thực',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã OTP đã được gửi đến ${_identifierController.text}',
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
          GlassPrimaryButton(label: 'Xác nhận mã OTP', onPressed: _next),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return GlassCard(
      key: const ValueKey(2),
      child: Form(
        key: _step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE50914).withValues(alpha: 0.12),
              ),
              child: const Icon(LucideIcons.lockOpen, color: Color(0xFFE50914), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tạo mật khẩu mới',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mật khẩu mới phải khác mật khẩu cũ và có ít nhất 6 ký tự.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 24),
            GlassInput(
              label: 'Mật khẩu mới',
              hint: '••••••••',
              prefixIcon: LucideIcons.lock,
              obscureText: true,
              controller: _newPasswordController,
              validator: (v) {
                if (v?.isEmpty == true) return 'Vui lòng nhập mật khẩu mới';
                if (v!.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 14),
            GlassInput(
              label: 'Xác nhận mật khẩu mới',
              hint: '••••••••',
              prefixIcon: LucideIcons.lock,
              obscureText: true,
              controller: _confirmPasswordController,
              validator: (v) {
                if (v?.isEmpty == true) return 'Vui lòng xác nhận mật khẩu';
                if (v != _newPasswordController.text) return 'Mật khẩu không khớp';
                return null;
              },
            ),
            const SizedBox(height: 24),
            GlassPrimaryButton(label: 'Đặt lại mật khẩu', onPressed: _next),
          ],
        ),
      ),
    );
  }
}
