import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/scroll_controller_extensions.dart';

/// Advanced form page with input masking and auto-scroll features
class AdvancedFormFeaturesPage extends StatefulWidget {
  const AdvancedFormFeaturesPage({super.key});

  @override
  State<AdvancedFormFeaturesPage> createState() => _AdvancedFormFeaturesPageState();
}

class _AdvancedFormFeaturesPageState extends State<AdvancedFormFeaturesPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _fieldKeys = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _selectedValues = {};
  
  // Simulated backend data with masking configuration
  final List<FormFieldData> _formFields = [
    FormFieldData(
      id: 'name',
      label: 'Full Name',
      type: FieldType.text,
      maskType: 0, // No masking
      value: 'John Doe',
    ),
    FormFieldData(
      id: 'phone',
      label: 'Phone Number',
      type: FieldType.text,
      maskType: 1, // Mask with **
      value: '13812345678',
    ),
    FormFieldData(
      id: 'country',
      label: 'Country',
      type: FieldType.dropdown,
      options: ['China', 'USA', 'Japan', 'Germany', 'France', 'UK'],
      maskType: 0,
    ),
    FormFieldData(
      id: 'email',
      label: 'Email Address',
      type: FieldType.text,
      maskType: 1, // Mask with **
      value: 'john.doe@example.com',
    ),
    FormFieldData(
      id: 'city',
      label: 'City',
      type: FieldType.dropdown,
      options: ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Hangzhou'],
      maskType: 0,
    ),
    FormFieldData(
      id: 'idNumber',
      label: 'ID Number',
      type: FieldType.text,
      maskType: 1, // Mask with **
      value: '123456789012345678',
    ),
    FormFieldData(
      id: 'occupation',
      label: 'Occupation',
      type: FieldType.dropdown,
      options: ['Engineer', 'Designer', 'Manager', 'Teacher', 'Doctor', 'Other'],
      maskType: 0,
    ),
    FormFieldData(
      id: 'bankAccount',
      label: 'Bank Account',
      type: FieldType.text,
      maskType: 1, // Mask with **
      value: '6222021234567890123',
    ),
    FormFieldData(
      id: 'education',
      label: 'Education Level',
      type: FieldType.dropdown,
      options: ['High School', 'Bachelor', 'Master', 'PhD'],
      maskType: 0,
    ),
    FormFieldData(
      id: 'address',
      label: 'Home Address',
      type: FieldType.text,
      maskType: 0, // No masking for address
      value: '123 Main Street, City',
    ),
    FormFieldData(
      id: 'industry',
      label: 'Industry',
      type: FieldType.dropdown,
      options: ['Technology', 'Finance', 'Healthcare', 'Education', 'Manufacturing'],
      maskType: 0,
    ),
    FormFieldData(
      id: 'salary',
      label: 'Annual Salary',
      type: FieldType.text,
      maskType: 1, // Mask salary
      value: '150000',
    ),
    FormFieldData(
      id: 'experience',
      label: 'Years of Experience',
      type: FieldType.dropdown,
      options: ['0-1', '2-5', '6-10', '11-15', '15+'],
      maskType: 0,
    ),
    FormFieldData(
      id: 'emergencyContact',
      label: 'Emergency Contact',
      type: FieldType.text,
      maskType: 1, // Mask contact info
      value: '13987654321',
    ),
    FormFieldData(
      id: 'department',
      label: 'Department',
      type: FieldType.dropdown,
      options: ['Engineering', 'Marketing', 'Sales', 'HR', 'Finance'],
      maskType: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (final field in _formFields) {
      _fieldKeys[field.id] = GlobalKey();
      if (field.type == FieldType.text) {
        _textControllers[field.id] = TextEditingController(
          text: _getMaskedValue(field.value ?? '', field.maskType),
        );
      }
    }
  }

  String _getMaskedValue(String value, int maskType) {
    if (maskType == 0 || value.isEmpty) {
      return value; // No masking
    }
    
    // maskType == 1: Mask with **
    if (value.length <= 4) {
      return '**'; // For very short values
    }
    
    // Show first 2 and last 2 characters, mask the middle
    final start = value.substring(0, 2);
    final end = value.substring(value.length - 2);
    final middleLength = value.length - 4;
    final maskedMiddle = '*' * (middleLength > 0 ? middleLength : 2);
    
    return '$start$maskedMiddle$end';
  }

  Future<void> _scrollToNextField(String currentFieldId) async {
    final currentIndex = _formFields.indexWhere((field) => field.id == currentFieldId);
    if (currentIndex < _formFields.length - 1) {
      // Find the next field
      final nextFieldId = _formFields[currentIndex + 1].id;
      final nextFieldKey = _fieldKeys[nextFieldId];
      
      if (nextFieldKey?.currentContext != null) {
        // Wait a bit for dropdown to close
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Use the extension method to scroll to the widget
        await _scrollController.scrollToWidget(
          nextFieldKey!,
          offset: 200, // 200px offset from top
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Form Features'),
        backgroundColor: Colors.green[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16),
            _buildScrollControlsSection(),
            const SizedBox(height: 24),
            ..._buildFormFields(),
            const SizedBox(height: 32),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollControlsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.control_camera, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'ScrollController Extension Demo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollUpByHeight(100),
                icon: const Icon(Icons.keyboard_arrow_up, size: 16),
                label: const Text('↑ 100px'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollDownByHeight(100),
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                label: const Text('↓ 100px'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollToTop(),
                icon: const Icon(Icons.vertical_align_top, size: 16),
                label: const Text('Top'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollToBottom(),
                icon: const Icon(Icons.vertical_align_bottom, size: 16),
                label: const Text('Bottom'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollByViewportPercentage(0.5),
                icon: const Icon(Icons.expand_more, size: 16),
                label: const Text('50% Down'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _scrollController.scrollByViewportPercentage(0.5, direction: -1),
                icon: const Icon(Icons.expand_less, size: 16),
                label: const Text('50% Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '🎮 Extension Methods Demo:\n'
            '• scrollUpByHeight() - Fixed height upward scroll\n'
            '• scrollDownByHeight() - Fixed height downward scroll\n'
            '• scrollToTop() / scrollToBottom() - Edge scrolling\n'
            '• scrollByViewportPercentage() - Viewport-based scrolling\n'
            '• scrollToWidget() - Auto-scroll to specific widgets',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: Colors.green[700], size: 28),
              const SizedBox(width: 12),
              Text(
                'Advanced Form Features Demo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '🎯 Key Features:\n'
            '• Input Masking: Fields with maskType=1 show ** masking\n'
            '• Auto-scroll: Dropdown selection triggers smooth scroll to next field\n'
            '• Backend Configuration: Masking controlled by server-side properties\n'
            '• User Experience: Smooth animations and intuitive navigation',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return _formFields.map((field) => 
      Container(
        key: _fieldKeys[field.id],
        margin: const EdgeInsets.only(bottom: 20),
        child: _buildFormField(field),
      )
    ).toList();
  }

  Widget _buildFormField(FormFieldData field) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (field.maskType == 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MASKED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (field.type == FieldType.text)
            _buildTextField(field)
          else if (field.type == FieldType.dropdown)
            _buildDropdownField(field),
        ],
      ),
    );
  }

  Widget _buildTextField(FormFieldData field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textControllers[field.id],
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[500]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          readOnly: field.maskType == 1, // Make masked fields read-only
        ),
        if (field.maskType == 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.security, size: 16, color: Colors.orange[600]),
                const SizedBox(width: 4),
                Text(
                  'Original: ${field.value ?? "N/A"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(FormFieldData field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedValues[field.id],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[500]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: Text('Select ${field.label.toLowerCase()}'),
          items: field.options?.map((option) => 
            DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            )
          ).toList(),
          onChanged: (value) {
            setState(() {
              _selectedValues[field.id] = value;
            });
            
            if (value != null) {
              // Auto-scroll to next field after selection
              _scrollToNextField(field.id);
            }
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.touch_app, size: 16, color: Colors.blue[600]),
            const SizedBox(width: 4),
            Text(
              'Auto-scrolls to next field after selection',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _showFormDataDialog(),
            icon: const Icon(Icons.send),
            label: const Text('Submit Form'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '📋 Form Summary:\n'
            '• Masked fields protect sensitive data\n'
            '• Dropdown selections enhance user flow\n'
            '• Automatic scrolling improves UX\n'
            '• Backend configuration controls masking',
            style: TextStyle(fontSize: 14, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFormDataDialog() {
    final formData = <String, String>{};
    
    for (final field in _formFields) {
      if (field.type == FieldType.text) {
        formData[field.label] = _textControllers[field.id]?.text ?? '';
      } else if (field.type == FieldType.dropdown) {
        formData[field.label] = _selectedValues[field.id] ?? 'Not selected';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: formData.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: entry.value),
                    ],
                  ),
                ),
              )
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Form Features'),
        content: const SingleChildScrollView(
          child: Text(
            '🎯 Feature Implementation:\n\n'
            '1. Input Field Masking:\n'
            '   • Backend provides maskType property (0=no mask, 1=mask)\n'
            '   • Masked fields show ** pattern while preserving original data\n'
            '   • Original values displayed for demo purposes\n\n'
            '2. Auto-scroll After Dropdown Selection:\n'
            '   • Automatically scrolls to next field after selection\n'
            '   • Smooth animation with 500ms duration\n'
            '   • 200px offset from top for optimal visibility\n\n'
            '3. Enhanced UX:\n'
            '   • Visual indicators for masked fields\n'
            '   • Form validation and data collection\n'
            '   • Responsive design with proper spacing\n'
            '   • Intuitive user flow guidance\n\n'
            '💡 Technical Details:\n'
            '• Uses GlobalKey for precise field targeting\n'
            '• ScrollController for smooth animations\n'
            '• State management for form data\n'
            '• Configurable masking logic\n'
            '• Platform-optimized performance',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

// Data models for form configuration
class FormFieldData {
  final String id;
  final String label;
  final FieldType type;
  final int maskType; // 0 = no mask, 1 = mask with **
  final String? value;
  final List<String>? options;

  FormFieldData({
    required this.id,
    required this.label,
    required this.type,
    required this.maskType,
    this.value,
    this.options,
  });
}

enum FieldType {
  text,
  dropdown,
}