import 'package:flutter/material.dart';
import '../utils/scroll_controller_extensions.dart';

/// Demo page showcasing ScrollController extension methods
class ScrollControllerDemoPage extends StatefulWidget {
  const ScrollControllerDemoPage({super.key});

  @override
  State<ScrollControllerDemoPage> createState() => _ScrollControllerDemoPageState();
}

class _ScrollControllerDemoPageState extends State<ScrollControllerDemoPage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];
  
  @override
  void initState() {
    super.initState();
    // Initialize keys for each section
    for (int i = 0; i < 10; i++) {
      _sectionKeys.add(GlobalKey());
    }
    
    // Listen to scroll changes for demo
    _scrollController.addListener(() {
      setState(() {}); // Update UI to show scroll position
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScrollController Extensions Demo'),
        backgroundColor: Colors.indigo[100],
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildInfoSection(),
                  ..._buildDemoSections(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    final hasClients = _scrollController.hasClients;
    final scrollPercentage = hasClients ? _scrollController.scrollPercentage : 0.0;
    final isAtTop = hasClients ? _scrollController.isAtTop : true;
    final isAtBottom = hasClients ? _scrollController.isAtBottom : false;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        border: Border(bottom: BorderSide(color: Colors.indigo[200]!)),
      ),
      child: Column(
        children: [
          // Scroll position indicator
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scroll Position: ${(scrollPercentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[700],
                      ),
                    ),
                    Text(
                      'At Top: $isAtTop | At Bottom: $isAtBottom',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Fixed height controls
          const Text('Fixed Height Scrolling:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollUpByHeight(50),
                icon: const Icon(Icons.keyboard_arrow_up, size: 16),
                label: const Text('↑ 50px'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollUpByHeight(100),
                icon: const Icon(Icons.keyboard_double_arrow_up, size: 16),
                label: const Text('↑ 100px'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollDownByHeight(50),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                label: const Text('↓ 50px'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollDownByHeight(100),
                icon: const Icon(Icons.keyboard_double_arrow_down, size: 16),
                label: const Text('↓ 100px'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Viewport percentage controls
          const Text('Viewport Percentage Scrolling:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollByViewportPercentage(0.25, direction: -1),
                icon: const Icon(Icons.expand_less, size: 16),
                label: const Text('25% Up'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollByViewportPercentage(0.25),
                icon: const Icon(Icons.expand_more, size: 16),
                label: const Text('25% Down'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollByViewportPercentage(0.5, direction: -1),
                icon: const Icon(Icons.expand_less, size: 16),
                label: const Text('50% Up'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollByViewportPercentage(0.5),
                icon: const Icon(Icons.expand_more, size: 16),
                label: const Text('50% Down'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollToTop(),
                icon: const Icon(Icons.vertical_align_top, size: 16),
                label: const Text('To Top'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[600]),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollToBottom(),
                icon: const Icon(Icons.vertical_align_bottom, size: 16),
                label: const Text('To Bottom'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Widget targeting controls
          const Text('Scroll to Specific Sections:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (index) => 
              ElevatedButton(
                onPressed: () => _scrollController.scrollToWidget(
                  _sectionKeys[index * 2],
                  offset: 100,
                ),
                child: Text('Section ${index * 2 + 1}'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.extension, color: Colors.blue[700], size: 28),
              const SizedBox(width: 12),
              Text(
                'ScrollController Extensions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '🎯 Available Extension Methods:\n\n'
            '• scrollUpByHeight(height) - 向上固定高度滚动\n'
            '• scrollDownByHeight(height) - 向下固定高度滚动\n'
            '• scrollToWidget(key, offset) - 滚动到指定组件\n'
            '• scrollToTop() - 滚动到顶部\n'
            '• scrollToBottom() - 滚动到底部\n'
            '• scrollByViewportPercentage(%) - 按视口百分比滚动\n\n'
            '📊 Useful Properties:\n\n'
            '• isAtTop - 是否在顶部\n'
            '• isAtBottom - 是否在底部\n'
            '• scrollPercentage - 滚动百分比 (0.0-1.0)\n\n'
            '✨ All methods support custom duration and curve animations!',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDemoSections() {
    return List.generate(10, (index) {
      final colors = [
        Colors.red[100]!,
        Colors.green[100]!,
        Colors.blue[100]!,
        Colors.orange[100]!,
        Colors.purple[100]!,
      ];
      
      return Container(
        key: _sectionKeys[index],
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        height: 200,
        decoration: BoxDecoration(
          color: colors[index % colors.length],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Demo Section ${index + 1}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the controls above to scroll to this section\n'
              'or test fixed-height scrolling from here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _scrollController.scrollUpByHeight(150),
                  child: const Text('↑ 150px'),
                ),
                ElevatedButton(
                  onPressed: () => _scrollController.scrollDownByHeight(150),
                  child: const Text('↓ 150px'),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}