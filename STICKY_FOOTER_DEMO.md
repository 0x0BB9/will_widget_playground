# Sticky Footer Demo

This demo implements a layout with a footer text that behaves differently based on content height:
- When content is shorter than screen height: Footer stays fixed at the bottom
- When content exceeds screen height: Footer scrolls with the content

## Features Implemented

1. **Adaptive Footer Positioning**:
   - Fixed position at bottom when content is short
   - Scrolls with content when content is tall
   - Smooth transition between states

2. **Interactive Content Control**:
   - Menu to switch between different content lengths
   - Visual feedback for current content amount
   - Real-time demonstration of footer behavior

3. **Visual Design**:
   - Clear visual separation for the footer
   - Consistent styling with the rest of the app
   - Informative content in both main area and footer

## Files Created

1. `lib/case/sticky_footer_case.dart` - Main implementation file
2. Updated `lib/main.dart` - Added demo to the main list

## Implementation Details

### Core Layout Components

1. **LayoutBuilder**: Determines available screen space
2. **SingleChildScrollView**: Enables scrolling when content overflows
3. **ConstrainedBox**: Ensures minimum height of content area
4. **IntrinsicHeight**: Allows Column to measure its intrinsic height
5. **Spacer**: Pushes footer to bottom when content is short
6. **Column**: Arranges content and footer vertically

### Key Implementation Pattern

```dart
LayoutBuilder(
  builder: (context, constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              // Main content here
              ...contentWidgets,
              
              // Spacer pushes footer to bottom when content is short
              Spacer(),
              
              // Footer that sticks to bottom or scrolls with content
              FooterWidget(),
            ],
          ),
        ),
      ),
    );
  },
)
```

### Behavior Logic

- **Short Content**: `Spacer()` expands to fill available space, pushing footer to screen bottom
- **Tall Content**: Content naturally pushes footer below the fold, making it scrollable
- **Smooth Transitions**: No visual jumps as content length changes

## Usage Instructions

1. Run the app and navigate to "粘性底部提示文字" in the demo list
2. Observe the footer position with the default (short) content
3. Use the menu in the top right to switch between:
   - 少量内容 (Short content) - Footer fixed at bottom
   - 中等内容 (Medium content) - Footer may scroll
   - 大量内容 (Long content) - Footer scrolls with content
4. Scroll the page when content is long to see the footer move

## Customization Options

The component can be easily customized by modifying:
- Content length and structure
- Footer styling and content
- Spacer behavior
- Scroll physics
- Visual styling of all components

## Technical Notes

- Uses Flutter's built-in layout widgets for optimal performance
- No external dependencies required
- Works on all screen sizes and orientations
- Maintains accessibility standards
- Follows Flutter's composition-based approach

## Common Use Cases

- Terms and conditions footers
- Important disclaimer text
- Action buttons that should be accessible
- Copyright information
- Help text that should always be visible for short content