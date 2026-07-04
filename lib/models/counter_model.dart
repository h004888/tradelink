/// Data class đại diện cho một counter trong Model layer.
///
/// Trong dự án thực tế, Model có thể là các entity, DTO,
/// hoặc class ánh xạ từ database / API response.
class CounterModel {
  final int value;

  const CounterModel({this.value = 0});

  CounterModel copyWith({int? value}) {
    return CounterModel(value: value ?? this.value);
  }
}
