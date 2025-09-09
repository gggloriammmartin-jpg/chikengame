import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.errorText,
    this.minLength,
    this.validator,
    this.showError = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? errorText;
  final int? minLength;
  final String? Function(String?)? validator;
  final bool showError;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _hasFocus = false;
  String? _currentErrorText;

  @override
  void initState() {
    super.initState();
    _currentErrorText = widget.errorText;
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorText != widget.errorText) {
      _currentErrorText = widget.errorText;
    }
  }

  void _validateInput(String value) {
    if (widget.minLength != null && value.length < widget.minLength!) {
      _currentErrorText = 'Minimum ${widget.minLength} character';
    } else if (value.isEmpty) {
      _currentErrorText = 'Please, enter nickname';
    } else {
      _currentErrorText = null;
    }

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: AppStyles.poppins16s300w.copyWith(color: AppColors.blackColor),
          controller: widget.controller,
          onChanged: _validateInput,
          onTap: () {
            setState(() {
              _hasFocus = true;
            });
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppStyles.poppins16s300w.copyWith(
              color: AppColors.grey173Color,
            ),
            filled: true,
            fillColor: AppColors.white240Color,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.showError && _currentErrorText != null
                    ? AppColors.redColor
                    : AppColors.white240Color,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (widget.showError && _currentErrorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '(!)',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                _currentErrorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
