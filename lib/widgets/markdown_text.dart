import 'package:flutter/material.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign? textAlign;
  final double lineHeight;

  const MarkdownText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color,
    this.textAlign,
    this.lineHeight = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final children = <InlineSpan>[];
    Color textColor = color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF121212));

    for (int li = 0; li < lines.length; li++) {
      if (li > 0) children.add(const TextSpan(text: '\n'));
      final line = lines[li];

      // Header # or ##
      if (line.startsWith('## ')) {
        children.add(TextSpan(
          text: line.substring(3),
          style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold, color: textColor, height: lineHeight),
        ));
        continue;
      }
      if (line.startsWith('# ')) {
        children.add(TextSpan(
          text: line.substring(2),
          style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold, color: textColor, height: lineHeight),
        ));
        continue;
      }

      // Parse inline formatting
      _parseInline(line, children, textColor);
    }

    return RichText(
      text: TextSpan(children: children, style: TextStyle(fontSize: fontSize, color: textColor, height: lineHeight)),
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  void _parseInline(String line, List<InlineSpan> children, Color textColor) {
    final buffer = StringBuffer();
    final spans = <TextSpan>[];
    int i = 0;

    void flushBuffer() {
      if (buffer.isNotEmpty) {
        spans.add(TextSpan(text: buffer.toString()));
        buffer.clear();
      }
    }

    while (i < line.length) {
      // **bold**
      if (line.startsWith('**', i)) {
        flushBuffer();
        int end = line.indexOf('**', i + 2);
        if (end != -1) {
          spans.add(TextSpan(
            text: line.substring(i + 2, end),
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ));
          i = end + 2;
          continue;
        }
      }

      // *italic*
      if (line[i] == '*' && i + 1 < line.length && line[i + 1] != '*' && !line.startsWith('**', i)) {
        flushBuffer();
        int end = line.indexOf('*', i + 1);
        if (end != -1 && (end + 1 >= line.length || line[end + 1] != '*')) {
          spans.add(TextSpan(
            text: line.substring(i + 1, end),
            style: TextStyle(fontStyle: FontStyle.italic, color: textColor),
          ));
          i = end + 1;
          continue;
        }
      }

      buffer.write(line[i]);
      i++;
    }

    flushBuffer();
    children.addAll(spans);
  }
}

class TypingText extends StatefulWidget {
  final String fullText;
  final double fontSize;
  final Color? color;
  final VoidCallback? onComplete;
  final Duration charInterval;

  const TypingText({
    super.key,
    required this.fullText,
    this.fontSize = 14,
    this.color,
    this.onComplete,
    this.charInterval = const Duration(milliseconds: 15),
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _displayedText = '';
  int _charIndex = 0;
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _charIndex = 0;
    _displayedText = '';
    _complete = false;
    _typeNextChar();
  }

  void _typeNextChar() {
    if (!mounted || _charIndex >= widget.fullText.length) {
      if (!_complete) {
        _complete = true;
        setState(() => _displayedText = widget.fullText);
        widget.onComplete?.call();
      }
      return;
    }

    // Type in small batches for smoothness
    final batchSize = widget.fullText.length > 200 ? 3 : (widget.fullText.length > 80 ? 2 : 1);
    final end = (_charIndex + batchSize).clamp(0, widget.fullText.length);

    if (mounted) {
      setState(() => _displayedText = widget.fullText.substring(0, end));
    }
    _charIndex = end;

    // Dynamic speed: faster for spaces/punctuation
    var delay = widget.charInterval;
    if (_charIndex < widget.fullText.length) {
      final nextChar = widget.fullText[_charIndex];
      if (nextChar == ' ' || nextChar == '\n') {
        delay = Duration(milliseconds: (widget.charInterval.inMilliseconds * 0.5).toInt());
      } else if ('.!?,'.contains(nextChar)) {
        delay = Duration(milliseconds: (widget.charInterval.inMilliseconds * 2).toInt());
      }
    }

    Future.delayed(delay, _typeNextChar);
  }

  @override
  void didUpdateWidget(TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullText != widget.fullText) {
      _startTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownText(
      text: _displayedText,
      fontSize: widget.fontSize,
      color: widget.color,
    );
  }
}
