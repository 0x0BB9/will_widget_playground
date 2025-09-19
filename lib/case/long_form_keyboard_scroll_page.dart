import 'package:flutter/material.dart';

/// Configuration class for form fields
class FormFieldConfig {
  final String section;
  final String label;
  final IconData icon;

  const FormFieldConfig(this.section, this.label, this.icon);
}

/// Long form page with smart keyboard-aware scrolling
class LongFormKeyboardScrollPage extends StatefulWidget {
  const LongFormKeyboardScrollPage({super.key});

  @override
  State<LongFormKeyboardScrollPage> createState() => _LongFormKeyboardScrollPageState();
}

class _LongFormKeyboardScrollPageState extends State<LongFormKeyboardScrollPage> {
  final ScrollController _scrollController = ScrollController();
  final List<TextEditingController> _textControllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<GlobalKey> _fieldKeys = [];
  
  // Form field configurations
  final List<FormFieldConfig> _formFields = [
    FormFieldConfig('Personal Information', 'First Name', Icons.person),
    FormFieldConfig('Personal Information', 'Last Name', Icons.person_outline),
    FormFieldConfig('Personal Information', 'Email Address', Icons.email),
    FormFieldConfig('Personal Information', 'Phone Number', Icons.phone),
    FormFieldConfig('Personal Information', 'Date of Birth', Icons.calendar_today),
    FormFieldConfig('Address Information', 'Street Address', Icons.home),
    FormFieldConfig('Address Information', 'City', Icons.location_city),
    FormFieldConfig('Address Information', 'State/Province', Icons.map),
    FormFieldConfig('Address Information', 'Postal Code', Icons.local_post_office),
    FormFieldConfig('Address Information', 'Country', Icons.public),
    FormFieldConfig('Professional Information', 'Company Name', Icons.business),
    FormFieldConfig('Professional Information', 'Job Title', Icons.work),
    FormFieldConfig('Professional Information', 'Years of Experience', Icons.timeline),
    FormFieldConfig('Professional Information', 'Industry', Icons.category),
    FormFieldConfig('Professional Information', 'Annual Income', Icons.attach_money),
    FormFieldConfig('Additional Information', 'Emergency Contact Name', Icons.contact_emergency),
    FormFieldConfig('Additional Information', 'Emergency Contact Phone', Icons.phone_callback),
    FormFieldConfig('Additional Information', 'Relationship', Icons.family_restroom),
    FormFieldConfig('Additional Information', 'Medical Conditions', Icons.medical_services),
    FormFieldConfig('Additional Information', 'Special Notes', Icons.note_alt),
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormControllers();
  }

  void _initializeFormControllers() {
    for (int i = 0; i < _formFields.length; i++) {
      _textControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _fieldKeys.add(GlobalKey());
      
      // Add focus listener for each field
      _focusNodes[i].addListener(() => _onFocusChanged(i));
    }
  }

  void _onFocusChanged(int index) {
    if (_focusNodes[index].hasFocus) {
      print('🎯 输入框 $index 获取焦点: ${_formFields[index].label}');
      _scrollToShowCurrentAndNextField(index);
    }
  }

