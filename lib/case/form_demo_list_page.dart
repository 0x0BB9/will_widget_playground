import 'package:flutter/material.dart';
import 'form_demo_cases.dart';

/// 表单演示列表页面
class FormDemoListPage extends StatelessWidget {
  const FormDemoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('表单演示'),
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
                    '表单演示说明',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '本模块包含各种表单组件的使用示例，包括基础表单、验证表单、'
                    '复杂表单布局、表单状态管理等实用案例，帮助开发者快速掌握Flutter表单开发。',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 表单案例列表
          _buildFormCard(
            context,
            title: '基础表单',
            description: '包含常用的输入框、下拉选择、开关等基础表单组件',
            icon: Icons.edit,
            iconColor: Colors.blue,
            onTap: () => _navigateToCase(context, const BasicFormCasePage()),
          ),
          
          _buildFormCard(
            context,
            title: '表单验证',
            description: '演示表单验证规则、错误提示、实时验证等功能',
            icon: Icons.verified,
            iconColor: Colors.green,
            onTap: () => _navigateToCase(context, const FormValidationCasePage()),
          ),

          _buildFormCard(
            context,
            title: '长表单智能滚动',
            description: '输入框获取焦点时自动滚动到屏幕可见区域50%居中位置',
            icon: Icons.keyboard_arrow_down,
            iconColor: Colors.deepPurple,
            onTap: () => _navigateToCase(context, const LongFormCasePage()),
          ),

          _buildFormCard(
            context,
            title: 'auto_scroll_to_error',
            description: 'A Flutter widget that improves form UX by automatically scrolling a scrollable form to the first invalid field when validation fails.',
            icon: Icons.keyboard_arrow_down,
            iconColor: Colors.deepPurple,
            onTap: () => _navigateToCase(context, const ErrorScrollForm()),
          ),

          _buildFormCard(
            context,
            title: 'ensure_visible_when_focused package',
            description: 'ensure-a-textfield-or-textformfield-is-visible-in-the-viewport-when-has-the-focus',
            icon: Icons.keyboard_arrow_down,
            iconColor: Colors.deepPurple,
            onTap: () => _navigateToCase(context, const EnsureVisibleWhenFocusedPage()),
          ),

          _buildFormCard(
            context,
            title: '复杂表单布局',
            description: '展示分组表单、多步骤表单、动态表单等复杂布局',
            icon: Icons.view_module,
            iconColor: Colors.orange,
            onTap: () => _navigateToCase(context, const ComplexFormCasePage()),
          ),
          
          _buildFormCard(
            context,
            title: '表单状态管理',
            description: '演示表单数据管理、状态保存、数据恢复等功能',
            icon: Icons.storage,
            iconColor: Colors.purple,
            onTap: () => _navigateToCase(context, const FormStateCasePage()),
          ),
          
          _buildFormCard(
            context,
            title: '自定义表单组件',
            description: '展示自定义输入组件、复合组件、特殊交互组件',
            icon: Icons.widgets,
            iconColor: Colors.teal,
            onTap: () => _navigateToCase(context, const CustomFormCasePage()),
          ),
          
          _buildFormCard(
            context,
            title: '响应式表单',
            description: '演示响应式表单设计、适配不同屏幕尺寸的表单布局',
            icon: Icons.devices,
            iconColor: Colors.indigo,
            onTap: () => _navigateToCase(context, const ResponsiveFormCasePage()),
          ),
        ],
      ),
    );
  }

  /// 构建表单案例卡片
  Widget _buildFormCard(
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

  /// 导航到具体的表单演示页面
  void _navigateToCase(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}