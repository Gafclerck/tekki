import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekki/core/theme/app_colors.dart';

class PrimaryCtaButton extends StatefulWidget {
  const PrimaryCtaButton({
    super.key,
    required this.onPressed,
    this.text = '🔒 Clôturer la caisse',
    this.isLocked = false,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isLocked;

  @override
  State<PrimaryCtaButton> createState() => _PrimaryCtaButtonState();
}

class _PrimaryCtaButtonState extends State<PrimaryCtaButton> {
  bool _isLocallyLocked = false;

  bool get _isEffectiveLocked =>
      widget.isLocked || _isLocallyLocked || widget.onPressed == null;

  @override
  void didUpdateWidget(covariant PrimaryCtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLocked && oldWidget.isLocked) {
      _isLocallyLocked = false;
    }
  }

  void _handleTap() {
    if (_isEffectiveLocked || widget.onPressed == null) return;
    setState(() {
      _isLocallyLocked = true;
    });
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.tertiary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          elevation: _isEffectiveLocked ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isEffectiveLocked ? null : _handleTap,
        child: Text(
          widget.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