  void _scrollToShowCurrentAndNextField(int currentIndex) {
    // 使用 WidgetsBinding 监听下一帧，确保键盘状态已更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performScrollAdjustment(currentIndex);
    });
  }

  void _performScrollAdjustment(int currentIndex) async {
    // 等待一小段时间让键盘开始弹出
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!mounted) return;
    
    // 获取当前键盘高度
    double currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // 如果键盘还没弹出，等待并重试
    if (currentKeyboardHeight == 0) {
      await _waitForKeyboard(currentIndex);
      return;
    }
    
    _calculateAndScroll(currentIndex, currentKeyboardHeight);
  }
  
  Future<void> _waitForKeyboard(int currentIndex) async {
    const maxWaitTime = 1000; // 最大等待1秒
    const checkInterval = 50;  // 每50ms检查一次
    int elapsedTime = 0;
    
    while (elapsedTime < maxWaitTime && mounted) {
      await Future.delayed(const Duration(milliseconds: checkInterval));
      elapsedTime += checkInterval;
      
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (keyboardHeight > 0) {
        print('🎹 键盘检测到，高度: ${keyboardHeight.toInt()}px，等待时间: ${elapsedTime}ms');
        _calculateAndScroll(currentIndex, keyboardHeight);
        return;
      }
    }
    
    // 🔧 修复：超时后使用预估键盘高度进行计算
    print('⚠️ 键盘检测超时，使用预估键盘高度');
    final screenHeight = MediaQuery.of(context).size.height;
    final estimatedKeyboardHeight = screenHeight * 0.4; // 预估键盘高度为屏幕40%
    _calculateAndScroll(currentIndex, estimatedKeyboardHeight);
  }
  
  void _calculateAndScroll(int currentIndex, double keyboardHeight) async {
    if (!mounted) return;
    
    // 获取屏幕尺寸
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - keyboardHeight;
    
    // 确保有足够的可用高度
    if (availableHeight < 200) {
      print('⚠️ 可用高度太小，跳过滚动调整');
      return;
    }
    
    // 估算单个输入框的高度（包含间距）
    const inputFieldHeight = 80.0;
    
    // 计算当前输入框的位置
    final currentFieldKey = _fieldKeys[currentIndex];
    if (currentFieldKey.currentContext == null) return;
    
    final RenderBox currentFieldBox = currentFieldKey.currentContext!.findRenderObject() as RenderBox;
    final currentFieldPosition = currentFieldBox.localToGlobal(Offset.zero);
    
    // 检查是否需要滚动
    bool needsScrolling = _shouldScroll(currentIndex, currentFieldPosition.dy, availableHeight, inputFieldHeight);
    
    if (!needsScrolling) {
      print('✅ 当前和下一个输入框已可见，无需滚动');
      return;
    }
    
    // 🔧 优化：智能计算目标位置
    // 目标：让当前输入框和下一个输入框都在键盘上方可见，同时最大化利用可见空间
    double targetScreenY;
    
    if (currentIndex >= _formFields.length - 1) {
      // 最后一个输入框：留出一个输入框高度的缓冲空间
      targetScreenY = availableHeight - inputFieldHeight * 1.5;
    } else {
      // 非最后一个输入框：确保当前和下一个输入框都可见
      // 留出两个输入框高度的空间，但不要过于保守
      final bufferSpace = inputFieldHeight * 1.8; // 稍微减少缓冲空间
      targetScreenY = availableHeight - bufferSpace;
    }
    
    // 计算需要的滚动距离
    final requiredScrollDistance = currentFieldPosition.dy - targetScreenY;
    final newScrollOffset = _scrollController.offset + requiredScrollDistance;
    
    // 限制在有效滚动范围内
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final clampedOffset = newScrollOffset.clamp(0.0, maxScrollExtent);
    
    print('🎯 滚动计算: 当前输入框Y=${currentFieldPosition.dy.toInt()}, 目标Y=${targetScreenY.toInt()}, 需要滚动=${requiredScrollDistance.toInt()}, 最终滚动到=${clampedOffset.toInt()}');
    
    // 平滑滚动到目标位置
    await _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
  
  /// 判断是否需要滚动
  /// 基于当前输入框和下一个输入框的可见性进行智能判断
  bool _shouldScroll(int currentIndex, double currentFieldY, double availableHeight, double inputFieldHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 🔧 强制滚动阈值：当输入框Y位置超过屏幕高度40%时强制滚动
    // 这可以防止底部输入框在初始焦点时被键盘遮挡
    if (currentFieldY > screenHeight * 0.4) {
      print('🎯 输入框位置超过40%阈值，强制滚动');
      return true;
    }
    
    // 检查当前输入框是否被键盘遮挡
    final currentFieldBottomY = currentFieldY + inputFieldHeight;
    if (currentFieldBottomY > availableHeight) {
      print('🎯 当前输入框被键盘遮挡，需要滚动');
      return true;
    }
    
    // 如果是最后一个输入框，只要当前框可见就不需要滚动
    if (currentIndex >= _formFields.length - 1) {
      return false;
    }
    
    // 检查下一个输入框是否存在且可见
    final nextFieldKey = _fieldKeys[currentIndex + 1];
    if (nextFieldKey.currentContext == null) {
      // 下一个输入框未渲染，保持当前判断结果
      return false;
    }
    
    final RenderBox nextFieldBox = nextFieldKey.currentContext!.findRenderObject() as RenderBox;
    final nextFieldPosition = nextFieldBox.localToGlobal(Offset.zero);
    final nextFieldBottomY = nextFieldPosition.dy + inputFieldHeight;
    
    // 检查下一个输入框是否完全可见
    if (nextFieldBottomY > availableHeight) {
      print('🎯 下一个输入框不完全可见，需要滚动');
      return true;
    }
    
    print('✅ 当前和下一个输入框都可见，无需滚动');
    return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 禁用自动resize，使用自定义滚动逻辑
      appBar: AppBar(
        title: const Text('Smart Keyboard Scroll Form'),
        backgroundColor: Colors.indigo[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllFields,
            tooltip: 'Clear All Fields',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInstructionHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildFormSections(),
                  const SizedBox(height: 32),
                  _buildSubmitSection(),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.indigo[100]!],
        ),
        border: Border(bottom: BorderSide(color: Colors.indigo[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.keyboard, color: Colors.indigo[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Smart Keyboard Scrolling',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '🎯 点击任意输入框，体验智能滚动效果！\n'
            '📱 表单自动定位，让键盘上方刚好显示当前和下一个输入框\n'
            '⌨️ 键盘感知滚动，确保最优可见性，不多不少刚刚好',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormSections() {
    final sections = <String, List<int>>{};
    
    for (int i = 0; i < _formFields.length; i++) {
      final sectionName = _formFields[i].section;
      sections[sectionName] ??= [];
      sections[sectionName]!.add(i);
    }
    
    final widgets = <Widget>[];
    
    sections.forEach((sectionName, fieldIndices) {
      widgets.add(_buildSectionHeader(sectionName));
      widgets.add(const SizedBox(height: 16));
      
      for (int index in fieldIndices) {
        widgets.add(_buildFormField(index));
        widgets.add(const SizedBox(height: 16));
      }
      
      widgets.add(const SizedBox(height: 8));
    });
    
    return widgets;
  }

  Widget _buildSectionHeader(String sectionName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        sectionName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildFormField(int index) {
    final field = _formFields[index];
    final isLastField = index == _formFields.length - 1;
    
    return Container(
      key: _fieldKeys[index],
      child: TextFormField(
        controller: _textControllers[index],
        focusNode: _focusNodes[index],
        decoration: InputDecoration(
          labelText: field.label,
          prefixIcon: Icon(field.icon, color: Colors.indigo[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
          ),
          suffixIcon: isLastField 
            ? Icon(Icons.check_circle_outline, color: Colors.green[600])
            : Icon(Icons.arrow_downward, color: Colors.grey[400], size: 16),
        ),
        textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (value) {
          if (!isLastField) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 48),
          const SizedBox(height: 16),
          Text(
            'Form Complete!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '所有输入框都已配置了智能键盘滚动功能。\n'
            '尝试点击不同的输入框，体验智能定位效果！',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAllFields,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearAllFields() {
    for (var controller in _textControllers) {
      controller.clear();
    }
    
    for (var focusNode in _focusNodes) {
      focusNode.unfocus();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All fields cleared'),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitForm() {
    final filledFields = _textControllers.where((controller) => controller.text.isNotEmpty).length;
    
    if (filledFields == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill at least one field to test the form'),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form submitted successfully! ($filledFields fields filled)'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }
}