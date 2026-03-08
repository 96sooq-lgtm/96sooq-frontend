import 'dart:io';

import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/view/screens/list_your_product_screen_2.dart';
import 'package:_96_sooq/features/categories/bloc/categories_bloc.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96_sooq/shared/global_widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ListYourProductScreen extends StatefulWidget {
  const ListYourProductScreen({super.key, this.requiresPayment = true});

  final bool requiresPayment;

  @override
  State<ListYourProductScreen> createState() => _ListYourProductScreenState();
}

class _ListYourProductScreenState extends State<ListYourProductScreen> {
  static const int _maxImageSizeBytes = 5 * 1024 * 1024;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  CategoryModel? _selectedCategory;
  CategoryModel? _selectedSubCategory;
  final List<XFile> _photos = <XFile>[];
  final List<String> _networkPhotos = <String>[];
  bool _openSubCategoryWhenLoaded = false;
  bool _submitted = false;
  bool _hasPhotoSizeError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesBloc = context.read<CategoriesBloc>();
      final state = categoriesBloc.state;
      if (state.categories.isEmpty &&
          state.categoriesStatus != CategoriesStatus.loading) {
        categoriesBloc.add(CategoriesRequested());
      }

      final flowState = context.read<AddlistPaymentFlowBloc>().state;
      if (flowState.flowMode == ListFlowMode.edit &&
          flowState.editingProduct != null) {
        final prod = flowState.editingProduct!;
        _titleController.text = prod.title;
        _descriptionController.text = prod.details;
        _categoryController.text = prod.categoryName ?? '';
        _subCategoryController.text = prod.subCategoryName ?? '';

        if (prod.images.isNotEmpty) {
          _networkPhotos.addAll(prod.images);
        } else if (prod.imageUrl.isNotEmpty) {
          _networkPhotos.add(prod.imageUrl);
        }

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subCategoryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFromList<T>({
    required String title,
    required List<T> options,
    required String Function(T value) labelBuilder,
    required ValueChanged<T> onSelected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(title, style: AppThemes.f16w600),
                );
              }

              final value = options[index - 1];
              return ListTile(
                title: Text(labelBuilder(value), style: AppThemes.f14w500),
                onTap: () {
                  onSelected(value);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
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

  Future<void> _onCategoryTap() async {
    final flowState = context.read<AddlistPaymentFlowBloc>().state;
    if (flowState.flowMode == ListFlowMode.edit) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    final state = context.read<CategoriesBloc>().state;

    if (state.categoriesStatus == CategoriesStatus.loading) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loading categories')));
      return;
    }

    if (state.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No categories available right now')),
      );
      return;
    }

    final localeCode = Localizations.localeOf(context).languageCode;

    await _pickFromList<CategoryModel>(
      title: localizations.addCategoryTitle,
      options: state.categories,
      labelBuilder: (category) => category.displayName(localeCode),
      onSelected: (category) {
        setState(() {
          _selectedCategory = category;
          _selectedSubCategory = null;
          _categoryController.text = category.displayName(localeCode);
          _subCategoryController.clear();
        });

        context.read<CategoriesBloc>().add(SubCategoriesRequested(category.id));
      },
    );
  }

  Future<void> _onSubCategoryTap() async {
    final flowState = context.read<AddlistPaymentFlowBloc>().state;
    if (flowState.flowMode == ListFlowMode.edit) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category first')),
      );
      return;
    }

    final state = context.read<CategoriesBloc>().state;

    if (state.subCategoriesStatus == SubCategoriesStatus.loading) {
      _openSubCategoryWhenLoaded = true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loading subcategories')));
      return;
    }

