class RootState {
  final int currentIndex;

  const RootState({required this.currentIndex});

  RootState copyWith({int? currentIndex}) {
    return RootState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
