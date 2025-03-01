import 'package:flutter/material.dart';

class TextFieldPages extends StatefulWidget {
  const TextFieldPages({super.key});

  @override
  State<TextFieldPages> createState() => _TextFieldPagesState();
}

class _TextFieldPagesState extends State<TextFieldPages> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("输入框合集")),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildExampleSection("基础输入框"),
          _buildTextFieldWithBorder(),
          SizedBox(height: 20),
          _buildTextFieldWithCustomBorder(),
          SizedBox(height: 20),
          _buildActionButtons(),
          SizedBox(height: 220),
          // test softKeyboard behavior
          // _buildTextField(),
        ],
      ),
    );
  }


  ///  自动滚动避免键盘遮挡
  // SingleChildScrollView(
  //   padding: EdgeInsets.only(
  //     bottom: MediaQuery.of(context).viewInsets.bottom + 20
  //   ),
  // )
  Widget _buildTextFieldWithBorder() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        labelText: "请输入内容",
        floatingLabelBehavior: FloatingLabelBehavior.auto, // 默认自动浮动
        hintText: 'Enter your info',
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: _textFieldBorder(),
        enabledBorder: _textFieldBorder(),
        focusedBorder: _textFieldBorder(color: Colors.lightBlue[200]!),
        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
        suffixIcon: _textController.text.isEmpty
            ? null
            : IconButton(
          icon: Icon(Icons.clear, color: Colors.grey[600]),
          onPressed: () => _textController.clear(),
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildTextFieldWithCustomBorder() {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: TextField(
        obscureText: true,
        controller: _textController,
        focusNode: _focusNode,
        style: TextStyle(
            fontSize: 14, color: Colors.black, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          fillColor: Colors.white.withValues(alpha: 0.9),
          labelText: "请输入内容",
          labelStyle: TextStyle(color: Colors.amber[600]),
          floatingLabelStyle: TextStyle(color: Colors.amber[100]),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
          suffixIcon: _textController.text.isEmpty
              ? null
              : IconButton(
            icon: Icon(Icons.visibility_off_outlined, color: Colors.grey[600]),
            onPressed: () => _textController.clear(),
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  OutlineInputBorder _textFieldBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color ?? Colors.grey[400]!,
        width: 1.5,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: Text('Cancel', style: TextStyle(color: Colors.blue[800])),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildExampleSection(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800]
          )
      ),
    );
  }

}
