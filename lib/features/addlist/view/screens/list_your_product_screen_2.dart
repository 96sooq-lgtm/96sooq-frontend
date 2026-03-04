import 'dart:io';

import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/s3_upload/s3_upload_service.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/data/listing_creation_api_service.dart';
import 'package:_96_sooq/features/addlist/view/screens/addlist_screen.dart';
import 'package:_96_sooq/features/addlist/view/screens/boost_your_product_screen.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/location/data/location_api_service.dart';
import 'package:_96_sooq/features/location/model/location_item_model.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_white_widget.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96_sooq/shared/global_widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListYourProductScreen2 extends StatefulWidget {
  const ListYourProductScreen2({super.key, this.requiresPayment = true});

  final bool requiresPayment;

  @override
  State<ListYourProductScreen2> createState() => _ListYourProductScreen2State();
}

class _ListYourProductScreen2State extends State<ListYourProductScreen2> {
  static const Set<String> _fixedAttributeNames = <String>{
    'name',
    'price',
    'description',
    'images',
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _wilayatController = TextEditingController();

  final LocationApiService _locationApiService = const LocationApiService();

  final Map<String, TextEditingController> _dynamicTextControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _dynamicDropdownControllers =
      <String, TextEditingController>{};
  final Map<String, String> _dynamicSelectedValues = <String, String>{};

  List<CategoryAttributeSchemaModel> _dynamicAttributes =
      <CategoryAttributeSchemaModel>[];

  List<LocationItemModel> _governorates = <LocationItemModel>[];
  List<LocationItemModel> _wilayats = <LocationItemModel>[];
  LocationItemModel? _selectedGovernorate;
  LocationItemModel? _selectedWilayat;

  bool _isGovernoratesLoading = false;
  bool _isWilayatsLoading = false;

  bool? _isNew;
  bool _submitted = false;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    final flowState = context.read<AddlistPaymentFlowBloc>().state;
    _dynamicAttributes = _buildRenderableDynamicAttributes(
      flowState.subCategoryAttributesSchema,
    );

    for (final attribute in _dynamicAttributes) {
      final type = attribute.type.trim().toLowerCase();
      final prefilledValue =
          flowState.dynamicAttributes[attribute.name]?.toString() ?? '';

      if (type == 'text') {
        _dynamicTextControllers[attribute.name] = TextEditingController(
          text: prefilledValue,
        );
      }

      if (type == 'dropdown') {
        _dynamicDropdownControllers[attribute.name] = TextEditingController(
          text: prefilledValue,
        );
      }

      if (prefilledValue.trim().isNotEmpty) {
        _dynamicSelectedValues[attribute.name] = prefilledValue.trim();
      }
    }

    _governorateController.text = flowState.city ?? '';
    _wilayatController.text = flowState.place ?? '';

    if (flowState.flowMode == ListFlowMode.edit &&
        flowState.editingProduct != null) {
      final prod = flowState.editingProduct!;
      final parsedAmount = double.tryParse(prod.amount);
      _priceController.text = parsedAmount?.toString() ?? '';
      _isNew = prod.condition?.toLowerCase() == 'new';
      if (_governorateController.text.trim().isEmpty) {
        _governorateController.text = prod.city ?? '';
      }
      if (_wilayatController.text.trim().isEmpty) {
        _wilayatController.text = prod.place ?? '';
      }
    }

    _loadGovernorates(
      prefillGovernorateId: flowState.governorateId,
      prefillWilayatId: flowState.wilayatId,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _governorateController.dispose();
    _wilayatController.dispose();

    for (final controller in _dynamicTextControllers.values) {
      controller.dispose();
    }
    for (final controller in _dynamicDropdownControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  List<CategoryAttributeSchemaModel> _buildRenderableDynamicAttributes(
    List<CategoryAttributeSchemaModel> schema,
  ) {
    return schema.where((attribute) {
      final name = attribute.name.trim().toLowerCase();
      final type = attribute.type.trim().toLowerCase();
      final status = attribute.status?.trim().toLowerCase();
      final isActive = status == null || status.isEmpty || status == 'active';

      return !_fixedAttributeNames.contains(name) &&
          isActive &&
          (type == 'radio' || type == 'dropdown' || type == 'text');
    }).toList();
  }

  String _attributeLabel(
    CategoryAttributeSchemaModel attribute,
    String locale,
  ) {
    if (locale.toLowerCase() == 'ar') {
      if (attribute.labelAr.trim().isNotEmpty) return attribute.labelAr.trim();
      return attribute.labelEn.trim();
    }

    if (attribute.labelEn.trim().isNotEmpty) return attribute.labelEn.trim();
    return attribute.labelAr.trim();
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

  Future<void> _loadGovernorates({
    String? prefillGovernorateId,
    String? prefillWilayatId,
  }) async {
    if (_isGovernoratesLoading) return;

    setState(() {
      _isGovernoratesLoading = true;
    });

    try {
      final governorates = await _locationApiService.fetchStates();
      if (!mounted) return;

      LocationItemModel? prefilledGovernorate;
      if ((prefillGovernorateId ?? '').trim().isNotEmpty) {
        for (final item in governorates) {
          if (item.id == prefillGovernorateId) {
            prefilledGovernorate = item;
            break;
          }
        }
      }

      final localeCode = Localizations.localeOf(context).languageCode;

      setState(() {
        _governorates = governorates;
        if (prefilledGovernorate != null) {
          _selectedGovernorate = prefilledGovernorate;
          _governorateController.text = prefilledGovernorate.displayName(
            localeCode,
          );
        }
      });

      if (prefilledGovernorate != null) {
        await _loadWilayats(
          governorateId: prefilledGovernorate.id,
          prefillWilayatId: prefillWilayatId,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isGovernoratesLoading = false;
        });
      }
    }
  }

  Future<void> _loadWilayats({
    required String governorateId,
    String? prefillWilayatId,
  }) async {
    if (_isWilayatsLoading) return;

    setState(() {
      _isWilayatsLoading = true;
    });

    try {
      final wilayats = await _locationApiService.fetchCities(
        stateId: governorateId,
      );
      if (!mounted) return;

      LocationItemModel? prefilledWilayat;
      if ((prefillWilayatId ?? '').trim().isNotEmpty) {
        for (final item in wilayats) {
          if (item.id == prefillWilayatId) {
            prefilledWilayat = item;
            break;
          }
        }
      }

      final localeCode = Localizations.localeOf(context).languageCode;

      setState(() {
        _wilayats = wilayats;
        if (prefilledWilayat != null) {
          _selectedWilayat = prefilledWilayat;
          _wilayatController.text = prefilledWilayat.displayName(localeCode);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isWilayatsLoading = false;
        });
      }
    }
  }

  void _onCancelFlow() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    final flowState = context.read<AddlistPaymentFlowBloc>().state;
    if (flowState.flowMode == ListFlowMode.edit) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AddlistScreen()),
      (route) => route.isFirst,
    );
  }

