import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../config/theme.dart';

class SleepTimerNotifier extends ChangeNotifier {
  Timer? _timer;
  DateTime? _endTime;
  int _remainingSeconds = 0;
  bool _active = false;
  int _totalMinutes = 0;

  bool get active => _active;
  int get remainingSeconds => _remainingSeconds;
  int get totalMinutes => _totalMinutes;
  String get remainingFormatted {
    if (!_active) return '';
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void start(int minutes) {
    cancel();
    _totalMinutes = minutes;
    _remainingSeconds = minutes * 60;
    _active = true;
    _endTime = DateTime.now().add(Duration(minutes: minutes));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    _remainingSeconds--;
    if (_remainingSeconds <= 0) {
      _timeUp();
    }
    notifyListeners();
  }

  void _timeUp() {
    cancel();
    // Access player and stop
    // The widget will handle this via listener
    notifyListeners();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _active = false;
    _remainingSeconds = 0;
    _totalMinutes = 0;
    _endTime = null;
    notifyListeners();
  }

  void addTime(int minutes) {
    if (!_active) return;
    _remainingSeconds += minutes * 60;
    _totalMinutes += minutes;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  @override
  Widget build(BuildContext context) {
    final timer = context.watch<SleepTimerNotifier>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timer_outlined, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(timer.active ? 'Timer Aktif' : 'Timer Tidur',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          if (timer.active) ...[
            const SizedBox(height: 16),
            Text(timer.remainingFormatted,
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w200, color: AppTheme.primary)),
            const SizedBox(height: 4),
            Text('${timer.totalMinutes} menit', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => timer.addTime(15),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+15m'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    timer.cancel();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                  ),
                  child: const Text('Matikan'),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),
            _DurationOption(minutes: 15, icon: Icons.coffee_outlined, label: '15 menit'),
            _DurationOption(minutes: 30, icon: Icons.tv_outlined, label: '30 menit'),
            _DurationOption(minutes: 45, icon: Icons.school_outlined, label: '45 menit'),
            _DurationOption(minutes: 60, icon: Icons.bedtime_outlined, label: '60 menit'),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final int minutes;
  final IconData icon;
  final String label;
  const _DurationOption({required this.minutes, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary, size: 18),
      ),      onTap: () {
                final timer = context.read<SleepTimerNotifier>();
                final player = context.read<PlayerProvider>();
                final startId = DateTime.now().millisecondsSinceEpoch;
                timer.start(minutes);
                Navigator.pop(context);
                // Schedule delayed stop only (not immediate)
                Future.delayed(Duration(minutes: minutes), () {
                  if (timer.active && timer.totalMinutes == minutes) {
                    player.stop();
                    timer.cancel();
                  }
                });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pemutaran akan berhenti dalam $label'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

class SleepTimerIndicator extends StatelessWidget {
  const SleepTimerIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<SleepTimerNotifier>();
    if (!timer.active) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const SleepTimerSheet(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, size: 14, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(timer.remainingFormatted,
              style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
