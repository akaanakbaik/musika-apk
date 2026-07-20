/// Format duration in seconds to MM:SS or HH:MM:SS format
String formatDuration(dynamic seconds) {
  if (seconds == null || seconds == 0) return '0:00';
  final totalSec = (seconds is num ? seconds.toInt() : int.tryParse(seconds.toString()) ?? 0).abs();
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  final s = totalSec % 60;
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Format milliseconds to readable duration
String formatMs(int ms) {
  if (ms <= 0) return '0:00';
  return formatDuration(ms ~/ 1000);
}

/// Format date string to readable format
String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final date = DateTime.parse(dateStr);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  } catch (_) {
    return dateStr;
  }
}

/// Format relative time (e.g., "2 hours ago", "3 days ago")
String formatRelativeTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  } catch (_) {
    return dateStr;
  }
}

/// Format count with abbreviations (e.g., 1.2K, 3.5M)
String formatCount(int count) {
  if (count < 1000) return count.toString();
  if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
  if (count < 1000000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  return '${(count / 1000000000).toStringAsFixed(1)}B';
}

/// Truncate text with ellipsis
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}

/// Capitalize first letter of each word
String capitalizeWords(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}

/// Convert snake_case to Title Case
String snakeToTitle(String text) {
  return text.split('_').map((word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }).join(' ');
}

/// Format file size in bytes to human readable
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

/// Extract YouTube video ID from various URL formats
String? extractYoutubeId(String url) {
  final patterns = [
    RegExp(r'youtube\.com/watch\?v=([A-Za-z0-9_-]{11})'),
    RegExp(r'youtu\.be/([A-Za-z0-9_-]{11})'),
    RegExp(r'youtube\.com/embed/([A-Za-z0-9_-]{11})'),
    RegExp(r'youtube\.com/shorts/([A-Za-z0-9_-]{11})'),
  ];
  for (final pattern in patterns) {
    final match = pattern.firstMatch(url);
    if (match != null) return match.group(1);
  }
  return null;
}

/// Check if a string is a valid URL
bool isValidUrl(String url) {
  return Uri.tryParse(url)?.hasScheme == true || url.startsWith('http');
}

/// Get thumbnail URL for a given YouTube video ID
String getYoutubeThumbnail(String videoId, {String quality = 'hqdefault'}) {
  return 'https://i.ytimg.com/vi/$videoId/$quality.jpg';
}

/// Parse user agent for device info (simplified)
String getDeviceInfo() {
  return 'Musika/1.0 (Android; Flutter)';
}