  String? _validateDynamicAttribute(CategoryAttributeSchemaModel attribute) {
    if (!attribute.requiredField) return null;

    final type = attribute.type.trim().toLowerCase();
    if (type == 'text') {
      final controller = _dynamicTextControllers[attribute.name];
      if ((controller?.text.trim() ?? '').isEmpty) {
        return 'This field is required';
      }
      return null;
    }

    final selectedValue = _dynamicSelectedValues[attribute.name]?.trim() ?? '';
    if (selectedValue.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _onPost() async {
    final localizations = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;

    setState(() => _submitted = true);
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isConditionValid = _isNew != null;
    final flowState = context.read<AddlistPaymentFlowBloc>().state;
    final isEditMode = flowState.flowMode == ListFlowMode.edit;
    if (!isFormValid ||
        !isConditionValid ||
        (!isEditMode &&
            (_selectedGovernorate == null || _selectedWilayat == null))) {
      return;
    }

    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    final paymentFlowBloc = context.read<AddlistPaymentFlowBloc>();
    final parsedProductPrice = double.tryParse(_priceController.text.trim());
    final conditionText = _isNew == null
        ? null
        : (_isNew! ? localizations.newCondition : localizations.usedCondition);

    final dynamicAttributes = <String, dynamic>{};
    for (final attribute in _dynamicAttributes) {
      final type = attribute.type.trim().toLowerCase();
      String value = '';

      if (type == 'text') {
        value = _dynamicTextControllers[attribute.name]?.text.trim() ?? '';
      } else {
        value = _dynamicSelectedValues[attribute.name]?.trim() ?? '';
      }

      if (value.isNotEmpty) {
        dynamicAttributes[attribute.name] = value;
      }
    }

    try {
      final s3Service = S3UploadService(DioServices.client);
      final photoPaths = paymentFlowBloc.state.photoPaths;
      final networkPhotos = paymentFlowBloc.state.networkPhotos;
      final List<String> imageUrls = [...networkPhotos];

      for (final photoPath in photoPaths) {
        if (photoPath.trim().isNotEmpty) {
          final file = File(photoPath);
          final bytes = await file.readAsBytes();
          final filename = photoPath.split('/').last;
          final result = await s3Service.uploadFile(
            bytes: bytes,
            filename: filename,
            folder: 'listings',
          );
          imageUrls.add(result.url);
        }
      }

      final creationService = const ListingCreationApiService();
      final requestPayload = <String, dynamic>{
        "title": paymentFlowBloc.state.productTitle,
        "description": paymentFlowBloc.state.description ?? "N/A",
        "condition": _isNew == true ? 'new' : 'used',
        "price": parsedProductPrice,
        "currency": "OMR",
        "images": imageUrls,
        "attributes_values": dynamicAttributes,
      };
      if (!isEditMode) {
        requestPayload["category_id"] = paymentFlowBloc.state.subCategoryId;
        requestPayload["location_id"] = _selectedGovernorate!.id;
        requestPayload["place_id"] = _selectedWilayat!.id;
      }

      ProductModel? postedProduct;

      if (paymentFlowBloc.state.flowMode == ListFlowMode.edit &&
          paymentFlowBloc.state.editingProduct != null) {
        postedProduct = await creationService.updateListing(
          id: paymentFlowBloc.state.editingProduct!.id,
          request: requestPayload,
        );

        if (!mounted) return;

        // Pop screen2 then screen1 and return success to MyDealsScreen.
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
        return;
      } else {
        postedProduct = await creationService.createListing(
          request: requestPayload,
        );
      }

      paymentFlowBloc.add(
        ProductDetailsCaptured(
          productTitle: paymentFlowBloc.state.productTitle,
          productPrice: parsedProductPrice,
          photoPaths: photoPaths,
          networkPhotos: networkPhotos,
          categoryName: paymentFlowBloc.state.categoryName ?? '',
          subCategoryName: paymentFlowBloc.state.subCategoryName ?? '',
          subCategoryId: paymentFlowBloc.state.subCategoryId ?? '',
          subCategoryAttributesSchema:
              paymentFlowBloc.state.subCategoryAttributesSchema,
          description: paymentFlowBloc.state.description ?? '',
          condition: conditionText,
          city: _selectedGovernorate?.displayName(localeCode) ??
              _governorateController.text.trim(),
          place: _selectedWilayat?.displayName(localeCode) ??
              _wilayatController.text.trim(),
          governorateId: _selectedGovernorate?.id,
          wilayatId: _selectedWilayat?.id,
          dynamicAttributes: dynamicAttributes,
          postedListingId: postedProduct?.id,
          postedProduct: postedProduct,
        ),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: paymentFlowBloc,
            child: const BoostYourProductScreen(
              source: BoostFlowSource.addList,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Widget _buildDynamicField(
    CategoryAttributeSchemaModel attribute,
    String localeCode,
  ) {
    final label = _attributeLabel(attribute, localeCode);
    final type = attribute.type.trim().toLowerCase();

    if (type == 'text') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(label: label, isRequired: attribute.requiredField),
          const SizedBox(height: 8),
          CustomTextFormField(
            labelText: label,
            controller: _dynamicTextControllers[attribute.name]!,
            validator: (_) => _validateDynamicAttribute(attribute),
          ),
        ],
      );
    }

    if (type == 'radio') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(label: label, isRequired: attribute.requiredField),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: attribute.options.map((option) {
              final isSelected =
                  _dynamicSelectedValues[attribute.name] == option;
              return _ConditionChip(
                label: option,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _dynamicSelectedValues[attribute.name] = option;
                  });
                },
              );
            }).toList(),
          ),
          if (_submitted && _validateDynamicAttribute(attribute) != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _validateDynamicAttribute(attribute)!,
                style: AppThemes.f12w400.copyWith(color: Colors.red),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequiredLabel(label: label, isRequired: attribute.requiredField),
        const SizedBox(height: 8),
        CustomTextFormField(
          labelText: label,
          controller: _dynamicDropdownControllers[attribute.name]!,
          readOnly: true,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          onTap: () {
            if (attribute.options.isEmpty) return;

            _pickFromList<String>(
              title: label,
              options: attribute.options,
              labelBuilder: (value) => value,
              onSelected: (value) {
                setState(() {
                  _dynamicSelectedValues[attribute.name] = value;
                  _dynamicDropdownControllers[attribute.name]!.text = value;
                });
              },
            );
          },
          validator: (_) => _validateDynamicAttribute(attribute),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Row(
            children: [
              Expanded(
                child: CustomButtonWhiteWidget(
                  text: localizations.cancelText,
                  onPressed: _onCancelFlow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: _isPosting
                      ? localizations.postingText
                      : localizations.postText,
                  onPressed: _isPosting ? () {} : _onPost,
                ),
              ),
            ],
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
                  const SizedBox(height: 30),
                  _RequiredLabel(label: localizations.conditionLabel),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ConditionChip(
                        label: localizations.newCondition,
                        isSelected: _isNew == true,
                        onTap: () => setState(() => _isNew = true),
                      ),
                      const SizedBox(width: 12),
                      _ConditionChip(
                        label: localizations.usedCondition,
                        isSelected: _isNew == false,
                        onTap: () => setState(() => _isNew = false),
                      ),
                    ],
                  ),
                  if (_submitted && _isNew == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Condition is required',
                        style: AppThemes.f12w400.copyWith(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 22),
                  _RequiredLabel(label: localizations.priceLabel),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.priceLabel,
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Price is required';
                      final amount = double.tryParse(text);
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _RequiredLabel(label: localizations.governorateLabel),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.governorateLabel,
                    controller: _governorateController,
                    readOnly: true,
                    suffixIcon: _isGovernoratesLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.keyboard_arrow_down_rounded),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return '${localizations.governorateLabel} is required';
                      }
                      return null;
                    },
                    onTap: () async {
                      final flowState = context
                          .read<AddlistPaymentFlowBloc>()
                          .state;
                      if (flowState.flowMode == ListFlowMode.edit) return;

                      if (_isGovernoratesLoading) return;

                      if (_governorates.isEmpty) {
                        await _loadGovernorates();
                        return;
                      }

                      await _pickFromList<LocationItemModel>(
                        title: localizations.governorateLabel,
                        options: _governorates,
                        labelBuilder: (value) => value.displayName(localeCode),
                        onSelected: (value) {
                          setState(() {
                            _selectedGovernorate = value;
                            _governorateController.text = value.displayName(
                              localeCode,
                            );
                            _selectedWilayat = null;
                            _wilayatController.clear();
                            _wilayats = <LocationItemModel>[];
                          });
                          _loadWilayats(governorateId: value.id);
                        },
                      );
                    },
                  ),
                  _RequiredLabel(label: localizations.wilayatLabel),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.wilayatLabel,
                    controller: _wilayatController,
                    readOnly: true,
                    suffixIcon: _isWilayatsLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.keyboard_arrow_down_rounded),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return '${localizations.wilayatLabel} is required';
                      }
                      return null;
                    },
                    onTap: () async {
                      final flowState = context
                          .read<AddlistPaymentFlowBloc>()
                          .state;
                      if (flowState.flowMode == ListFlowMode.edit) return;

                      if (_selectedGovernorate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select governorate first'),
                          ),
                        );
                        return;
                      }

                      if (_isWilayatsLoading) return;

                      if (_wilayats.isEmpty) {
                        await _loadWilayats(
                          governorateId: _selectedGovernorate!.id,
                        );
                        return;
                      }

                      await _pickFromList<LocationItemModel>(
                        title: localizations.wilayatLabel,
                        options: _wilayats,
                        labelBuilder: (value) => value.displayName(localeCode),
                        onSelected: (value) {
                          setState(() {
                            _selectedWilayat = value;
                            _wilayatController.text = value.displayName(
                              localeCode,
                            );
                          });
                        },
                      );
                    },
                  ),
                  for (final attribute in _dynamicAttributes) ...[
                    const SizedBox(height: 16),
                    _buildDynamicField(attribute, localeCode),
                  ],
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

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 110),
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF272727) : Colors.transparent,
          ),
        ),
        child: Center(child: Text(label, style: AppThemes.f14w500)),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.label, this.isRequired = true});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: RichText(
        text: TextSpan(
          text: label,
          style: AppThemes.f16w500.copyWith(color: AppColors.brandBlack),
          children: [
            if (isRequired)
              const TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