    if (state.subCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subcategories found for this category'),
        ),
      );
      return;
    }

    final localeCode = Localizations.localeOf(context).languageCode;

    await _pickFromList<CategoryModel>(
      title: localizations.addSubCategoryTitle,
      options: state.subCategories,
      labelBuilder: (subCategory) => subCategory.displayName(localeCode),
      onSelected: (subCategory) {
        setState(() {
          _selectedSubCategory = subCategory;
          _subCategoryController.text = subCategory.displayName(localeCode);
        });
      },
    );

    _openSubCategoryWhenLoaded = false;
  }

  void _onNext() {
    setState(() => _submitted = true);

    final formValid = _formKey.currentState?.validate() ?? false;
    final hasEnoughPhotos = (_photos.length + _networkPhotos.length) >= 3;
    if (!formValid || !hasEnoughPhotos) return;

    final paymentFlowBloc = context.read<AddlistPaymentFlowBloc>();
    final editingProduct = paymentFlowBloc.state.editingProduct;
    paymentFlowBloc.add(
      ProductDetailsCaptured(
        productTitle: _titleController.text.trim(),
        photoPaths: _photos.map((p) => p.path).toList(),
        networkPhotos: _networkPhotos,
        categoryName: _categoryController.text.trim(),
        subCategoryName: _subCategoryController.text.trim(),
        subCategoryId:
            _selectedSubCategory?.id ??
            paymentFlowBloc.state.subCategoryId ??
            editingProduct?.categoryId ??
            '',
        subCategoryAttributesSchema:
            _selectedSubCategory?.attributesSchema ??
            paymentFlowBloc.state.subCategoryAttributesSchema,
        dynamicAttributes:
            editingProduct?.attributesValues ??
            paymentFlowBloc.state.dynamicAttributes,
        description: _descriptionController.text.trim(),
        governorateId:
            paymentFlowBloc.state.governorateId ?? editingProduct?.locationId,
        wilayatId: paymentFlowBloc.state.wilayatId ?? editingProduct?.placeId,
        city:
            paymentFlowBloc.state.city ??
            editingProduct?.locationNameEn ??
            editingProduct?.city,
        place:
            paymentFlowBloc.state.place ??
            editingProduct?.placeNameEn ??
            editingProduct?.place,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: paymentFlowBloc,
          child: ListYourProductScreen2(
            requiresPayment: widget.requiresPayment,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocListener<CategoriesBloc, CategoriesState>(
      listenWhen: (previous, current) =>
          previous.subCategoriesStatus != current.subCategoriesStatus,
      listener: (context, state) {
        if (_openSubCategoryWhenLoaded &&
            state.subCategoriesStatus == SubCategoriesStatus.loaded &&
            state.subCategories.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _onSubCategoryTap();
          return;
        }

        if (_openSubCategoryWhenLoaded &&
            state.subCategoriesStatus == SubCategoriesStatus.loaded &&
            state.subCategories.isEmpty) {
          _openSubCategoryWhenLoaded = false;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No subcategories found for this category'),
            ),
          );
          return;
        }

        if (state.subCategoriesStatus == SubCategoriesStatus.error &&
            (state.subCategoriesError?.isNotEmpty ?? false)) {
          _openSubCategoryWhenLoaded = false;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.subCategoriesError!)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: CustomButton(
              text: localizations.nextText,
              onPressed: _onNext,
            ),
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
                        Text(
                          localizations.listYourProductTitle,
                          style: AppThemes.f16w600,
                        ),
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
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onTap: _onCategoryTap,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    ),
                    _RequiredLabel(label: localizations.addSubCategoryTitle),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      labelText: localizations.addSubCategoryTitle,
                      controller: _subCategoryController,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onTap: _onSubCategoryTap,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Subcategory is required';
                        }
                        return null;
                      },
                    ),
                    _RequiredLabel(label: localizations.addImagesTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Add at least 3 photos of your ad',
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
                                          _photos[mediaIndex - networkCount]
                                              .path,
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
                                      _photos.removeAt(
                                        mediaIndex - networkCount,
                                      );
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
                          'Please add images smaller than 5 MB',
                          style: AppThemes.f12w400.copyWith(color: Colors.red),
                        ),
                      ),
                    if (_submitted &&
                        (_photos.length + _networkPhotos.length) < 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          'At least 3 photos are required',
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
