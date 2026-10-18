import 'package:flutter/material.dart';

import '../constants.dart';
import 'theme.dart';

/// Translucent card with a hairline border; optional tap with ink ripple.
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(18), this.glow = false});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Accent-coloured border and soft glow, for the "done" state.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [EmColors.surface, EmColors.surface.withValues(alpha: .6)],
        ),
        border: Border.all(color: glow ? EmColors.magenta.withValues(alpha: .55) : EmColors.border),
        boxShadow: [
          if (glow) BoxShadow(color: EmColors.magenta.withValues(alpha: .18), blurRadius: 24, spreadRadius: -6),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (b) => EmColors.accent.createShader(Offset.zero & b.size),
      child: Text(text, style: style),
    );
  }
}

/// Full-width call to action filled with the accent gradient.
class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: EmColors.accent,
        boxShadow: [BoxShadow(color: EmColors.magenta.withValues(alpha: .35), blurRadius: 22, spreadRadius: -6, offset: const Offset(0, 8))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, color: EmColors.background, size: 20), const SizedBox(width: 10)],
                Text(label, style: const TextStyle(fontFamily: EmTheme.font, fontWeight: FontWeight.w700, fontSize: 15, color: EmColors.background)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A filter shown as a pill ("Place: Gaon ▾") that opens a menu of options.
class PillMenu<T> extends StatelessWidget {
  const PillMenu({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onSelected,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = value != options.first;
    return PopupMenuButton<T>(
      tooltip: label,
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (_) => [for (final o in options) PopupMenuItem(value: o, child: Text(optionLabel(o)))],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: active ? EmColors.accent : null,
          color: active ? null : EmColors.surface,
          border: Border.all(color: active ? Colors.transparent : EmColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active ? optionLabel(value) : label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5, color: active ? EmColors.background : EmColors.text),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 18, color: active ? EmColors.background : EmColors.muted),
          ],
        ),
      ),
    );
  }
}

/// Thin progress bar filled with the accent gradient.
class GradientProgress extends StatelessWidget {
  const GradientProgress({super.key, required this.value, this.height = 6});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: EmColors.surfaceHigh, borderRadius: BorderRadius.circular(height)),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1).toDouble(),
        child: Container(
          decoration: BoxDecoration(gradient: EmColors.accent, borderRadius: BorderRadius.circular(height)),
        ),
      ),
    );
  }
}

/// Round check that animates between pending and done.
class StatusToggle extends StatelessWidget {
  const StatusToggle({super.key, required this.done, required this.onChanged, required this.tooltip});

  final bool done;
  final ValueChanged<bool> onChanged;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: () => onChanged(!done),
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: done ? EmColors.accent : null,
            border: done ? null : Border.all(color: EmColors.muted, width: 1.6),
          ),
          child: done ? const Icon(Icons.check_rounded, size: 18, color: EmColors.background) : null,
        ),
      ),
    );
  }
}

/// Small uppercase label above a group.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text.toUpperCase(),
            style: const TextStyle(fontSize: 11.5, letterSpacing: 1.6, fontWeight: FontWeight.w700, color: EmColors.muted)),
      );
}

String formatDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final l = d.toLocal();
  return '${l.day} ${months[l.month - 1]} ${l.year}';
}

/// Amount with the configured currency and thousands separators: ₹12,500.
String formatMoney(num amount) {
  final whole = amount.abs().round().toString();
  final grouped = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '${amount < 0 ? '−' : ''}$currencySymbol$grouped';
}

/// Up to two initials for an avatar.
String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
}
