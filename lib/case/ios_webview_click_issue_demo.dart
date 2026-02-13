import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// iOS WebView 点击问题复现 Demo
/// 
/// 问题描述：
/// 在 iOS 18.2 beta 及后续版本中，当页面先触发 Flutter widget（如 Drawer、ContextMenu）
/// 后，WKWebView 内的点击事件（链接、按钮）不再响应（可高亮但不激活），
/// 需要重新加载 WebView 才能恢复。
/// 
/// 测试步骤：
/// 1. 运行此页面
/// 2. 点击 WebView 中的链接/按钮，确认正常工作
/// 3. 点击右上角菜单按钮打开 Drawer
/// 4. 关闭 Drawer
/// 5. 再次点击 WebView 中的链接/按钮，观察是否失效
class IOSWebViewClickIssueDemo extends StatefulWidget {
  const IOSWebViewClickIssueDemo({super.key});

  @override
  State<IOSWebViewClickIssueDemo> createState() => _IOSWebViewClickIssueDemoState();
}

class _IOSWebViewClickIssueDemoState extends State<IOSWebViewClickIssueDemo> {
  late final WebViewController _controller;
  bool _webViewInteractionEnabled = true;
  String _lastAction = '初始状态';
  int _testStep = 0;

  @override
  void initState() {
    super.initState();
    
    // 初始化 WebView 控制器
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _lastAction = '页面开始加载: $url';
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _lastAction = '页面加载完成: $url';
              _webViewInteractionEnabled = true;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // 记录导航请求
            setState(() {
              _lastAction = '尝试导航到: ${request.url}';
            });
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_getTestHtmlContent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS WebView 点击问题测试'),
        backgroundColor: _webViewInteractionEnabled 
          ? Colors.blue 
          : Colors.red.shade300,
        actions: [
          // 测试用的 Overlay 触发按钮
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'reload',
                child: Text('🔄 重新加载 WebView'),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Text('🔄 重置测试状态'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'drawer',
                child: Text('🧭 打开抽屉 (Drawer)'),
              ),
              const PopupMenuItem(
                value: 'dialog',
                child: Text('💬 显示对话框 (Dialog)'),
              ),
              const PopupMenuItem(
                value: 'context_menu',
                child: Text('🖱️ 长按上下文菜单'),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildTestDrawer(),
      body: Column(
        children: [
          // 测试状态指示器
          _buildStatusIndicator(),
          
          // 测试说明
          _buildTestInstructions(),
          
          // WebView 区域
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
      // 长按触发上下文菜单测试
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContextMenuTest();
        },
        child: const Icon(Icons.touch_app),
        tooltip: '长按测试上下文菜单',
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: _webViewInteractionEnabled 
        ? Colors.green.shade100 
        : Colors.red.shade100,
      child: Row(
        children: [
          Icon(
            _webViewInteractionEnabled ? Icons.check_circle : Icons.error,
            color: _webViewInteractionEnabled 
              ? Colors.green 
              : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _webViewInteractionEnabled 
                ? 'WebView 点击功能正常 ✅' 
                : 'WebView 点击功能可能失效 ⚠️',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _webViewInteractionEnabled 
                  ? Colors.green 
                  : Colors.red,
              ),
            ),
          ),
          Text(
            '步骤: $_testStep',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建测试说明
  Widget _buildTestInstructions() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔍 测试步骤',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('1. 确认 WebView 中链接可正常点击'),
            const Text('2. 点击右上角菜单触发 Flutter Overlay'),
            const Text('3. 关闭 Overlay 后再次测试 WebView 点击'),
            const Text('4. 如点击失效，请点击AppBar菜单重新加载WebView'),
            const SizedBox(height: 12),
            Text(
              '最后操作: $_lastAction',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建测试用的抽屉
  Widget _buildTestDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              '测试抽屉 (Drawer)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('重新加载 WebView'),
            onTap: () {
              Navigator.pop(context);
              _reloadWebView();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('查看问题说明'),
            onTap: () {
              Navigator.pop(context);
              _showProblemInfo();
            },
          ),
        ],
      ),
    );
  }

  /// 处理菜单动作
  void _handleMenuAction(String action) {
    switch (action) {
      case 'reload':
        _reloadWebView();
        break;
      case 'reset':
        _resetTest();
        break;
      case 'drawer':
        Scaffold.of(context).openDrawer();
        setState(() {
          _lastAction = '打开了抽屉 (Drawer)';
          _testStep = 2;
        });
        break;
      case 'dialog':
        _showTestDialog();
        setState(() {
          _lastAction = '显示了对话框 (Dialog)';
          _testStep = 2;
        });
        break;
      case 'context_menu':
        _showContextMenuTest();
        setState(() {
          _lastAction = '触发了上下文菜单';
          _testStep = 2;
        });
        break;
    }
  }

  /// 重新加载 WebView
  void _reloadWebView() {
    setState(() {
      _webViewInteractionEnabled = false;
      _lastAction = '正在重新加载 WebView...';
    });
    _controller.loadHtmlString(_getTestHtmlContent());
  }

  /// 重置测试状态
  void _resetTest() {
    setState(() {
      _webViewInteractionEnabled = true;
      _lastAction = '测试已重置';
      _testStep = 0;
    });
  }

  /// 显示测试对话框
  void _showTestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('测试对话框'),
          content: const Text('这是用来测试 Overlay 的对话框。点击确认后关闭对话框，然后测试 WebView 点击功能。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _lastAction = '关闭了对话框';
                });
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  /// 显示上下文菜单测试
  void _showContextMenuTest() {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + 100,
        position.dy + 100,
        position.dx + 100,
        position.dy + 100,
      ),
      items: [
        const PopupMenuItem(
          value: 'item1',
          child: Text('上下文菜单项 1'),
        ),
        const PopupMenuItem(
          value: 'item2',
          child: Text('上下文菜单项 2'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _lastAction = '选择了上下文菜单项: $value';
        });
      }
    });
  }

  /// 显示问题说明
  void _showProblemInfo() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📱 iOS WebView 点击问题说明',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text('问题版本：iOS 18.2 beta 及后续版本'),
              const SizedBox(height: 8),
              const Text('问题现象：'),
              const Text('- WebView 中元素可高亮但无法激活'),
              const Text('- 点击链接、按钮无响应'),
              const Text('- 需要重新加载 WebView 才能恢复'),
              const SizedBox(height: 12),
              const Text('触发条件：'),
              const Text('- 先触发 Flutter Overlay（Drawer、Dialog、ContextMenu 等）'),
              const Text('- 然后返回 WebView 进行点击操作'),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 获取测试用的 HTML 内容
  String _getTestHtmlContent() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>WebView 点击测试页面</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                margin: 0;
                padding: 20px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                color: white;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 15px;
                padding: 25px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            }
            h1 {
                text-align: center;
                margin-bottom: 30px;
                font-size: 28px;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            }
            .test-section {
                margin: 25px 0;
                padding: 20px;
                background: rgba(255, 255, 255, 0.15);
                border-radius: 12px;
                border-left: 4px solid #fff;
            }
            .test-button {
                display: block;
                width: 100%;
                padding: 15px;
                margin: 10px 0;
                background: linear-gradient(45deg, #ff6b6b, #ffa500);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 18px;
                font-weight: bold;
                text-align: center;
                cursor: pointer;
                transition: all 0.3s ease;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            }
            .test-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
            }
            .test-link {
                display: block;
                padding: 15px;
                margin: 10px 0;
                background: rgba(255, 255, 255, 0.2);
                border-radius: 8px;
                color: white;
                text-decoration: none;
                text-align: center;
                font-weight: 500;
                transition: background 0.3s ease;
            }
            .test-link:hover {
                background: rgba(255, 255, 255, 0.3);
            }
            .form-group {
                margin: 20px 0;
            }
            input, textarea {
                width: 100%;
                padding: 12px;
                border-radius: 8px;
                border: 2px solid rgba(255, 255, 255, 0.3);
                background: rgba(255, 255, 255, 0.1);
                color: white;
                font-size: 16px;
                margin-top: 8px;
                box-sizing: border-box;
            }
            input::placeholder, textarea::placeholder {
                color: rgba(255, 255, 255, 0.7);
            }
            select {
                width: 100%;
                padding: 12px;
                border-radius: 8px;
                border: 2px solid rgba(255, 255, 255, 0.3);
                background: rgba(255, 255, 255, 0.1);
                color: white;
                font-size: 16px;
                margin-top: 8px;
                box-sizing: border-box;
            }
            .checkbox-group {
                display: flex;
                align-items: center;
                margin: 15px 0;
            }
            .checkbox-group input {
                width: auto;
                margin-right: 10px;
            }
            .counter {
                text-align: center;
                font-size: 18px;
                margin: 20px 0;
                padding: 15px;
                background: rgba(255, 255, 255, 0.2);
                border-radius: 8px;
            }
            .counter-value {
                font-size: 24px;
                font-weight: bold;
                color: #ffd700;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔬 WebView 点击测试</h1>
            
            <div class="test-section">
                <h2>🔢 点击计数器</h2>
                <div class="counter">
                    当前点击次数: <span id="counter-value" class="counter-value">0</span>
                </div>
                <button class="test-button" onclick="incrementCounter()">
                    🖱️ 点击我增加计数器
                </button>
                <button class="test-button" onclick="resetCounter()" style="background: linear-gradient(45deg, #4CAF50, #8BC34A);">
                    ♻️ 重置计数器
                </button>
            </div>
            
            <div class="test-section">
                <h2>🔗 链接测试</h2>
                <a href="#section1" class="test-link" onclick="logEvent('跳转到章节1')">
                    📍 跳转到章节1
                </a>
                <a href="#section2" class="test-link" onclick="logEvent('跳转到章节2')">
                    📍 跳转到章节2
                </a>
                <a href="javascript:alert('这是一个JavaScript弹窗！')" class="test-link" onclick="logEvent('触发JavaScript弹窗')">
                    ⚡ 触发JavaScript弹窗
                </a>
            </div>
            
            <div class="test-section">
                <h2>📝 表单测试</h2>
                <div class="form-group">
                    <label>文本输入框:</label>
                    <input type="text" placeholder="请输入文本..." onfocus="logEvent('文本框获得焦点')" onblur="logEvent('文本框失去焦点')">
                </div>
                <div class="form-group">
                    <label>下拉选择框:</label>
                    <select onchange="logEvent('选择了选项: ' + this.value)">
                        <option value="">请选择...</option>
                        <option value="option1">选项1</option>
                        <option value="option2">选项2</option>
                        <option value="option3">选项3</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>多行文本框:</label>
                    <textarea placeholder="请输入多行文本..." rows="3" onfocus="logEvent('文本域获得焦点')" onblur="logEvent('文本域失去焦点')"></textarea>
                </div>
                <div class="checkbox-group">
                    <input type="checkbox" id="test-checkbox" onchange="logEvent('复选框状态: ' + (this.checked ? '选中' : '未选中'))">
                    <label for="test-checkbox">测试复选框</label>
                </div>
            </div>
            
            <div class="test-section">
                <h2>🎨 样式交互测试</h2>
                <button class="test-button" onclick="changeBackgroundColor()" style="background: linear-gradient(45deg, #9c27b0, #e91e63);">
                    🎨 改变背景颜色
                </button>
                <button class="test-button" onclick="toggleVisibility()" style="background: linear-gradient(45deg, #00bcd4, #009688);">
                    👁️ 切换元素可见性
                </button>
            </div>
            
            <div id="section1" class="test-section">
                <h2>📑 章节1</h2>
                <p>这是章节1的内容。点击上面的链接可以跳转到这里。</p>
                <button class="test-button" onclick="logEvent('章节1按钮被点击')" style="background: linear-gradient(45deg, #ff9800, #ff5722);">
                    章节1测试按钮
                </button>
            </div>
            
            <div id="section2" class="test-section">
                <h2>📑 章节2</h2>
                <p>这是章节2的内容。点击上面的链接可以跳转到这里。</p>
                <button class="test-button" onclick="logEvent('章节2按钮被点击')" style="background: linear-gradient(45deg, #795548, #607d8b);">
                    章节2测试按钮
                </button>
            </div>
        </div>

        <script>
            let counter = 0;
            
            function incrementCounter() {
                counter++;
                document.getElementById('counter-value').textContent = counter;
                logEvent('计数器增加到: ' + counter);
            }
            
            function resetCounter() {
                counter = 0;
                document.getElementById('counter-value').textContent = counter;
                logEvent('计数器已重置');
            }
            
            function changeBackgroundColor() {
                const colors = ['#667eea', '#764ba2', '#f093fb', '#f5576c', '#4facfe', '#00f2fe'];
                const randomColor = colors[Math.floor(Math.random() * colors.length)];
                document.body.style.background = 'linear-gradient(135deg, ' + randomColor + ' 0%, ' + 
                    colors[(colors.indexOf(randomColor) + 1) % colors.length] + ' 100%)';
                logEvent('背景颜色已改变');
            }
            
            function toggleVisibility() {
                const sections = document.querySelectorAll('.test-section');
                sections.forEach(section => {
                    section.style.display = section.style.display === 'none' ? 'block' : 'none';
                });
                logEvent('元素可见性已切换');
            }
            
            function logEvent(message) {
                console.log('[WebView Event] ' + message);
                // 可以通过 Flutter 通道发送消息给原生端
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler('webviewEvent', message);
                }
            }
            
            // 页面加载完成时的提示
            document.addEventListener('DOMContentLoaded', function() {
                logEvent('WebView页面加载完成');
            });
        </script>
    </body>
    </html>
    ''';
  }
}