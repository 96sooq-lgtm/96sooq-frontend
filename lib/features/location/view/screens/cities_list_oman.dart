import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/core/bloc/location/bloc/location_bloc.dart';
import 'package:_96_sooq/features/location/model/location_item_model.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CitiesListOman extends StatefulWidget {
  const CitiesListOman({super.key, required this.state});

  final LocationItemModel state;

  @override
  State<CitiesListOman> createState() => _CitiesListOmanState();
}

class _CitiesListOmanState extends State<CitiesListOman> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<LocationBloc>();
    final hasCitiesForState =
        bloc.state.citiesStatus == LocationLoadStatus.success &&
        bloc.state.cities.isNotEmpty &&
        bloc.state.cities.every((item) => item.parentId == widget.state.id);
    if (!hasCitiesForState) {
      bloc.add(LocationCitiesRequested(widget.state.id));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
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
                  Text(localizations.selectCityLabel, style: AppThemes.f16w600),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.state.displayName(languageCode),
                style: AppThemes.f14w500,
              ),
              const SizedBox(height: 12),
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
                      previous.citiesStatus != current.citiesStatus ||
                      previous.cities != current.cities ||
                      previous.errorMessage != current.errorMessage,
                  builder: (context, state) {
                    if (state.citiesStatus == LocationLoadStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.citiesStatus == LocationLoadStatus.failure) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.errorMessage ?? 'Failed to load cities',
                              style: AppThemes.f14w500,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                context.read<LocationBloc>().add(
                                  LocationCitiesRequested(widget.state.id),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final query = _searchController.text.trim().toLowerCase();
                    final items = state.cities.where((item) {
                      final name = item.displayName(languageCode).toLowerCase();
                      return query.isEmpty || name.contains(query);
                    }).toList();

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No cities found',
                          style: AppThemes.f14w500,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
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
                          onTap: () {
                            context.read<LocationBloc>().add(
                              LocationCitySelected(
                                state: widget.state,
                                city: item,
                              ),
                            );
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            if (navigator.canPop()) {
                              navigator.pop();
                            }
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
    );
  }
}
