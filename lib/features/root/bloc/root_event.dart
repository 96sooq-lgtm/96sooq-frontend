abstract class RootEvent {}

class ChangeTabEvent extends RootEvent {
  final int index;
  ChangeTabEvent(this.index);
}
