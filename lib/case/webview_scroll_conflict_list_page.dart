import 'package:flutter/material.dart';
import 'webview_scroll_conflict_cases.dart';

/// WebView 滑动冲突实验列表页面
class WebViewScrollConflictListPage extends StatelessWidget {
  const WebViewScrollConflictListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView 滑动冲突实验'),
        backgroundColor: Colors.blue[100],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 页面说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '实验说明',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '本实验用于测试和解决 ScrollView 中嵌套 WebView 时的滑动冲突问题。'
                    '包含多种场景的测试用例，帮助理解和解决实际开发中遇到的滑动冲突。',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 实验案例列表
          _buildCaseCard(
            context,
            title: '默认滑动冲突',
            description: '展示未处理的 ScrollView 嵌套 WebView 滑动冲突问题',
            icon: Icons.warning,
            iconColor: Colors.orange,
            onTap: () => _navigateToCase(context, const DefaultScrollConflictCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: '手势拦截解决方案',
            description: '使用手势拦截和 NotificationListener 解决滑动冲突',
            icon: Icons.gesture,
            iconColor: Colors.green,
            onTap: () => _navigateToCase(context, const GestureInterceptionCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: 'Physics 控制方案',
            description: '通过动态控制滚动物理效果解决冲突',
            icon: Icons.settings_input_component,
            iconColor: Colors.blue,
            onTap: () => _navigateToCase(context, const PhysicsControlCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: '自定义滚动行为',
            description: '实现自定义滚动行为来处理嵌套滚动',
            icon: Icons.tune,
            iconColor: Colors.purple,
            onTap: () => _navigateToCase(context, const CustomScrollBehaviorCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: '混合解决方案',
            description: '综合多种技术的混合解决方案',
            icon: Icons.merge_type,
            iconColor: Colors.teal,
            onTap: () => _navigateToCase(context, const HybridSolutionCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: '动态高度方案',
            description: '获取 WebView 内容高度，设置给 WebView 容器实现真正滚动',
            icon: Icons.height,
            iconColor: Colors.deepPurple,
            onTap: () => _navigateToCase(context, const DynamicHeightCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: '安全动态高度',
            description: '加强版动态高度方案，限制最大高度防止 crash',
            icon: Icons.security,
            iconColor: Colors.green,
            onTap: () => _navigateToCase(context, const SafeDynamicHeightCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: '简单动态高度',
            description: '最简单的动态高度方案，直接使用 evaluateJavascript',
            icon: Icons.flash_on,
            iconColor: Colors.amber,
            onTap: () => _navigateToCase(context, const SimpleDynamicHeightCasePage()),
          ),
          
          _buildCaseCard(
            context,
            title: 'Sliver 嵌套方案',
            description: '参考 extended_sliver 的思路，外层控制内层滚动',
            icon: Icons.layers,
            iconColor: Colors.indigo,
            onTap: () => _navigateToCase(context, const SliverNestedCasePage()),
          ),
        ],
      ),
    );
  }

  /// 构建案例卡片
  Widget _buildCaseCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  /// 导航到具体的实验页面
  void _navigateToCase(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}