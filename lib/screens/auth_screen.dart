import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
  final _formKey = GlobalKey<FormState>();

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
    if (_loginEmailCtrl.text.trim().isEmpty || _loginPassCtrl.text.isEmpty) return;
    final success = await auth.login(_loginEmailCtrl.text.trim(), _loginPassCtrl.text);
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _register(AuthProvider auth) async {
    if (_regEmailCtrl.text.trim().isEmpty || _regPassCtrl.text.isEmpty || _regUserCtrl.text.trim().isEmpty) return;
    final success = await auth.register(_regEmailCtrl.text.trim(), _regPassCtrl.text, _regUserCtrl.text.trim());
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'musi', style: TextStyle(fontWeight: FontWeight.w900)),
              TextSpan(text: 'ka', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Sign In'), Tab(text: 'Register')],
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLogin(),
                _buildRegister(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _loginEmailCtrl,
                decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loginPassCtrl,
                decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
                obscureText: true,
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : () => _login(auth),
                  child: auth.loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegister() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _regUserCtrl,
              decoration: const InputDecoration(hintText: 'Username', prefixIcon: Icon(Icons.person_outlined)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _regEmailCtrl,
              decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _regPassCtrl,
              decoration: const InputDecoration(hintText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
              obscureText: true,
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.loading ? null : () => _register(auth),
                child: auth.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
