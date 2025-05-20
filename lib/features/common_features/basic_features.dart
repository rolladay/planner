import 'package:flutter/material.dart';

// 키패드 내려가고 이동하게 하는 함수
void handlePopWithKeyboardCheck(BuildContext context) {
  if (FocusScope.of(context).hasPrimaryFocus == false) {
    // 키패드 닫기
    FocusManager.instance.primaryFocus?.unfocus();

    // 키패드가 완전히 닫힌 후 화면 전환 (약간의 딜레이 추가)
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.of(context).pop();
    });
  } else {
    // 키패드가 열려있지 않으면 바로 이전 화면으로 이동
    Navigator.of(context).pop();
  }
}



String formatTime(DateTime dateTime) {
  // 시간과 분만 표시 (예: 14:30)
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
