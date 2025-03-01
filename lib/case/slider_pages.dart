import 'package:flutter/material.dart';

class SliderExamplePage extends StatefulWidget {
  const SliderExamplePage({super.key});

  @override
  State<SliderExamplePage> createState() => _SliderExamplePageState();
}

class _SliderExamplePageState extends State<SliderExamplePage> {
  var _value = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("滑块合集")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildExampleSection("基础滑块"),
          // 基础水平滑块
          Slider(
            value: _value,
            min: 0,
            max: 100,
            divisions: 10,  // 分10个刻度
            label: '${_value.round()}', // 显示当前值标签
            onChanged: (newValue) => setState(() => _value = newValue),
          ),
          Slider(
            value: _value,
            min: 0,
            max: 100,
            onChanged: null, // 置空即禁用
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GradientSlider(
              value: _value,
              activeGradient: LinearGradient(
                colors: [Colors.blue, Colors.green],
                stops: [0.0, 1.0],
              ),
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
          SizedBox(height: 20),
          // 自定义垂直滑块
          SizedBox(
            width: 8,
            child: const GradientSlider(
              value: 0.3,
              direction: Axis.vertical,
              activeGradient: LinearGradient(
                colors: [Colors.blue, Colors.green],
                stops: [0.0, 1.0],
              ),
              trackHeight: 8,
              thumbSize: 24,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExampleSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800])),
    );
  }
}

class GradientSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final LinearGradient activeGradient;
  final double trackHeight;
  final double thumbSize;
  final Axis direction;

  const GradientSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.activeGradient = const LinearGradient(colors: [Colors.blue, Colors.red]),
    this.trackHeight = 4.0,
    this.thumbSize = 20.0,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: trackHeight,
        /// 自定义thumbShape：
        // thumbShape: _GradientThumb(thumbSize: thumbSize),
        /// 官方thumbShape： 类名	形状特征	适用场景	来源
        // RoundSliderThumbShape	圆形（默认）	通用场景
        // RectangularSliderThumbShape	矩形	需要直角风格
        // PaddleSliderThumbShape	水滴形（Material Design 3）	新版设计规范
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 8, // 滑块半径
          disabledThumbRadius: 6, // 禁用状态半径
        ),
        overlayShape: RoundSliderOverlayShape(overlayRadius: thumbSize * 0.4),
        activeTrackColor: Colors.transparent,
        inactiveTrackColor: Colors.transparent,
        trackShape: _GradientTrackShape(
          gradient: activeGradient,
          direction: direction,
        ),
      ),
      child: RotatedBox(
        quarterTurns: direction == Axis.vertical ? 3 : 0,
        child: Slider(
          value: value.clamp(0, 100),
          thumbColor: Colors.white,
          onChanged: onChanged,
          min: 0,
          max: 100,
        ),
      ),
    );
  }
}

class _GradientTrackShape extends SliderTrackShape {
  final LinearGradient gradient;
  final Axis direction;

  const _GradientTrackShape({
    required this.gradient,
    required this.direction,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // 1. 绘制非活动区域（白色背景）
    final inactivePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
    canvas.drawRRect(
    RRect.fromRectAndRadius(trackRect, Radius.circular(trackRect.height / 2)),
    inactivePaint,
    );

    // 2. 绘制活动区域（渐变色）
    final activeRect = Rect.fromLTRB(
    trackRect.left,
    trackRect.top,
    thumbCenter.dx,
    trackRect.bottom,
    );

    final clipPath = Path()
    ..addRRect(RRect.fromRectAndRadius(activeRect, Radius.circular(trackRect.height / 2)));

    canvas.save();
    canvas.clipPath(clipPath);

    final gradientPaint = Paint()
    ..shader = gradient.createShader(trackRect)
    ..style = PaintingStyle.fill;
    canvas.drawRRect(
    RRect.fromRectAndRadius(trackRect, Radius.circular(trackRect.height / 2)),
    gradientPaint,
    );

    canvas.restore();

    /*// 绘制完整渐变背景
    final backgroundPaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final radius = Radius.circular(trackRect.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      backgroundPaint,
    );

    // 绘制激活部分遮罩
    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final clipPath = Path()
      ..addRRect(RRect.fromRectAndRadius(activeRect, radius));

    canvas.saveLayer(trackRect, Paint());
    canvas.clipPath(clipPath);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      backgroundPaint
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(0.5),
          BlendMode.srcATop,
        ),
    );
    canvas.restore();*/
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4.0;
    final trackWidth = parentBox.size.width;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class _GradientThumb extends SliderComponentShape {
  final double thumbSize;

  const _GradientThumb({required this.thumbSize});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbSize, thumbSize);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final thumbPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    // 绘制圆形滑块
    canvas.drawCircle(center, this.thumbSize / 2, thumbPaint);

    // 添加内嵌效果
    final innerPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, this.thumbSize / 2 - 2, innerPaint);
  }
}
