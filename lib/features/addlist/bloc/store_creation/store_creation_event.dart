part of 'store_creation_bloc.dart';

sealed class StoreCreationEvent {
  const StoreCreationEvent();
}

class StoreCreationInitialized extends StoreCreationEvent {
  const StoreCreationInitialized();
}

class StoreGovernoratesRequested extends StoreCreationEvent {
  const StoreGovernoratesRequested();
}

class StoreDistrictsRequested extends StoreCreationEvent {
  const StoreDistrictsRequested({required this.governorateId});

  final String governorateId;
}

class StoreGovernorateSelected extends StoreCreationEvent {
  const StoreGovernorateSelected(this.governorate);

  final LocationItemModel governorate;
}

class StoreDistrictSelected extends StoreCreationEvent {
  const StoreDistrictSelected(this.district);

  final LocationItemModel district;
}

class StoreLogoUploadRequested extends StoreCreationEvent {
  const StoreLogoUploadRequested({
    required this.bytes,
    required this.filename,
    this.folder = 'stores/logos',
  });

  final Uint8List bytes;
  final String filename;
  final String folder;
}

class StoreSubmitted extends StoreCreationEvent {
  const StoreSubmitted({
    required this.nameEn,
    required this.nameAr,
    required this.description,
    required this.storeNumber,
  });

  final String nameEn;
  final String nameAr;
  final String description;
  final String storeNumber;
}

class StoreCreationReset extends StoreCreationEvent {
  const StoreCreationReset();
}

class StoreEditInitialized extends StoreCreationEvent {
  const StoreEditInitialized({required this.storeId, required this.logoUrl});

  final String storeId;
  final String logoUrl;
}

class StoreUpdateSubmitted extends StoreCreationEvent {
  const StoreUpdateSubmitted({
    required this.storeId,
    required this.nameEn,
    required this.nameAr,
    required this.description,
    required this.storeNumber,
    required this.originalGovernorateId,
    required this.originalWilayatId,
  });

  final String storeId;
  final String nameEn;
  final String nameAr;
  final String description;
  final String storeNumber;
  final String originalGovernorateId;
  final String originalWilayatId;
}
