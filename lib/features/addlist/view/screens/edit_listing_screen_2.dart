import 'dart:io';

import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/s3_upload/s3_upload_service.dart';
import 'package:_96_sooq/features/addlist/data/listing_creation_api_service.dart';
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

class EditListingScreen2 extends StatefulWidget {
  const EditListingScreen2({
    super.key,
    required this.product,
    required this.title,
    required this.description,
    required this.localPhotoPaths,
    required this.networkPhotos,
  });

  final ProductModel product;
  final String title;
  final String description;
  final List<String> localPhotoPaths;
  final List<String> networkPhotos;

  @override
  State<EditListingScreen2> createState() => _EditListingScreen2State();
}

class _EditListingScreen2State extends State<EditListingScreen2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _wilayatController = TextEditingController();

  final LocationApiService _locationApiService = const LocationApiService();

  bool _isGovernoratesLoading = false;
  bool _isWilayatsLoading = false;

  bool? _isNew;
  bool _submitted = false;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    final prod = widget.product;
    final parsedAmount = double.tryParse(prod.amount);
    _priceController.text = parsedAmount?.toString() ?? '';
    _isNew = prod.condition?.toLowerCase() == 'new';

    // Pre-fill location text
    _governorateController.text = prod.locationNameEn ?? prod.city ?? '';
    _wilayatController.text = prod.placeNameEn ?? prod.place ?? '';

    // Load governorates to match and pre-fill the model objects
    _loadGovernorates(
      prefillGovernorateId: prod.locationId,
      prefillWilayatId: prod.placeId,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _governorateController.dispose();
    _wilayatController.dispose();
    super.dispose();
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
        if (prefilledGovernorate != null) {
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
        if (prefilledWilayat != null) {
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

  Future<void> _onUpdate() async {
    setState(() => _submitted = true);
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isConditionValid = _isNew != null;
    if (!isFormValid || !isConditionValid) return;

    if (_isPosting) return;

    setState(() {
      _isPosting = true;
    });

    final parsedProductPrice = double.tryParse(_priceController.text.trim());

    try {
      final s3Service = S3UploadService(DioServices.client);
      final List<String> imageUrls = [...widget.networkPhotos];

      // Filter out empty paths
      final localPhotoPaths = widget.localPhotoPaths
          .where((p) => p.trim().isNotEmpty)
          .toList();

      if (localPhotoPaths.length == 1) {
        final file = File(localPhotoPaths.first);
        final bytes = await file.readAsBytes();
        final filename = localPhotoPaths.first.split('/').last;
        final result = await s3Service.uploadFile(
          bytes: bytes,
          filename: filename,
          folder: 'listings',
        );
        imageUrls.add(result.url);
      } else if (localPhotoPaths.length > 1) {
        final fileEntries = <({List<int> bytes, String filename})>[];
        for (final photoPath in localPhotoPaths) {
          final file = File(photoPath);
          final bytes = await file.readAsBytes();
          final filename = photoPath.split('/').last;
          fileEntries.add((bytes: bytes, filename: filename));
        }
        final results = await s3Service.uploadFiles(
          files: fileEntries,
          folder: 'listings',
        );
        imageUrls.addAll(results.map((r) => r.url));
      }

      final creationService = const ListingCreationApiService();
      final requestPayload = <String, dynamic>{
        "title": widget.title,
        "description": widget.description,
        "condition": _isNew == true ? 'new' : 'used',
        "price": parsedProductPrice,
        "currency": "OMR",
        "images": imageUrls,
      };

      await creationService.updateListing(
        id: widget.product.id,
        request: requestPayload,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop both edit screens and return true to My Deals
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          child: Row(
            children: [
              Expanded(
                child: CustomButtonWhiteWidget(
                  text: localizations.cancelText,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: _isPosting ? 'Updating...' : 'Update',
                  onPressed: _isPosting ? () {} : _onUpdate,
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
                      Text('Edit Listing', style: AppThemes.f16w600),
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
                    enabled: false,
                    suffixIcon: _isGovernoratesLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.lock_outline, size: 18),
                  ),
                  _RequiredLabel(label: localizations.wilayatLabel),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: localizations.wilayatLabel,
                    controller: _wilayatController,
                    readOnly: true,
                    enabled: false,
                    suffixIcon: _isWilayatsLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.lock_outline, size: 18),
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
  const _RequiredLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
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
