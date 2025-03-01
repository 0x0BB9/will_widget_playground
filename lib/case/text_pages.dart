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
          _buildExampleSection("height 不为 1.0的Text 如何在 Row 中‘居中‘: 可能是给了 Height 以后高度不够导致的"),
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
            style: TextStyle(height: 1.7, fontWeight: FontWeight.bold, backgroundColor: Colors.amber),
            textHeightBehavior: TextHeightBehavior(
              applyHeightToFirstAscent: true,  // 禁用首行顶部间距
              applyHeightToLastDescent: true,  // 禁用末行底部间距
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
