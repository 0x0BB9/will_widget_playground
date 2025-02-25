import 'package:flutter/material.dart';
import 'package:will_widget_playground/case/button_case_pages.dart';
import 'package:will_widget_playground/case/container_with_bg_case_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DemoHomePage(),
    );
  }
}

// 主页组件
class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  // 示例数据列表
  final List<DemoItem> _demos = [
    DemoItem(
      title: "按钮合集",
      description: "包含各种按钮样式和交互",
      pageBuilder: (context) => ButtonExamplesPage(),
    ),
    DemoItem(
      title: "复杂的背景",
      description: "多种复杂背景效果展示",
      pageBuilder: (context) => ContainerWithBgCasePages(),
    ),
    // 后续添加更多示例...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Widget 实验室"),
      ),
      body: ListView.builder(
        itemCount: _demos.length,
        itemBuilder: (context, index) => _buildDemoItem(_demos[index]),
      ),
    );
  }

  // 列表项组件
  Widget _buildDemoItem(DemoItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.widgets, color: Colors.blue),
        title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.description),
        trailing: Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: item.pageBuilder),
        ),
      ),
    );
  }
}

// 示例数据模型
class DemoItem {
  final String title;
  final String description;
  final WidgetBuilder pageBuilder;

  DemoItem({
    required this.title,
    required this.description,
    required this.pageBuilder,
  });
}
