import 'dart:io';

import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/addlist/bloc/store_creation/store_creation_bloc.dart';
import 'package:_96_sooq/features/addlist/view/screens/addlist_screen.dart';
import 'package:_96_sooq/features/addlist/view/screens/list_your_product_screen.dart';
import 'package:_96_sooq/features/location/model/location_item_model.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/profile/model/store_check_response_model.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96_sooq/shared/global_widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CreateYourStoreScreen extends StatefulWidget {
  const CreateYourStoreScreen({
    super.key,
    this.requiresPayment = true,
    this.existingStore,
  });

  final bool requiresPayment;
  final StoreProfileModel? existingStore;

  @override
  State<CreateYourStoreScreen> createState() => _CreateYourStoreScreenState();
}

class _CreateYourStoreScreenState extends State<CreateYourStoreScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController storeNameEnglish = TextEditingController();
  final TextEditingController storeNameArabic = TextEditingController();
  final TextEditingController storeMobileNumber = TextEditingController();
  final TextEditingController governorateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _storeImage;
  bool _submitted = false;
  bool _hasChanges = false;

  bool get _isEditMode => widget.existingStore != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<StoreCreationBloc>();

      if (_isEditMode) {
        final store = widget.existingStore!;
        storeNameEnglish.text = store.name;
        storeNameArabic.text = store.nameAr;
        storeMobileNumber.text = store.storeNumber;
        descriptionController.text = store.description;
        governorateController.text = store.governorateEn.isNotEmpty
            ? store.governorateEn
            : store.governorateId;
        districtController.text = store.wilayatEn.isNotEmpty
            ? store.wilayatEn
            : store.wilayat;

        bloc.add(StoreEditInitialized(storeId: store.id, logoUrl: store.logo));
      } else {
        bloc.add(const StoreCreationInitialized());
      }

      // Track changes
      storeNameEnglish.addListener(_onFieldChanged);
      storeNameArabic.addListener(_onFieldChanged);
      storeMobileNumber.addListener(_onFieldChanged);
      descriptionController.addListener(_onFieldChanged);
    });
  }

  void _onFieldChanged() {
    if (!_isEditMode) return;
    final store = widget.existingStore!;
    final changed =
        storeNameEnglish.text != store.name ||
        storeNameArabic.text != store.nameAr ||
        storeMobileNumber.text != store.storeNumber ||
        descriptionController.text != store.description;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    storeNameEnglish.dispose();
    storeNameArabic.dispose();
    storeMobileNumber.dispose();
    governorateController.dispose();
    districtController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStoreImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _storeImage = File(picked.path);
      if (_isEditMode) _hasChanges = true;
    });

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    context.read<StoreCreationBloc>().add(
      StoreLogoUploadRequested(bytes: bytes, filename: picked.name),
    );
  }

  Future<void> _pickFromList({
    required String title,
    required List<LocationItemModel> options,
    required String Function(LocationItemModel value) labelBuilder,
    required ValueChanged<LocationItemModel> onSelected,
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

  void _submitStore() {
    setState(() => _submitted = true);
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_isEditMode) {
      context.read<StoreCreationBloc>().add(
        StoreUpdateSubmitted(
          storeId: widget.existingStore!.id,
          nameEn: storeNameEnglish.text,
          nameAr: storeNameArabic.text,
          description: descriptionController.text,
          storeNumber: storeMobileNumber.text,
          originalGovernorateId: widget.existingStore!.governorateId,
          originalWilayatId: widget.existingStore!.wilayat,
        ),
      );
    } else {
      context.read<StoreCreationBloc>().add(
        StoreSubmitted(
          nameEn: storeNameEnglish.text,
          nameAr: storeNameArabic.text,
          description: descriptionController.text,
          storeNumber: storeMobileNumber.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;

    return BlocConsumer<StoreCreationBloc, StoreCreationState>(
      listenWhen: (previous, current) =>
          previous.logoUploadStatus != current.logoUploadStatus ||
          previous.submitStatus != current.submitStatus ||
          previous.submitError != current.submitError ||
          previous.governoratesStatus != current.governoratesStatus ||
          previous.districtsStatus != current.districtsStatus,
      listener: (context, state) {
        if (state.logoUploadStatus == StoreLoadStatus.failure &&
            (state.logoUploadError?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.logoUploadError!)));
        }

        if (state.governoratesStatus == StoreLoadStatus.failure &&
            (state.governoratesError?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.governoratesError!)));
        }

        // Auto-select governorate in edit mode
        if (_isEditMode &&
            state.governoratesStatus == StoreLoadStatus.success &&
            state.selectedGovernorate == null &&
            state.governorates.isNotEmpty) {
          final store = widget.existingStore!;
          final match = state.governorates
              .where((g) => g.id == store.governorateId)
              .toList();
          if (match.isNotEmpty) {
            context.read<StoreCreationBloc>().add(
              StoreGovernorateSelected(match.first),
            );
            governorateController.text = match.first.displayName(
              Localizations.localeOf(context).languageCode,
            );
          }
        }

        if (state.districtsStatus == StoreLoadStatus.failure &&
            (state.districtsError?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.districtsError!)));
        }

        // Auto-select district in edit mode
        if (_isEditMode &&
            state.districtsStatus == StoreLoadStatus.success &&
            state.selectedDistrict == null &&
            state.districts.isNotEmpty) {
          final store = widget.existingStore!;
          final match = state.districts
              .where((d) => d.id == store.wilayat)
              .toList();
          if (match.isNotEmpty) {
            context.read<StoreCreationBloc>().add(
              StoreDistrictSelected(match.first),
            );
            districtController.text = match.first.displayName(
              Localizations.localeOf(context).languageCode,
            );
          }
        }

        if (state.submitStatus == StoreLoadStatus.failure &&
            (state.submitError?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.submitError!)));
        }

        if (state.submitStatus == StoreLoadStatus.success) {
          if (_isEditMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.storeUpdatedSuccess),
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.storeCreatedSuccess),
              ),
            );
            context.read<StoreProfileBloc>().add(
              const StoreProfileMarkedCreated(),
            );
            context.read<StoreProfileBloc>().add(
              const StoreProfileCheckRequested(),
            );
            final paymentState = context.read<AddlistPaymentFlowBloc>().state;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => AddlistPaymentFlowBloc()
                    ..add(
                      FlowInitialized(
                        accountType:
                            paymentState.accountType ??
                            ListingAccountType.business,
                        requiresPayment: widget.requiresPayment,
                        planTitle: paymentState.basePlanTitle,
                        planId: paymentState.basePlanId ?? '',
                        planAmount: paymentState.basePlanAmount,
                        currency: paymentState.basePlanCurrency ?? 'OMR',
                        useExistingQuota: paymentState.useExistingQuota,
                        vatAmount: paymentState.vatAmount ?? 0.0,
                      ),
                    ),
                  child: ListYourProductScreen(
                    requiresPayment: widget.requiresPayment,
                  ),
                ),
              ),
              ModalRoute.withName(AddlistScreen.routeName),
            );
          }
        }
      },
      builder: (context, state) {
        final isUploadingLogo =
            state.logoUploadStatus == StoreLoadStatus.loading;
        final isSubmitting = state.submitStatus == StoreLoadStatus.loading;
        final hasUploadedLogo = (state.logoUrl?.trim().isNotEmpty ?? false);
        final canSubmit = _isEditMode ? _hasChanges : true;

        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: CustomButton(
                text: _isEditMode ? localizations.updateStoreText : localizations.continueText,
                isLoading: isSubmitting,
                color: canSubmit
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withValues(alpha: 0.45),
                onPressed: isSubmitting || !canSubmit ? () {} : _submitStore,
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
                            _isEditMode
                                ? localizations.editYourStoreTitle
                                : localizations.createYourStoreTitle,
                            style: AppThemes.f16w600,
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Center(
                        child: GestureDetector(
                          onTap: isUploadingLogo ? null : _pickStoreImage,
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 70,
                                backgroundColor: const Color(0xFFF7F8F9),
                                backgroundImage: _storeImage != null
                                    ? FileImage(_storeImage!)
                                    : (_isEditMode &&
                                          widget
                                              .existingStore!
                                              .logo
                                              .isNotEmpty &&
                                          _storeImage == null)
                                    ? NetworkImage(widget.existingStore!.logo)
                                    : null,
                              ),
                              if (_storeImage == null &&
                                  !(_isEditMode &&
                                      widget.existingStore!.logo.isNotEmpty))
                                const Positioned.fill(
                                  child: Center(
                                    child: Icon(
                                      Icons.photo_camera,
                                      size: 36,
                                      color: AppColors.brandBlack,
                                    ),
                                  ),
                                ),
                              if (_isEditMode || _storeImage != null)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.photo_camera,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (isUploadingLogo)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0x99000000),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_submitted &&
                                  !hasUploadedLogo &&
                                  !isUploadingLogo)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          localizations.uploadBusinessLogoText,
                          style: AppThemes.f18w600,
                        ),
                      ),
                      if (_submitted && !hasUploadedLogo)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Business logo is required',
                              style: AppThemes.f12w400.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 25),
                      _RequiredLabel(
                        label: '${localizations.storeNameLabel}(English)',
                      ),
                      const SizedBox(height: 7),
                      CustomTextFormField(
                        labelText: localizations.enterFullNameHint,
                        controller: storeNameEnglish,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Store name in English is required';
                          }
                          return null;
                        },
                      ),
                      _RequiredLabel(
                        label: '${localizations.storeNameLabel}(بالعربية)',
                      ),
                      const SizedBox(height: 7),
                      CustomTextFormField(
                        labelText: localizations.enterFullNameHint,
                        controller: storeNameArabic,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Store name in Arabic is required';
                          }
                          return null;
                        },
                      ),
                      _RequiredLabel(
                        label:
                            "${localizations.storeTitle} ${localizations.mobileNumber}",
                      ),
                      const SizedBox(height: 7),
                      CustomTextFormField(
                        labelText:
                            "${localizations.storeTitle} ${localizations.mobileNumber}",
                        controller: storeMobileNumber,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Store mobile number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const _RequiredLabel(label: 'Governorate'),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: 'Governorate',
                        controller: governorateController,
                        readOnly: true,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                        ),
                        onTap: () async {
                          if (state.governoratesStatus ==
                              StoreLoadStatus.loading) {
                            return;
                          }
                          if (state.governorates.isEmpty) {
                            context.read<StoreCreationBloc>().add(
                              const StoreGovernoratesRequested(),
                            );
                            return;
                          }
                          await _pickFromList(
                            title: 'Governorate',
                            options: state.governorates,
                            labelBuilder: (value) =>
                                value.displayName(localeCode),
                            onSelected: (value) {
                              governorateController.text = value.displayName(
                                localeCode,
                              );
                              districtController.clear();
                              context.read<StoreCreationBloc>().add(
                                StoreGovernorateSelected(value),
                              );
                              if (_isEditMode) {
                                setState(() => _hasChanges = true);
                              }
                            },
                          );
                        },
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Governorate is required';
                          }
                          return null;
                        },
                      ),
                      const _RequiredLabel(label: 'District'),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: localizations.districtLabel,
                        controller: districtController,
                        readOnly: true,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                        ),
                        onTap: () async {
                          if (state.selectedGovernorate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.selectGovernorateFirst,
                                ),
                              ),
                            );
                            return;
                          }
                          if (state.districtsStatus ==
                              StoreLoadStatus.loading) {
                            return;
                          }
                          if (state.districts.isEmpty) {
                            context.read<StoreCreationBloc>().add(
                              StoreDistrictsRequested(
                                governorateId: state.selectedGovernorate!.id,
                              ),
                            );
                            return;
                          }

                          await _pickFromList(
                            title: localizations.selectYourDistrict,
                            options: state.districts,
                            labelBuilder: (value) =>
                                value.displayName(localeCode),
                            onSelected: (value) {
                              districtController.text = value.displayName(
                                localeCode,
                              );
                              context.read<StoreCreationBloc>().add(
                                StoreDistrictSelected(value),
                              );
                              if (_isEditMode) {
                                setState(() => _hasChanges = true);
                              }
                            },
                          );
                        },
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'District is required';
                          }
                          return null;
                        },
                      ),
                      _RequiredLabel(label: localizations.descriptionLabel),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: localizations.descriptionLabel,
                        controller: descriptionController,
                        maxLines: 8,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
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
      },
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
