import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// 证件类型数据模型
class IdDocumentType {
  final String id;
  final String name;
  final String description;

  IdDocumentType({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// 证件图片数据模型
class IdDocumentImage {
  final String id;
  final String imagePath;
  final int order;

  IdDocumentImage({
    required this.id,
    required this.imagePath,
    required this.order,
  });
}

/// 证件类型与图片关联数据模型
class IdDocumentWithImages {
  final IdDocumentType documentType;
  final List<IdDocumentImage> images;

  IdDocumentWithImages({
    required this.documentType,
    required this.images,
  });
}

/// 证件图片上传案例页面
class IdDocumentImageCasePage extends StatefulWidget {
  const IdDocumentImageCasePage({super.key});

  @override
  State<IdDocumentImageCasePage> createState() =>
      _IdDocumentImageCasePageState();
}

class _IdDocumentImageCasePageState extends State<IdDocumentImageCasePage> {
  // 模拟后端返回的证件类型数据
  final List<IdDocumentType> _documentTypes = [
    IdDocumentType(
      id: '1',
      name: '身份证',
      description: '请上传身份证正反面照片',
    ),
    IdDocumentType(
      id: '2',
      name: '护照',
      description: '请上传护照个人信息页照片',
    ),
    IdDocumentType(
      id: '3',
      name: '驾驶证',
      description: '请上传驾驶证正副页照片',
    ),
    IdDocumentType(
      id: '4',
      name: '营业执照',
      description: '请上传营业执照照片',
    ),
  ];

  // 存储每个证件类型对应的图片
  final Map<String, List<IdDocumentImage>> _documentImages = {};
  
  // 图片选择器实例
  final ImagePicker _picker = ImagePicker();
  
  // 设备是否支持图片选择器
  bool _isPickerSupported = true; // 默认假设支持

  @override
  void initState() {
    super.initState();
    // 初始化每个证件类型的图片列表
    for (var docType in _documentTypes) {
      _documentImages[docType.id] = [];
    }
    
    // 检查图片选择器是否支持 (简化处理)
    _checkPickerSupport();
  }
  
  /// 检查图片选择器是否支持
  void _checkPickerSupport() async {
    // 在较老的版本中，我们简化处理，假设支持
    // 实际项目中可以根据Android版本进行判断
    setState(() {
      _isPickerSupported = true;
    });
  }

  /// 模拟拍照或从相册选择图片
  Future<String?> _pickImage() async {
    // 检查图片选择器是否支持
    if (!_isPickerSupported) {
      // 显示不支持提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前设备不支持图片选择功能')),
        );
      }
      return null;
    }
    
    try {
      final PickedFile? image = await _picker.getImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        // 检查文件大小
        final file = File(image.path);
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);
        
        // 如果图片大于5MB，提示用户
        if (sizeInMB > 5) {
          if (mounted) {
            final shouldContinue = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('图片过大'),
                content: Text('选择的图片大小为${sizeInMB.toStringAsFixed(2)}MB，大于5MB，可能会导致上传缓慢，是否继续？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('继续'),
                  ),
                ],
              ),
            );
            
            if (shouldContinue != true) {
              return null;
            }
          }
        }
        
        // 对图片进行压缩（如果大于1MB）
        if (sizeInMB > 1) {
          final compressedPath = await _compressImage(image.path);
          if (compressedPath != null) {
            return compressedPath;
          }
        }
        
        return image.path;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
    
    return null;
  }
  
  /// 压缩图片
  Future<String?> _compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = file.uri.pathSegments.last;
      final newPath = '${file.parent.path}/compressed_$fileName';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        newPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      if (result != null) {
        // 检查压缩后的文件大小
        final compressedFile = File(result.path);
        final originalSize = await file.length();
        final compressedSize = await compressedFile.length();
        
        debugPrint('Original size: ${originalSize / (1024 * 1024)} MB');
        debugPrint('Compressed size: ${compressedSize / (1024 * 1024)} MB');
        debugPrint('Compression ratio: ${(compressedSize / originalSize * 100).toStringAsFixed(2)}%');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '图片已压缩: ${(originalSize / (1024 * 1024)).toStringAsFixed(2)}MB → ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)}MB',
              ),
            ),
          );
        }
        
        return result.path;
      }
    } catch (e) {
      debugPrint('Image compression failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片压缩失败: $e')),
        );
      }
    }
    
    return null;
  }

  /// 添加图片到指定证件类型
  Future<void> _addImageToDocument(String documentTypeId) async {
    final imagePath = await _pickImage();
    if (imagePath != null) {
      final images = _documentImages[documentTypeId] ?? [];
      if (images.length < 3) {
        // 最多只能添加3张图片
        final newImage = IdDocumentImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: imagePath,
          order: images.length + 1,
        );
        setState(() {
          images.add(newImage);
          _documentImages[documentTypeId] = images;
        });
      }
    }
  }

  /// 替换指定位置的图片
  Future<void> _replaceImage(
      String documentTypeId, int imageIndex) async {
    final imagePath = await _pickImage();
    if (imagePath != null) {
      final images = _documentImages[documentTypeId] ?? [];
      if (imageIndex < images.length) {
        setState(() {
          images[imageIndex] = IdDocumentImage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imagePath: imagePath,
            order: imageIndex + 1,
          );
          _documentImages[documentTypeId] = images;
        });
      }
    }
  }

  /// 删除指定位置的图片
  void _deleteImage(String documentTypeId, int imageIndex) {
    final images = _documentImages[documentTypeId] ?? [];
    if (imageIndex < images.length) {
      setState(() {
        images.removeAt(imageIndex);
        // 更新后续图片的顺序
        for (int i = imageIndex; i < images.length; i++) {
          images[i] = IdDocumentImage(
            id: images[i].id,
            imagePath: images[i].imagePath,
            order: i + 1,
          );
        }
        _documentImages[documentTypeId] = images;
      });
    }
  }

  /// 提交数据到后端
  void _submitData() {
    // 构造要提交的数据
    final List<IdDocumentWithImages> documentsToSubmit = [];
    
    for (var docType in _documentTypes) {
      final images = _documentImages[docType.id] ?? [];
      if (images.isNotEmpty) {
        documentsToSubmit.add(IdDocumentWithImages(
          documentType: docType,
          images: images,
        ));
      }
    }
    
    // 在实际应用中，这里会将数据提交到后端
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交成功'),
        content: Text('共提交${documentsToSubmit.length}种证件类型的数据'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    // 打印提交的数据（用于调试）
    debugPrint('=== 提交的数据 ===');
    for (var doc in documentsToSubmit) {
      debugPrint('证件类型: ${doc.documentType.name}');
      for (var image in doc.images) {
        debugPrint('  图片${image.order}: ${image.imagePath}');
      }
    }
    debugPrint('==================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('证件图片上传'),
        backgroundColor: Colors.blue[100],
      ),
      body: SingleChildScrollView(
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
                      Icon(Icons.photo_library, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '证件图片上传演示',
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
                    '• 每种证件类型最多可上传3张图片\n'
                    '• 图片以缩略图形式横向排列\n'
                    '• 点击添加按钮上传图片\n'
                    '• 点击图片可替换或删除\n'
                    '• 提交时将数据发送到后端',
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 证件类型列表
            ..._documentTypes.map((docType) {
              final images = _documentImages[docType.id] ?? [];
              return _buildDocumentSection(docType, images);
            }).toList(),
            
            const SizedBox(height: 32),
            
            // 提交按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '提交证件信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建证件类型区域
  Widget _buildDocumentSection(
      IdDocumentType documentType, List<IdDocumentImage> images) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            documentType.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            documentType.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // 图片展示区域
          _buildImageRow(documentType.id, images),
        ],
      ),
    );
  }

  /// 构建图片行
  Widget _buildImageRow(String documentTypeId, List<IdDocumentImage> images) {
    return Row(
      children: [
        // 已上传的图片
        ...List.generate(
          images.length,
          (index) => _buildImageThumbnail(
            documentTypeId,
            images[index],
            index,
          ),
        ),
        // 添加按钮（最多显示3个）
        if (images.length < 3)
          _buildAddImageButton(documentTypeId, images.length),
        // 填充剩余空间的空位（最多3个）
        ...List.generate(
          2 - images.length,
          (index) => const Expanded(child: SizedBox()),
        ),
      ],
    );
  }

  /// 构建图片缩略图
  Widget _buildImageThumbnail(
      String documentTypeId, IdDocumentImage image, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showImageOptions(documentTypeId, index),
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ExtendedImage.file(
              File(image.imagePath),
              fit: BoxFit.cover,
              loadStateChanged: (ExtendedImageState state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                    // 图片加载中，显示加载指示器
                    return Center(
                      child: CircularProgressIndicator(
                        value: state.loadingProgress?.expectedTotalBytes != null
                            ? state.loadingProgress!.cumulativeBytesLoaded /
                                state.loadingProgress!.expectedTotalBytes!
                            : null,
                      ),
                    );
                  case LoadState.completed:
                    // 图片加载完成，返回图片
                    return state.completedWidget;
                  case LoadState.failed:
                    // 图片加载失败，显示错误占位符
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 32,
                      ),
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 构建添加图片按钮
  Widget _buildAddImageButton(String documentTypeId, int currentIndex) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addImageToDocument(documentTypeId),
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue[300]!,
              style: BorderStyle.solid,
            ),
            color: Colors.blue[50],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '添加图片',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示图片操作选项（替换/删除）
  void _showImageOptions(String documentTypeId, int imageIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('替换图片'),
              onTap: () {
                Navigator.pop(context);
                _replaceImage(documentTypeId, imageIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('删除图片'),
              onTap: () {
                Navigator.pop(context);
                _deleteImage(documentTypeId, imageIndex);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}