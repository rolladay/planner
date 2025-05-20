import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../features/calendar_features/calendar_data_source.dart';
import '../features/calendar_features/event_service.dart';
import '../features/common_features/basic_features.dart';
import '../features/common_features/crud_features.dart';
import 'creat_event_page.dart';
import '../features/objectbox/objectbox_service.dart';
import '../features/providers/selected_date_provider.dart';
import '../models/event_model.dart';

// 메인 시작화면이고, 달력으로 시작 (이건 맞음) -232lines
class MonthlyCalendar extends ConsumerStatefulWidget {
  const MonthlyCalendar({super.key});

  @override
  MonthlyCalendarState createState() => MonthlyCalendarState();
}

class MonthlyCalendarState extends ConsumerState<MonthlyCalendar> {
  // SFCalendar 제공 캘린더 컨트롤러 위젯 탭하면 index의 날짜같은 정보 주는
  // 그외 확정적인 건 여기서 다 클래스 필드로(클래스 내부에 선언된 변수(멤버 변수)) 선언해라. 가변적인건 InitState에서
  // 필드는 클래스 내부에 선언된 변수만을 의미합니다. 메서드 내부에서 선언한 변수는 지역 변수
  late CalendarController _calendarController;
  DateTime _selectedDate = DateTime.now();
  final EventService _eventService = EventService();

  // initState에서 loadEvent 함수안에서 _dateSource에 오브젝트박스 모든 이벤트 불러와서
  // appointments에 이벤트리스트가 들어가 있게됨(나중에 월별로 하든 뭐 해야지?)
  // initState에서 선언해줘야함. 만들어질때 비어있기도 하고 변하면 변한거 반영해야지
  EventDataSource? _dataSource;

  // 선택한 날짜에 존재하는 이벤트 객체 불러오기
  List<EventModel> _selectedDateEvents = [];

