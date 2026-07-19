import 'package:flutter/material.dart';
import '../config/theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.child),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOut,
      child: Container(
        color: const Color(0xFF0a0a0a),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF141414),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 8)],
                ),
                child: const Icon(Icons.music_note_rounded, size: 48, color: AppTheme.primary),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'musi', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    TextSpan(text: 'ka', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Your music, everywhere', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13, letterSpacing: 2)),
              const SizedBox(height: 40),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
