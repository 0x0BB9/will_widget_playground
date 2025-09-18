import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:will_widget_playground/case/button_case_pages.dart';
import 'package:will_widget_playground/case/container_with_bg_case_pages.dart';
import 'package:will_widget_playground/case/device_info_page.dart';
import 'package:will_widget_playground/case/slider_pages.dart';
import 'package:will_widget_playground/case/stepper_case_pages.dart';
import 'package:will_widget_playground/case/text_field_pages.dart';
import 'package:will_widget_playground/splash/splash_widget.dart';

import 'case/currency_case_pages.dart';
import 'case/image_case_pages.dart';
import 'case/text_pages.dart';
import 'case/webview_scroll_case_pages.dart';
import 'case/minimizable_dialog_page.dart';
import 'case/getx_dialog_page.dart';
import 'case/long_form_keyboard_scroll_page.dart';

void main() {
  //使用 DebugPaintSizeEnabled 显示组件边界：
  debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimPageTransitionsBuilder(),
          },
        ),
      ),
      home: SplashWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NoAnimPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
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
      title: "智能键盘滚动表单",
      description: "长表单页面，点击输入框时智能滚动，确保当前和下一个输入框都可见",
      pageBuilder: (context) => LongFormKeyboardScrollPage(),
    ),
    DemoItem(
      title: "WebView 滑动冲突",
      description: "实验 ScrollView 中嵌套 WebView 的滑动冲突问题",
      pageBuilder: (context) => WebViewScrollCasePage(),
    ),
    DemoItem(
      title: "复杂的背景",
      description: "多种复杂背景效果展示",
      pageBuilder: (context) => ContainerWithBgCasePages(),
    ),
    DemoItem(
      title: "图片加载",
      description: "图片增加蒙版效果",
      pageBuilder: (context) => ImageExamplesPage(),
    ),
    DemoItem(
      title: "输入框合集",
      description: "包含各种样式和交互",
      pageBuilder: (context) => TextFieldPages(),
    ),
    DemoItem(
      title: "Text合集",
      description: "WhyNotText",
      pageBuilder: (context) => TextPages(),
    ),
    DemoItem(
      title: "滑块合集",
      description: "WhyNotSlider",
      pageBuilder: (context) => SliderExamplePage(),
    ),
    DemoItem(
      title: "步骤合集",
      description: "WhyNotStepper",
      pageBuilder: (context) => StepperExamplesPage(),
    ),
    DemoItem(
      title: "货币格式化",
      description: "WhyNotCurrencyFormat",
      pageBuilder: (context) => CurrencyExamplesPage(),
    ),
    DemoItem(
      title: "设备指纹",
      description: " Allow user to get device fingerprint",
      pageBuilder: (context) => DeviceInfoPage(),
    ),
    DemoItem(
      title: "GetX 可最小化弹窗",
      description: "演示使用 GetX 管理的弹窗收缩到悬浮按钮并可重新展开的交互效果",
      pageBuilder: (context) => MinimizableDialogPage(),
    ),
    DemoItem(
      title: "GetX 收缩弹窗",
      description: "使用 GetX 实现点击 FAB 弹出对话框，关闭时收缩回 FAB 的动画效果",
      pageBuilder: (context) => GetXDialogPage(),
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
