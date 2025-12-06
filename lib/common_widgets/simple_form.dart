import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

// Nguyên tắc 6: Thiết kế form điền thông tin đơn giản
// Tối giản các trường thông tin, UX tốt
class SimpleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const SimpleTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          enabled: enabled,
          autofocus: autofocus,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: AppConstants.defaultIconSize,
                    color: AppColors.textSecondary,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultPadding,
            ),
            // Đảm bảo vùng cảm ứng tốt
            constraints: const BoxConstraints(
              minHeight: AppConstants.minTouchTargetSize,
            ),
          ),
        ),
      ],
    );
  }
}

// Form wrapper đơn giản với validation tự động
class SimpleForm extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final List<Widget> children;
  final VoidCallback? onSubmit;
  final String? submitButtonText;
  final bool isLoading;

  const SimpleForm({
    super.key,
    this.formKey,
    required this.children,
    this.onSubmit,
    this.submitButtonText,
    this.isLoading = false,
  });

  @override
  State<SimpleForm> createState() => _SimpleFormState();
}

class _SimpleFormState extends State<SimpleForm> {
  late final GlobalKey<FormState> _internalFormKey;

  @override
  void initState() {
    super.initState();
    _internalFormKey = widget.formKey ?? GlobalKey<FormState>();
  }

  void _handleSubmit() {
    if (_internalFormKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _internalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppConstants.defaultPadding,
              ),
              child: child,
            ),
          ),
          if (widget.onSubmit != null) ...[
            const SizedBox(height: AppConstants.smallPadding),
            SizedBox(
              height: AppConstants.buttonHeight,
              child: FilledButton(
                onPressed: widget.isLoading ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        height: AppConstants.defaultIconSize,
                        width: AppConstants.defaultIconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.submitButtonText ?? 'Gửi',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
