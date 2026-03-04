import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/core/bloc/location/bloc/location_bloc.dart';
import 'package:_96_sooq/features/location/view/screens/cities_list_oman.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GovernarateListScreen extends StatefulWidget {
  const GovernarateListScreen({super.key});

  @override
  State<GovernarateListScreen> createState() => _GovernarateListScreenState();
}

class _GovernarateListScreenState extends State<GovernarateListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<LocationBloc>();
    if (bloc.state.statesStatus != LocationLoadStatus.success ||
        bloc.state.states.isEmpty) {
      bloc.add(LocationStatesRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onUseCurrentLocation() {
    context.read<LocationBloc>().add(LocationUseCurrentRequested());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final languageCode = Localizations.localeOf(context).languageCode;

    return BlocListener<LocationBloc, LocationState>(
      listenWhen: (previous, current) =>
          previous.currentLocationStatus != current.currentLocationStatus ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.currentLocationStatus == LocationLoadStatus.failure &&
            (state.errorMessage?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          return;
        }
        if (state.currentLocationStatus == LocationLoadStatus.success &&
            state.selectedState != null &&
            state.selectedCity != null) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: BlocBuilder<LocationBloc, LocationState>(
            buildWhen: (previous, current) =>
                previous.currentLocationStatus != current.currentLocationStatus,
            builder: (context, state) {
              return CustomButton(
                text: localizations.useCurrentLocationText,
                isLoading:
                    state.currentLocationStatus == LocationLoadStatus.loading,
                onPressed: _onUseCurrentLocation,
              );
            },
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButtonWidget(ontap: () => Navigator.pop(context)),
                    Text(
                      localizations.selectLocationLabel,
                      style: AppThemes.f16w600,
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '${localizations.search}...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.03),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<LocationBloc, LocationState>(
                    buildWhen: (previous, current) =>
                        previous.statesStatus != current.statesStatus ||
                        previous.states != current.states,
                    builder: (context, state) {
                      if (state.statesStatus == LocationLoadStatus.loading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      if (state.statesStatus == LocationLoadStatus.failure) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.errorMessage ??
                                    'Failed to load governorates',
                                style: AppThemes.f14w500,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  context.read<LocationBloc>().add(
                                    LocationStatesRequested(),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final query = _searchController.text.trim().toLowerCase();
                      final items = state.states.where((item) {
                        final name = item
                            .displayName(languageCode)
                            .toLowerCase();
                        return query.isEmpty || name.contains(query);
                      }).toList();
                      final allInOmanLabel = localizations.allInOmanText;
                      final showAllInOman =
                          query.isEmpty ||
                          allInOmanLabel.toLowerCase().contains(query);

                      if (items.isEmpty && !showAllInOman) {
                        return Center(
                          child: Text(
                            'No governorates found',
                            style: AppThemes.f14w500,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: items.length + (showAllInOman ? 1 : 0),
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          if (showAllInOman && index == 0) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                allInOmanLabel,
                                style: isArabic
                                    ? AppThemes.f14w500.copyWith(
                                        fontWeight: FontWeight.w700,
                                      )
                                    : AppThemes.f14w500,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                context.read<LocationBloc>().add(
                                  LocationCountryFallbackSelected(
                                    label: allInOmanLabel,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            );
                          }
                          final itemIndex = showAllInOman ? index - 1 : index;
                          final item = items[itemIndex];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.displayName(languageCode),
                              style: isArabic
                                  ? AppThemes.f14w500.copyWith(
                                      fontWeight: FontWeight.w700,
                                    )
                                  : AppThemes.f14w500,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CitiesListOman(state: item),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
