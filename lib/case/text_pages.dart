import 'package:flutter/material.dart';

class TextPages extends StatefulWidget {
  const TextPages({super.key});

  @override
  State<TextPages> createState() => _TextPagesState();
}

class _TextPagesState extends State<TextPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TExt合集")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildExampleSection("基础文本"),
          _buildNormalText(),
          SizedBox(height: 20),
          // I need a long text to test the overflow.
          _buildOverflowText(),
          SizedBox(height: 20),
          _buildRichText(),
          SizedBox(height: 20),
          ExpandableText(
            text: 'Flutter是Google开源的UI工具包，帮助开发者通过一套代码库高效构建多平台精美应用。'
                '它使用Dart语言开发，提供丰富的预制组件，支持iOS、Android、Web、Windows、macOS和Linux平台。'
                'Flutter的核心优势在于高性能的渲染引擎和热重载功能，极大提升开发效率。',
            maxLines: 3,
            expandText: '展开更多',
            collapseText: '收起',
            textStyle: TextStyle(fontSize: 16, color: Colors.grey[800]),
            buttonColor: Colors.blue,
          ),
          SizedBox(height: 20),
          ExpandableLayout(
            buttonColor: Colors.blue,
            buttonSize: 32,
            padding: EdgeInsets.all(16),
            upperChild: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('始终显示的内容区域', style: TextStyle(fontSize: 16)),
            ),
            lowerChild: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('可展开的附加内容', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  FlutterLogo(size: 48),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildExampleSection(
              "height 不为 1.0的Text 如何在 Row 中‘居中‘: 可能是给了 Height 以后高度不够导致的"),
          _buildTextInRow(),
          SizedBox(height: 20),
          _buildRowWithTextHeight(height: 2, fixed: false),
          SizedBox(height: 20),
          _buildRowWithTextHeight(height: 2, fixed: true),
        ],
      ),
    );
  }

  Widget _buildExampleSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue[800],
            decorationStyle: TextDecorationStyle.dashed,
            decorationThickness: 2,
          )),
    );
  }

  _buildNormalText() {
    return Text(
      'This is a normal text.',
      style: TextStyle(
        fontSize: 24,
        // color: Colors.blue,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        letterSpacing: 2.0,
        wordSpacing: 2.0,
        height: 2.0,
        shadows: [Shadow(color: Colors.grey, offset: Offset(2, 2))],
        backgroundColor: Colors.black12,
        foreground: Paint()
          ..color = Colors.amber
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      ),
    );
  }

  _buildOverflowText() {
    return Text(
      'This is a text that will overflow the screen if it is too long. And today i do not have enough words to fill this text. So thanks for reading.',
      overflow: TextOverflow.ellipsis,
      maxLines: 2, // 设置最大行数
    );
  }

  _buildRichText() {
    return RichText(
      text: TextSpan(
        text: 'This is a ',
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: 'bold',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: ' and ',
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'italic',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(
            text: ' text.',
            style: TextStyle(color: Colors.amber),
          ),
        ],
      ),
    );
  }

  _buildTextInRow() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 24, child: Checkbox(value: true, onChanged: (v) {})),
          Text(
            'Text in RowYYYi',
            style: TextStyle(
                height: 1.7,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.amber),
            textHeightBehavior: TextHeightBehavior(
              applyHeightToFirstAscent: true, // 禁用首行顶部间距
              applyHeightToLastDescent: true, // 禁用末行底部间距
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithTextHeight({double height = 1.0, bool fixed = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100], // 背景色突出组件边界
      child: Stack(
        children: [
          // 水平参考线（红色虚线）
          // const Center(child: DashedLine()),
          // 内容区域
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: true,
                onChanged: (v) {},
                fillColor: MaterialStateProperty.all(Colors.blue[100]),
              ),
              fixed
                  ? SizedBox(
                      // 修复方案：固定高度 + Align
                      height: 48, // Checkbox 放大后的高度
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildText(height: height),
                      ),
                    )
                  : _buildText(height: height), // 未修复的文本
            ],
          ),
        ],
      ),
    );
  }

  // 构建带背景色的 Text（放大字体以突显偏移）
  Widget _buildText({double height = 1.0}) {
    return Container(
      color: Colors.orange[100], // 文本背景色
      child: Text(
        'Flutter Text Alignment',
        style: TextStyle(
          fontSize: 30, // 放大字体
          height: height,
          color: Colors.black,
        ),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String expandText;
  final String collapseText;
  final TextStyle textStyle;
  final Color buttonColor;

  const ExpandableText({
    super.key,
    required this.text,
    required this.maxLines,
    this.expandText = '展开',
    this.collapseText = '收起',
    this.textStyle = const TextStyle(fontSize: 14),
    this.buttonColor = Colors.blue,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  bool _showButton = false;
  final _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTextOverflow());
  }

  void _checkTextOverflow() {
    final renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: renderBox.size.width);

    setState(() {
      _showButton = textPainter.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.text,
          key: _textKey,
          style: widget.textStyle,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (_showButton)
          Container(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              iconAlignment: IconAlignment.end,
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: widget.buttonColor,
              ),
              label: Text(
                _isExpanded ? widget.collapseText : widget.expandText,
                style: TextStyle(
                  color: widget.buttonColor,
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                setState(() => _isExpanded = !_isExpanded);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(40, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }
}

class ExpandableLayout extends StatefulWidget {
  final Widget upperChild; // 始终显示的上半部分
  final Widget lowerChild; // 可展开的下半部分
  final Color buttonColor; // 按钮颜色
  final double buttonSize; // 按钮尺寸
  final EdgeInsets padding; // 整体内边距

  const ExpandableLayout({
    super.key,
    required this.upperChild,
    required this.lowerChild,
    this.buttonColor = Colors.blue,
    this.buttonSize = 24,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<ExpandableLayout> createState() => _ExpandableLayoutState();
}

class _ExpandableLayoutState extends State<ExpandableLayout> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上半部分（始终显示）+
          widget.upperChild,
          // 下半部分（可折叠）
          /*AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: widget.lowerChild,
          ),*/
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: SizedBox(
                height: _isExpanded ? null : 0, // 关键：控制高度
                child: widget.lowerChild,
              ),
            ),
          ),
          // 展开按钮
          Align(alignment: Alignment.centerRight, child: _buildToggleButton())
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.buttonSize / 2),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(4),
          child: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            size: widget.buttonSize,
            color: widget.buttonColor,
          ),
        ),
      ),
    );
  }
}

// 自定义参考线组件（虚线）
class DashedLine extends StatelessWidget {
  const DashedLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, 1),
          painter: _DashedLinePainter(),
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    final max = size.width;
    double x = 0;
    while (x < max) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
