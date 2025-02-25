import 'dart:ui';

import 'package:flutter/material.dart';

class ContainerWithBgCasePages extends StatelessWidget {
  const ContainerWithBgCasePages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("背景合集")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildExampleSection("背景颜色叠加"),
          // 添加更多按钮示例...
          buildClipRRect()
        ],
      ),
    );
  }

  /// 背景颜色叠加
  /// Container
  // ├─ ClipRRect (圆角裁剪)
  // │  └─ Container (灰色背景)
  // │     └─ Stack
  // │        ├─ Opacity (透明度控制)
  // │        │  └─ ImageFiltered (高斯模糊)
  // │        │     └─ Container (渐变圆形)
  // │        └─ Padding + Text (内容层)

  /// 组件/操作	渲染耗时 (预估)	GPU负载	重绘频率
  // ImageFilter.blur	5-8ms (sigma=8)	高	每次重绘
  // ClipRRect	1-2ms	中	首次布局
  // RadialGradient	0.5-1ms	低	首次绘制
  // Opacity + Stack	2-3ms	中	动态变化时
  Widget buildClipRRect() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(46), // 可选圆角
      child: Container(
        height: 200, // 自定义高度
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            // 淡蓝色1/4圆形
            Positioned(
              right: -240,
              top: -240,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10,
                  sigmaY: 10,
                  tileMode: TileMode.decal // 避免边缘渗透
                  ),
                  child: Container(
                  width: 380, // 圆形直径
                  height: 380,
                  decoration: BoxDecoration(
                    color: Colors.blue[200]!.withValues(alpha: 0.4), // 减少渲染层级
                    borderRadius: BorderRadius.circular(190),
                    /*gradient: RadialGradient(
                          center: Alignment(0.7, -0.7),
                          radius: 0.5,
                          colors: [
                            Colors.lightBlue[200]!.withValues(alpha: 0.9),
                            Colors.lightBlue[100]!.withValues(alpha: 0.3),
                          ],
                        ),*/
                  ),
                ),
              ),
            ),
            // 容器内容（示例文本）
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Content Area with long text',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
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
