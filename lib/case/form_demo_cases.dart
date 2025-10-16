import 'package:auto_scroll_to_error/auto_scroll_to_error.dart';
import 'package:ensure_visible_when_focused/ensure_visible_when_focused.dart';
import 'package:flutter/material.dart';

/// 基础表单案例页面
class BasicFormCasePage extends StatefulWidget {
  const BasicFormCasePage({super.key});

  @override
  State<BasicFormCasePage> createState() => _BasicFormCasePageState();
}

class _BasicFormCasePageState extends State<BasicFormCasePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGender = '男';
  bool _agreeTerms = false;
  double _ageSlider = 25;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础表单'),
        backgroundColor: Colors.blue[100],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面说明
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '基础表单组件演示',
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
                      '• 文本输入框 (TextField)\n'
                      '• 下拉选择 (DropdownButton)\n'
                      '• 复选框 (Checkbox)\n'
                      '• 滑块 (Slider)\n'
                      '• 基础表单验证',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 基础输入框
              _buildSectionTitle('基础信息'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  hintText: '请输入您的姓名',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  hintText: '请输入邮箱地址',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  if (!value.contains('@')) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号码',
                  hintText: '请输入手机号码',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入手机号码';
                  }
                  if (value.length != 11) {
                    return '请输入11位手机号码';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // 选择组件
              _buildSectionTitle('选择项'),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    hint: const Text('请选择性别'),
                    isExpanded: true,
                    items: ['男', '女', '其他'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 滑块
              _buildSectionTitle('年龄选择'),
              Text('当前年龄: ${_ageSlider.round()}岁'),
              Slider(
                value: _ageSlider,
                min: 18,
                max: 80,
                divisions: 62,
                label: '${_ageSlider.round()}岁',
                onChanged: (double value) {
                  setState(() {
                    _ageSlider = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // 复选框
              _buildSectionTitle('协议确认'),
              CheckboxListTile(
                title: const Text('我同意用户协议和隐私政策'),
                value: _agreeTerms,
                onChanged: (bool? value) {
                  setState(() {
                    _agreeTerms = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _agreeTerms ? _submitForm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '提交表单',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 重置按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _resetForm,
                  child: const Text(
                    '重置表单',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 显示提交结果
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('表单提交成功'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('姓名: ${_nameController.text}'),
              Text('邮箱: ${_emailController.text}'),
              Text('手机: ${_phoneController.text}'),
              Text('性别: $_selectedGender'),
              Text('年龄: ${_ageSlider.round()}岁'),
              Text('同意协议: ${_agreeTerms ? "是" : "否"}'),
            ],
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

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _selectedGender = '男';
      _agreeTerms = false;
      _ageSlider = 25;
    });
    _formKey.currentState?.reset();
  }
}

/// 表单验证案例页面
class FormValidationCasePage extends StatefulWidget {
  const FormValidationCasePage({super.key});

  @override
  State<FormValidationCasePage> createState() => _FormValidationCasePageState();
}

class _FormValidationCasePageState extends State<FormValidationCasePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('表单验证'),
        backgroundColor: Colors.green[100],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面说明
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          '表单验证演示',
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
                      '• 实时验证\n'
                      '• 复杂验证规则\n'
                      '• 自定义错误提示\n'
                      '• 密码强度检测\n'
                      '• 确认密码验证',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 用户名验证
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  hintText: '请输入用户名 (3-20个字符)',
                  prefixIcon: Icon(Icons.account_circle),
                  border: OutlineInputBorder(),
                ),
                validator: _validateUsername,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),

              const SizedBox(height: 16),

              // 密码验证
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码 (至少8位，包含字母和数字)',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: _validatePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  // 当密码改变时，重新验证确认密码
                  if (_confirmPasswordController.text.isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                },
              ),

              const SizedBox(height: 8),

              // 密码强度指示器
              _buildPasswordStrengthIndicator(),

              const SizedBox(height: 16),

              // 确认密码验证
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  hintText: '请再次输入密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: _validateConfirmPassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),

              const SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '验证并提交',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名至少需要3个字符';
    }
    if (value.length > 20) {
      return '用户名不能超过20个字符';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return '用户名只能包含字母、数字和下划线';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 8) {
      return '密码至少需要8个字符';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return '密码必须包含至少一个字母和一个数字';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != _passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  Widget _buildPasswordStrengthIndicator() {
    String password = _passwordController.text;
    int strength = _calculatePasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('密码强度:', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  strength <= 1
                      ? Colors.red
                      : strength <= 2
                          ? Colors.orange
                          : strength <= 3
                              ? Colors.yellow
                              : Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              strength <= 1
                  ? '弱'
                  : strength <= 2
                      ? '中'
                      : strength <= 3
                          ? '强'
                          : '很强',
              style: TextStyle(
                fontSize: 12,
                color: strength <= 1
                    ? Colors.red
                    : strength <= 2
                        ? Colors.orange
                        : strength <= 3
                            ? Colors.yellow
                            : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('验证通过'),
          content: const Text('所有表单验证都已通过，可以提交数据！'),
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
}

/// 占位页面 - 其他表单案例
class ComplexFormCasePage extends StatelessWidget {
  const ComplexFormCasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('复杂表单布局'), backgroundColor: Colors.orange[100]),
      body: const Center(
          child: Text('复杂表单布局演示页面\n(待完善)', textAlign: TextAlign.center)),
    );
  }
}

class FormStateCasePage extends StatelessWidget {
  const FormStateCasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('表单状态管理'), backgroundColor: Colors.purple[100]),
      body: const Center(
          child: Text('表单状态管理演示页面\n(待完善)', textAlign: TextAlign.center)),
    );
  }
}

