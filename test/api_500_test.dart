import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  test('Test 500 API Call', () async {
    final dio = Dio(
      BaseOptions(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1bWVyYWhzYW43NTdAZ21haWwuY29tIiwicm9sZSI6ImN1c3RvbWVyIiwidXNlcl9pZCI6ImE2ZmZhM2FjLTE1N2QtNDA3NS04MzU1LTQ5ZTQ3ZDY0ZGE1ZSIsImV4cCI6MTc4MDMwODYwOX0.TDuidqE7dVVbH9PTnvFoCwo_deey213YVdjulGZ35-Q',
        },
      ),
    );

    try {
      final response = await dio.get(
        'https://nine6sooq-backend.onrender.com/api/listings/29cb1654-4996-44d3-bd5d-66bf66da18fc',
      );
      print('SUCCESS: \${response.statusCode}');
      print('DATA: \${response.data}');
    } on DioException catch (e) {
      print('DIO ERROR: \${e.response?.statusCode}');
      print('DATA: \${e.response?.data}');
      expect(e.response?.statusCode, isNot(500));
    }
  });
}
