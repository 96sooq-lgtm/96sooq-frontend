import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_event.dart';
import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_state.dart';
import 'package:_96_sooq/features/categories/data/category_feed_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFeedBloc extends Bloc<CategoryFeedEvent, CategoryFeedState> {
  final CategoryFeedApiService apiService;
  static const int _limit = 10;

  CategoryFeedBloc({required this.apiService})
    : super(const CategoryFeedState()) {
    on<FetchCategoryFeed>(_onFetchCategoryFeed);
  }

  Future<void> _onFetchCategoryFeed(
    FetchCategoryFeed event,
    Emitter<CategoryFeedState> emit,
  ) async {
    if (event.isRefresh) {
      emit(
        state.copyWith(
          status: CategoryFeedStatus.loading,
          products: [],
          hasReachedMax: false,
          skip: 0,
          errorMessage: null,
        ),
      );
    } else if (state.hasReachedMax) {
      return;
    }

    try {
      if (state.status == CategoryFeedStatus.initial) {
        emit(state.copyWith(status: CategoryFeedStatus.loading));
      }

      final response = await apiService.fetchCategoryFeed(
        categoryId: event.categoryId,
        skip: state.skip,
        limit: _limit,
        governorate: event.governorate,
      );

      final isMax = response.listings.length < _limit;

      emit(
        state.copyWith(
          status: CategoryFeedStatus.success,
          category: response.category,
          products: List.of(state.products)..addAll(response.listings),
          hasReachedMax: isMax,
          skip: (state.skip + response.listings.length).toInt(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryFeedStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
