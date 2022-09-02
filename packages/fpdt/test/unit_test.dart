import 'package:fpdt/unit.dart';
import 'package:test/test.dart';

void main() {
  test('unit equality', () {
    const unit1 = unit;
    const unit2 = unit;

    expect(unit1, equals(unit2));
    expect(unit1.hashCode, equals(unit2.hashCode));
  });
}
