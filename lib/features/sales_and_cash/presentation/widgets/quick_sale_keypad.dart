import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekki/core/theme/app_colors.dart';

class QuickSaleKeypad extends StatelessWidget {
  const QuickSaleKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  final void Function(int digit) onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 8),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) {
        final digit = int.parse(val);
        return _KeypadButton(
          label: val,
          key: ValueKey('keypad_$val'),
          onTap: () {
            HapticFeedback.selectionClick();
            onDigitPressed(digit);
          },
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _KeypadButton(
          label: 'C',
          key: const ValueKey('keypad_clear'),
          textColor: AppColors.secondary,
          onTap: () {
            HapticFeedback.selectionClick();
            onClearPressed();
          },
        ),
        _KeypadButton(
          label: '0',
          key: const ValueKey('keypad_0'),
          onTap: () {
            HapticFeedback.selectionClick();
            onDigitPressed(0);
          },
        ),
        _KeypadButton(
          icon: Icons.backspace_outlined,
          key: const ValueKey('keypad_backspace'),
          textColor: AppColors.primary,
          onTap: () {
            HapticFeedback.selectionClick();
            onDeletePressed();
          },
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    super.key,
    this.label,
    this.icon,
    this.textColor,
    required this.onTap,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final Color? textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 64, // min height >= 60dp
          child: Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: AppColors.tertiary,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              splashColor: AppColors.background,
              highlightColor: AppColors.background,
              child: Center(
                child: icon != null
                    ? Icon(
                        icon,
                        size: 26,
                        color: textColor ?? AppColors.primary,
                      )
                    : Text(
                        label!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor ?? AppColors.primary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
