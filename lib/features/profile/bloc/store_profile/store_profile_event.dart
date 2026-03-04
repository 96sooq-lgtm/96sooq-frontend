abstract class StoreProfileEvent {
  const StoreProfileEvent();
}

class StoreProfileCheckRequested extends StoreProfileEvent {
  const StoreProfileCheckRequested();
}

class StoreProfileCleared extends StoreProfileEvent {
  const StoreProfileCleared();
}

class StoreProfileMarkedCreated extends StoreProfileEvent {
  const StoreProfileMarkedCreated();
}
