import 'package:flutter/material.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool autofocus;
  final TextInputAction textInputAction;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType    = TextInputType.text,
    this.isPassword      = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.autofocus       = false,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:      widget.controller,
      validator:       widget.validator,
      keyboardType:    widget.keyboardType,
      obscureText:     widget.isPassword && _obscure,
      onChanged:       widget.onChanged,
      autofocus:       widget.autofocus,
      textInputAction: widget.textInputAction,
      style: const TextStyle(color: AppTheme.onSurface, fontSize: 15),
      decoration: InputDecoration(
        labelText:  widget.label,
        hintText:   widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.onSurfaceSub,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
      ),
    );
  }
}
