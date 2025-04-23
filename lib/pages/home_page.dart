import 'package:flutter/material.dart';
import 'package:rolla/pages/monthly_calendar.dart';
import 'package:rolla/pages/my_profile.dart';
import 'package:rolla/pages/todo_list.dart';
import '../constants/my_bnb.dart';
import 'day_planner.dart';


// 마이홈에는 바텀네비게이션바만 있으면 됨.
class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  int _selectedIndex = 0;
  // late CalendarController _calendarController;
  void _onBnbItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const MonthlyCalendar();
      case 1:
        return const DayPlanner();
      case 2:
        return const ToDoList();
      case 3:
        return const MyProfile();
      default:
        return const MonthlyCalendar(); // 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 빌드바디에 의해 새로운 위젯들이 그려지는 경우, 기존 위젯은 dispose 되는 개념
      body: _buildBody(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.black,
            height: 1,
            width: double.infinity,
          ),
          BottomNavigationBar(

            // selectedFontSize: 12,
            // selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            showSelectedLabels: false,
            showUnselectedLabels: false,

            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: myBnbList,
            currentIndex: _selectedIndex,
            onTap: _onBnbItemTapped,
          ),
        ],
      ),
    );
  }
}
