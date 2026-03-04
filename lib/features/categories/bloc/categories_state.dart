part of 'categories_bloc.dart';

enum CategoriesStatus { initial, loading, loaded, error }

enum SubCategoriesStatus { initial, loading, loaded, error }

@immutable
class CategoriesState {
  final CategoriesStatus categoriesStatus;
  final List<CategoryModel> categories;
  final String? categoriesError;
  final SubCategoriesStatus subCategoriesStatus;
  final List<CategoryModel> subCategories;
  final String? subCategoriesError;
  final String? selectedParentId;
  final int storesViewRequestVersion;

  const CategoriesState({
    this.categoriesStatus = CategoriesStatus.initial,
    this.categories = const <CategoryModel>[],
    this.categoriesError,
    this.subCategoriesStatus = SubCategoriesStatus.initial,
    this.subCategories = const <CategoryModel>[],
    this.subCategoriesError,
    this.selectedParentId,
    this.storesViewRequestVersion = 0,
  });

  CategoriesState copyWith({
    CategoriesStatus? categoriesStatus,
    List<CategoryModel>? categories,
    String? categoriesError,
    SubCategoriesStatus? subCategoriesStatus,
    List<CategoryModel>? subCategories,
    String? subCategoriesError,
    String? selectedParentId,
    int? storesViewRequestVersion,
    bool clearCategoriesError = false,
    bool clearSubCategoriesError = false,
  }) {
    return CategoriesState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      categories: categories ?? this.categories,
      categoriesError: clearCategoriesError
          ? null
          : (categoriesError ?? this.categoriesError),
      subCategoriesStatus: subCategoriesStatus ?? this.subCategoriesStatus,
      subCategories: subCategories ?? this.subCategories,
      subCategoriesError: clearSubCategoriesError
          ? null
          : (subCategoriesError ?? this.subCategoriesError),
      selectedParentId: selectedParentId ?? this.selectedParentId,
      storesViewRequestVersion:
          storesViewRequestVersion ?? this.storesViewRequestVersion,
    );
  }
}
