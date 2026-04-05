import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  const ProductFilterBottomSheet({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialCondition,
    this.initialSellerType,
  });

  final double? initialMinPrice;
  final double? initialMaxPrice;
  final String? initialCondition; // 'All', 'New', 'Used'
  final String? initialSellerType; // 'Individual', 'Business/Store'

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  String _selectedCondition = 'All';
  String? _selectedSellerType; // null means none selected

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.initialMinPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.initialMaxPrice?.toStringAsFixed(0) ?? '',
    );
    _selectedCondition = widget.initialCondition ?? 'All';
    _selectedSellerType = widget.initialSellerType;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppThemes.f16w700.copyWith(color: AppColors.brandBlack),
      ),
    );
  }

  Widget _buildPriceField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppThemes.f14w500.copyWith(color: const Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OMR',
                  style: AppThemes.f14w500.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppThemes.f14w400.copyWith(
                      color: AppColors.brandBlack.withValues(alpha: 0.35),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppThemes.f14w400.copyWith(
                    color: AppColors.brandBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSegment(String internalLabel, String displayLabel) {
    final isSelected = _selectedCondition == internalLabel;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCondition = internalLabel;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            displayLabel,
            style: AppThemes.f14w600.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSellerTypeChip(
    String internalLabel,
    String displayLabel,
    IconData icon,
  ) {
    final isSelected = _selectedSellerType == internalLabel;
    final color = isSelected ? Colors.black : const Color(0xFF6B7280);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedSellerType == internalLabel) {
            _selectedSellerType = null;
          } else {
            _selectedSellerType = internalLabel;
          }
        });
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(displayLabel, style: AppThemes.f14w500.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Price Range
            _buildSectionTitle(loc.priceRangeTitle),
            Row(
              children: [
                Expanded(
                  child: _buildPriceField(
                    loc.minPriceLabel,
                    '50',
                    _minPriceController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPriceField(
                    loc.maxPriceLabel,
                    '350',
                    _maxPriceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Condition
            _buildSectionTitle(loc.conditionLabel),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildConditionSegment('All', loc.allText),
                  _buildConditionSegment('New', loc.newCondition),
                  _buildConditionSegment('Used', loc.usedCondition),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Seller Type
            _buildSectionTitle(loc.sellerTypeTitle),
            Wrap(
              spacing: 12,
              children: [
                _buildSellerTypeChip(
                  'Individual',
                  loc.individualShortLabel,
                  Icons.person_outline,
                ),
                _buildSellerTypeChip(
                  'Business/Store',
                  loc.businessShortLabel,
                  Icons.store_mall_directory_outlined,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final minPrice = double.tryParse(_minPriceController.text);
                  final maxPrice = double.tryParse(_maxPriceController.text);
                  Navigator.pop(context, {
                    'minPrice': minPrice,
                    'maxPrice': maxPrice,
                    'condition': _selectedCondition,
                    'sellerType': _selectedSellerType,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  loc.applyFiltersButton,
                  style: AppThemes.f16w600.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
