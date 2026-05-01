import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/product_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // null = add mode
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  File? _imageFile;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.product!.name;
      _descCtrl.text = widget.product!.description;
      _priceCtrl.text = widget.product!.price.toString();
      _categoryCtrl.text = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final adminVM = context.read<AdminViewModel>();
    bool success;

    if (_isEditing) {
      success = await adminVM.updateProduct(
        existingProduct: widget.product!,
        name: _nameCtrl.text,
        description: _descCtrl.text,
        price: double.parse(_priceCtrl.text.trim()),
        category: _categoryCtrl.text,
        newImageFile: _imageFile,
      );
    } else {
      success = await adminVM.addProduct(
        name: _nameCtrl.text,
        description: _descCtrl.text,
        price: double.parse(_priceCtrl.text.trim()),
        category: _categoryCtrl.text,
        imageFile: _imageFile!,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminVM.successMessage ?? 'Success'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminVM.errorMessage ?? 'Failed'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Add Product')),
      body: LoadingOverlay(
        isLoading: adminVM.isLoading,
        message: _isEditing ? 'Updating product...' : 'Adding product...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : (_isEditing && widget.product!.imageUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(widget.product!.imageUrl), fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_imageFile == null && (!_isEditing || widget.product!.imageUrl.isEmpty))
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.textSecondary),
                              SizedBox(height: 8),
                              Text('Tap to select image', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(controller: _nameCtrl, label: 'Product Name', prefixIcon: Icons.inventory_2_outlined, validator: (v) => Validators.required(v, 'Product Name')),
                const SizedBox(height: 16),
                CustomTextField(controller: _descCtrl, label: 'Description', prefixIcon: Icons.description_outlined, maxLines: 3, validator: (v) => Validators.required(v, 'Description')),
                const SizedBox(height: 16),
                CustomTextField(controller: _priceCtrl, label: 'Price (₹)', prefixIcon: Icons.currency_rupee, keyboardType: TextInputType.number, validator: Validators.price),
                const SizedBox(height: 16),
                CustomTextField(controller: _categoryCtrl, label: 'Category', prefixIcon: Icons.category_outlined, validator: (v) => Validators.required(v, 'Category')),
                const SizedBox(height: 32),
                CustomButton(
                  label: _isEditing ? 'Update Product' : 'Add Product',
                  icon: _isEditing ? Icons.save_outlined : Icons.add_circle_outline,
                  onPressed: _save,
                  isLoading: adminVM.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
