import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';

/// Comprehensive solution for third-party H5 input keyboard occlusion in WebView
class WebViewH5KeyboardSolutionPage extends StatefulWidget {
  const WebViewH5KeyboardSolutionPage({super.key});

  @override
  State<WebViewH5KeyboardSolutionPage> createState() => _WebViewH5KeyboardSolutionPageState();
}

class _WebViewH5KeyboardSolutionPageState extends State<WebViewH5KeyboardSolutionPage> {
  late final WebViewController _webViewController;
  late final ScrollController _scrollController;
  final ValueNotifier<double> _webViewHeightNotifier = ValueNotifier<double>(600);
  
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _setupTimer;
  
  // Input focus management
  bool _isInputFocused = false;
  double _focusedInputTop = 0;
  double _focusedInputHeight = 0;
  String _focusedInputType = '';
  String _debugInfo = 'Initializing WebView...';
  
  // Custom URL management
  final TextEditingController _urlController = TextEditingController();
  String _customUrl = '';
  
  // Test URLs for different scenarios
  final List<TestScenario> _testScenarios = [
    TestScenario(
      name: 'Local Form Test',
      description: '本地测试表单，模拟第三方H5页面',
      url: 'local_form',
    ),
    TestScenario(
      name: 'Custom URL',
      description: '自定义URL地址',
      url: 'custom_url',
    ),
    TestScenario(
      name: 'Baidu Search',
      description: '百度搜索页面，测试真实第三方页面',
      url: 'https://m.baidu.com',
    ),
    TestScenario(
      name: 'GitHub Login',
      description: 'GitHub移动版登录页面',
      url: 'https://github.com/login',
    ),
  ];
  
