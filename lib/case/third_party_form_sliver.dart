import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';

/// Specialized Sliver WebView solution for third-party forms
class ThirdPartyFormSliverPage extends StatefulWidget {
  const ThirdPartyFormSliverPage({super.key});

  @override
  State<ThirdPartyFormSliverPage> createState() => _ThirdPartyFormSliverPageState();
}

class _ThirdPartyFormSliverPageState extends State<ThirdPartyFormSliverPage> {
  late final WebViewController _webViewController;
  late final ScrollController _scrollController;
  final ValueNotifier<double> _contentHeightNotifier = ValueNotifier<double>(800);
  
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _heightDetectionTimer;
  String _debugInfo = 'Loading third-party form...';
  int _heightUpdateCount = 0;
  bool _isInputFocused = false;
  double _focusedInputTop = 0;
  
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
          onPageStarted: (String url) {
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoading = true;
                _debugInfo = 'Loading: $url';
              });
            }
          },
          onPageFinished: (String url) {
            if (!_isDisposed && mounted) {
              setState(() {
                _isLoading = false;
                _debugInfo = 'Page loaded, detecting height...';
              });
              _setupWebViewFeatures();
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
        'HeightChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_isDisposed && mounted) {
            final height = double.tryParse(message.message);
            if (height != null && height >= 100) {
              final adjustedHeight = height > 4000 ? 4000.0 : height;
              _contentHeightNotifier.value = adjustedHeight;
              setState(() {
                _heightUpdateCount++;
                _debugInfo = 'Height: ${height.toInt()}px (Update #$_heightUpdateCount)';
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
      ..addJavaScriptChannel(
        'DebugChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_isDisposed && mounted) {
            setState(() {
              _debugInfo = 'JS: ${message.message}';
            });
          }
        },
      )
      // Load the actual third-party form
      ..loadRequest(Uri.parse('https://integration.unnax.com/widget/reader/?sid=s_d6d59d6328204e5f93a1c04b75c4f913'));
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
    
    // Multiple detection attempts for dynamic content
    final delays = [2000, 5000, 8000, 12000]; // Progressive delays
    
    for (int i = 0; i < delays.length; i++) {
      Timer(Duration(milliseconds: delays[i]), () {
        if (!_isDisposed && mounted) {
          _runHeightDetection(i + 1);
        }
      });
    }
  }

  void _runHeightDetection(int attempt) {
    if (_isDisposed) return;
    
    _webViewController.runJavaScript('''
      (function() {
        try {
          DebugChannel.postMessage('Height detection attempt $attempt');
          
          // Wait for potential lazy-loaded content
          setTimeout(() => {
            // Multiple height calculation strategies
            const body = document.body;
            const html = document.documentElement;
            
            const heights = [
              body?.scrollHeight || 0,
              body?.offsetHeight || 0,
              html?.scrollHeight || 0,
              html?.offsetHeight || 0,
              body?.getBoundingClientRect().height || 0
            ];
            
            // Check for iframes which might contain the actual form
            const iframes = document.querySelectorAll('iframe');
            iframes.forEach(iframe => {
              try {
                if (iframe.contentDocument) {
                  heights.push(iframe.contentDocument.body?.scrollHeight || 0);
                  heights.push(iframe.contentDocument.documentElement?.scrollHeight || 0);
                }
              } catch(e) {
                // Cross-origin iframe, can't access content
              }
            });
            
            const maxHeight = Math.max(...heights.filter(h => h > 0));
            
            // Log details for debugging
            DebugChannel.postMessage('Heights found: ' + JSON.stringify(heights));
            DebugChannel.postMessage('Selected height: ' + maxHeight);
            
            if (maxHeight > 200) {
              HeightChannel.postMessage(maxHeight.toString());
            }
            
            // Setup input detection
            const inputs = document.querySelectorAll('input, textarea, select, [contenteditable]');
            DebugChannel.postMessage('Found ' + inputs.length + ' input elements');
            
            inputs.forEach((input, index) => {
              input.addEventListener('focus', function() {
                const rect = this.getBoundingClientRect();
                const focusData = {
                  focused: true,
                  top: rect.top + window.pageYOffset
                };
                this.scrollIntoView({ behavior: 'smooth', block: 'center' });
                InputFocusChannel.postMessage(JSON.stringify(focusData));
              });
              
              input.addEventListener('blur', function() {
                InputFocusChannel.postMessage(JSON.stringify({focused: false, top: 0}));
              });
            });
            
            // Check for dynamically loaded content
            if (window.MutationObserver && attempt <= 2) {
              const observer = new MutationObserver((mutations) => {
                let hasChanges = false;
                mutations.forEach((mutation) => {
                  if (mutation.addedNodes.length > 0) {
                    hasChanges = true;
                  }
                });
                
                if (hasChanges) {
                  setTimeout(() => {
                    const newHeight = Math.max(
                      document.body?.scrollHeight || 0,
                      document.documentElement?.scrollHeight || 0
                    );
                    if (newHeight > maxHeight + 100) {
                      HeightChannel.postMessage(newHeight.toString());
                      DebugChannel.postMessage('Height updated due to DOM changes: ' + newHeight);
                    }
                  }, 1000);
                }
              });
              
              observer.observe(document.body, {
                childList: true,
                subtree: true
              });
            }
            
          }, 1000);
          
        } catch (error) {
          DebugChannel.postMessage('Error in height detection: ' + error.message);
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third-party Form Sliver'),
        backgroundColor: Colors.purple[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _runHeightDetection(99),
          ),
        ],
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
      color: Colors.purple[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Third-party Form Test', 
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple[700])),
          const SizedBox(height: 8),
          Text('Content Height: ${contentHeight.toInt()}px'),
          Text('Debug: $_debugInfo', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          if (_isInputFocused) 
            Text('Input Focused at: ${_focusedInputTop.toInt()}px', 
                 style: TextStyle(color: Colors.orange[700])),
          const SizedBox(height: 8),
          const Text('🎯 Testing real third-party form:\n• Progressive height detection\n• Cross-frame content handling\n• Dynamic content monitoring'),
        ],
      ),
    );
  }

  Widget _buildWebViewContainer(double contentHeight) {
    return Container(
      height: contentHeight,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
                      Text('Loading third-party form...'),
                    ],
                  ),
                ),
              ),
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
        '✨ Third-party Form Features:\n'
        '• Progressive height detection with multiple attempts\n'
        '• Cross-frame content handling for embedded forms\n'
        '• Advanced DOM mutation monitoring\n'
        '• Real-time debug information\n'
        '• Handles slow-loading dynamic content',
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}