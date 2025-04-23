import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../features/calendar_features/event_service.dart';
import '../features/common_features/common_features.dart';
import '../models/event_model.dart';
import '../features/objectbox/objectbox_service.dart';

// 일정 생성하는 위젯
class CreateEventPage extends StatefulWidget {
  final DateTime initialDate;
  final Function(EventModel) onEventCreated;

  const CreateEventPage({
    super.key,
    required this.initialDate,
    required this.onEventCreated,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late TextEditingController eventNameController;
  late TextEditingController eventMemoController;
  late DateTime selectedStartDate;
  late DateTime selectedEndDate;
  bool isAllDay = false;

  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController();
    eventMemoController = TextEditingController();
    selectedStartDate = widget.initialDate;
    print(widget.initialDate);
    selectedEndDate = widget.initialDate.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    eventNameController.dispose();
    eventMemoController.dispose();
    super.dispose();
  }

  // AM/PM 포맷으로 시간 표시
  String formatTimeString(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$period ${hour12.toString().padLeft(2, '0')}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.access_alarm),
            onPressed: () {
              handlePopWithKeyboardCheck(context);
            }),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Task it', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text('저장', style: TextStyle(color: Colors.black)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black, height: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: eventNameController,
                decoration: const InputDecoration(
                  hintText: '일정 이름을 입력하세요',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.black26),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                ),
                cursorColor: Colors.black,
              ),
              const SizedBox(height: 24),

              // 종일 토글 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAllDay ? 'Task on date' : 'Task with schedule',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isAllDay,
                    onChanged: (value) {
                      setState(() {
                        isAllDay = value;
                      });
                    },
                    activeColor: Colors.black,
                    activeTrackColor: Colors.grey[300],  // 켜진 상태의 트랙 색상
                    inactiveTrackColor: Colors.grey[300],  // 꺼진 상태의 트랙 색상
                    inactiveThumbColor: Colors.grey[50],
                    trackOutlineColor: WidgetStateColor.transparent// 꺼진 상태의 동그란 버튼 색상
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 시간 선택 UI (isAllDay가 false일 때만 표시)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시간 선택 행
                  Opacity(
                    opacity: isAllDay ? 0.5 : 1.0, // isAllDay가 true면 반투명하게
                    child: AbsorbPointer( // isAllDay가 true면 탭 이벤트 무시
                      absorbing: isAllDay,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => showIOSTimePicker(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  formatTimeString(selectedStartDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('→', style: TextStyle(fontSize: 18)),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => showIOSTimePicker(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  formatTimeString(selectedEndDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // iOS 스타일 TimePicker 표시
  void showIOSTimePicker(bool isStartTime) {
    DateTime initialTime = isStartTime ? selectedStartDate : selectedEndDate;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('취소'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: const Text('완료'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  // minuteInterval: 5,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      if (isStartTime) {
                        // 시작 시간 변경 시 날짜 정보는 유지하고 시간만 변경
                        selectedStartDate = DateTime(
                          widget.initialDate.year,
                          widget.initialDate.month,
                          widget.initialDate.day,
                          newTime.hour,
                          newTime.minute,
                        );

                        // 시작 시간이 종료 시간보다 늦으면 종료 시간 자동 조정
                        if (selectedStartDate.isAfter(selectedEndDate)) {
                          selectedEndDate = selectedStartDate.add(const Duration(hours: 1));
                        }
                      } else {
                        // 종료 시간 변경 시 날짜 정보는 유지하고 시간만 변경
                        selectedEndDate = DateTime(
                          widget.initialDate.year,
                          widget.initialDate.month,
                          widget.initialDate.day,
                          newTime.hour,
                          newTime.minute,
                        );

                        // 종료 시간이 시작 시간보다 이르면 자동 조정
                        if (selectedEndDate.isBefore(selectedStartDate)) {
                          selectedEndDate = selectedStartDate.add(const Duration(hours: 1));
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // 0414 이걸 event_service의 함수를 재사용하는 방식으로 바꿔줘야하.. 언젠가는....

  void _saveEvent() async {
    // createEvent 함수 호출
    EventModel newEvent = await _eventService.createEvent(
      eventName: eventNameController.text,
      from: selectedStartDate,
      to: selectedEndDate,
      isAllDay: isAllDay,
    );

    // 콜백 실행 - loadEvents(앞화면에서 넘어온 것)
    if (mounted) {
      // 콜백 실행
      widget.onEventCreated(newEvent);
      handlePopWithKeyboardCheck(context);
    }
  }
}



