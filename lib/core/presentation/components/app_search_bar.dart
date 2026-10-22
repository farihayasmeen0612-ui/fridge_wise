import 'package:flutter/material.dart';
import '../../theme/app_colors_extension.dart';

/// Clean search bar with clear button and standard border styling.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.onChanged,
    super.key,
    this.controller,
    this.hintText = 'Search food by name...',
    this.onClear,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: colors.textSecondary),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: colors.textSecondary),
                  onPressed: () {
                    controller!.clear();
                    onChanged('');
                    onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
