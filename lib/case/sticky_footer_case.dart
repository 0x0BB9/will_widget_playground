import 'package:flutter/material.dart';

class StickyFooterDemo extends StatefulWidget {
  @override
  _StickyFooterDemoState createState() => _StickyFooterDemoState();
}

class _StickyFooterDemoState extends State<StickyFooterDemo> {
  int _contentItems = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('粘性底部提示文字'),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              setState(() {
                _contentItems = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 3,
                child: Text('少量内容'),
              ),
              PopupMenuItem(
                value: 10,
                child: Text('中等内容'),
              ),
              PopupMenuItem(
                value: 20,
                child: Text('大量内容'),
              ),
            ],
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '粘性底部提示文字演示',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '这个页面演示了如何实现一个粘性底部提示文字：',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        _buildFeatureItem('内容不足时', '提示文字固定在屏幕底部'),
                        _buildFeatureItem('内容充足时', '提示文字跟随在内容下方'),
                        SizedBox(height: 20),
                        Text(
                          '当前内容项数: $_contentItems',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '使用右上角菜单切换内容量来测试不同场景',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dynamic content based on _contentItems
                  ...List.generate(_contentItems, (index) {
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '内容区块 ${index + 1}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '这是第${index + 1}个内容区块。'
                              '这里有一些示例文本用来填充空间，'
                              '展示当内容量变化时底部提示文字的行为。',
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.info, size: 16, color: Colors.blue),
                                SizedBox(width: 5),
                                Text(
                                  '信息提示',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Spacer to push footer to bottom when content is short
                  Spacer(),
                  // Sticky footer text
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      border: Border(
                        top: BorderSide(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '重要提示',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '这是底部提示文字。当页面内容不足以填满屏幕时，'
                          '它会固定在屏幕底部；当内容超过屏幕高度时，'
                          '它会跟随在内容的最后面。',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '请尝试使用右上角菜单切换不同的内容量来观察效果。',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}