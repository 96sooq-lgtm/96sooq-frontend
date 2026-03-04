import 'package:_96_sooq/features/addlist/model/listing_prices_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListingPricesResponseModel', () {
    test('parses quota and plans from payload', () {
      final model = ListingPricesResponseModel.fromJson({
        'quota_status': {
          'can_create_free': true,
          'can_create_paid': true,
          'usage': 0,
          'paid_remaining': -1,
        },
        'plans': [
          {
            'id': 'ac63ac0e-c2af-4234-9aed-ec5d09dd1f82',
            'name_en': 'Premium Listing',
            'name_ar': 'قائمة أساسية',
            'type': 'listing',
            'price': 20.0,
            'duration_days': 30,
            'features': {},
            'is_active': true,
            'created_at': '2026-02-18T06:43:43.201637+00:00',
            'description':
                '1. Unlimited Listings for 30 days.\n2. Enhanced Visibility.\n3. Featured Listing Placement',
            'quota': -1,
            'target_audience': 'store',
            'is_best_value': true,
          },
          {
            'id': '05f6efc3-e539-4f41-b60d-afdf17808c25',
            'name_en': 'Basic Free Plan',
            'name_ar': 'الخطة المجانية الأساسية',
            'type': 'listing',
            'price': 0.0,
            'duration_days': 30,
            'features': {},
            'is_active': true,
            'created_at': '2026-02-19T11:31:29.040481+00:00',
            'description':
                '1. 1 Listing Per Month\n2. Standard Visibility\n3. 30 Days Listing Duration',
            'quota': 1,
            'target_audience': 'everyone',
            'is_best_value': false,
          },
        ],
      });

      expect(model.quotaStatus, isNotNull);
      expect(model.quotaStatus!.canCreateFree, isTrue);
      expect(model.quotaStatus!.paidRemaining, -1);
      expect(model.plans.length, 2);
      expect(model.plans.first.displayName('en'), 'Premium Listing');
      expect(model.plans.first.displayName('ar'), 'قائمة أساسية');
      expect(model.plans.first.featureLines.length, 3);
      expect(model.plans.first.isBestValue, isTrue);
      expect(model.plans.last.price, 0.0);
    });

    test('handles missing optional fields safely', () {
      final model = ListingPricesResponseModel.fromJson({
        'plans': [
          {'id': 'p1', 'name_en': '', 'name_ar': '', 'description': ''},
        ],
      });

      expect(model.quotaStatus, isNull);
      expect(model.plans.single.displayName('en'), 'Plan');
      expect(model.plans.single.featureLines, isEmpty);
      expect(model.plans.single.price, 0.0);
      expect(model.plans.single.durationDays, 0);
    });
  });
}
