import 'package:astrology_app/app.dart';
import 'package:astrology_app/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app and subscription plans are configured', () {
    expect(const AstroApp(), isA<ConsumerWidget>());
    expect(SubscriptionPlan.monthly.priceJpy, 550);
    expect(SubscriptionPlan.yearly.priceJpy, 5500);
  });
}