class CustomFormCasePage extends StatelessWidget {
  const CustomFormCasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('自定义表单组件'), backgroundColor: Colors.teal[100]),
      body: const Center(
          child: Text('自定义表单组件演示页面\n(待完善)', textAlign: TextAlign.center)),
    );
  }
}

class ResponsiveFormCasePage extends StatelessWidget {
  const ResponsiveFormCasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('响应式表单'), backgroundColor: Colors.indigo[100]),
      body: const Center(
          child: Text('响应式表单演示页面\n(待完善)', textAlign: TextAlign.center)),
    );
  }
}

/// 长表单智能滚动案例页面
class LongFormCasePage extends StatefulWidget {
  const LongFormCasePage({super.key});

  @override
  State<LongFormCasePage> createState() => _LongFormCasePageState();
}

class _LongFormCasePageState extends State<LongFormCasePage> {
  final _formKey = GlobalKey<FormState>();
  final _autoScrollKey = GlobalKey<AutoScrollToErrorState>();
  final _scrollController = ScrollController();

  // 创建多个输入框控制器和GlobalKey
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<GlobalKey> _fieldKeys = []; // 用于获取输入框的实际位置

  @override
  void initState() {
    super.initState();

    // 初始化20个输入框的控制器、焦点节点和Key
    for (int i = 0; i < 20; i++) {
      _controllers.add(TextEditingController());
      _fieldKeys.add(GlobalKey());
      final focusNode = FocusNode();
      focusNode.addListener(() => _onFocusChange(i, focusNode));
      _focusNodes.add(focusNode);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // 焦点变化时的处理
  void _onFocusChange(int index, FocusNode focusNode) {
    if (focusNode.hasFocus) {
      debugPrint('输入框 $index 获取焦点');
      // 使用延时确保键盘完全弹出后再滚动
      _scrollToFieldWithDelay(index);
    }
  }

  // 延时滚动到指定输入框
  void _scrollToFieldWithDelay(int index) {
    // 延时500ms确保键盘完全弹出
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performScrollToField(index);
      }
    });
  }

  void _performScrollToField(int index) {
    if (!mounted) return;

    try {
      final context = this.context;
      final mediaQuery = MediaQuery.of(context);
      final keyboardHeight = mediaQuery.viewInsets.bottom;
      final screenHeight = mediaQuery.size.height;
      final appBarHeight = kToolbarHeight + mediaQuery.padding.top;

      // 调试信息
      debugPrint('=== 滚动调试信息 ===');
      debugPrint('index: $index');
      debugPrint('keyboardHeight: $keyboardHeight');
      debugPrint('screenHeight: $screenHeight');
      debugPrint('appBarHeight: $appBarHeight');

      // 如果键盘高度仍然为0，使用预设值
      final effectiveKeyboardHeight =
          keyboardHeight > 0 ? keyboardHeight : 300.0; // 预设键盘高度300px
      debugPrint('使用的键盘高度: $effectiveKeyboardHeight');

      // 获取输入框的实际位置
      final RenderBox? renderBox =
          _fieldKeys[index].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        debugPrint('无法获取RenderBox，使用降级方案');
        _fallbackScrollToField(index, effectiveKeyboardHeight);
        return;
      }

      // 获取输入框相对于屏幕的位置
      final fieldPosition = renderBox.localToGlobal(Offset.zero);
      final fieldHeight = renderBox.size.height;

      debugPrint('输入框位置: ${fieldPosition.dy}');
      debugPrint('输入框高度: $fieldHeight');

      // 计算可见区域（排除AppBar和键盘）
      final visibleAreaTop = appBarHeight;
      final visibleAreaBottom = screenHeight - effectiveKeyboardHeight;
      final visibleAreaHeight = visibleAreaBottom - visibleAreaTop;

      debugPrint('可见区域顶部: $visibleAreaTop');
      debugPrint('可见区域底部: $visibleAreaBottom');
      debugPrint('可见区域高度: $visibleAreaHeight');

      // 计算目标位置：输入框中心应该在可见区域的中心
      final targetFieldCenter = visibleAreaTop + (visibleAreaHeight / 2);
      final fieldCenterY = fieldPosition.dy + (fieldHeight / 2);

      debugPrint('目标中心位置: $targetFieldCenter');
      debugPrint('输入框中心Y: $fieldCenterY');

      // 检查输入框是否已经在理想位置附近（允许50px的误差范围）
      final distanceFromTarget = (fieldCenterY - targetFieldCenter).abs();
      final toleranceRange = 50.0; // 50px的容差范围

      debugPrint('与目标位置的距离: $distanceFromTarget');
      debugPrint('容差范围: $toleranceRange');

      // 检查输入框是否在可见区域内
      final isFieldVisible = fieldPosition.dy >= visibleAreaTop &&
          (fieldPosition.dy + fieldHeight) <= visibleAreaBottom;

      debugPrint('输入框是否在可见区域内: $isFieldVisible');

      // 如果输入框已经在理想位置附近且完全可见，则不进行滚动
      if (distanceFromTarget <= toleranceRange && isFieldVisible) {
        debugPrint('输入框已在理想位置，无需滚动');
        debugPrint('========================\n');
        return;
      }

      // 计算需要的滚动偏移量
      final scrollOffset = fieldCenterY - targetFieldCenter;

      debugPrint('需要滚动偏移: $scrollOffset');

      // 获取当前滚动位置
      final currentScrollPosition = _scrollController.offset;
      final targetScrollPosition = currentScrollPosition + scrollOffset;

      // 限制滚动位置在合理范围内
      final maxScrollPosition = _scrollController.position.maxScrollExtent;
      final finalScrollPosition =
          targetScrollPosition.clamp(0.0, maxScrollPosition);

      debugPrint('当前滚动位置: $currentScrollPosition');
      debugPrint('目标滚动位置: $targetScrollPosition');
      debugPrint('最终滚动位置: $finalScrollPosition');

      // 执行滚动动画
      debugPrint('执行滚动动画');
      _scrollController.animateTo(
        finalScrollPosition,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );

      debugPrint('========================\n');
    } catch (e) {
      debugPrint('获取位置失败: $e');
      // 如果获取位置失败，使用降级方案
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final effectiveKeyboardHeight =
          keyboardHeight > 0 ? keyboardHeight : 300.0;
      _fallbackScrollToField(index, effectiveKeyboardHeight);
    }
  }

  // 降级方案：使用估算位置
  void _fallbackScrollToField(int index, [double? keyboardHeight]) {
    if (!mounted) return;

    final context = this.context;
    final mediaQuery = MediaQuery.of(context);
    final currentKeyboardHeight =
        keyboardHeight ?? mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final appBarHeight = kToolbarHeight + mediaQuery.padding.top;

    // 如果键盘高度仍然为0，使用预设值
    final effectiveKeyboardHeight =
        currentKeyboardHeight > 0 ? currentKeyboardHeight : 300.0;

    debugPrint('=== 降级方案调试信息 ===');
    debugPrint('使用的键盘高度(降级): $effectiveKeyboardHeight');

    // 计算可见区域
    final visibleAreaTop = appBarHeight;
    final visibleAreaBottom = screenHeight - effectiveKeyboardHeight;
    final availableHeight = visibleAreaBottom - visibleAreaTop;

    // 估算输入框位置（每个输入框约76px高度）
    final estimatedFieldTop = index * 76.0;
    final estimatedFieldCenter = estimatedFieldTop + 38.0; // 38是输入框高度的一半

    // 计算目标中心位置
    final targetCenter = visibleAreaTop + (availableHeight / 2);

    // 检查是否需要滚动（使用50px容差）
    final distanceFromTarget = (estimatedFieldCenter - targetCenter).abs();
    final toleranceRange = 50.0;

    debugPrint('估算的输入框中心位置(降级): $estimatedFieldCenter');
    debugPrint('目标中心位置(降级): $targetCenter');
    debugPrint('与目标位置的距离(降级): $distanceFromTarget');

    // 如果已经在理想位置附近，则不滚动
    if (distanceFromTarget <= toleranceRange) {
      debugPrint('输入框已在理想位置(降级)，无需滚动');
      debugPrint('========================\n');
      return;
    }

    // 计算目标滚动位置
    final targetScrollPosition =
        estimatedFieldTop - (availableHeight * 0.5) + 38;

    // 限制滚动位置在合理范围内
    final maxScrollPosition = _scrollController.position.maxScrollExtent;
    final finalScrollPosition =
        targetScrollPosition.clamp(0.0, maxScrollPosition);

    debugPrint('可用高度(降级): $availableHeight');
    debugPrint('估算位置(降级): $estimatedFieldTop');
    debugPrint('目标滚动(降级): $targetScrollPosition');
    debugPrint('最终位置(降级): $finalScrollPosition');
    debugPrint('执行滚动动画(降级)');
    debugPrint('========================\n');

    // 执行平滑滚动
    _scrollController.animateTo(
      finalScrollPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('长表单智能滚动'),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面说明
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.keyboard_arrow_down, color: Colors.deepPurple[700]),
                        const SizedBox(width: 8),
                        Text(
                          '长表单智能滚动演示',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 点击任意输入框获取焦点\n'
                      '• 键盘弹出后自动滚动到合适位置\n'
                      '• 输入框居于屏幕可见区域50%处\n'
                      '• 如果已在理想位置则不滚动\n'
                      '• 优化用户输入体验',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 生成20个输入框
              ...List.generate(20, (index) => Container(
                key: _fieldKeys[index], // 添加GlobalKey
                margin: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  decoration: InputDecoration(
                    labelText: '输入框 ${index + 1}',
                    hintText: '请输入内容 ${index + 1}',
                    prefixIcon: Icon(_getIconForIndex(index)),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return '请输入内容 ${index + 1}';
                    }
                    return null;
                  },
                ),
              )),
              
              const SizedBox(height: 32),
              
              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '提交表单',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 清空按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _clearForm,
                  child: const Text(
                    '清空表单',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              // 底部留白，保证最后一个输入框也能正常滚动
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  // 为不同的输入框返回不同的图标
  IconData _getIconForIndex(int index) {
    final icons = [
      Icons.person,
      Icons.email,
      Icons.phone,
      Icons.location_on,
      Icons.work,
      Icons.school,
      Icons.cake,
      Icons.favorite,
      Icons.star,
      Icons.home,
    ];
    return icons[index % icons.length];
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 统计填写的输入框数量
      int filledCount = 0;
      for (var controller in _controllers) {
        if (controller.text.isNotEmpty) {
          filledCount++;
        }
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('表单提交成功'),
          content: Text('您已填写了 $filledCount 个输入框的内容！'),
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
  
  void _clearForm() {
    for (var controller in _controllers) {
      controller.clear();
    }
    // 滚动到顶部
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('表单已清空'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class ErrorScrollForm extends StatefulWidget {
  const ErrorScrollForm({super.key});

  @override
  State<ErrorScrollForm> createState() => _ErrorScrollFormState();
}

class _ErrorScrollFormState extends State<ErrorScrollForm> {
  final _formKey = GlobalKey<FormState>();
  final _autoScrollKey = GlobalKey<AutoScrollToErrorState>();
  final _scrollController = ScrollController();

  // Generate a list of field keys for 12 fields
  final List<GlobalKey<FormFieldState<String>>> _fieldKeys =
  List.generate(12, (i) => GlobalKey<FormFieldState<String>>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Scroll To Error Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: AutoScrollToError(
        key: _autoScrollKey,
        formKey: _formKey,
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < _fieldKeys.length; i++) ...[
                  AutoScrollFormField<String>(
                    key: _fieldKeys[i],
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Field ${i + 1} required'
                        : null,
                    builder: (field) => TextField(
                      decoration: InputDecoration(
                        labelText: 'Field ${i + 1}',
                        errorText: field.errorText,
                      ),
                      onChanged: field.didChange,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
                ElevatedButton(
                  onPressed: () async {
                    // Validate the form
                    final valid = _formKey.currentState?.validate() ?? false;
                    if (!valid) {
                      // Scroll to the first error field
                      await _autoScrollKey.currentState?.scrollToFirstError();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form is valid!')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      ),
    );

  }}

class EnsureVisibleWhenFocusedPage extends StatefulWidget {
  const EnsureVisibleWhenFocusedPage({
    Key? key,
  }) : super(key: key);

  @override
  _EnsureVisibleWhenFocusedPageState createState() => _EnsureVisibleWhenFocusedPageState();
}

class _EnsureVisibleWhenFocusedPageState extends State<EnsureVisibleWhenFocusedPage> {
  late GlobalKey<FormState> _formKey;
  late FocusNode _focusNode;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  EnsureVisibleWhenFocused(
                    focusNode: _focusNode,
                    child: TextFormField(
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '* Form Field',
                      ),
                      validator: (value) => 'Required Field',
                    ),
                  ),
                  ...List.generate(
                    30,
                        (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Form Field ${i + 1}',
                        ),
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final _form = _formKey.currentState!;
            _form.validate();
            _focusNode.requestFocus();
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}







