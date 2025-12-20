
import 'package:flutter/material.dart';

/// A reusable search bar widget that can be used across the app.
class ReusableSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const ReusableSearchBar({
    Key? key,
    required this.controller,
    this.hintText = "Tìm kiếm...",
    this.autofocus = false,
    this.onSubmitted,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          // The clear button is managed by the parent widget through rebuilding
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 22),
                  onPressed: () {
                    // Clear text and notify parent to refilter/rebuild
                    controller.clear();
                    if (onChanged != null) {
                      onChanged!('');
                    }
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        ),
      ),
    );
  }
}