  // 캘린더컨트롤러 초기화 및 선택날짜 프로바이더 읽고, 이벤트 불러오고,
  // updateSelectedDateEvents 를 통해 날짜별 이벤트 리스트를 생성해둔다. 근데 모든 날짜에 대해 실행
  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _selectedDate = ref.read(selectedDateProvider);
    //오브젝트박스에서 List불러와서 eventDataSource의 appointments에다 집어넣는 과정
    _loadEvents();
    updateSelectedDateEvents();
    print(_selectedDate);
    print("Provider 값: ${ref.read(selectedDateProvider)}");
  }

  // 이벤트 데이터 로드 메서드 오브젝트박스에서 불러와서 이벤트데이터소스로 전환
  void _loadEvents() {
    final events = ObjectBoxService.getAllEvents();
    setState(() {
      _dataSource = EventDataSource(events);
    });
    print('로드된 이벤트 수: ${events.length}');
    print('box이름: ${ObjectBoxService.store.directoryPath}');
  }

  void updateSelectedDateEvents() {
    // 데이터소스 널아닐때 러프오니트먼트(모든 이벤트 다 담고 있는 객체)접근
    // 즉, where의 조건에 맞는 것만 골라서 map으로 돌려 List로 만든다 로 이해하면 되나? 이것의 문법예시는?
    // 리스트.where((요소) => 조건식).map((요소) => 변환식).toList();
    _selectedDateEvents = _dataSource?.appointments
            ?.where((event) => isSameDay(event.from, _selectedDate))
            .map((event) => event as EventModel)
            .toList() ??
        [];
    setState(() {});
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    return date1?.year == date2?.year &&
        date1?.month == date2?.month &&
        date1?.day == date2?.day;
  }

  // 이벤트 목록 위젯 (재사용)
  Widget _buildDayEventsList() {
    return ListView.builder(
      itemCount: _selectedDateEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedDateEvents[index];
        return GestureDetector(
          // index가 아닌 event 객체를 전달
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return _buildEventDetailSheet(event);
              },
            );
          },
          onLongPress: () => showDeleteDialog(event, context),

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('assets/images/clock.png'),
                  ),
                  Text(event.eventName),
                  const Spacer(), // 이벤트 이름과 시간 사이에 공간을 만듭니다
                  (event.isAllDay == true)
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Free',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${formatTime(event.from)} - ${formatTime(event.to)}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventDetailSheet(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event.eventName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // 이벤트 수정 기능 구현
                  Navigator.pop(context);
                  // 수정 화면으로 이동하는 코드 추가
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset('assets/images/clock.png', width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                event.isAllDay
                    ? '종일'
                    : '${formatTime(event.from)} - ${formatTime(event.to)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // if (event.description != null && event.description!.isNotEmpty)
          //   Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text(
          //         '메모',
          //         style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         event.description!,
          //         style: const TextStyle(fontSize: 16),
          //       ),
          //     ],
          //   ),
          // const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('닫기'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDeleteDialog(event, context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Future<void> _deleteEvent(int id) async {
  //   try {
  //     // 1. 이벤트 삭제
  //     await _eventService.deleteEvent(id);
  //
  //     // 2. 이벤트 목록 다시 로드
  //     final events = ObjectBoxService.getAllEvents();
  //
  //     // 3. 상태 변수 업데이트
  //     if (mounted) {
  //       setState(() {
  //         _dataSource = EventDataSource(events);
  //         // 선택된 날짜의 이벤트 목록도 업데이트
  //         _selectedDateEvents = events
  //             .where((event) => isSameDay(event.from, _selectedDate))
  //             .toList();
  //       });
  //
  //       // 4. 성공 메시지 표시
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('일정이 삭제되었습니다'),
  //           duration: Duration(seconds: 1),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('일정 삭제 중 오류가 발생했습니다: $e')),
  //       );
  //     }
  //   }
  // }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dataSource == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          // _셀렉티드데이트가 초기값은 now이지만, 이 후 선택하면 riverpod에 의해 계속 추적
          DateFormat('yyyy MMMM').format(_selectedDate),
          style: GoogleFonts.paytoneOne(
            fontSize: 22,
            // fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black, height: 2.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          children: [
            Expanded(
              //Expanded위젯의 파라미터 - flex
              flex: 7,
              child: SfCalendar(
                view: CalendarView.month,
                dataSource: _dataSource,
                controller: _calendarController,
                viewHeaderHeight: 16,
                viewHeaderStyle: const ViewHeaderStyle(
                  dayTextStyle: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                monthCellBuilder:
                    (BuildContext buildContext, MonthCellDetails details) {
                  bool hasAppointments = _dataSource?.appointments?.any(
                          (event) => isSameDay(event.from, details.date)) ??
                      false;

                  final middleDate =
                      details.visibleDates[details.visibleDates.length ~/ 2];

                  List<EventModel> dayEvents = _dataSource?.appointments
                          ?.where(
                              (event) => isSameDay(event.from, details.date))
                          .map((event) => event as EventModel)
                          .toList() ??
                      [];

                  // 셀의 배경색 설정 (선택적)
                  Color textColor;
                  if (details.date.month == middleDate.month) {
                    // 현재 월
                    textColor = Colors.black;
                  } else if (details.date.isBefore(middleDate)) {
                    // 이전 월
                    textColor = Colors.grey[400]!;
                  } else {
                    // 다음 월
                    textColor = Colors.grey[400]!;
                  }

                  bool isToday = isSameDay(details.date, DateTime.now());

                  // 오늘 날짜 강조
                  if (isSameDay(details.date, DateTime.now())) {
                    textColor = Colors.blue;
                  }
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black26, // 아래쪽 테두리 색상
                          width: 0.5, // 테두리 두께
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          details.date.day.toString(),
                          style: TextStyle(
                            fontSize: 11, // 글씨 크기
                            color: textColor, // 글씨 색상
                          ),
                        ),
                      ),
                    ),
                  );
                },

                cellBorderColor: Colors.transparent,
                headerHeight: 0,
                todayHighlightColor: Colors.black,

                selectionDecoration: BoxDecoration(
                  color: Colors.black12.withOpacity(0.1), // 매우 연한 반투명 효과
                  border: Border.all(color: Colors.black87, width: 2),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                ),

                monthViewSettings: const MonthViewSettings(
                  dayFormat: 'EEE',
                  appointmentDisplayCount: 3,
                  showTrailingAndLeadingDates: true,
                ),

                onViewChanged: (ViewChangedDetails details) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      // 현재 보이는 월 찾기 (visibleDates 배열의 중간 날짜 사용)
                      DateTime visibleMonthDate = details
                          .visibleDates[details.visibleDates.length ~/ 2];
                      // 현재 선택된 날짜의 일(day) 가져오기
                      int currentDay = _selectedDate.day;
                      // 새로운 월의 마지막 날짜 계산
                      int lastDayOfMonth = DateTime(visibleMonthDate.year,
                              visibleMonthDate.month + 1, 0)
                          .day;
                      // 현재 선택된 날짜의 일(day)이 새 월의 마지막 날짜보다 크면 마지막 날짜 사용
                      int targetDay = currentDay > lastDayOfMonth
                          ? lastDayOfMonth
                          : currentDay;
                      // 새로운 선택 날짜 생성
                      DateTime newSelectedDate = DateTime(visibleMonthDate.year,
                          visibleMonthDate.month, targetDay);
                      // 상태 변수와 컨트롤러 모두 업데이트
                      _selectedDate = newSelectedDate;
                      _calendarController.selectedDate = newSelectedDate;
                      ref
                          .read(selectedDateProvider.notifier)
                          .updateDate(newSelectedDate);
                      updateSelectedDateEvents();
                    });
                  });
                },

                // onLongPress: _onLongPress,
                onTap: (CalendarTapDetails details) {
                  if (details.targetElement == CalendarElement.calendarCell) {
                    if (isSameDay(details.date, _selectedDate)) {
                      // showDialog 대신 Navigator.push 사용
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEventPage(
                            initialDate: details.date!, // 선택한 날짜 전달
                            onEventCreated: (EventModel newEvent) {
                              _loadEvents();
                              updateSelectedDateEvents();
                            },
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        _selectedDate = details.date!;
                        ref
                            .read(selectedDateProvider.notifier)
                            .updateDate(_selectedDate);
                        updateSelectedDateEvents();
                        print(_selectedDate);
                        print("Provider 값: ${ref.read(selectedDateProvider)}");
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Taskit  ${DateFormat('MM/dd').format(_selectedDate)} ',
                style: GoogleFonts.paytoneOne(
                  fontSize: 14,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Expanded(
                flex: 6,
                // 리스트뷰 빌더 소환
                child: _selectedDateEvents.isNotEmpty
                    ? _buildDayEventsList()
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/empty_taskit.png',
                              width: 36),
                          const SizedBox(height: 16),
                          const Text('Task it easy.', style: TextStyle(color: Colors.black54),),
                        ],
                      ))),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
