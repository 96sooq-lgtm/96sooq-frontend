import 'package:_96_sooq/features/categories/bloc/categories_api_service.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesApiService _apiService;
  int _subCategoriesRequestToken = 0;

  CategoriesBloc({CategoriesApiService? apiService})
    : _apiService = apiService ?? const CategoriesApiService(),
      super(const CategoriesState()) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<SubCategoriesRequested>(_onSubCategoriesRequested);
    on<StoresViewRequested>(_onStoresViewRequested);
  }

  Future<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(
      state.copyWith(
        categoriesStatus: CategoriesStatus.loading,
        clearCategoriesError: true,
      ),
    );

    try {
      final categories = await _apiService.fetchCategories();
      emit(
        state.copyWith(
          categoriesStatus: CategoriesStatus.loaded,
          categories: categories,
          clearCategoriesError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          categoriesStatus: CategoriesStatus.error,
          categoriesError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSubCategoriesRequested(
    SubCategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (event.parentId.isEmpty) {
      return;
    }

    if (state.selectedParentId == event.parentId &&
        state.subCategoriesStatus == SubCategoriesStatus.loaded) {
      return;
    }

    final requestToken = ++_subCategoriesRequestToken;

    emit(
      state.copyWith(
        selectedParentId: event.parentId,
        subCategoriesStatus: SubCategoriesStatus.loading,
        subCategories: const <CategoryModel>[],
        clearSubCategoriesError: true,
      ),
    );

    try {
      final subCategories = await _apiService.fetchSubCategories(
        parentId: event.parentId,
      );

      if (requestToken != _subCategoriesRequestToken) {
        return;
      }

      emit(
        state.copyWith(
          subCategoriesStatus: SubCategoriesStatus.loaded,
          subCategories: subCategories,
          selectedParentId: event.parentId,
          clearSubCategoriesError: true,
        ),
      );
    } catch (e) {
      if (requestToken != _subCategoriesRequestToken) {
        return;
      }

      emit(
        state.copyWith(
          subCategoriesStatus: SubCategoriesStatus.error,
          subCategoriesError: e.toString(),
          selectedParentId: event.parentId,
        ),
      );
    }
  }

  void _onStoresViewRequested(
    StoresViewRequested event,
    Emitter<CategoriesState> emit,
  ) {
    emit(
      state.copyWith(
        selectedParentId: '',
        subCategoriesStatus: SubCategoriesStatus.initial,
        subCategories: const <CategoryModel>[],
        clearSubCategoriesError: true,
        storesViewRequestVersion: state.storesViewRequestVersion + 1,
      ),
    );
  }
}
