import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async'; // 添加 Timer 导入

/// 默认滑动冲突案例页面
class DefaultScrollConflictCasePage extends StatefulWidget {
  const DefaultScrollConflictCasePage({super.key});

  @override
  State<DefaultScrollConflictCasePage> createState() => _DefaultScrollConflictCasePageState();
}

class _DefaultScrollConflictCasePageState extends State<DefaultScrollConflictCasePage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 更新加载进度
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(_generateTestHtml());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('默认滑动冲突'),
        backgroundColor: Colors.orange[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部说明区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        '滑动冲突演示',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '这里展示了未处理的滑动冲突问题：\n'
                    '• 尝试在 WebView 区域内滑动\n'
                    '• 观察外层 ScrollView 和内层 WebView 的滑动冲突\n'
                    '• 注意滑动手势可能被错误处理',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),

            // 一些外层内容
            ...List.generate(3, (index) => Container(
              height: 100,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Center(
                child: Text(
                  '外层内容区域 ${index + 1}\n尝试在这里滑动',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )),

            // WebView 区域
            Container(
              height: 400,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    // WebView 标题栏
                    Container(
                      height: 40,
                      color: Colors.orange[200],
                      child: const Center(
                        child: Text(
                          'WebView 区域 (存在滑动冲突)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // WebView 内容
                    Expanded(
                      child: Stack(
                        children: [
                          WebViewWidget(controller: _webViewController),
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 更多外层内容
            ...List.generate(5, (index) => Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Center(
                child: Text(
                  '底部内容区域 ${index + 1}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )),

            // 测试说明
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        '测试建议',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. 先在外层区域滑动，观察正常滑动行为\n'
                    '2. 在 WebView 区域内尝试滑动网页内容\n'
                    '3. 观察是否出现滑动冲突或不期望的行为\n'
                    '4. 尝试从 WebView 边缘开始滑动\n'
                    '5. 对比其他解决方案的效果',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('滑动冲突说明'),
        content: const Text(
          '当 ScrollView 中嵌套 WebView 时，可能出现以下问题：\n\n'
          '1. 手势冲突：外层和内层都响应滑动手势\n'
          '2. 滑动方向混乱：垂直滑动可能触发水平滑动\n'
          '3. 滑动中断：滑动过程中突然停止或跳跃\n'
          '4. 滑动范围错误：滑动超出预期范围\n\n'
          '这个页面展示了未处理的原始冲突状态。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _generateTestHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>滑动测试页面</title>
        <style>
            body {
                margin: 0;
                padding: 20px;
                font-family: Arial, sans-serif;
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            }
            .header {
                background: #4CAF50;
                color: white;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
                text-align: center;
            }
            .content-section {
                background: white;
                margin: 10px 0;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                min-height: 100px;
            }
            .scroll-indicator {
                background: #FF9800;
                color: white;
                padding: 10px;
                border-radius: 4px;
                margin: 10px 0;
                text-align: center;
            }
            .conflict-demo {
                background: #f44336;
                color: white;
                padding: 15px;
                border-radius: 8px;
                margin: 20px 0;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h2>WebView 滑动测试页面</h2>
            <p>在这里尝试各种滑动操作</p>
        </div>
        
        <div class="conflict-demo">
            <h3>⚠️ 滑动冲突区域</h3>
            <p>在这个区域内滑动可能会遇到冲突问题</p>
        </div>
        
        <div class="scroll-indicator">
            📱 向下滚动查看更多内容
            <p>在这个区域内滑动可能会遇到冲突问题</p>
        </div>
        
        ${List.generate(20, (index) => '''
        <div class="content-section">
            <h3>内容区块 ${index + 1}</h3>
            <p>这是第 ${index + 1} 个内容区块。尝试在这里进行滑动操作，观察是否出现滑动冲突。</p>
            <p>滑动冲突通常表现为：滑动不流畅、意外停止、或者触发了错误的滑动方向。</p>
            ${index % 3 == 0 ? '''
            <div style="background: #e3f2fd; padding: 10px; border-radius: 4px; margin-top: 10px;">
                <strong>测试点 ${(index ~/ 3) + 1}:</strong> 尝试从这里开始滑动，观察滑动行为是否符合预期。
            </div>
            ''' : ''}
        </div>
        ''').join('')}
        
        <div class="scroll-indicator">
            🎯 滑动测试完成
        </div>
        
        <div class="content-section">
            <h3>测试总结</h3>
            <p>如果您在滑动过程中遇到了问题，这就是典型的滑动冲突现象。</p>
            <p>请返回上级页面，尝试其他解决方案。</p>
        </div>
    </body>
    </html>
    ''';
  }
}

/// 手势拦截解决方案案例页面
class GestureInterceptionCasePage extends StatefulWidget {
  const GestureInterceptionCasePage({super.key});

  @override
  State<GestureInterceptionCasePage> createState() => _GestureInterceptionCasePageState();
}

class _GestureInterceptionCasePageState extends State<GestureInterceptionCasePage> {
  late final WebViewController _webViewController;
  final ScrollController _outerScrollController = ScrollController();
  bool _isLoading = true;
  bool _canWebViewScrollUp = false;
  bool _canWebViewScrollDown = false;
  bool _isWebViewScrolling = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _updateWebViewScrollState();
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final data = message.message.split(',');
          if (data.length >= 2) {
            setState(() {
              _canWebViewScrollUp = data[0] == 'true';
              _canWebViewScrollDown = data[1] == 'true';
            });
          }
        },
      )
      ..loadHtmlString(_generateScrollTestHtml());
  }

  void _updateWebViewScrollState() {
    _webViewController.runJavaScript('''
      function updateScrollState() {
        const canScrollUp = window.pageYOffset > 0;
        const canScrollDown = window.pageYOffset < (document.body.scrollHeight - window.innerHeight);
        FlutterChannel.postMessage(canScrollUp + ',' + canScrollDown);
      }
      
      updateScrollState();
      
      let scrollTimeout;
      window.addEventListener('scroll', function() {
        clearTimeout(scrollTimeout);
        scrollTimeout = setTimeout(updateScrollState, 10);
      }, { passive: true });
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手势拦截解决方案'),
        backgroundColor: Colors.green[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // 监听外层滚动事件
          return false;
        },
        child: SingleChildScrollView(
          controller: _outerScrollController,
          physics: _isWebViewScrolling 
              ? const NeverScrollableScrollPhysics() 
              : const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 顶部内容区域
              _buildTopContent(),
              
              // WebView 区域
              _buildWebViewSection(),
              
              // 底部内容区域
              _buildBottomContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.green[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    '手势拦截解决方案',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '状态监控: WebView 可向上滚动: $_canWebViewScrollUp, 可向下滚动: $_canWebViewScrollDown',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 4),
              const Text(
                '• WebView 内部可滚动时，手势由 WebView 处理\n'
                '• WebView 滚动到边界时，手势传递给外层 ScrollView\n'
                '• 实现了智能的滚动边界检测和手势协调',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        
        ...List.generate(3, (index) => Container(
          height: 100,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Center(
            child: Text(
              '外层内容区域 ${index + 1}\n(手势拦截版本)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWebViewSection() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // WebView 标题栏
            Container(
              height: 40,
              color: Colors.green[200],
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(
                    'WebView 区域 (手势拦截)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_canWebViewScrollUp)
                    Icon(Icons.keyboard_arrow_up, color: Colors.green[700], size: 20),
                  if (_canWebViewScrollDown)
                    Icon(Icons.keyboard_arrow_down, color: Colors.green[700], size: 20),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // WebView 内容
            Expanded(
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isWebViewScrolling = true;
                  });
                },
                onPanUpdate: (details) {
                  final dy = details.delta.dy;
                  
                  // 向上滑动 (dy < 0) 且 WebView 不能再向上滚动时，交给外层
                  if (dy < 0 && !_canWebViewScrollUp) {
                    setState(() {
                      _isWebViewScrolling = false;
                    });
                    
                    // 触发外层滚动
                    final currentOffset = _outerScrollController.offset;
                    final newOffset = currentOffset - dy;
                    _outerScrollController.animateTo(
                      newOffset.clamp(0.0, _outerScrollController.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                  }
                  
                  // 向下滑动 (dy > 0) 且 WebView 不能再向下滚动时，交给外层
                  else if (dy > 0 && !_canWebViewScrollDown) {
                    setState(() {
                      _isWebViewScrolling = false;
                    });
                    
                    // 触发外层滚动
                    final currentOffset = _outerScrollController.offset;
                    final newOffset = currentOffset - dy;
                    _outerScrollController.animateTo(
                      newOffset.clamp(0.0, _outerScrollController.position.maxScrollExtent),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                  }
                },
                onPanEnd: (details) {
                  setState(() {
                    _isWebViewScrolling = false;
                  });
                },
                child: Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Column(
      children: [
        ...List.generate(5, (index) => Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Center(
            child: Text(
              '底部内容区域 ${index + 1}\n(手势拦截版本)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        )),
        
        // 测试说明
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '解决方案原理',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '1. 通过 JavaScript 实时监控 WebView 的滚动状态\n'
                '2. 使用 GestureDetector 拦截 WebView 的手势事件\n'
                '3. 根据滚动方向和边界状态决定手势的处理方\n'
                '4. 动态控制外层 ScrollView 的滚动物理效果\n'
                '5. 实现平滑的滚动切换和边界检测',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手势拦截解决方案'),
        content: const Text(
          '本解决方案的核心思路：\n\n'
          '1. 实时监控 WebView 滚动状态\n'
          '2. 拦截并分析手势方向\n'
          '3. 智能决定手势处理方\n'
          '4. 实现流畅的滚动切换\n\n'
          '优点：响应灵敏，用户体验好\n'
          '缺点：实现复杂，需要精确的边界检测',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _generateScrollTestHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>手势拦截滑动测试</title>
        <style>
            body {
                margin: 0;
                padding: 20px;
                font-family: Arial, sans-serif;
                background: linear-gradient(135deg, #e8f5e8 0%, #c8e6c9 100%);
            }
            .header {
                background: #4CAF50;
                color: white;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
                text-align: center;
            }
            .content-section {
                background: white;
                margin: 10px 0;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                min-height: 100px;
                border-left: 4px solid #4CAF50;
            }
            .scroll-indicator {
                background: #2E7D32;
                color: white;
                padding: 10px;
                border-radius: 4px;
                margin: 10px 0;
                text-align: center;
            }
            .gesture-demo {
                background: #1B5E20;
                color: white;
                padding: 15px;
                border-radius: 8px;
                margin: 20px 0;
            }
            .scroll-status {
                position: fixed;
                top: 10px;
                right: 10px;
                background: rgba(0,0,0,0.8);
                color: white;
                padding: 10px;
                border-radius: 4px;
                font-size: 12px;
                z-index: 1000;
            }
        </style>
    </head>
    <body>
        <div class="scroll-status" id="scrollStatus">
            滚动位置: 0px
        </div>
        
        <div class="header">
            <h2>🎯 手势拦截测试页面</h2>
            <p>智能滚动边界检测</p>
        </div>
        
        <div class="gesture-demo">
            <h3>✨ 手势拦截区域</h3>
            <p>在这个区域内的滚动会被智能处理，边界时自动切换到外层滚动</p>
        </div>
        
        <div class="gesture-demo">
            <h3>✨ 手势拦截区域</h3>
            <p>在这个区域内的滚动会被智能处理，边界时自动切换到外层滚动</p>
        </div>
        
        <div class="scroll-indicator">
            📱 向下滚动测试边界检测
        </div>
        
        ${List.generate(25, (index) => '''
        <div class="content-section">
            <h3>📄 内容区块 ${index + 1}</h3>
            <p>这是第 ${index + 1} 个内容区块，用于测试手势拦截功能。</p>
            <p>手势拦截解决方案会智能判断滚动方向和边界状态：</p>
            <ul>
                <li><strong>向上滚动</strong>：到达顶部时自动切换到外层</li>
                <li><strong>向下滚动</strong>：到达底部时自动切换到外层</li>
                <li><strong>中间滚动</strong>：保持在 WebView 内部处理</li>
            </ul>
            ${index % 4 == 0 ? '''
            <div style="background: #f1f8e9; padding: 15px; border-radius: 4px; margin-top: 10px; border-left: 4px solid #8bc34a;">
                <strong>🔍 测试点 ${(index ~/ 4) + 1}:</strong> 尝试在这里进行各种方向的滚动，观察手势是否被正确处理。注意观察右上角的滚动状态和 WebView 标题栏的箭头指示器。
            </div>
            ''' : ''}
        </div>
        ''').join('')}
        
        <div class="scroll-indicator">
            🎯 到达底部 - 继续向下滑动将切换到外层
        </div>
        
        <div class="content-section">
            <h3>📊 测试完成</h3>
            <p>如果手势拦截功能正常工作，您应该体验到：</p>
            <ul>
                <li>WebView 内部滚动流畅自然</li>
                <li>边界处平滑切换到外层滚动</li>
                <li>没有滚动冲突或卡顿现象</li>
                <li>滚动状态指示器实时更新</li>
            </ul>
        </div>
        
        <script>
            function updateScrollStatus() {
                const scrollTop = window.pageYOffset;
                const scrollHeight = document.body.scrollHeight;
                const windowHeight = window.innerHeight;
                const scrollStatus = document.getElementById('scrollStatus');
                
                scrollStatus.innerHTML = `滚动位置: \${scrollTop}px<br>总高度: \${scrollHeight}px<br>可视高度: \${windowHeight}px`;
            }
            
            window.addEventListener('scroll', updateScrollStatus, { passive: true });
            updateScrollStatus();
        </script>
    </body>
    </html>
    ''';
  }
}

/// 安全动态高度方案 - 限制最大高度防止crash
class SafeDynamicHeightCasePage extends StatefulWidget {
  const SafeDynamicHeightCasePage({super.key});

  @override
  State<SafeDynamicHeightCasePage> createState() => _SafeDynamicHeightCasePageState();
}

class _SafeDynamicHeightCasePageState extends State<SafeDynamicHeightCasePage> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  double _webViewHeight = 400;
  bool _isDisposed = false;
  static const double _maxHeight = 2000; // 严格高度限制
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('SafeChannel', onMessageReceived: (msg) {
        if (!_isDisposed && mounted) {
          final h = double.tryParse(msg.message) ?? 400;
          setState(() {
            _webViewHeight = h > _maxHeight ? _maxHeight : h;
            _isLoading = false;
          });
        }
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) => _webViewController?.runJavaScript(
          'SafeChannel.postMessage(Math.min(document.body.scrollHeight, $_maxHeight).toString())'
        ),
      ))
      ..loadHtmlString('''
      <!DOCTYPE html>
      <html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"></head>
      <body style="margin:0;padding:20px;font-family:Arial;">
        <h1>🛡️ 安全动态高度</h1>
        <p>高度限制在${_maxHeight.toInt()}px以内，防止crash</p>
        ${List.generate(4, (i) => '<div style="padding:15px;margin:10px 0;background:#e8f5e8;border-radius:6px;"><h3>内容 ${i+1}</h3><p>测试内容</p></div>').join()}
      </body></html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('安全动态高度'), backgroundColor: Colors.green[100]),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Text('显示高度: ${_webViewHeight.toInt()}px (最大${_maxHeight.toInt()}px)', 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            height: _webViewHeight,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _webViewController == null || _isLoading
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _webViewController!),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text('✅ 安全防护：自动限制最大高度防止crash',
                      style: TextStyle(color: Colors.green[700])),
          ),
        ]),
      ),
    );
  }
}

/// Physics 控制方案案例页面
class PhysicsControlCasePage extends StatefulWidget {
  const PhysicsControlCasePage({super.key});

  @override
  State<PhysicsControlCasePage> createState() => _PhysicsControlCasePageState();
}

class _PhysicsControlCasePageState extends State<PhysicsControlCasePage> {
  late final WebViewController _webViewController;
  final ScrollController _outerScrollController = ScrollController();
  bool _isLoading = true;
  bool _webViewHasFocus = false;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      // 加载真实的第三方网页
      ..loadRequest(Uri.parse('https://flutter.dev/docs'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Physics 控制方案'),
        backgroundColor: Colors.blue[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // 当检测到嵌套滚动时，动态调整外层滚动物理效果
          if (notification.depth == 1 && _webViewHasFocus) {
            // 内层滚动时，临时禁用外层滚动
            return true; // 消费滚动事件
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _outerScrollController,
          // 使用自定义的滚动物理效果
          physics: _webViewHasFocus 
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 顶部内容区域
              _buildTopContent(),
              
              // WebView 区域
              _buildWebViewSection(),
              
              // 底部内容区域  
              _buildBottomContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings_input_component, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Physics 控制方案',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'WebView 焦点状态: ${_webViewHasFocus ? "激活" : "未激活"}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 4),
              const Text(
                '• 动态控制外层 ScrollView 的 Physics\n'
                '• WebView 获得焦点时禁用外层滚动\n'
                '• 适用于加载第三方 URL 的场景\n'
                '• 不需要 JavaScript 注入',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        
        ...List.generate(3, (index) => Container(
          height: 100,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Center(
            child: Text(
              '外层内容区域 ${index + 1}\n(Physics 控制版本)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWebViewSection() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // WebView 标题栏
            Container(
              height: 40,
              color: Colors.blue[200],
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(
                    'WebView 区域 (第三方网页)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _webViewHasFocus ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _webViewHasFocus ? '焦点' : '未激活',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // WebView 内容
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  setState(() {
                    _webViewHasFocus = true;
                  });
                },
                onPanStart: (details) {
                  setState(() {
                    _webViewHasFocus = true;
                  });
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // 检测到 WebView 内的滚动结束时，重新启用外层滚动
                    if (notification is ScrollEndNotification) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() {
                            _webViewHasFocus = false;
                          });
                        }
                      });
                    }
                    return false;
                  },
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _webViewController),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      // 透明的点击检测层
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _webViewHasFocus = true;
                            });
                          },
                          onPanDown: (details) {
                            setState(() {
                              _webViewHasFocus = true;
                            });
                          },
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Column(
      children: [
        // 点击区域用于重置焦点
        GestureDetector(
          onTap: () {
            setState(() {
              _webViewHasFocus = false;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '点击这里重置 WebView 焦点状态，恢复外层滚动',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...List.generate(5, (index) => Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Center(
            child: Text(
              '底部内容区域 ${index + 1}\n(Physics 控制版本)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        )),
        
        // 解决方案说明
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.indigo[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Physics 控制方案优势',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '✅ 适用于第三方 URL，无需 JavaScript 注入\n'
                '✅ 实现简单，性能开销小\n'
                '✅ 通过焦点状态控制滚动物理效果\n'
                '✅ 用户体验相对自然\n\n'
                '⚠️ 需要用户主动操作来切换焦点状态\n'
                '⚠️ 可能需要额外的 UI 提示',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Physics 控制方案'),
        content: const Text(
          '本方案通过动态控制滚动物理效果来解决冲突：\n\n'
          '1. 监听 WebView 的交互状态\n'
          '2. WebView 激活时禁用外层滚动\n'
          '3. 滚动结束后自动恢复外层滚动\n'
          '4. 提供手动重置焦点的功能\n\n'
          '特别适合加载第三方网页的场景，'
          '因为不需要在网页中注入任何代码。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 自定义滚动行为案例页面
class CustomScrollBehaviorCasePage extends StatefulWidget {
  const CustomScrollBehaviorCasePage({super.key});

  @override
  State<CustomScrollBehaviorCasePage> createState() => _CustomScrollBehaviorCasePageState();
}

class _CustomScrollBehaviorCasePageState extends State<CustomScrollBehaviorCasePage> {
  late final WebViewController _webViewController;
  final ScrollController _outerScrollController = ScrollController();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      // 加载另一个第三方网页进行测试
      ..loadRequest(Uri.parse('https://pub.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义滚动行为'),
        backgroundColor: Colors.purple[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: ScrollConfiguration(
        // 使用自定义的滚动行为
        behavior: _CustomScrollBehavior(),
        child: NestedScrollView(
          controller: _outerScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _buildTopContent(),
              ),
            ];
          },
          body: Column(
            children: [
              // WebView 区域
              _buildWebViewSection(),
              
              // 底部滚动内容
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildBottomContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.purple[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, color: Colors.purple[700]),
                  const SizedBox(width: 8),
                  Text(
                    '自定义滚动行为方案',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '• 使用 NestedScrollView 实现嵌套滚动\n'
                '• 自定义 ScrollBehavior 控制滚动物理效果\n'
                '• 支持第三方 URL，无需 JavaScript\n'
                '• 更好的嵌套滚动协调',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        
        ...List.generate(2, (index) => Container(
          height: 100,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Center(
            child: Text(
              '头部内容区域 ${index + 1}\n(自定义滚动行为版本)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWebViewSection() {
    return Container(
      height: 350,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // WebView 标题栏
            Container(
              height: 40,
              color: Colors.purple[200],
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(
                    'WebView 区域 (NestedScrollView)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '嵌套滚动',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // WebView 内容
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBottomContent() {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.cyan[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyan[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.navigation, color: Colors.cyan[700]),
                const SizedBox(width: 8),
                Text(
                  '嵌套滚动区域',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '这个区域使用 NestedScrollView 实现了更好的滚动协调。\n'
              '在这里滚动会更加流畅和自然。',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 16),
      
      ...List.generate(8, (index) => Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple[200]!),
        ),
        child: Center(
          child: Text(
            '底部内容区域 ${index + 1}\n(嵌套滚动版本)',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      )),
      
      // 技术说明
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.engineering, color: Colors.teal[700]),
                const SizedBox(width: 8),
                Text(
                  '技术实现详情',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '1. NestedScrollView: 提供天然的嵌套滚动支持\n'
              '2. ScrollConfiguration: 自定义滚动物理效果\n'
              '3. SliverToBoxAdapter: 将普通 Widget 转为 Sliver\n'
              '4. 自动处理滚动边界和手势协调\n'
              '5. 支持复杂的嵌套布局结构',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    ];
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义滚动行为方案'),
        content: const Text(
          '这个方案使用 Flutter 内置的 NestedScrollView\n'
          '来实现更好的嵌套滚动支持：\n\n'
          '• 自然的滚动边界处理\n'
          '• 更好的手势协调\n'
          '• 支持复杂的布局结构\n'
          '• 适合第三方 URL\n\n'
          '这是最推荐的解决方案之一，\n'
          '因为它利用了 Flutter 的原生支持。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 自定义滚动行为类
class _CustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // 返回适合嵌套滚动的物理效果
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // 自定义滚动条样式
    return Scrollbar(
      controller: details.controller,
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    // 自定义过度滚动指示器
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Colors.purple.withOpacity(0.3),
      child: child,
    );
  }
}

/// 混合解决方案案例页面
class HybridSolutionCasePage extends StatefulWidget {
  const HybridSolutionCasePage({super.key});

  @override
  State<HybridSolutionCasePage> createState() => _HybridSolutionCasePageState();
}

class _HybridSolutionCasePageState extends State<HybridSolutionCasePage> {
  late final WebViewController _webViewController;
  final ScrollController _outerScrollController = ScrollController();
  bool _isLoading = true;
  bool _webViewHasFocus = false;
  bool _isWebViewInteracting = false;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      // 加载 GitHub 网页作为测试
      ..loadRequest(Uri.parse('https://integration.unnax.com/widget/reader/?sid=s_b740a1c19bab44759ad997fbd0b4af02'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('混合解决方案'),
        backgroundColor: Colors.teal[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: _HybridScrollBehavior(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // 组合多种滚动监听策略
            if (notification.depth == 1 && _isWebViewInteracting) {
              // WebView 交互时阻止外层滚动传播
              return true;
            }
            return false;
          },
          child: NestedScrollView(
            controller: _outerScrollController,
            // 动态调整物理效果
            physics: _getAdaptiveScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildTopContent(),
                ),
              ];
            },
            body: Column(
              children: [
                // WebView 区域
                _buildWebViewSection(),
                
                // 底部滚动内容
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: _buildBottomContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 自适应滚动物理效果
  ScrollPhysics _getAdaptiveScrollPhysics() {
    if (_isWebViewInteracting) {
      return const NeverScrollableScrollPhysics();
    } else if (_webViewHasFocus) {
      return const BouncingScrollPhysics(
        parent: RangeMaintainingScrollPhysics(),
      );
    } else {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }
  }

  Widget _buildTopContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[50]!, Colors.teal[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.merge_type, color: Colors.teal[700]),
                  const SizedBox(width: 8),
                  Text(
                    '混合解决方案',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '状态: WebView焦点(${_webViewHasFocus ? "是" : "否"}), 交互中(${_isWebViewInteracting ? "是" : "否"})',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 4),
              const Text(
                '🔀 综合优势：\n'
                '• NestedScrollView + 自定义 ScrollBehavior\n'
                '• 智能焦点检测 + 动态 Physics 切换\n'
                '• 多层滚动监听 + 手势事件拦截\n'
                '• 适配第三方 URL + 极佳用户体验',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        
        ...List.generate(2, (index) => Container(
          height: 100,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[50]!, Colors.teal[100]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal[200]!),
          ),
          child: Center(
            child: Text(
              '头部内容区域 ${index + 1}\n(混合解决方案版本)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWebViewSection() {
    return Container(
      height: 380,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // 增强的 WebView 标题栏
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[200]!, Colors.teal[300]!],
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.web, color: Colors.teal[800]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'WebView 区域 (混合解决方案)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // 状态指示器
                  if (_isWebViewInteracting)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '交互中',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (_webViewHasFocus)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '激活',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '闲置',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // 增强的 WebView 内容
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  setState(() {
                    _webViewHasFocus = true;
                    _isWebViewInteracting = true;
                  });
                },
                onPanStart: (details) {
                  setState(() {
                    _webViewHasFocus = true;
                    _isWebViewInteracting = true;
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isWebViewInteracting = false;
                  });
                  
                  // 延时重置焦点状态
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    if (mounted) {
                      setState(() {
                        _webViewHasFocus = false;
                      });
                    }
                  });
                },
                onTapUp: (details) {
                  setState(() {
                    _isWebViewInteracting = false;
                  });
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // 更精细的滚动事件处理
                    if (notification is ScrollStartNotification) {
                      setState(() {
                        _isWebViewInteracting = true;
                      });
                    } else if (notification is ScrollEndNotification) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          setState(() {
                            _isWebViewInteracting = false;
                          });
                        }
                      });
                    }
                    return false;
                  },
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _webViewController),
                      if (_isLoading)
                        Container(
                          color: Colors.white.withOpacity(0.8),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('加载第三方网页中...'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBottomContent() {
    return [
      // 重置按钮
      GestureDetector(
        onTap: () {
          setState(() {
            _webViewHasFocus = false;
            _isWebViewInteracting = false;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[50]!, Colors.orange[100]!],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.refresh, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '点击重置 WebView 状态，恢复外层滚动',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      const SizedBox(height: 16),
      
      ...List.generate(6, (index) => Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[50]!, Colors.teal[100]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal[200]!),
        ),
        child: Center(
          child: Text(
            '底部内容区域 ${index + 1}\n(混合解决方案版本)',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      )),
      
      // 综合评估
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[50]!, Colors.indigo[100]!],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.indigo[700]),
                const SizedBox(width: 8),
                Text(
                  '混合方案综合评估',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '🏆 最佳实践组合：\n'
              '• NestedScrollView: 提供天然的嵌套滚动支持\n'
              '• 动态 Physics: 根据状态自动调整滚动物理效果\n'
              '• 智能监听: 多层次滚动事件监听和处理\n'
              '• 状态管理: 精细的焦点和交互状态跟踪\n'
              '• 用户体验: 提供直观的状态反馈和手动控制\n\n'
              '🎯 适用场景：所有类型的 WebView 嵌入场景',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    ];
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('混合解决方案'),
        content: const SingleChildScrollView(
          child: Text(
            '这是最综合的解决方案，结合了多种技术：\n\n'
            '📚 技术组合：\n'
            '1. NestedScrollView: 核心滚动容器\n'
            '2. 自定义 ScrollBehavior: 优化滚动表现\n'
            '3. 动态 ScrollPhysics: 智能切换滚动模式\n'
            '4. 多层次事件监听: 精确捕获滚动意图\n'
            '5. GestureDetector: 增强手势识别\n\n'
            '🚀 核心优势：\n'
            '• 适配所有类型的网页内容\n'
            '• 完全支持第三方 URL\n'
            '• 极佳的用户体验和流畅度\n'
            '• 可视化的状态反馈\n'
            '• 健壮的错误处理和恢复机制\n\n'
            '🎯 推荐指数: ★★★★★',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 混合解决方案的自定义滚动行为
class _HybridScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: RangeMaintainingScrollPhysics(),
    );
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(
      controller: details.controller,
      thickness: 4,
      radius: const Radius.circular(2),
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Colors.teal.withOpacity(0.4),
      child: child,
    );
  }
}

/// 动态高度方案案例页面
class DynamicHeightCasePage extends StatefulWidget {
  const DynamicHeightCasePage({super.key});

  @override
  State<DynamicHeightCasePage> createState() => _DynamicHeightCasePageState();
}

class _DynamicHeightCasePageState extends State<DynamicHeightCasePage> {
  WebViewController? _webViewController; // 改为可为空
  final ScrollController _outerScrollController = ScrollController();
  bool _isLoading = true;
  double _webViewHeight = 400; // 初始高度
  double _contentHeight = 0; // 网页内容高度
  bool _heightDetected = false;
  bool _isDisposed = false; // 添加销毁状态检查
  Timer? _heightDetectionTimer; // 添加定时器管理
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _heightDetectionTimer?.cancel(); // 取消定时器
    _outerScrollController.dispose();
    _cleanupWebView(); // 添加清理方法
    _webViewController = null; // 清空引用
    super.dispose();
  }

  void _cleanupWebView() {
    if (_webViewController == null || _isDisposed) return;
    
    try {
      _webViewController!.runJavaScript('''
        try {
          // 清理所有 Observer 和定时器
          if (window.heightResizeObserver) {
            window.heightResizeObserver.disconnect();
            window.heightResizeObserver = null;
          }
          if (window.heightMutationObserver) {
            window.heightMutationObserver.disconnect();
            window.heightMutationObserver = null;
          }
          if (window.heightDetectionTimeout) {
            clearTimeout(window.heightDetectionTimeout);
            window.heightDetectionTimeout = null;
          }
        } catch (e) {
          console.log('Cleanup error:', e);
        }
      ''').catchError((error) {
        // 忽略清理时的错误
      });
    } catch (e) {
      // 忽略清理时的错误
    }
  }

  void _initializeWebView() {
    if (_isDisposed) return;
    
    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (!_isDisposed && mounted) {
                setState(() {
                  _isLoading = true;
                  _heightDetected = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (!_isDisposed && mounted) {
                setState(() {
                  _isLoading = false;
                });
                // 延迟检测高度，等待页面完全加载
                _heightDetectionTimer = Timer(const Duration(milliseconds: 500), () {
                  if (!_isDisposed && mounted) {
                    _detectContentHeight();
                  }
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (!_isDisposed && mounted) {
                setState(() {
                  _isLoading = false;
                  _webViewHeight = 400; // 设置默认高度
                });
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'HeightChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (!_isDisposed && mounted) {
              try {
                final height = double.tryParse(message.message);
                // 严格限制高度范围，防止过大高度导致crash
                if (height != null && height >= 100 && height <= 5000) { // 限制最大高度为5000px
                  setState(() {
                    _contentHeight = height;
                    _webViewHeight = height;
                    _heightDetected = true;
                  });
                } else if (height != null && height > 5000) {
                  // 高度过大时设置为最大允许高度
                  setState(() {
                    _contentHeight = height;
                    _webViewHeight = 5000; // 限制显示高度
                    _heightDetected = true;
                  });
                }
              } catch (e) {
                // 忽略解析错误
              }
            }
          },
        );
      
      // 加载简单的本地 HTML 内容进行测试
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_isDisposed && _webViewController != null) {
          _webViewController!.loadRequest(Uri.parse('https://integration.unnax.com/widget/reader/?sid=s_b740a1c19bab44759ad997fbd0b4af02'));
        }
      });
    } catch (e) {
      // WebView 初始化失败，设置默认状态
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _webViewHeight = 400;
        });
      }
    }
  }

  void _detectContentHeight() {
    if (_isDisposed || _webViewController == null || !mounted) return;
    
    try {
      _webViewController!.runJavaScript('''
        (function() {
          try {
            // 先清理之前的 Observer
            if (window.heightResizeObserver) {
              window.heightResizeObserver.disconnect();
              window.heightResizeObserver = null;
            }
            if (window.heightMutationObserver) {
              window.heightMutationObserver.disconnect();
              window.heightMutationObserver = null;
            }
            if (window.heightDetectionTimeout) {
              clearTimeout(window.heightDetectionTimeout);
              window.heightDetectionTimeout = null;
            }
            
            // 获取文档的真实高度
            function calculateHeight() {
              const body = document.body;
              const html = document.documentElement;
              
              if (!body || !html) return 800; // 默认高度
              
              const heights = [
                body.scrollHeight || 0,
                body.offsetHeight || 0,
                html.clientHeight || 0,
                html.scrollHeight || 0,
                html.offsetHeight || 0
              ];
              
              return Math.max(...heights.filter(h => h > 0));
            }
            
            const height = calculateHeight();
            
            // 验证高度是否合理，严格限制范围
            if (height >= 100 && height <= 5000) {
              HeightChannel.postMessage(height.toString());
            } else if (height > 5000) {
              // 高度过大时传递最大允许值
              HeightChannel.postMessage('5000');
            } else {
              HeightChannel.postMessage('800'); // 默认高度
            }
            
            // 设置新的 ResizeObserver（简化版本）
            let lastHeight = height;
            
            if (window.ResizeObserver) {
              window.heightResizeObserver = new ResizeObserver(function(entries) {
                try {
                  const newHeight = calculateHeight();
                  // 只在高度变化较大时才更新，且限制范围
                  if (Math.abs(newHeight - lastHeight) > 50 && newHeight >= 100 && newHeight <= 5000) {
                    lastHeight = newHeight;
                    HeightChannel.postMessage(newHeight.toString());
                  } else if (newHeight > 5000 && lastHeight <= 5000) {
                    // 高度超过限制时只发送一次最大值
                    lastHeight = 5000;
                    HeightChannel.postMessage('5000');
                  }
                } catch (e) {
                  // 忽略错误
                }
              });
              
              const body = document.body;
              if (body) {
                window.heightResizeObserver.observe(body);
              }
            }
            
            // 设置简化的 MutationObserver
            if (window.MutationObserver) {
              window.heightMutationObserver = new MutationObserver(function(mutations) {
                try {
                  // 防抖处理
                  if (window.heightDetectionTimeout) {
                    clearTimeout(window.heightDetectionTimeout);
                  }
                  
                  window.heightDetectionTimeout = setTimeout(function() {
                    const newHeight = calculateHeight();
                    if (Math.abs(newHeight - lastHeight) > 50 && newHeight >= 100 && newHeight <= 5000) {
                      lastHeight = newHeight;
                      HeightChannel.postMessage(newHeight.toString());
                    } else if (newHeight > 5000 && lastHeight <= 5000) {
                      // 高度超过限制时只发送一次最大值
                      lastHeight = 5000;
                      HeightChannel.postMessage('5000');
                    }
                  }, 500); // 增加防抖时间
                } catch (e) {
                  // 忽略错误
                }
              });
              
              const body = document.body;
              if (body) {
                window.heightMutationObserver.observe(body, {
                  childList: true,
                  subtree: true
                  // 移除 attributes 监听减少触发频率
                });
              }
            }
            
          } catch (error) {
            console.error('Height detection error:', error);
            HeightChannel.postMessage('800'); // 发送默认高度
          }
        })();
      ''').catchError((error) {
        // JavaScript 执行失败，设置默认高度
        if (!_isDisposed && mounted) {
          setState(() {
            _webViewHeight = 800;
            _heightDetected = false;
          });
        }
      });
    } catch (e) {
      // 全局错误处理
      if (!_isDisposed && mounted) {
        setState(() {
          _webViewHeight = 800;
          _heightDetected = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态高度方案'),
        backgroundColor: Colors.deepPurple[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _detectContentHeight();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _outerScrollController,
        child: Column(
          children: [
            // 顶部内容区域
            _buildTopContent(),
            
            // 动态高度的 WebView 区域
            _buildDynamicWebViewSection(),
            
            // 底部内容区域
            _buildBottomContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.height, color: Colors.deepPurple[700]),
                  const SizedBox(width: 8),
                  Text(
                    '动态高度方案',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '内容高度: ${_contentHeight.toInt()}px, WebView高度: ${_webViewHeight.toInt()}px',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              if (_contentHeight > 5000)
                Text(
                  '警告：内容高度过大（${_contentHeight.toInt()}px），已限制显示高度为5000px',
                  style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    _heightDetected ? Icons.check_circle : Icons.hourglass_empty,
                    color: _heightDetected ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _heightDetected ? '高度检测完成' : '高度检测中...',
                    style: TextStyle(
                      fontSize: 12,
                      color: _heightDetected ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '🎯 核心思路:\n'
                '• 通过 JavaScript 获取网页真实内容高度\n'
                '• 动态设置 WebView 容器高度匹配内容高度\n'
                '• WebView 不再需要内部滚动，全部由外层处理\n'
                '• 实现真正的一体化滚动体验\n'
                '• 使用本地 HTML 内容确保稳定性',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        
        ...List.generate(2, (index) => Container(
          height: 100,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.deepPurple[200]!),
          ),
          child: Center(
            child: Text(
              '外层内容区域 ${index + 1}\n(动态高度方案版本)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDynamicWebViewSection() {
    return Container(
      // 使用动态计算的高度
      height: _webViewHeight,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // WebView 标题栏
            Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[200]!, Colors.deepPurple[300]!],
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.web_asset, color: Colors.deepPurple[800]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'WebView 区域 (本地 HTML)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // 高度信息显示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _heightDetected ? Colors.green[600] : Colors.orange[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_webViewHeight.toInt()}px',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            
            // WebView 内容区域
            Expanded(
              child: _webViewController == null 
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('初始化 WebView 中...'),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      WebViewWidget(controller: _webViewController!),
                      if (_isLoading)
                        Container(
                          color: Colors.white.withOpacity(0.9),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('加载网页并检测高度中...'),
                              ],
                            ),
                          ),
                        ),
                      
                      // 高度检测进度指示器
                      if (!_heightDetected && !_isLoading)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '检测高度',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Column(
      children: [
        // 操作控制区域
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[100]!],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.control_camera, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '高度控制',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!_isDisposed && _webViewController != null) {
                          _detectContentHeight();
                        }
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('重新检测高度'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!_isDisposed && mounted) {
                          setState(() {
                            _webViewHeight = 400; // 重置为默认高度
                            _heightDetected = false;
                            _contentHeight = 0;
                          });
                          // 清理 JavaScript 中的 Observer
                          _cleanupWebView();
                        }
                      },
                      icon: const Icon(Icons.restore, size: 16),
                      label: const Text('重置高度'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...List.generate(4, (index) => Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple[50]!, Colors.deepPurple[100]!],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.deepPurple[200]!),
          ),
          child: Center(
            child: Text(
              '底部内容区域 ${index + 1}\n(一体化滚动体验)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        )),
        
        // 方案说明
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[50]!, Colors.green[100]!],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    '动态高度方案优势',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '🚀 核心优势:\n'
                '• WebView 内容真正可滚动（无滚动冲突）\n'
                '• 一体化滚动体验，就像原生内容一样\n'
                '• 支持动态内容高度变化\n'
                '• 适用于任何第三方网页\n'
                '• 性能优秀，无复杂的手势处理\n\n'
                '🎯 实现原理:\n'
                '• JavaScript 实时检测网页内容高度\n'
                '• ResizeObserver 监听尺寸变化\n'
                '• MutationObserver 监听 DOM 变化\n'
                '• 动态调整 WebView 容器高度\n'
                '• 外层 ScrollView 统一处理所有滚动',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('动态高度方案详解'),
        content: const SingleChildScrollView(
          child: Text(
            '这是最接近完美解决方案的方法！\n\n'
            '🎯 核心思路:\n'
            '1. 使用 JavaScript 获取网页真实内容高度\n'
            '2. 通过 JavaScriptChannel 传递高度信息\n'
            '3. 动态设置 WebView 容器高度\n'
            '4. WebView 不再需要内部滚动\n'
            '5. 外层 ScrollView 统一处理滚动\n\n'
            '🚀 技术特点:\n'
            '• ResizeObserver: 监听尺寸变化\n'
            '• MutationObserver: 监听 DOM 变化\n'
            '• 多重高度检测策略\n'
            '• 自动适应动态内容\n\n'
            '✅ 效果对比:\n'
            '• 之前: WebView 内部滚动 + 外层滚动冲突\n'
            '• 现在: 只有外层滚动，完全一体化\n\n'
            '这就是您要的效果：WebView 内容真正可滚动！',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('明白了'),
          ),
        ],
      ),
    );
  }

  String _generateSimpleTestHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>动态高度测试</title>
        <style>
            body {
                margin: 0;
                padding: 20px;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                line-height: 1.6;
            }
            .header {
                background: rgba(255,255,255,0.1);
                padding: 30px;
                border-radius: 15px;
                text-align: center;
                margin-bottom: 20px;
                backdrop-filter: blur(10px);
            }
            .content-box {
                background: rgba(255,255,255,0.1);
                margin: 15px 0;
                padding: 25px;
                border-radius: 12px;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.2);
            }
            .highlight {
                background: rgba(255,215,0,0.3);
                padding: 15px;
                border-radius: 8px;
                margin: 15px 0;
                border-left: 4px solid #ffd700;
            }
            .dynamic-content {
                background: rgba(76,175,80,0.3);
                padding: 20px;
                border-radius: 10px;
                margin: 20px 0;
                border: 2px solid rgba(76,175,80,0.5);
            }
            .footer {
                background: rgba(0,0,0,0.3);
                padding: 25px;
                border-radius: 12px;
                text-align: center;
                margin-top: 30px;
            }
            h1 { font-size: 2.5em; margin: 0; }
            h2 { color: #ffd700; }
            h3 { color: #87ceeb; }
            .btn {
                background: rgba(255,255,255,0.2);
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 20px;
                margin: 5px;
                cursor: pointer;
                backdrop-filter: blur(5px);
                border: 1px solid rgba(255,255,255,0.3);
            }
            .btn:hover {
                background: rgba(255,255,255,0.3);
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🚀 动态高度测试页面</h1>
            <p>本地 HTML 内容，简单且安全</p>
        </div>
        
        <div class="highlight">
            <h2>✨ 测试说明</h2>
            <p>这个页面用于测试动态高度检测功能。页面内容会动态扩展，WebView 容器高度会自动调整。</p>
        </div>
        
        ${List.generate(8, (index) => '''
        <div class="content-box">
            <h3>📄 内容区块 ${index + 1}</h3>
            <p>这是第 ${index + 1} 个内容区块。每个区块都有一定的高度，用于测试动态高度检测功能。</p>
            ${index % 3 == 0 ? '''
            <div class="dynamic-content">
                <strong>🔍 特殊内容区域 ${(index ~/ 3) + 1}</strong><br>
                这个区域包含更多的内容和不同的样式，用于测试高度计算的准确性。您应该能够看到 WebView 高度在实时更新。
            </div>
            ''' : ''}
            <p><small>时间戳: ${DateTime.now().millisecondsSinceEpoch}</small></p>
        </div>
        ''').join('')}
        
        <div class="dynamic-content">
            <h2>🎯 动态内容测试</h2>
            <p>点击下面的按钮来测试动态内容添加：</p>
            <button class="btn" onclick="addContent()">添加内容</button>
            <button class="btn" onclick="removeContent()">移除内容</button>
            <div id="dynamic-area"></div>
        </div>
        
        <div class="footer">
            <h3>📊 测试完成</h3>
            <p>如果您能看到这里，说明动态高度检测功能正常工作！</p>
            <p><strong>WebView 内容完全可滚动，无滚动冲突！</strong></p>
        </div>
        
        <script>
            let contentCounter = 0;
            
            function addContent() {
                contentCounter++;
                const dynamicArea = document.getElementById('dynamic-area');
                const newContent = document.createElement('div');
                newContent.style.cssText = 'background: rgba(255,255,255,0.2); padding: 15px; margin: 10px 0; border-radius: 8px;';
                newContent.innerHTML = `
                    <strong>新增内容 \${contentCounter}</strong><br>
                    这是动态添加的内容，用于测试高度检测的实时性。
                    <br><small>添加时间: \${new Date().toLocaleTimeString()}</small>
                `;
                dynamicArea.appendChild(newContent);
            }
            
            function removeContent() {
                const dynamicArea = document.getElementById('dynamic-area');
                if (dynamicArea.children.length > 0) {
                    dynamicArea.removeChild(dynamicArea.lastElementChild);
                }
            }
            
            // 模拟一些动态变化
            setTimeout(function() {
                addContent();
            }, 2000);
            
            setTimeout(function() {
                addContent();
            }, 4000);
        </script>
    </body>
    </html>
    ''';
  }
}

/// 最简单的动态高度方案
class SimpleDynamicHeightCasePage extends StatefulWidget {
  const SimpleDynamicHeightCasePage({super.key});

  @override
  State<SimpleDynamicHeightCasePage> createState() => _SimpleDynamicHeightCasePageState();
}

class _SimpleDynamicHeightCasePageState extends State<SimpleDynamicHeightCasePage> {
  late final WebViewController _webViewController;
  double _webViewHeight = 400.0;
  bool _isLoading = true;
  String _debugInfo = '初始化中...'; // 添加调试信息
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            await _onPageFinished();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://integration.unnax.com/widget/reader/?sid=s_b740a1c19bab44759ad997fbd0b4af02'));
  }

  Future<void> _onPageFinished() async {
    try {
      setState(() {
        _isLoading = false;
      });
      
      // 等待更长时间确保页面完全渲染
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // 尝试不同的方法获取高度
      String jsCode = '''
        (function() {
          var height = Math.max(
            document.body.scrollHeight,
            document.body.offsetHeight,
            document.documentElement.clientHeight,
            document.documentElement.scrollHeight,
            document.documentElement.offsetHeight
          );
          return height;
        })();
      ''';
      
      final heightResult = await _webViewController.runJavaScriptReturningResult(jsCode);
      
      print('获取到的高度结果: $heightResult'); // 调试信息
      
      // 更新调试信息
      setState(() {
        _debugInfo = '原始结果: $heightResult';
      });
      
      double newHeight = 400.0; // 默认值
      
      // 尝试解析结果
      if (heightResult != null) {
        if (heightResult is num) {
          newHeight = heightResult.toDouble();
        } else {
          String heightStr = heightResult.toString();
          // 移除可能的引号或其他字符
          heightStr = heightStr.replaceAll(RegExp(r'[^\d.]'), '');
          newHeight = double.tryParse(heightStr) ?? 400.0;
        }
      }
      
      print('解析后的高度: $newHeight'); // 调试信息
      
      // 限制最大高度防止crash
      if (newHeight < 100) newHeight = 400; // 太小的值也不合理
      if (newHeight > 3000) newHeight = 3000;
      
      if (mounted) {
        setState(() {
          _webViewHeight = newHeight;
          _debugInfo += ', 最终高度: $newHeight';
        });
        print('设置 WebView 高度为: $_webViewHeight'); // 调试信息
      }
    } catch (e) {
      print('获取高度失败: $e'); // 调试信息
      // 如果获取高度失败，使用默认高度
      if (mounted) {
        setState(() {
          _webViewHeight = 800;
          _debugInfo = '错误: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('简单动态高度方案'),
        backgroundColor: Colors.amber[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _onPageFinished(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.amber[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        '简单动态高度方案',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'WebView 高度: ${_webViewHeight.toInt()}px',
                    style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                  Text(
                    '调试信息: $_debugInfo',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '⚡ 核心方法:\n'
                    '• 使用 runJavaScriptReturningResult\n'
                    '• 直接获取 document.documentElement.scrollHeight\n'
                    '• 在 onPageFinished 中更新高度\n'
                    '• 简单有效，代码量最少',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            
            // 一些外层内容
            ...List.generate(2, (index) => Container(
              height: 80,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Center(
                child: Text(
                  '外层内容区域 ${index + 1}\n(简单动态高度版本)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )),
            
            // WebView 区域
            Container(
              height: _webViewHeight,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Column(
                  children: [
                    // WebView 标题栏
                    Container(
                      height: 40,
                      color: Colors.amber[200],
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(Icons.web, color: Colors.amber[800]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'WebView 区域 (简单方案)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[600],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_webViewHeight.toInt()}px',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    
                    // WebView 内容
                    Expanded(
                      child: _isLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('加载中...'),
                              ],
                            ),
                          )
                        : WebViewWidget(controller: _webViewController),
                    ),
                  ],
                ),
              ),
            ),
            
            // 底部内容
            ...List.generate(3, (index) => Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Center(
                child: Text(
                  '底部内容区域 ${index + 1}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )),
            
            // 方案说明
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        '核心代码实现',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Future<void> _onPageFinished() async {\n'
                      '  final result = await _webViewController\n'
                      '    .runJavaScriptReturningResult(\n'
                      '      "document.documentElement.scrollHeight;"\n'
                      '    );\n'
                      '  double newHeight = double.parse(result.toString());\n'
                      '  setState(() => _webViewHeight = newHeight);\n'
                      '}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '✅ 优点: 代码简单、易理解、直接有效\n'
                    '⚠️ 注意: 添加了高度限制和错误处理防止crash',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateSimpleHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>简单动态高度测试</title>
        <style>
            body {
                margin: 0;
                padding: 20px;
                font-family: Arial, sans-serif;
                background: linear-gradient(135deg, #FFF8E1 0%, #FFE082 100%);
            }
            .section {
                background: white;
                margin: 15px 0;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                border-left: 4px solid #FFC107;
            }
            h1 { color: #F57C00; text-align: center; }
            h3 { color: #FF8F00; }
        </style>
    </head>
    <body>
        <h1>⚡ 简单动态高度测试</h1>
        
        ${List.generate(6, (index) => '''
        <div class="section">
            <h3>📄 内容区块 ${index + 1}</h3>
            <p>这是第 ${index + 1} 个内容区块。使用最简单的方法获取页面高度：</p>
            <p><code>document.documentElement.scrollHeight</code></p>
            ${index == 2 ? '<p><strong>🎯 中间测试点：页面高度会在这里被重新计算</strong></p>' : ''}
        </div>
        ''').join('')}
        
        <div class="section">
            <h3>✅ 测试完成</h3>
            <p><strong>简单有效的动态高度方案！</strong></p>
            <p>代码简洁，易于理解和维护。</p>
        </div>
    </body>
    </html>
    ''';
  }
}

/// Sliver 嵌套方案 - 参考 extended_sliver 的思路
class SliverNestedCasePage extends StatefulWidget {
  const SliverNestedCasePage({super.key});

  @override
  State<SliverNestedCasePage> createState() => _SliverNestedCasePageState();
}

class _SliverNestedCasePageState extends State<SliverNestedCasePage> {
  late final WebViewController _webViewController;
  final ValueNotifier<double> _contentHeightNotifier = ValueNotifier<double>(400);
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _heightDetectionTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _heightDetectionTimer?.cancel();
    _contentHeightNotifier.dispose();
    _cleanupWebView();
    super.dispose();
  }

  void _cleanupWebView() {
    if (_isDisposed) return;
    
    try {
      _webViewController.runJavaScript('''
        try {
          if (window.sliverHeightObserver) {
            window.sliverHeightObserver.disconnect();
            window.sliverHeightObserver = null;
          }
        } catch (e) {}
      ''').catchError((error) {});
    } catch (e) {}
  }

  void _initializeWebView() {
    if (_isDisposed) return;
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoading = false;
              });
              _heightDetectionTimer = Timer(const Duration(milliseconds: 800), () {
                if (!_isDisposed && mounted) {
                  _setupHeightDetection();
                }
              });
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'SliverHeightChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_isDisposed && mounted) {
            try {
              final height = double.tryParse(message.message);
              if (height != null && height >= 200 && height <= 4000) {
                _contentHeightNotifier.value = height;
              }
            } catch (e) {}
          }
        },
      )
      ..loadRequest(Uri.parse('https://integration.unnax.com/widget/reader/?sid=s_b740a1c19bab44759ad997fbd0b4af02'));
  }

  void _setupHeightDetection() {
    if (_isDisposed) return;
    
    try {
      _webViewController.runJavaScript('''
        (function() {
          try {
            function calculateSliverHeight() {
              const body = document.body;
              const html = document.documentElement;
              
              if (!body || !html) return 800;
              
              const heights = [
                body.scrollHeight || 0,
                body.offsetHeight || 0,
                html.scrollHeight || 0,
                html.offsetHeight || 0
              ];
              
              return Math.max(...heights.filter(h => h > 0));
            }
            
            const initialHeight = calculateSliverHeight();
            SliverHeightChannel.postMessage(initialHeight.toString());
            
            // 设置 ResizeObserver
            if (window.ResizeObserver) {
              window.sliverHeightObserver = new ResizeObserver(function(entries) {
                try {
                  const newHeight = calculateSliverHeight();
                  SliverHeightChannel.postMessage(newHeight.toString());
                } catch (e) {}
              });
              
              if (document.body) {
                window.sliverHeightObserver.observe(document.body);
              }
            }
            
          } catch (error) {
            SliverHeightChannel.postMessage('800');
          }
        })();
      ''').catchError((error) {
        if (!_isDisposed && mounted) {
          _contentHeightNotifier.value = 800;
        }
      });
    } catch (e) {
      if (!_isDisposed && mounted) {
        _contentHeightNotifier.value = 800;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliver 嵌套方案'),
        backgroundColor: Colors.indigo[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _setupHeightDetection();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<double>(
        valueListenable: _contentHeightNotifier,
        builder: (context, contentHeight, child) {
          return CustomScrollView(
            slivers: [
              // 头部内容
              SliverToBoxAdapter(
                child: _buildHeaderContent(contentHeight),
              ),
              
              // 一些外层内容
              ...List.generate(2, (index) => SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo[50]!, Colors.indigo[100]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo[200]!),
                  ),
                  child: Center(
                    child: Text(
                      '外层 Sliver 内容 ${index + 1}\n(Sliver 嵌套方案)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )),
              
              // 核心：SliverToNestedScrollBoxAdapter 风格的 WebView
              _buildSliverWebView(contentHeight),
              
              // 底部内容
              ...List.generate(3, (index) => SliverToBoxAdapter(
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo[50]!, Colors.indigo[100]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo[200]!),
                  ),
                  child: Center(
                    child: Text(
                      '底部 Sliver 内容 ${index + 1}\n(统一滚动体验)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )),
              
              // 说明区域
              SliverToBoxAdapter(
                child: _buildExplanationSection(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(double contentHeight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.indigo[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.layers, color: Colors.indigo[700]),
              const SizedBox(width: 8),
              Text(
                'Sliver 嵌套方案',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'WebView 内容高度: ${contentHeight.toInt()}px (动态监听)',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 4),
          const Text(
            '🔄 extended_sliver 思路:\n'
            '• 使用 CustomScrollView + Sliver 架构\n'
            '• ValueListenableBuilder 监听高度变化\n'
            '• WebView 作为 Sliver 的一部分\n'
            '• 外层完全控制滚动，无滚动冲突\n'
            '• 一体化的 Sliver 滚动体验',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverWebView(double contentHeight) {
    return SliverToBoxAdapter(
      child: Container(
        height: contentHeight,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo[300]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              // WebView 标题栏
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo[200]!, Colors.indigo[300]!],
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(Icons.web_stories, color: Colors.indigo[800]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'WebView 区域 (Sliver 嵌套)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    // 高度和状态指示器
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${contentHeight.toInt()}px',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.indigo[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Sliver',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              
              // WebView 内容区域
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),
                    if (_isLoading)
                      Container(
                        color: Colors.white.withOpacity(0.9),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('加载 Sliver WebView 中...'),
                            ],
                          ),
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
  }

  Widget _buildExplanationSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'extended_sliver 方案解析',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '🎯 核心原理:\n'
            '• CustomScrollView: 统一的 Sliver 滚动容器\n'
            '• SliverToBoxAdapter: 将 WebView 转换为 Sliver\n'
            '• ValueListenableBuilder: 监听高度变化并重建\n'
            '• 外层控制内层: WebView 不再独立滚动\n\n'
            '🚀 优势对比:\n'
            '• vs 手势拦截: 更简单，无复杂手势处理\n'
            '• vs 动态高度: 更好的架构，天然的 Sliver 支持\n'
            '• vs Physics控制: 更彻底的解决方案\n\n'
            '🎪 体验效果:\n'
            '• 完全一体化的滚动体验\n'
            '• WebView 内容如原生组件般流畅\n'
            '• 支持复杂的 Sliver 布局组合\n'
            '• 适用于各种第三方网页内容',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sliver 嵌套方案详解'),
        content: const SingleChildScrollView(
          child: Text(
            'extended_sliver 的 SliverToNestedScrollBoxAdapter 提供了最优雅的解决方案！\n\n'
            '🏗️ 架构设计:\n'
            '1. CustomScrollView 作为根容器\n'
            '2. WebView 作为 SliverToBoxAdapter 的 child\n'
            '3. ValueListenableBuilder 监听高度变化\n'
            '4. 外层完全接管滚动控制\n\n'
            '🔧 关键技术:\n'
            '• Sliver 架构: Flutter 原生的滚动解决方案\n'
            '• 高度监听: JavaScript + Channel 通信\n'
            '• 手势接管: 外层统一处理所有滚动\n\n'
            '🎯 适用场景:\n'
            '• 复杂的滚动布局（多个 Sliver 组合）\n'
            '• 需要与其他 Sliver 组件协同\n'
            '• 要求最佳用户体验的场景\n'
            '• 大型应用的架构级解决方案\n\n'
            '这是目前最推荐的企业级解决方案！',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('太棒了！'),
          ),
        ],
      ),
    );
  }

  String _generateSliverTestHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sliver 嵌套测试页面</title>
        <style>
            body {
                margin: 0;
                padding: 20px;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                background: linear-gradient(135deg, #3f51b5 0%, #9c27b0 100%);
                color: white;
                line-height: 1.6;
            }
            .header {
                background: rgba(255,255,255,0.15);
                padding: 30px;
                border-radius: 15px;
                text-align: center;
                margin-bottom: 25px;
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.2);
            }
            .sliver-section {
                background: rgba(255,255,255,0.1);
                margin: 20px 0;
                padding: 25px;
                border-radius: 12px;
                backdrop-filter: blur(8px);
                border: 1px solid rgba(255,255,255,0.15);
                border-left: 4px solid #ff4081;
            }
            h1 { font-size: 2.5em; margin: 0; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
            h2 { color: #ffeb3b; text-shadow: 1px 1px 2px rgba(0,0,0,0.3); }
            h3 { color: #81c784; }
            .sliver-badge {
                display: inline-block;
                background: rgba(255,64,129,0.8);
                color: white;
                padding: 8px 15px;
                border-radius: 20px;
                font-size: 0.9em;
                font-weight: bold;
                margin: 10px 5px;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🎪 Sliver 嵌套测试页面</h1>
            <p>基于 extended_sliver 思路实现</p>
            <div class="sliver-badge">CustomScrollView</div>
            <div class="sliver-badge">SliverToBoxAdapter</div>
            <div class="sliver-badge">ValueListenableBuilder</div>
        </div>
        
        ${List.generate(6, (index) => '''
        <div class="sliver-section">
            <h3>🧩 Sliver 内容块 ${index + 1}</h3>
            <p>这是第 ${index + 1} 个内容块，完全集成在 Sliver 滚动体系中。</p>
            <p>外层 CustomScrollView 统一控制滚动，WebView 不再有独立的滚动行为。</p>
        </div>
        ''').join('')}
        
        <div class="sliver-section">
            <h2>🎯 Sliver 嵌套完成</h2>
            <p><strong>体验最优雅的 WebView 嵌套解决方案！</strong></p>
            <p>这就是 extended_sliver 的魅力所在。</p>
        </div>
    </body>
    </html>
    ''';
  }
}