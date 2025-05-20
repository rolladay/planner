import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/objectbox/objectbox_service.dart';
import 'pages/home_page.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  // 화면 방향 고정 (선택 사항)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // ObjectBox 초기화 - 스토어(box브릿지)를 오픈해서 사용가능한 상태로 만듬(없으면 생성) main.dart에서 실행
  await ObjectBoxService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskit',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        splashFactory: InkRipple.splashFactory,
        // splashFactory: NoSplash.splashFactory,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.black26,
        ),


        useMaterial3: true,
      ),
      home: const MyHome(),
    );
  }
}
