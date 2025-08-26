import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageExamplesPage extends StatelessWidget {
  const ImageExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("图片合集")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildExampleSection("基础图片"),
          ExtendedImage.asset(
            "assets/images/POA_Card.png",
            width: 400,
            height: 200,
            fit: BoxFit.fill,
            border: Border.all(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            //cancelToken: cancellationToken,
          ),
          Stack(
            children: [
              ExtendedImage.asset(
                "assets/images/POA_Card.png",
                width: 400,
                height: 200,
                fit: BoxFit.fill,
                border: Border.all(color: Colors.red, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                //cancelToken: cancellationToken,
              ),
              // 添加半透明蒙版层
              Container(
                width: 400,
                height: 200,
                decoration: BoxDecoration(
                  // 半透明深灰色蒙版，可通过opacity调整模糊程度
                  color: Colors.black38.withOpacity(0.8),
                  // 保持与图片相同的圆角
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
            ],
          ),
          // 添加带局部模糊蒙版的版本
          _buildExampleSection("带敏感信息保护的图片"),
          Stack(
            children: [
              // 底层原图
              ExtendedImage.asset(
                "assets/images/POA_Card.png",
                width: 400,
                height: 200,
                fit: BoxFit.fill,
                border: Border.all(color: Colors.red, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              // 全区域模糊蒙版（修复无效果问题）
              ClipRRect( // 确保模糊效果在圆角内生效
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // 增强模糊强度
                  child: Container(
                    width: 400, // 与原图同宽
                    height: 200, // 与原图同高
                    color: Colors.transparent, // 透明容器承载模糊效果
                  ),
                ),
              ),
            ],
          ),
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
