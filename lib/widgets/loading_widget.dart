import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ],
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final bool isGrid;

  const ShimmerList({super.key, this.itemCount = 6, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF282828)
          : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF383838)
          : Colors.grey[100]!,
      child: isGrid ? _buildGrid() : _buildList(),
    );
  }

  Widget _buildList() {
    return Column(
      children: List.generate(itemCount, (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: itemCount,
      itemBuilder: (_, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ShimmerSongTile extends StatelessWidget {
  const ShimmerSongTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF282828)
          : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF383838)
          : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40, height: 24),
          ],
        ),
      ),
    );
  }
}

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulsingDot({
    super.key,
    this.color = AppTheme.primary,
    this.size = 8.0,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Opacity(
        opacity: _animation.value,
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
