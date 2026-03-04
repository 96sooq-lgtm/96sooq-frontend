import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryAttributeSchemaModel', () {
    test('parses status options and multiple', () {
      final model = CategoryAttributeSchemaModel.fromJson(const {
        'name': 'color',
        'type': 'dropdown',
        'label_en': 'Color',
        'label_ar': 'لون',
        'required': true,
        'status': 'active',
        'options': ['Red', 'Green', 'Blue'],
        'multiple': true,
      });

      expect(model.name, 'color');
      expect(model.type, 'dropdown');
      expect(model.status, 'active');
      expect(model.options, <String>['Red', 'Green', 'Blue']);
      expect(model.multiple, isTrue);
    });

    test('keeps backward compatibility when optional keys are missing', () {
      final model = CategoryAttributeSchemaModel.fromJson(const {
        'name': 'brand',
        'type': 'text',
        'label_en': 'Brand',
        'label_ar': 'ماركة',
        'required': false,
      });

      expect(model.status, isNull);
      expect(model.options, isEmpty);
      expect(model.multiple, isFalse);
    });
  });
}