  TestScenario _currentScenario = TestScenario(
    name: 'Local Form Test',
    description: '本地测试表单，模拟第三方H5页面',
    url: 'local_form',
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeWebView();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _setupTimer?.cancel();
    _webViewHeightNotifier.dispose();
    _scrollController.dispose();
    _urlController.dispose();
    super.dispose();
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
                _debugInfo = 'Loading: ${url.length > 50 ? url.substring(0, 50) + '...' : url}';
              });
            }
          },
          onPageFinished: (String url) {
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoading = false;
                _debugInfo = 'Page loaded, setting up keyboard handlers...';
              });
              _setupKeyboardHandlers();
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (!_isDisposed && mounted) {
              setState(() {
                _debugInfo = 'Error: ${error.description}';
              });
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'KeyboardHandler',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_isDisposed && mounted) {
            _handleKeyboardMessage(message.message);
          }
        },
      )
      ..addJavaScriptChannel(
        'HeightChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_isDisposed && mounted) {
            final height = double.tryParse(message.message);
            if (height != null && height >= 300) {
              final adjustedHeight = height > 2000 ? 2000.0 : height;
              _webViewHeightNotifier.value = adjustedHeight;
              print('WebView height updated: $height -> $adjustedHeight');
            }
          }
        },
      );
      
    // Load initial content
    _loadCurrentScenario();
  }

  void _handleKeyboardMessage(String message) {
    try {
      final data = json.decode(message);
      final type = data['type'] as String;
      
      switch (type) {
        case 'focus':
          setState(() {
            _isInputFocused = true;
            _focusedInputTop = (data['top'] as num).toDouble();
            _focusedInputHeight = (data['height'] as num?)?.toDouble() ?? 40.0;
            _focusedInputType = data['inputType'] as String? ?? 'input';
            _debugInfo = 'Input focused: ${_focusedInputType} at Y=${_focusedInputTop.toInt()}px';
          });
          _scrollToInput();
          break;
          
        case 'blur':
          setState(() {
            _isInputFocused = false;
            _debugInfo = 'Input blurred';
          });
          break;
          
        case 'resize':
          final newHeight = (data['height'] as num).toDouble();
          if (newHeight >= 300) {
            final adjustedHeight = newHeight > 2000 ? 2000.0 : newHeight;
            _webViewHeightNotifier.value = adjustedHeight;
          }
          break;
      }
    } catch (e) {
      print('Error parsing keyboard message: $e');
    }
  }

  void _scrollToInput() {
    if (!_isInputFocused || _isDisposed) return;
    
    // Wait for keyboard to appear
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_isInputFocused) return;
      
      final mediaQuery = MediaQuery.of(context);
      final keyboardHeight = mediaQuery.viewInsets.bottom;
      final screenHeight = mediaQuery.size.height;
      final availableHeight = screenHeight - keyboardHeight - kToolbarHeight - 50; // 50px buffer
      
      // Calculate WebView's position in the screen
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      
      final webViewRect = renderBox.localToGlobal(Offset.zero);
      final webViewTopInScreen = webViewRect.dy;
      
      // Calculate absolute position of the focused input
      final inputAbsoluteTop = webViewTopInScreen + _focusedInputTop;
      final inputAbsoluteBottom = inputAbsoluteTop + _focusedInputHeight;
      
      // Check if input is obscured by keyboard
      if (inputAbsoluteBottom > availableHeight) {
        // Calculate how much to scroll to bring input into view
        final targetPosition = availableHeight * 0.6; // Position input at 60% of available height
        final scrollDelta = inputAbsoluteTop - targetPosition;
        final newOffset = _scrollController.offset + scrollDelta;
        
        // Clamp to valid scroll range
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final clampedOffset = newOffset.clamp(0.0, maxScrollExtent);
        
        setState(() {
          _debugInfo = 'Scrolling: input at ${inputAbsoluteTop.toInt()}px, target: ${targetPosition.toInt()}px, scroll: ${clampedOffset.toInt()}px';
        });
        
        // Perform smooth scroll
        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() {
          _debugInfo = 'Input already visible, no scroll needed';
        });
      }
    });
  }

  void _setupKeyboardHandlers() {
    if (_isDisposed) return;
    
    // Use progressive delays to handle different loading scenarios
    final delays = [500, 1500, 3000];
    
    for (int i = 0; i < delays.length; i++) {
      _setupTimer = Timer(Duration(milliseconds: delays[i]), () {
        if (!_isDisposed && mounted) {
          _injectKeyboardScript(i + 1);
        }
      });
    }
  }

  void _injectKeyboardScript(int attempt) {
    if (_isDisposed) return;
    
    final script = '''
      (function() {
        console.log('Setting up keyboard handlers (attempt $attempt)...');
        
        // Dynamic height detection
        function updateHeight() {
          const height = Math.max(
            document.body.scrollHeight || 0,
            document.body.offsetHeight || 0,
            document.documentElement.scrollHeight || 0,
            document.documentElement.offsetHeight || 0
          );
          if (height > 100) {
            HeightChannel.postMessage(height.toString());
          }
        }
        
        // Initial height update
        updateHeight();
        
        // Monitor for dynamic content changes
        if (window.ResizeObserver) {
          const resizeObserver = new ResizeObserver(() => {
            setTimeout(updateHeight, 100);
          });
          resizeObserver.observe(document.body);
        }
        
        // Setup input focus detection
        function setupInputHandlers() {
          const inputs = document.querySelectorAll('input, textarea, select, [contenteditable="true"], [contenteditable=""]');
          console.log('Found ' + inputs.length + ' input elements');
          
          inputs.forEach((input, index) => {
            // Remove existing listeners to avoid duplicates
            input.removeEventListener('focus', input._focusHandler);
            input.removeEventListener('blur', input._blurHandler);
            
            // Create focus handler
            input._focusHandler = function(e) {
              setTimeout(() => {
                const rect = this.getBoundingClientRect();
                const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
                
                const focusData = {
                  type: 'focus',
                  top: rect.top + scrollTop,
                  height: rect.height,
                  inputType: this.tagName.toLowerCase() + '_' + (this.type || 'text'),
                  index: index
                };
                
                KeyboardHandler.postMessage(JSON.stringify(focusData));
                console.log('Input focused:', focusData);
                
                // Ensure input is visible within WebView
                this.scrollIntoView({ 
                  behavior: 'smooth', 
                  block: 'center',
                  inline: 'nearest'
                });
              }, 50);
            };
            
            // Create blur handler
            input._blurHandler = function(e) {
              KeyboardHandler.postMessage(JSON.stringify({
                type: 'blur',
                index: index
              }));
              console.log('Input blurred');
            };
            
            // Add event listeners
            input.addEventListener('focus', input._focusHandler, true);
            input.addEventListener('blur', input._blurHandler, true);
          });
          
          // Update height after setup
          setTimeout(updateHeight, 200);
        }
        
        // Initial setup
        setupInputHandlers();
        
        // Re-setup on DOM changes (for dynamic content)
        if (window.MutationObserver) {
          const observer = new MutationObserver((mutations) => {
            let shouldResetup = false;
            mutations.forEach((mutation) => {
              if (mutation.type === 'childList') {
                mutation.addedNodes.forEach((node) => {
                  if (node.nodeType === 1) { // Element node
                    const hasInputs = node.querySelectorAll && 
                                    node.querySelectorAll('input, textarea, select, [contenteditable]').length > 0;
                    if (hasInputs || node.matches && node.matches('input, textarea, select, [contenteditable]')) {
                      shouldResetup = true;
                    }
                  }
                });
              }
            });
            
            if (shouldResetup) {
              console.log('DOM changed, re-setting up input handlers...');
              setTimeout(setupInputHandlers, 100);
            }
          });
          
          observer.observe(document.body, {
            childList: true,
            subtree: true
          });
        }
        
        console.log('Keyboard handlers setup complete (attempt $attempt)');
      })();
    ''';
    
    _webViewController.runJavaScript(script).catchError((error) {
      print('Error injecting script (attempt $attempt): $error');
    });
  }

  void _loadCurrentScenario() {
    if (_currentScenario.url == 'local_form') {
      _loadLocalForm();
    } else if (_currentScenario.url == 'custom_url') {
      _showCustomUrlDialog();
    } else {
      _webViewController.loadRequest(Uri.parse(_currentScenario.url));
    }
  }
  
  void _showCustomUrlDialog() {
    _urlController.text = _customUrl.isEmpty ? 'https://' : _customUrl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入自定义URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL地址',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            const Text(
              '提示：请输入完整的URL地址，包含http://或https://前缀',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = _urlController.text.trim();
              if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                _customUrl = url;
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                  _debugInfo = 'Loading custom URL: $url';
                });
                _webViewController.loadRequest(Uri.parse(url));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('请输入有效的URL地址'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('加载'),
          ),
        ],
      ),
    );
  }

  void _loadLocalForm() {
    final htmlContent = '''
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <title>第三方H5表单测试</title>
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                line-height: 1.6;
                color: #333;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 20px;
            }
            
            .container {
                max-width: 400px;
                margin: 0 auto;
                background: white;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.3);
                overflow: hidden;
            }
            
            .header {
                background: linear-gradient(45deg, #ff6b6b, #feca57);
                color: white;
                padding: 30px 20px;
                text-align: center;
            }
            
            .header h1 {
                font-size: 24px;
                margin-bottom: 10px;
            }
            
            .form-container {
                padding: 30px 20px;
            }
            
            .form-group {
                margin-bottom: 25px;
            }
            
            .form-group label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: #555;
            }
            
            .form-group input,
            .form-group textarea,
            .form-group select {
                width: 100%;
                padding: 15px;
                border: 2px solid #e1e8ed;
                border-radius: 10px;
                font-size: 16px;
                transition: all 0.3s ease;
                background: #f8f9fa;
            }
            
            .form-group input:focus,
            .form-group textarea:focus,
            .form-group select:focus {
                outline: none;
                border-color: #667eea;
                background: white;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
                transform: translateY(-2px);
            }
            
            .form-group textarea {
                min-height: 100px;
                resize: vertical;
                font-family: inherit;
            }
            
            .checkbox-group {
                display: flex;
                align-items: center;
                margin-top: 20px;
            }
            
            .checkbox-group input[type="checkbox"] {
                width: auto;
                margin-right: 10px;
                transform: scale(1.2);
            }
            
            .submit-btn {
                width: 100%;
                padding: 15px;
                background: linear-gradient(45deg, #667eea, #764ba2);
                color: white;
                border: none;
                border-radius: 10px;
                font-size: 18px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                margin-top: 20px;
            }
            
            .submit-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            }
            
            .info-section {
                background: #f8f9fa;
                padding: 20px;
                margin-top: 20px;
                border-radius: 10px;
                border-left: 4px solid #28a745;
            }
            
            .info-section h3 {
                color: #28a745;
                margin-bottom: 10px;
            }
            
            .dynamic-content {
                margin-top: 30px;
                padding: 20px;
                background: #fff3cd;
                border-radius: 10px;
                border-left: 4px solid #ffc107;
            }
            
            @media (max-width: 480px) {
                .container {
                    margin: 10px;
                    border-radius: 12px;
                }
                
                .header {
                    padding: 20px;
                }
                
                .form-container {
                    padding: 20px 15px;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 第三方H5表单</h1>
                <p>测试键盘遮挡解决方案</p>
            </div>
            
            <div class="form-container">
                <form id="testForm">
                    <div class="form-group">
                        <label for="name">姓名 *</label>
                        <input type="text" id="name" name="name" placeholder="请输入您的姓名" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">邮箱地址 *</label>
                        <input type="email" id="email" name="email" placeholder="example@domain.com" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">手机号码</label>
                        <input type="tel" id="phone" name="phone" placeholder="请输入手机号码">
                    </div>
                    
                    <div class="form-group">
                        <label for="age">年龄</label>
                        <input type="number" id="age" name="age" placeholder="请输入年龄" min="1" max="120">
                    </div>
                    
                    <div class="form-group">
                        <label for="city">所在城市</label>
                        <select id="city" name="city">
                            <option value="">请选择城市</option>
                            <option value="beijing">北京</option>
                            <option value="shanghai">上海</option>
                            <option value="guangzhou">广州</option>
                            <option value="shenzhen">深圳</option>
                            <option value="hangzhou">杭州</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="website">个人网站</label>
                        <input type="url" id="website" name="website" placeholder="https://your-website.com">
                    </div>
                    
                    <div class="form-group">
                        <label for="password">密码</label>
                        <input type="password" id="password" name="password" placeholder="请输入密码">
                    </div>
                    
                    <div class="form-group">
                        <label for="birthdate">出生日期</label>
                        <input type="date" id="birthdate" name="birthdate">
                    </div>
                    
                    <div class="form-group">
                        <label for="comments">备注信息</label>
                        <textarea id="comments" name="comments" placeholder="请输入您的备注信息..."></textarea>
                    </div>
                    
                    <div class="checkbox-group">
                        <input type="checkbox" id="agree" name="agree" required>
                        <label for="agree">我同意相关条款和隐私政策</label>
                    </div>
                    
                    <button type="submit" class="submit-btn">提交表单</button>
                </form>
                
                <div class="info-section">
                    <h3>📱 测试说明</h3>
                    <p>点击任意输入框测试键盘遮挡解决方案：</p>
                    <ul style="margin-left: 20px; margin-top: 10px;">
                        <li>自动检测输入框焦点</li>
                        <li>智能滚动避免键盘遮挡</li>
                        <li>支持各种输入类型</li>
                        <li>兼容动态内容变化</li>
                    </ul>
                </div>
                
                <div class="dynamic-content" id="dynamicContent">
                    <h3>🔄 动态内容测试</h3>
                    <p>这里会动态添加更多输入框...</p>
                    <button type="button" id="addFieldBtn" style="margin-top: 10px; padding: 8px 16px; border: none; background: #007bff; color: white; border-radius: 5px; cursor: pointer;">添加更多字段</button>
                </div>
            </div>
        </div>
        
        <script>
            // Dynamic field addition
            let fieldCount = 0;
            document.getElementById('addFieldBtn').addEventListener('click', function() {
                fieldCount++;
                const container = document.getElementById('dynamicContent');
                const newField = document.createElement('div');
                newField.className = 'form-group';
                newField.style.marginTop = '15px';
                newField.innerHTML = 
                    '<label for="dynamic' + fieldCount + '">动态字段 ' + fieldCount + '</label>' +
                    '<input type="text" id="dynamic' + fieldCount + '" name="dynamic' + fieldCount + '" placeholder="这是动态添加的输入框 ' + fieldCount + '">';
                container.appendChild(newField);
                
                // Focus on the new field
                setTimeout(() => {
                    document.getElementById('dynamic' + fieldCount).focus();
                }, 100);
            });
            
            // Form submission
            document.getElementById('testForm').addEventListener('submit', function(e) {
                e.preventDefault();
                alert('表单提交测试成功！\\n\\n在实际应用中，这里会发送数据到服务器。');
            });
            
            // Input focus logging
            document.querySelectorAll('input, textarea, select').forEach((input, index) => {
                input.addEventListener('focus', function() {
                    console.log('Input focused: ' + (this.id || this.name || 'unnamed') + ' (' + this.type + ')');
                });
                
                input.addEventListener('blur', function() {
                    console.log('Input blurred: ' + (this.id || this.name || 'unnamed'));
                });
            });
            
            console.log('Local form loaded with', document.querySelectorAll('input, textarea, select').length, 'input fields');
        </script>
    </body>
    </html>
    ''';
    
    _webViewController.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView H5 键盘解决方案'),
        backgroundColor: Colors.blue[100],
        actions: [
          PopupMenuButton<TestScenario>(
            icon: const Icon(Icons.web),
            onSelected: (scenario) {
              setState(() {
                _currentScenario = scenario;
                _isLoading = true;
                _debugInfo = 'Switching to ${scenario.name}...';
              });
              _loadCurrentScenario();
            },
            itemBuilder: (context) => _testScenarios.map((scenario) {
              return PopupMenuItem<TestScenario>(
                value: scenario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scenario.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      scenario.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(),
          Expanded(
            child: ValueListenableBuilder<double>(
              valueListenable: _webViewHeightNotifier,
              builder: (context, webViewHeight, _) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildWebViewContainer(webViewHeight),
                      _buildInstructionsSection(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.web, color: Colors.blue[700], size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentScenario.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
                  ),
                )
              else if (_isInputFocused)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Input Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentScenario.description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Debug: $_debugInfo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContainer(double height) {
    return Container(
      height: height,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
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
                      Text(
                        '正在加载页面...',
                        style: TextStyle(fontSize: 16),
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

  Widget _buildInstructionsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700], size: 24),
              const SizedBox(width: 8),
              Text(
                '解决方案特性',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            '🎯 智能焦点检测',
            '自动检测第三方H5页面中的输入框焦点变化',
            Colors.blue,
          ),
          _buildFeatureItem(
            '📱 键盘感知滚动',
            '根据键盘高度智能调整页面滚动位置',
            Colors.purple,
          ),
          _buildFeatureItem(
            '🔄 动态内容适配',
            '支持动态加载的表单和异步渲染的输入框',
            Colors.orange,
          ),
          _buildFeatureItem(
            '⚡ 多重检测策略',
            '使用多种时机和方法确保输入框处理的完整性',
            Colors.teal,
          ),
          _buildFeatureItem(
            '🛡️ 容错处理',
            '处理各种异常情况，确保功能稳定性',
            Colors.red,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 使用提示',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. 点击页面顶部的网页图标可切换不同测试场景\n'
                  '2. 本地表单测试包含了各种输入类型\n'
                  '3. 真实第三方网站可能需要网络连接\n'
                  '4. 观察Debug信息了解处理过程',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: color[600],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TestScenario {
  final String name;
  final String description;
  final String url;

  TestScenario({
    required this.name,
    required this.description,
    required this.url,
  });
}
