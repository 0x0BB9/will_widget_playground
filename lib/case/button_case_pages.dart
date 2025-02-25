import 'package:flutter/material.dart';

class ButtonExamplesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("按钮合集")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildExampleSection("基础按钮"),
          ElevatedButton(onPressed: () {}, child: Text("ElevatedButton")),
          TextButton(onPressed: () {}, child: Text("TextButton")),
          // 添加更多按钮示例...
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
              color: Colors.blue[800]
          )
      ),
    );
  }
}
