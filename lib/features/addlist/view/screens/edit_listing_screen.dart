import 'dart:io';

import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/view/screens/edit_listing_screen_2.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96_sooq/shared/global_widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditListingScreen extends StatefulWidget {
  const EditListingScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  static const int _maxImageSizeBytes = 5 * 1024 * 1024;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _photos = <XFile>[];
  final List<String> _networkPhotos = <String>[];
  bool _submitted = false;
  bool _hasPhotoSizeError = false;

  @override
  void initState() {
    super.initState();
    final prod = widget.product;
    _titleController.text = prod.title;
    _descriptionController.text = prod.details;
    _categoryController.text = prod.categoryName ?? '';
    _subCategoryController.text = prod.subCategoryName ?? '';

    if (prod.images.isNotEmpty) {
      _networkPhotos.addAll(prod.images);
    } else if (prod.imageUrl.isNotEmpty) {
      _networkPhotos.add(prod.imageUrl);
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subCategoryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picked = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    final validPhotos = <XFile>[];
    var hasOversized = false;

    for (final photo in picked) {
      final sizeInBytes = await File(photo.path).length();
      if (sizeInBytes > _maxImageSizeBytes) {
        hasOversized = true;
        continue;
      }
      validPhotos.add(photo);
    }

    setState(() {
      _photos.addAll(validPhotos);
      _hasPhotoSizeError = hasOversized;
    });
  }

  void _onNext() {
    setState(() => _submitted = true);

    final formValid = _formKey.currentState?.validate() ?? false;
    final hasEnoughPhotos = (_photos.length + _networkPhotos.length) >= 3;
    if (!formValid || !hasEnoughPhotos) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditListingScreen2(
          product: widget.product,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          localPhotoPaths: _photos.map((p) => p.path).toList(),
          networkPhotos: List<String>.from(_networkPhotos),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: CustomButton(text: localizations.nextText, onPressed: _onNext),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackButtonWidget(ontap: () => Navigator.pop(context)),
                      Text(localizations.editListingTitle, style: AppThemes.f16w600),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _RequiredLabel(label: localizations.addCategoryTitle),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.addCategoryTitle,
                    controller: _categoryController,
                    readOnly: true,
                    enabled: false,
                    suffixIcon: const Icon(Icons.lock_outline, size: 18),
                  ),
                  _RequiredLabel(label: localizations.addSubCategoryTitle),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.addSubCategoryTitle,
                    controller: _subCategoryController,
                    readOnly: true,
                    enabled: false,
                    suffixIcon: const Icon(Icons.lock_outline, size: 18),
                  ),
                  _RequiredLabel(label: localizations.addImagesTitle),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.addAtLeast3Photos,
                    style: AppThemes.f14w400.copyWith(
                      color: AppColors.productListingTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _networkPhotos.length + _photos.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return GestureDetector(
                          onTap: _pickPhotos,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.black.withValues(alpha: 0.03),
                              border: Border.all(
                                color:
                                    (_submitted &&
                                            (_photos.length +
                                                    _networkPhotos.length <
                                                3)) ||
                                        _hasPhotoSizeError
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 28,
                                  color: AppColors.brandBlack,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  localizations.addImagesTitle,
                                  style: AppThemes.f14w500.copyWith(
                                    color: AppColors.productListingTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final mediaIndex = index - 1;
                      final networkCount = _networkPhotos.length;
                      final isNetworkImage = mediaIndex < networkCount;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox.expand(
                              child: isNetworkImage
                                  ? Image.network(
                                      _networkPhotos[mediaIndex],
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(
                                        _photos[mediaIndex - networkCount].path,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isNetworkImage) {
                                    _networkPhotos.removeAt(mediaIndex);
                                  } else {
                                    _photos.removeAt(mediaIndex - networkCount);
                                  }
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (_hasPhotoSizeError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        localizations.pleaseAddSmallerImages,
                        style: AppThemes.f12w400.copyWith(color: Colors.red),
                      ),
                    ),
                  if (_submitted &&
                      (_photos.length + _networkPhotos.length) < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        localizations.atLeast3PhotosRequired,
                        style: AppThemes.f12w400.copyWith(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _RequiredLabel(label: localizations.titleLabel),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.titleLabel,
                    controller: _titleController,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  _RequiredLabel(label: localizations.descriptionLabel),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.descriptionLabel,
                    controller: _descriptionController,
                    maxLines: 6,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: RichText(
        text: TextSpan(
          text: label,
          style: AppThemes.f16w500.copyWith(color: AppColors.brandBlack),
          children: const [
            TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
