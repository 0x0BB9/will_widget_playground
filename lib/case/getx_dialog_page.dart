import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX Controller for managing minimizable dialog state
class GetXDialogController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> fabPulseAnimation;

  // Dialog content properties
  var dialogTitle = 'GetX Notification'.obs;
  var dialogContent = 'This is a GetX dialog with shrinking animation back to FloatingActionButton.'.obs;
  var dialogIcon = Icons.notifications_active.obs;
  var dialogColor = Rx<Color>(Colors.blue);
  
  // Dialog state
  var isDialogVisible = false.obs;
  var fabPulseScale = 1.0.obs;
  var isClosing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Simple animations for overlay use
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInBack,
    ));

    slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 1.2),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInQuart,
    ));

    fabPulseAnimation = Tween<double>(
      begin: 1.0,  
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticOut,
    ));
  }

  void showDialog() {
    print('🎯 GetX Dialog: showDialog called');
    
    // 安全检查：确保页面状态正常
    if (!_canShowDialog()) {
      print('❌ 页面状态不允许显示弹窗');
      return;
    }
    
    // Reset all states and animation
    isDialogVisible.value = true;
    isClosing.value = false; // Reset closing state
    animationController.reset(); // Ensure animation starts from beginning
    
    Get.dialog(
      GetXAnimatedDialog(),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }
  
  /// 检查是否可以显示弹窗
  bool _canShowDialog() {
    // 1. 检查弹窗是否已打开
    if (Get.isDialogOpen == true) {
      print('❌ 弹窗已打开');
      return false;
    }
    
    // 2. 检查上下文是否有效
    if (Get.context == null || !Get.context!.mounted) {
      print('❌ 页面上下文无效');
      return false;
    }
    
    // 3. 检查当前路由
    final currentRoute = Get.currentRoute;
    if (currentRoute.isEmpty || !currentRoute.contains('GetXDialogPage')) {
      print('❌ 不在目标页面：$currentRoute');
      return false;
    }
    
    print('✅ 可以显示弹窗');
    return true;
  }

  void closeDialogWithAnimation() async {
    print('🎯 Starting shrink animation');
    
    // Mark as closing to prevent flash
    isClosing.value = true;
    
    // Close GetX dialog immediately to prevent lifecycle interference
    Get.back();
    
    // Create overlay animation that runs independently
    await _runOverlayAnimation();
    
    // Reset states
    isDialogVisible.value = false;
    isClosing.value = false;
    
    // Trigger FAB pulse effect
    _triggerFabPulse();
  }
  
  Future<void> _runOverlayAnimation() async {
    // Get overlay state
    final overlay = Overlay.of(Get.overlayContext!);
    
    // Create animated overlay entry
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _buildShrinkingOverlay(context),
    );
    
    // Insert overlay
    overlay.insert(overlayEntry);
    
    // Run animation
    animationController.forward();
    
    // Wait for completion
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Remove overlay
    overlayEntry.remove();
    
    // Reset animation
    animationController.reset();
  }
  
  Widget _buildShrinkingOverlay(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final fabSize = 56.0;
        final fabMargin = 16.0;
        final fabPosition = Offset(
          screenSize.width - fabMargin - (fabSize / 2),
          screenSize.height - fabMargin - (fabSize / 2) - kBottomNavigationBarHeight,
        );
        
        final centerPosition = Offset(screenSize.width / 2, screenSize.height / 2);
        final slideDirection = (fabPosition - centerPosition);
        final normalizedSlide = Offset(
          slideDirection.dx / screenSize.width,
          slideDirection.dy / screenSize.height,
        );
        
        return Transform.translate(
          offset: Offset(
            normalizedSlide.dx * screenSize.width * animationController.value,
            normalizedSlide.dy * screenSize.height * animationController.value,
          ),
          child: Transform.scale(
            scale: 1.0 - animationController.value,
            child: Opacity(
              opacity: 1.0 - (animationController.value * 0.8),
              child: Center(
                child: Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          dialogColor.value.withOpacity(0.1),
                          Colors.white
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: dialogColor.value.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                dialogIcon.value,
                                color: dialogColor.value,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                dialogTitle.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: dialogColor.value,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          dialogContent.value,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void closeDialogDirectly() {
    Get.back();
    isDialogVisible.value = false;
    isClosing.value = false;
    animationController.reset(); // Reset animation state
  }

  void _triggerFabPulse() {
    // Animate FAB pulse effect
    fabPulseScale.value = 1.3;
    
    Future.delayed(const Duration(milliseconds: 200), () {
      fabPulseScale.value = 1.0;
    });
  }

  void updateDialogType(String type, IconData icon, Color color) {
    dialogTitle.value = '$type Notification';
    dialogIcon.value = icon;
    dialogColor.value = color;
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

/// GetX Dialog Widget with shrinking animation
class GetXAnimatedDialog extends StatefulWidget {
  const GetXAnimatedDialog({super.key});

  @override
  State<GetXAnimatedDialog> createState() => _GetXAnimatedDialogState();
}

class _GetXAnimatedDialogState extends State<GetXAnimatedDialog> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GetXDialogController>();
    
    // Simple dialog without complex animation logic
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Obx(() => Container(
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
                  onPressed: controller.closeDialogDirectly,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: controller.closeDialogWithAnimation,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.dialogColor.value,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}

/// Main page demonstrating GetX dialog with shrinking animation
class GetXDialogPage extends StatelessWidget {
  const GetXDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(GetXDialogController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Minimizable Dialog'),
        backgroundColor: Colors.teal[100],
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
            _buildCustomizationSection(controller),
            const SizedBox(height: 24),
            _buildInstructionsSection(),
          ],
        ),
      ),
      floatingActionButton: Obx(() => AnimatedScale(
        scale: controller.fabPulseScale.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        child: FloatingActionButton(
          onPressed: controller.isDialogVisible.value ? null : () {
            print('🎯 FAB pressed: Show GetX Dialog');
            controller.showDialog();
          },
          backgroundColor: controller.dialogColor.value,
          tooltip: 'Show GetX Dialog',
          child: Icon(
            controller.dialogIcon.value,
            color: Colors.white,
          ),
        ),
      )),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[50]!, Colors.teal[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.get_app, color: Colors.teal[700], size: 28),
              const SizedBox(width: 12),
              Text(
                'GetX Dialog with Shrinking Animation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '🎯 GetX Features:\n'
            '• State management with reactive variables (Rx)\n'
            '• Custom dialog animations with GetX transitions\n'
            '• Shrinking animation towards FloatingActionButton\n'
            '• Automatic controller lifecycle management\n'
            '• Real-time UI updates with Obx widgets',
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
            'Dialog Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                print('🎯 Button pressed: Show GetX Dialog');
                controller.showDialog();
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Show GetX Dialog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Text(
            'Status: ${controller.isDialogVisible.value ? "Dialog Visible" : "Ready to show"}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,  
              color: Colors.green[700],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection(GetXDialogController controller) {
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
            'Customize Dialog',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          
          const Text('Dialog Type:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDialogTypeChip('Success', Icons.check_circle, Colors.green, controller),
              _buildDialogTypeChip('Warning', Icons.warning, Colors.orange, controller),
              _buildDialogTypeChip('Error', Icons.error, Colors.red, controller),
              _buildDialogTypeChip('Info', Icons.info, Colors.blue, controller),
              _buildDialogTypeChip('Message', Icons.message, Colors.purple, controller),
            ],
          ),
          
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => controller.dialogContent.value = value,
            decoration: const InputDecoration(
              labelText: 'Dialog Content',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTypeChip(String label, IconData icon, Color color, GetXDialogController controller) {
    return Obx(() {
      final isSelected = controller.dialogIcon.value == icon;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.updateDialogType(label, icon, color);
          }
        },
        selectedColor: color,
        backgroundColor: color.withOpacity(0.1),
      );
    });
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
                'How to Use GetX Dialog',
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
            '1. 🎨 Customize the dialog type and content above\n'
            '2. 🚀 Click the FloatingActionButton to show GetX dialog\n'
            '3. ✅ Click "Confirm" to see the shrinking animation\n'
            '4. 📦 Watch the dialog shrink towards the FAB position\n'
            '5. 🔄 FAB pulses briefly after dialog closes\n\n'
            '💡 GetX Technical Features:\n'
            '• Reactive state management with .obs variables\n'
            '• Automatic controller disposal on page close\n'
            '• Custom animations with AnimationController\n'
            '• Real-time UI updates with Obx widget\n'
            '• GetX dialog system with custom transitions',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}