import 'package:flutter/material.dart';

/// Extensions for ScrollController to provide additional scrolling functionality
extension ScrollControllerExtensions on ScrollController {
  /// Scrolls up by a fixed height with smooth animation
  /// 
  /// [height] - The distance to scroll up in pixels
  /// [duration] - Animation duration, defaults to 300ms
  /// [curve] - Animation curve, defaults to Curves.easeInOut
  /// 
  /// Returns a Future that completes when the animation finishes
  Future<void> scrollUpByHeight(
    double height, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients) return;
    
    final currentOffset = offset;
    final targetOffset = (currentOffset - height).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    
    await animateTo(
      targetOffset,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Scrolls down by a fixed height with smooth animation
  /// 
  /// [height] - The distance to scroll down in pixels
  /// [duration] - Animation duration, defaults to 300ms
  /// [curve] - Animation curve, defaults to Curves.easeInOut
  /// 
  /// Returns a Future that completes when the animation finishes
  Future<void> scrollDownByHeight(
    double height, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients) return;
    
    final currentOffset = offset;
    final targetOffset = (currentOffset + height).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    
    await animateTo(
      targetOffset,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Scrolls to show a specific widget with optional offset
  /// 
  /// [key] - GlobalKey of the target widget
  /// [offset] - Additional offset from the top, defaults to 0
  /// [duration] - Animation duration, defaults to 500ms
  /// [curve] - Animation curve, defaults to Curves.easeInOut
  /// 
  /// Returns a Future that completes when the animation finishes
  Future<void> scrollToWidget(
    GlobalKey key, {
    double offset = 0,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients || key.currentContext == null) return;
    
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final targetOffset = (this.offset + position.dy - offset).clamp(
      this.position.minScrollExtent,
      this.position.maxScrollExtent,
    );
    
    await animateTo(
      targetOffset,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Scrolls to the top of the scrollable content
  /// 
  /// [duration] - Animation duration, defaults to 500ms
  /// [curve] - Animation curve, defaults to Curves.easeInOut
  /// 
  /// Returns a Future that completes when the animation finishes
  Future<void> scrollToTop({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients) return;
    
    await animateTo(
      position.minScrollExtent,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Scrolls to the bottom of the scrollable content
  /// 
  /// [duration] - Animation duration, defaults to 500ms
  /// [curve] - Animation curve, defaults to Curves.easeInOut
  /// 
  /// Returns a Future that completes when the animation finishes
  Future<void> scrollToBottom({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients) return;
    
    await animateTo(
      position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Scrolls by a percentage of the viewport height
  /// 
  /// [percentage] - Percentage of viewport to scroll (0.0 to 1.0)
  /// [direction] - Scroll direction (positive for down, negative for up)
  /// [duration] - Animation duration, defaults to 300ms
  /// [curve] - Animation curve, defaults to Curves.easeInOut
  /// 
  /// Returns a Future that completes when the animation finishes
  Future<void> scrollByViewportPercentage(
    double percentage, {
    int direction = 1, // 1 for down, -1 for up
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (!hasClients) return;
    
    final viewportHeight = position.viewportDimension;
    final scrollDistance = viewportHeight * percentage * direction;
    
    final currentOffset = offset;
    final targetOffset = (currentOffset + scrollDistance).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    
    await animateTo(
      targetOffset,
      duration: duration,
      curve: curve,
    );
  }
  
  /// Checks if the scroll position is at the top
  bool get isAtTop => hasClients && offset <= position.minScrollExtent;
  
  /// Checks if the scroll position is at the bottom
  bool get isAtBottom => hasClients && offset >= position.maxScrollExtent;
  
  /// Gets the current scroll percentage (0.0 at top, 1.0 at bottom)
  double get scrollPercentage {
    if (!hasClients) return 0.0;
    
    final range = position.maxScrollExtent - position.minScrollExtent;
    if (range <= 0) return 0.0;
    
    return ((offset - position.minScrollExtent) / range).clamp(0.0, 1.0);
  }
}