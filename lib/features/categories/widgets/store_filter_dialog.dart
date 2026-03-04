import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/categories/bloc/store_bloc/store_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreFilterDialog extends StatefulWidget {
  const StoreFilterDialog({super.key});

  @override
  State<StoreFilterDialog> createState() => _StoreFilterDialogState();
}

class _StoreFilterDialogState extends State<StoreFilterDialog> {
  late int _selectedStars;
  late bool _anyRating;

  @override
  void initState() {
    super.initState();
    final storeState = context.read<StoreBloc>().state;
    _anyRating = storeState.filterAnyRating;
    _selectedStars = (storeState.filterMinRating ?? 1.0).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Stack(
              alignment: Alignment.center,
              children: [
                Text('Filter', style: AppThemes.f18w700),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 22),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Rating label
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('Rating', style: AppThemes.f14w600),
            ),

            const SizedBox(height: 12),

            // Stars row
            Row(
              children: [
                ...List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStars = starIndex;
                        _anyRating = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 4),
                      child: Icon(
                        starIndex <= _selectedStars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 36,
                        color: const Color(0xFFE9BD0E),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${_selectedStars.toDouble().toStringAsFixed(1)}+',
                  style: AppThemes.f14w500,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Any Rating checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  _anyRating = !_anyRating;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _anyRating
                            ? Colors.black
                            : const Color(0xFFD0D0D0),
                        width: 1.5,
                      ),
                      color: _anyRating ? Colors.black : Colors.transparent,
                    ),
                    child: _anyRating
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text('Any Rating', style: AppThemes.f14w500),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: AppThemes.f16w600,
                ),
                child: const Text('Apply'),
              ),
            ),

            const SizedBox(height: 12),

            // Reset button
            GestureDetector(
              onTap: _onReset,
              child: Text(
                'Reset',
                style: AppThemes.f14w500.copyWith(
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onApply() {
    context.read<StoreBloc>().add(
      StoreFilterChanged(
        minRating: _anyRating ? null : _selectedStars.toDouble(),
        anyRating: _anyRating,
      ),
    );
    Navigator.pop(context);
  }

  void _onReset() {
    context.read<StoreBloc>().add(const StoreFilterReset());
    Navigator.pop(context);
  }
}
