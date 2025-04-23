import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_date_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() {
    return DateTime.now(); // 기본값은 현재 날짜
  }

  void updateDate(DateTime newDate) {
    state = newDate;
  }
}