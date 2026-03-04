import 'package:_96_sooq/features/offers/bloc/offers_bloc.dart';
import 'package:_96_sooq/features/offers/bloc/offers_event.dart';
import 'package:_96_sooq/features/offers/bloc/offers_state.dart';
import 'package:_96_sooq/features/offers/view/screens/offers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:shimmer/shimmer.dart';

class OffersWidget extends StatefulWidget {
  const OffersWidget({super.key});

  @override
  State<OffersWidget> createState() => _OffersWidgetState();
}

class _OffersWidgetState extends State<OffersWidget> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<OffersBloc>().add(const FetchOffers());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        /// ================= SHIMMER =================
        if (state.status == OffersStatus.initial ||
            (state.status == OffersStatus.loading && state.offers.isEmpty)) {
          return SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Shimmer.fromColors(
                    baseColor: const Color(0xFFE6E6E6),
                    highlightColor: const Color(0xFFF5F5F5),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        if (state.offers.isEmpty) {
          return const SizedBox.shrink();
        }

        /// ================= OFFERS LIST =================
        return SizedBox(
          height: 70,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: state.hasReachedMax
                ? state.offers.length
                : state.offers.length + 1,
            itemBuilder: (context, index) {
              if (index >= state.offers.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final offer = state.offers[index];
              final hasImage =
                  offer.avatarUrl != null && offer.avatarUrl!.trim().isNotEmpty;

              return Padding(
                padding: const EdgeInsets.only(right: 18),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OffersScreen(
                          offers: state.offers,
                          initialOfferIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFEA00), Color(0xFF998C00)],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),

                      /// 🔴 PERFECT CIRCULAR IMAGE
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: hasImage || offer.stories.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    hasImage
                                        ? offer.avatarUrl!
                                        : offer.stories.first,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasImage || offer.stories.isNotEmpty
                            ? null
                            : const Icon(
                                Icons.store_mall_directory_rounded,
                                color: Colors.grey,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
