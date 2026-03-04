import 'package:flutter/material.dart';

class MovingDotsIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final int maxVisible;

  const MovingDotsIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();
    if (itemCount == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 18,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    }

    final visibleCount = itemCount < maxVisible ? itemCount : maxVisible;

    int start;

    // 🔑 Instagram-style sliding logic
    if (currentIndex <= visibleCount - 2) {
      start = 0;
    } else if (currentIndex >= itemCount - 2) {
      start = itemCount - visibleCount;
    } else {
      start = currentIndex - (visibleCount - 2);
    }

    if (start < 0) start = 0;

    final end = (start + visibleCount).clamp(0, itemCount);
    final visibleIndexes = List.generate(end - start, (i) => start + i);

    final hasLeftOverflow = start > 0;
    final hasRightOverflow = end < itemCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasLeftOverflow) _overflowDot(),

        ...visibleIndexes.map((index) {
          final isActive = index == currentIndex;
          final isNear = (index - currentIndex).abs() == 1;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 18 : (isNear ? 10 : 6),
            height: 5,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.black
                  : Colors.black.withValues(alpha: isNear ? 0.6 : 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),

        if (hasRightOverflow) _overflowDot(),
      ],
    );
  }

  Widget _overflowDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
    );
  }
}
