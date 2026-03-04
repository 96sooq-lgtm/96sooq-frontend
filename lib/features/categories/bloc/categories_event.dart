part of 'categories_bloc.dart';

@immutable
sealed class CategoriesEvent {}

final class CategoriesRequested extends CategoriesEvent {}

final class SubCategoriesRequested extends CategoriesEvent {
  SubCategoriesRequested(this.parentId);

  final String parentId;
}

final class StoresViewRequested extends CategoriesEvent {}
