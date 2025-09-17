import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';

/// Enhanced Sliver WebView solution with input field focus management
class SliverWebViewInputSolutionPage extends StatefulWidget {
  const SliverWebViewInputSolutionPage({super.key});

  @override
  State<SliverWebViewInputSolutionPage> createState() => _SliverWebViewInputSolutionPageState();
}

class _SliverWebViewInputSolutionPageState extends State<SliverWebViewInputSolutionPage> {
  late final WebViewController _webViewController;
  late final ScrollController _scrollController;
  final ValueNotifier<double> _contentHeightNotifier = ValueNotifier<double>(400);
  
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _heightDetectionTimer;
  
  // Input field focus management
  double _focusedInputTop = 0;
  bool _isInputFocused = false;
  String _debugInfo = 'Initializing...';
  int _heightUpdateCount = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeWebView();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _heightDetectionTimer?.cancel();
    _contentHeightNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    if (_isDisposed) return;
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (!_isDisposed && mounted) {
              setState(() => _isLoading = false);
              _setupWebViewFeatures();
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'HeightChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_isDisposed && mounted) {
            final height = double.tryParse(message.message);
            if (height != null && height >= 100) {
              final adjustedHeight = height > 3000 ? 3000 : height;
              _contentHeightNotifier.value = adjustedHeight + 50;
              setState(() {
                _heightUpdateCount++;
                _debugInfo = 'Height: ${height.toInt()}px -> ${adjustedHeight.toInt()}px (Update #$_heightUpdateCount)';
              });
              print('Height updated: $height -> $adjustedHeight');
            } else {
              setState(() {
                _debugInfo = 'Invalid height received: ${message.message}';
              });
            }
          }
        },
      )
      ..addJavaScriptChannel(
        'InputFocusChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_isDisposed && mounted) {
            _handleInputFocus(message.message);
          }
        },
      )
      ..loadHtmlString(_generateInputTestHtml());
    
    // Uncomment below to test with a real third-party form
    // ..loadRequest(Uri.parse('https://integration.unnax.com/widget/reader/?sid=s_b740a1c19bab44759ad997fbd0b4af02'));
  }

  void _handleInputFocus(String messageData) {
    try {
      final data = jsonDecode(messageData);
      final bool isFocused = data['focused'] ?? false;
      final double top = (data['top'] ?? 0).toDouble();
      
      setState(() {
        _isInputFocused = isFocused;
        _focusedInputTop = top;
      });
      
      if (isFocused) _scrollToInput();
    } catch (e) {
      print('Error handling input focus: $e');
    }
  }

  void _scrollToInput() {
    if (!_isInputFocused || _isDisposed) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final mediaQuery = MediaQuery.of(context);
      final keyboardHeight = mediaQuery.viewInsets.bottom;
      final screenHeight = mediaQuery.size.height;
      final availableHeight = screenHeight - keyboardHeight - kToolbarHeight;
      
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      
      final webViewRect = renderBox.localToGlobal(Offset.zero);
      final inputAbsoluteTop = webViewRect.dy + _focusedInputTop;
      final targetPosition = availableHeight * 0.3;
      
      if (inputAbsoluteTop > targetPosition) {
        final scrollDelta = inputAbsoluteTop - targetPosition;
        final newOffset = _scrollController.offset + scrollDelta;
        
        _scrollController.animateTo(
          newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _setupWebViewFeatures() {
    if (_isDisposed) return;
    
    // Use multiple delayed attempts for third-party content
    _heightDetectionTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!_isDisposed && mounted) {
        _setupHeightAndInputDetection();
      }
    });
    
    // Additional check after more time for slow-loading content
    Timer(const Duration(milliseconds: 5000), () {
      if (!_isDisposed && mounted) {
        _webViewController.runJavaScript('''
          const currentHeight = Math.max(
            document.body.scrollHeight,
            document.documentElement.scrollHeight,
            document.body.offsetHeight,
            document.documentElement.offsetHeight
          );
          if (currentHeight > 500) {
            HeightChannel.postMessage(currentHeight.toString());
            console.log('Late height check:', currentHeight);
          }
        ''');
      }
    });
  }

  void _setupHeightAndInputDetection() {
    if (_isDisposed) return;
    
    _webViewController.runJavaScript('''
      (function() {
        let lastHeight = 0;
        let stableCount = 0;
        let detectionTimer = null;
        
        function calculateHeight() {
          const body = document.body;
          const html = document.documentElement;
          if (!body || !html) return 800;
          
          // Multiple height calculation strategies
          const heights = [
            body.scrollHeight || 0,
            body.offsetHeight || 0,
            html.scrollHeight || 0,
            html.offsetHeight || 0,
            body.getBoundingClientRect().height || 0
          ];
          
          return Math.max(...heights.filter(h => h > 0));
        }
        
        function detectHeightWithRetry() {
          const currentHeight = calculateHeight();
          
          // Check if height has stabilized
          if (Math.abs(currentHeight - lastHeight) < 10) {
            stableCount++;
          } else {
            stableCount = 0;
            lastHeight = currentHeight;
          }
          
          // Send height if it seems stable or after maximum retries
          if (stableCount >= 2 || currentHeight > 500) {
            HeightChannel.postMessage(currentHeight.toString());
            console.log('Height detected:', currentHeight);
            
            // Continue monitoring for changes
            setTimeout(detectHeightWithRetry, 2000);
          } else {
            // Retry more frequently if content is still loading
            setTimeout(detectHeightWithRetry, 500);
          }
        }
        
        function setupInputFocusDetection() {
          // Use setTimeout to ensure all elements are available
          setTimeout(() => {
            const inputs = document.querySelectorAll('input, textarea, select, [contenteditable]');
            console.log('Found inputs:', inputs.length);
            
            inputs.forEach((input, index) => {
              input.addEventListener('focus', function() {
                const rect = this.getBoundingClientRect();
                const focusData = {
                  focused: true,
                  top: rect.top + window.pageYOffset,
                  element: this.tagName + '_' + index
                };
                
                // Ensure input is visible within WebView
                this.scrollIntoView({ behavior: 'smooth', block: 'center' });
                InputFocusChannel.postMessage(JSON.stringify(focusData));
                console.log('Input focused:', focusData);
              });
              
              input.addEventListener('blur', function() {
                InputFocusChannel.postMessage(JSON.stringify({focused: false, top: 0}));
              });
            });
          }, 1000);
        }
        
        // Initial height detection with delay
        setTimeout(() => {
          detectHeightWithRetry();
          setupInputFocusDetection();
        }, 1000);
        
        // Advanced observers for dynamic content
        if (window.ResizeObserver) {
          const resizeObserver = new ResizeObserver(() => {
            clearTimeout(detectionTimer);
            detectionTimer = setTimeout(() => {
              const newHeight = calculateHeight();
              if (newHeight > lastHeight + 50) {
                HeightChannel.postMessage(newHeight.toString());
                lastHeight = newHeight;
              }
              setupInputFocusDetection();
            }, 500);
          });
          
          if (document.body) {
            resizeObserver.observe(document.body);
          }
        }
        
        // MutationObserver for DOM changes
        if (window.MutationObserver) {
          const mutationObserver = new MutationObserver((mutations) => {
            let hasSignificantChanges = false;
            mutations.forEach((mutation) => {
              if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                // Check if added nodes are significant (not just text nodes)
                for (let node of mutation.addedNodes) {
                  if (node.nodeType === 1) { // Element node
                    hasSignificantChanges = true;
                    break;
                  }
                }
              }
            });
            
            if (hasSignificantChanges) {
              clearTimeout(detectionTimer);
              detectionTimer = setTimeout(() => {
                const newHeight = calculateHeight();
                HeightChannel.postMessage(newHeight.toString());
                setupInputFocusDetection();
                console.log('DOM changed, new height:', newHeight);
              }, 1000);
            }
          });
          
          mutationObserver.observe(document.body, {
            childList: true,
            subtree: true
          });
        }
        
        // Fallback: periodic height checks for stubborn content
        let checkCount = 0;
        const maxChecks = 20;
        const periodicCheck = setInterval(() => {
          checkCount++;
          const currentHeight = calculateHeight();
          
          if (currentHeight > lastHeight + 100 || checkCount >= maxChecks) {
            HeightChannel.postMessage(currentHeight.toString());
            lastHeight = currentHeight;
            
            if (checkCount >= maxChecks) {
              clearInterval(periodicCheck);
            }
          }
        }, 2000);
        
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sliver WebView Input Solution'),
        backgroundColor: Colors.teal[100],
      ),
      body: ValueListenableBuilder<double>(
        valueListenable: _contentHeightNotifier,
        builder: (context, contentHeight, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeaderContent(contentHeight)),
              SliverToBoxAdapter(child: _buildWebViewContainer(contentHeight)),
              SliverToBoxAdapter(child: _buildFooterContent()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(double contentHeight) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sliver WebView Input Solution (Enhanced)', 
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[700])),
          const SizedBox(height: 8),
          Text('Content Height: ${contentHeight.toInt()}px'),
          Text('Debug: $_debugInfo', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          if (_isInputFocused) 
            Text('Input Focused at: ${_focusedInputTop.toInt()}px', 
                 style: TextStyle(color: Colors.orange[700])),
          const SizedBox(height: 8),
          const Text('🎯 Enhanced for Third-party Forms:\n• Multiple height detection strategies\n• Delayed detection for slow-loading content\n• Advanced DOM change monitoring\n• Auto-scroll to focused inputs'),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _setupHeightAndInputDetection(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Re-detect'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[600]),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _webViewController.runJavaScript('console.log("Current height:", document.body.scrollHeight);'),
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text('Debug'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContainer(double contentHeight) {
    return Container(
      height: contentHeight,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: const Text(
        '✨ Features:\n'
        '• Focus Detection: Monitors input focus/blur events\n'
        '• Auto-scroll: Brings focused inputs into view\n'
        '• Keyboard Awareness: Adjusts for keyboard appearance\n'
        '• Dynamic Heights: Handles content changes',
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  String _generateInputTestHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { padding: 20px; font-family: Arial, sans-serif; }
            .form-section { background: white; margin: 16px 0; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .form-group { margin-bottom: 16px; }
            label { display: block; margin-bottom: 4px; font-weight: bold; }
            input, textarea, select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 16px; }
            input:focus, textarea:focus, select:focus { border-color: #007cba; outline: none; }
        </style>
    </head>
    <body>
        <h1>🎯 Input Field Test</h1>
        <p>Test auto-scroll functionality by focusing on inputs below</p>
        
        <div class="form-section">
            <h2>Personal Information</h2>
            <div class="form-group">
                <label for="firstName">First Name</label>
                <input type="text" id="firstName" placeholder="Enter first name">
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" placeholder="your.email@example.com">
            </div>
            <div class="form-group">
                <label for="phone">Phone</label>
                <input type="tel" id="phone" placeholder="+1 (555) 123-4567">
            </div>
        </div>
        
        <div class="form-section">
            <h2>Address</h2>
            <div class="form-group">
                <label for="address">Street Address</label>
                <input type="text" id="address" placeholder="123 Main Street">
            </div>
            <div class="form-group">
                <label for="city">City</label>
                <input type="text" id="city" placeholder="Your city">
            </div>
            <div class="form-group">
                <label for="state">State</label>
                <select id="state">
                    <option value="">Select state...</option>
                    <option value="CA">California</option>
                    <option value="NY">New York</option>
                    <option value="TX">Texas</option>
                </select>
            </div>
        </div>
        
        <div class="form-section">
            <h2>Additional Info</h2>
            <div class="form-group">
                <label for="company">Company</label>
                <input type="text" id="company" placeholder="Company name">
            </div>
            <div class="form-group">
                <label for="bio">Biography</label>
                <textarea id="bio" rows="4" placeholder="Tell us about yourself..."></textarea>
            </div>
            <div class="form-group">
                <label for="comments">Comments</label>
                <textarea id="comments" rows="3" placeholder="Additional comments..."></textarea>
            </div>
        </div>
    </body>
    </html>
    ''';
  }
}