import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/data/addlist_subscription_api_service.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/addlist/model/listing_prices_response_model.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddlistPaymentFlowBloc listing prices', () {
    test(
      'maps business account to isStore=true and stores plans + quota',
      () async {
        final fakeService = _FakeSubscriptionApiService(
          response: const ListingPricesResponseModel(
            quotaStatus: ListingQuotaStatusModel(
              canCreateFree: true,
              canCreatePaid: true,
              usage: 1,
              paidRemaining: -1,
            ),
            plans: [
              ListingPlanModel(
                id: 'plan-1',
                nameEn: 'Business Plan',
                nameAr: 'خطة المتجر',
                type: 'listing',
                price: 20,
                durationDays: 30,
                description: 'Line 1\nLine 2',
                quota: -1,
                targetAudience: 'store',
                isBestValue: true,
                isActive: true,
                createdAt: null,
                features: <String, dynamic>{},
                raw: <String, dynamic>{},
              ),
            ],
          ),
        );
        final bloc = AddlistPaymentFlowBloc(
          subscriptionApiService: fakeService,
        );

        final future = expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<AddlistPaymentFlowState>(
              (state) =>
                  state.listingPricesStatus == ListingPricesStatus.loading &&
                  state.listingPricesForAccountType ==
                      ListingAccountType.business,
            ),
            predicate<AddlistPaymentFlowState>(
              (state) =>
                  state.listingPricesStatus == ListingPricesStatus.success &&
                  state.listingPrices.length == 1 &&
                  state.listingQuotaStatus != null,
            ),
          ]),
        );

        bloc.add(
          const ListingPricesRequested(
            accountType: ListingAccountType.business,
          ),
        );
        await future;

        expect(fakeService.lastIsStore, isTrue);
        await bloc.close();
      },
    );

    test('maps individual account to isStore=false', () async {
      final fakeService = _FakeSubscriptionApiService(
        response: const ListingPricesResponseModel(
          quotaStatus: null,
          plans: <ListingPlanModel>[],
        ),
      );
      final bloc = AddlistPaymentFlowBloc(subscriptionApiService: fakeService);

      bloc.add(
        const ListingPricesRequested(
          accountType: ListingAccountType.individual,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(fakeService.lastIsStore, isFalse);
      await bloc.close();
    });
  });

  group('AddlistPaymentFlowBloc product details', () {
    test(
      'stores extended product fields including dynamic attributes',
      () async {
        final bloc = AddlistPaymentFlowBloc();

        bloc.add(
          const ProductDetailsCaptured(
            productTitle: 'iPhone 14',
            productPrice: 399.5,
            photoPaths: ['/tmp/p.jpg'],
            categoryName: 'Electronics',
            subCategoryName: 'Mobile Phones',
            description: 'Good condition',
            condition: 'Used',
            city: 'Muscat',
            place: 'Qurum',
            subCategoryId: 'sub-1',
            subCategoryAttributesSchema: <CategoryAttributeSchemaModel>[
              CategoryAttributeSchemaModel(
                name: 'brand',
                type: 'text',
                labelEn: 'Brand',
                labelAr: 'ماركة',
                requiredField: true,
                accept: null,
                status: 'active',
                options: <String>[],
                optionsAr: <String>[],
                multiple: false,
              ),
            ],
            dynamicAttributes: <String, dynamic>{'brand': 'Apple'},
            governorateId: 'gov-1',
            wilayatId: 'wil-1',
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(bloc.state.productTitle, 'iPhone 14');
        expect(bloc.state.subCategoryId, 'sub-1');
        expect(bloc.state.dynamicAttributes['brand'], 'Apple');
        expect(bloc.state.governorateId, 'gov-1');
        expect(bloc.state.wilayatId, 'wil-1');
        expect(bloc.state.subCategoryAttributesSchema.length, 1);

        await bloc.close();
      },
    );
  });
}

class _FakeSubscriptionApiService extends AddlistSubscriptionApiService {
  _FakeSubscriptionApiService({required this.response});

  final ListingPricesResponseModel response;
  bool? lastIsStore;

  @override
  Future<ListingPricesResponseModel> fetchListingPrices({
    required bool isStore,
  }) async {
    lastIsStore = isStore;
    return response;
  }
}
