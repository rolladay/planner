import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../features/calendar_features/calendar_data_source.dart';
import '../features/providers/selected_date_provider.dart';
import '../features/objectbox/objectbox_service.dart';
import 'creat_event_page.dart';

class DayPlanner extends ConsumerStatefulWidget {
  const DayPlanner({super.key});

  @override
  DayPlannerState createState() => DayPlannerState();
}

class DayPlannerState extends ConsumerState<DayPlanner> {
  late CalendarController _calendarController;
  EventDataSource? _dataSource;
  late DateTime _selectedDate;// 초기 날짜 설정

  // initState안에서 컨트롤러 정의가 이뤄지는게 좋음. 메모리 관리 등
  @override
  void initState() {
    super.initState();
    _selectedDate = ref.read(selectedDateProvider);
    _calendarController = CalendarController();
    _calendarController.view = CalendarView.day;
    _calendarController.displayDate = _selectedDate;
    _loadEvents();
    print(_selectedDate);
    print("Provider 값: ${ref.read(selectedDateProvider)}");
  }

  // 클래스 내 정의한 _dataSource 변수에 이벤트리스트(SHC데이터) 선언
  void _loadEvents() {
    final events = ObjectBoxService.getAllEvents();
    setState(() {
      _dataSource = EventDataSource(events);
    });
  }

  void _handleDateNavigation(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset));
      _calendarController.displayDate = _selectedDate;
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _selectedDate = ref.watch(selectedDateProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          DateFormat('yyyy dd MMMM').format(_selectedDate),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black, height: 2.0),
        ),
      ),
      body: _dataSource == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SfCalendar(
                appointmentTextStyle: const TextStyle(
                  fontSize: 10, // 원하는 크기로 조정
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                headerHeight: 0,
                viewHeaderHeight: 120,





                // 사용자가 스와이프나 탭할떄 호출되는 함수
                onViewChanged: (ViewChangedDetails details) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      // details...는 필요. 프로바이더 상태업데이트와 별도로 로컬 상태관리 필요
                      _selectedDate = details.visibleDates.first;
                      ref.read(selectedDateProvider.notifier).updateDate(_selectedDate);
                    });
                  });
                },
                controller: _calendarController,
                view: CalendarView.day,
                dataSource: _dataSource,
                // 롱탭했을때 뭘 줄지 여기 정의, 수정이 되는게 좋겠다.
                onLongPress: (details) {
                  showDialog(
                    context: context,
                    builder: (context) => CreateEventPage(
                      initialDate: details.date ?? DateTime.now(),
                      onEventCreated: (newEvent) => _loadEvents(),
                    ),
                  );
                },
                timeSlotViewSettings: const TimeSlotViewSettings(
                  startHour: 06,
                  minimumAppointmentDuration: Duration(minutes: 30),
                  timeIntervalHeight: 60,
                  timeFormat: 'HH:mm',
                  timeTextStyle: TextStyle(fontSize: 12),
                ),
                todayTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => CreateEventPage(
            initialDate: _selectedDate,
            onEventCreated: (newEvent) => _loadEvents(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
