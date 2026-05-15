
// Usage in AddPostDetailsTab:
//   PostTagPicker(
//     selectedTags: _selectedTags,
//     onChanged: (tags) => setState(() => _selectedTags = tags),
//   )

import 'package:flutter/material.dart';
import '../../constants/post_tags.dart';
import '../../models/post_tag.dart';

class PostTagPicker extends StatelessWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final int maxTags;

  const PostTagPicker({
    super.key,
    required this.selectedTags,
    required this.onChanged,
    this.maxTags = 5,
  });

  void _toggle(String label) {
    final updated = List<String>.from(selectedTags);
    if (updated.contains(label)) {
      updated.remove(label);
    } else {
      if (updated.length >= maxTags) return; // silently cap
      updated.add(label);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = PostTags.byCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(37, 24, 15, 0.8),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              '${selectedTags.length}/$maxTags selected',
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromRGBO(37, 24, 15, 0.4),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── One section per category ─────────────────────────────
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category label
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(37, 24, 15, 0.4),
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Chip row — wraps automatically
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((tag) {
                  final isSelected = selectedTags.contains(tag.label);
                  final isDisabled =
                      !isSelected && selectedTags.length >= maxTags;

                  return _TagChip(
                    tag: tag,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    onTap: () => _toggle(tag.label),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }
}

// ── Private chip widget ──────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final PostTag tag;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB08968).withOpacity(0.15)
              : const Color.fromRGBO(205, 189, 175, 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B6F47)
                : const Color.fromRGBO(119, 82, 66, 0.22),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 5),
            Text(
              tag.label,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight:
                isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isDisabled
                    ? const Color.fromRGBO(37, 24, 15, 0.25)
                    : isSelected
                    ? const Color(0xFF8B6F47)
                    : const Color.fromRGBO(37, 24, 15, 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}