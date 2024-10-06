import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class TVHelper {
  static void handleKeyEvent(
      BuildContext context,
      KeyEvent event,
      List<dynamic> items,
      int focusedIndex,
      ScrollController scrollController,
      Function(int) onItemFocusChange,
      Function(int) onItemSelected) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        int nextIndex = (focusedIndex + 1).clamp(0, items.length - 1);
        onItemFocusChange(nextIndex);
        scrollToFocusedItem(context, scrollController, nextIndex, items.length);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        int nextIndex = (focusedIndex - 1).clamp(0, items.length - 1);
        onItemFocusChange(nextIndex);
        scrollToFocusedItem(context, scrollController, nextIndex, items.length);
      } else if (event.logicalKey == LogicalKeyboardKey.select) {
        onItemSelected(focusedIndex);
      }
    }
  }

  static void scrollToFocusedItem(BuildContext context,
      ScrollController scrollController, int focusedIndex, int itemCount) {
    const itemHeight = 70.0; // Approximate height of a ListTile
    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 200.0; // Height of the header (adjust if different)
    final viewportHeight = screenHeight - headerHeight;

    final itemPosition = focusedIndex * itemHeight;
    final viewportStart = scrollController.offset;
    final viewportEnd = viewportStart + viewportHeight;

    if (itemPosition < viewportStart) {
      scrollController.animateTo(
        itemPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (itemPosition + itemHeight > viewportEnd) {
      scrollController.animateTo(
        itemPosition + itemHeight - viewportHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}