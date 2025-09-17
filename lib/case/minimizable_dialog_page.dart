import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX Controller for managing dialog state and animations
class GetXDialogController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController dialogAnimationController;
  late AnimationController shrinkAnimationController;
  late Animation<double> scaleAnimation;
  late Animation<Offset> positionAnimation;
  
  RxBool isDialogVisible = false.obs;
  RxString dialogTitle = 'GetX Dialog Demo'.obs;
  RxString dialogContent = 'This is a GetX dialog that can shrink back to the FloatingActionButton with smooth animation!'.obs;
  Rx<Color> dialogColor = Colors.deepPurple.obs;
  Rx<IconData> dialogIcon = Icons.star.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Dialog appearance animation
    dialogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Shrink back to FAB animation
    shrinkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation for dialog
    scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: dialogAnimationController,
      curve: Curves.elasticOut,
    ));

    // Position animation for shrinking to FAB
    positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.8, 1.2), // Move towards bottom-right (FAB position)
    ).animate(CurvedAnimation(
      parent: shrinkAnimationController,
      curve: Curves.easeInBack,
    ));
  }

  void showGetXDialog() {
    isDialogVisible.value = true;
    dialogAnimationController.forward();
  }

  Future<void> closeDialogWithShrink() async {
    // Start shrink animation
    await shrinkAnimationController.forward();
    
    // Hide dialog and reset animations
    isDialogVisible.value = false;
    dialogAnimationController.reset();
    shrinkAnimationController.reset();
  }

  void updateDialogType(String type) {
    switch (type) {
      case 'success':
        dialogColor.value = Colors.green;
        dialogIcon.value = Icons.check_circle;
        dialogTitle.value = 'Success!';
        dialogContent.value = 'Operation completed successfully. This GetX dialog will shrink back to the FAB when closed.';
        break;
      case 'warning':
        dialogColor.value = Colors.orange;
        dialogIcon.value = Icons.warning;
        dialogTitle.value = 'Warning';
        dialogContent.value = 'Please review your action. This warning dialog can be minimized with GetX animation.';
        break;
      case 'error':
        dialogColor.value = Colors.red;
        dialogIcon.value = Icons.error;
        dialogTitle.value = 'Error Occurred';
        dialogContent.value = 'Something went wrong. Check the details and try again.';
        break;
      case 'info':
        dialogColor.value = Colors.blue;
        dialogIcon.value = Icons.info;
        dialogTitle.value = 'Information';
        dialogContent.value = 'Here is some important information for you to review.';
        break;
      default:
        dialogColor.value = Colors.deepPurple;
        dialogIcon.value = Icons.star;
        dialogTitle.value = 'GetX Dialog Demo';
        dialogContent.value = 'This is a GetX dialog that can shrink back to the FloatingActionButton with smooth animation!';
    }
  }

  @override
  void onClose() {
    dialogAnimationController.dispose();
    shrinkAnimationController.dispose();
    super.onClose();
  }
}

/// Page demonstrating a minimizable dialog that can be collapsed to a floating action button
class MinimizableDialogPage extends StatelessWidget {
  const MinimizableDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize GetX controller
    final controller = Get.put(GetXDialogController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Minimizable Dialog Demo'),
        backgroundColor: Colors.indigo[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildControlSection(controller),
            const SizedBox(height: 24),
            _buildDemoOptionsSection(controller),
            const SizedBox(height: 24),
            _buildInstructionsSection(),
          ],
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(controller),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(),
        const SizedBox(height: 16),
        // Additional content sections can be added here
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.indigo[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_in_picture, color: Colors.indigo[700], size: 28),
              const SizedBox(width: 12),
              Text(
                'Minimizable Dialog Demo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '🎯 Features:\n'
            '• GetX reactive state management with controllers\n'
            '• Dialog shrinks back to Scaffold\'s FloatingActionButton\n'
            '• Maintains dialog state during animations\n'
            '• Custom animation curves for smooth transitions\n'
            '• Interactive demo with customizable dialog types',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(GetXDialogController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GetX Dialog Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          
          // Status display with Obx
          Obx(() => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.isDialogVisible.value ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  controller.isDialogVisible.value ? Icons.visibility : Icons.visibility_off,
                  color: controller.isDialogVisible.value ? Colors.green[700] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Dialog Status: ${controller.isDialogVisible.value ? "Visible" : "Hidden"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: controller.isDialogVisible.value ? Colors.green[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showGetXDialog(controller),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Show GetX Dialog'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (Get.isDialogOpen ?? false) {
                      controller.closeDialogWithShrink();
                      Get.back();
                    }
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close Dialog'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
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

  Widget _buildDemoOptionsSection(GetXDialogController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize GetX Dialog',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          
          // Dialog type selection
          const Text('Dialog Type:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDialogTypeChip('Default', 'default', Icons.star, Colors.deepPurple, controller),
              _buildDialogTypeChip('Success', 'success', Icons.check_circle, Colors.green, controller),
              _buildDialogTypeChip('Warning', 'warning', Icons.warning, Colors.orange, controller),
              _buildDialogTypeChip('Error', 'error', Icons.error, Colors.red, controller),
              _buildDialogTypeChip('Info', 'info', Icons.info, Colors.blue, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTypeChip(String label, String type, IconData icon, Color color, GetXDialogController controller) {
    return ElevatedButton.icon(
      onPressed: () => controller.updateDialogType(type),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color),
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.purple[700]),
              const SizedBox(width: 8),
              Text(
                'How to Use',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. 📝 Select a dialog type to customize appearance\n'
            '2. 🎭 Click the FloatingActionButton to show GetX dialog\n'
            '3. 📦 Click "Close with Animation" to see shrink effect\n'
            '4. 🔄 The dialog will animate back to the FAB position\n'
            '5. ✅ Uses GetX reactive state management\n\n'
            '💡 Technical Details:\n'
            '• GetXController manages state and animations\n'
            '• Obx widgets for reactive UI updates\n'
            '• Custom AnimationController with elastic curves\n'
            '• Smooth shrink animation to FAB position\n'
            '• Proper memory cleanup with onClose()',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }



  Widget _buildAnimatedFAB(GetXDialogController controller) {
    return Obx(() => FloatingActionButton(
      onPressed: () => _showGetXDialog(controller),
      backgroundColor: controller.dialogColor.value,
      tooltip: 'Show GetX Dialog',
      child: Icon(controller.dialogIcon.value, color: Colors.white),
    ));
  }

  void _showGetXDialog(GetXDialogController controller) {
    controller.showGetXDialog();
    
    Get.dialog(
      AnimatedBuilder(
        animation: controller.dialogAnimationController,
        builder: (context, child) {
          return AnimatedBuilder(
            animation: controller.shrinkAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: controller.scaleAnimation.value * (1.0 - controller.shrinkAnimationController.value),
                child: Transform.translate(
                  offset: Offset(
                    controller.positionAnimation.value.dx * MediaQuery.of(context).size.width,
                    controller.positionAnimation.value.dy * MediaQuery.of(context).size.height,
                  ),
                  child: Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            controller.dialogColor.value.withOpacity(0.1),
                            Colors.white
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dialog header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: controller.dialogColor.value.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  controller.dialogIcon.value,
                                  color: controller.dialogColor.value,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  controller.dialogTitle.value,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: controller.dialogColor.value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Dialog content
                          Text(
                            controller.dialogContent.value,
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Dialog actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  controller.closeDialogWithShrink();
                                  Get.back();
                                },
                                child: const Text('Close with Animation'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  controller.isDialogVisible.value = false;
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: controller.dialogColor.value,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}