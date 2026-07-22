import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../config/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regUserCtrl = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();
  bool _loginObscure = true;
  bool _regObscure = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regUserCtrl.dispose();
    super.dispose();
  }

  Future<void> _login(AuthProvider auth) async {
    if (!_loginFormKey.currentState!.validate()) return;
    final success = await auth.login(
      _loginEmailCtrl.text.trim(),
      _loginPassCtrl.text,
    );
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _register(AuthProvider auth) async {
    if (!_regFormKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setujui syarat dan ketentuan untuk melanjutkan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final success = await auth.register(
      _regEmailCtrl.text.trim(),
      _regPassCtrl.text,
      _regUserCtrl.text.trim(),
    );
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'musi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                    TextSpan(text: 'ka', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dengarkan musik tanpa batas',
                style: TextStyle(fontSize: 13, color: Colors.grey[500], letterSpacing: 0.5),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(child: Text('Masuk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                    Tab(child: Text('Daftar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                  ],
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLogin(isDark),
          _buildRegister(isDark),
        ],
      ),
    );
  }

  Widget _buildLogin(bool isDark) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _loginFormKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Email Field
              TextFormField(
                controller: _loginEmailCtrl,
                decoration: _inputDecor('Email', Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email diperlukan';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password Field
              TextFormField(
                controller: _loginPassCtrl,
                decoration: _inputDecor('Password', Icons.lock_outlined).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_loginObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _loginObscure = !_loginObscure),
                  ),
                ),
                obscureText: _loginObscure,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password diperlukan';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPassword(context),
                  child: const Text('Lupa password?', style: TextStyle(fontSize: 13, color: AppTheme.primary)),
                ),
              ),
              // Error
              if (auth.error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(auth.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : () => _login(auth),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: auth.loading
                      ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('atau', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),
                  Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.black12)),
                ],
              ),
              const SizedBox(height: 16),
              // Switch to Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun?', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: const Text('Daftar', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegister(bool isDark) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _regFormKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Username
              TextFormField(
                controller: _regUserCtrl,
                decoration: _inputDecor('Username', Icons.person_outlined),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Username diperlukan';
                  if (v.trim().length < 3) return 'Username minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email
              TextFormField(
                controller: _regEmailCtrl,
                decoration: _inputDecor('Email', Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email diperlukan';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password
              TextFormField(
                controller: _regPassCtrl,
                decoration: _inputDecor('Password', Icons.lock_outlined).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_regObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _regObscure = !_regObscure),
                  ),
                ),
                obscureText: _regObscure,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password diperlukan';
                  if (v.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Terms Checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'Saya setuju dengan Syarat & Ketentuan dan Kebijakan Privasi',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                activeColor: AppTheme.primary,
                dense: true,
              ),
              // Error
              if (auth.error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(auth.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : () => _register(auth),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: auth.loading
                      ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                      : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun?', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  TextButton(
                    onPressed: () => _tabController.animateTo(0),
                    child: const Text('Masuk', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    final emailCtrl = TextEditingController();
    bool sending = false;
    final authSvc = AuthService();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1e1e1e) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 20),
            const Text('Lupa Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Masukkan email untuk menerima kode reset', style: TextStyle(fontSize: 13, color: Colors.white54)),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              decoration: _inputDecor('Email', Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sending
                    ? null
                    : () async {
                        setSheetState(() => sending = true);
                        final res = await authSvc.forgotPassword(emailCtrl.text.trim());
                        Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res['success'] == true
                                  ? 'Kode reset telah dikirim ke email'
                                  : (res['error'] ?? 'Gagal mengirim kode')),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: sending
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Kirim Kode Reset'),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: isDark ? const Color(0xFF282828) : const Color(0xFFF0F0F0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
