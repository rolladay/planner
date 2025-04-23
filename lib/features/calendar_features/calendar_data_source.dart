import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/event_model.dart';
import '../objectbox/objectbox_service.dart';

class EventDataSource extends CalendarDataSource {
  // 생성자 이벤트모델 리스트를 받아서 appointments에 할당해줌
  EventDataSource(List<EventModel> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }


  // note 찾으려고 에러나는거 방지하기 위해
  @override
  String getNotes(int index) {
    // EventModel에 notes 속성이 없으므로 빈 문자열 반환
    return '';
  }

  // 색상관련 override
  @override
  Color getColor(int index) {
    // 여기서 원하는 색상을 반환
    return Colors.black54; // 모든 일정의 색상(및 인디케이터)을 검은색으로 변경

    // 또는 일정 유형에 따라 다른 색상 반환
    // final event = appointments![index] as EventModel;
    // if (event.eventName.contains('회의')) {
    //   return Colors.red;
    // } else {
    //   return Colors.black;
    // }
  }

  // 이벤트 추가 메소드
  // void addEvent(EventModel event) {
  //   appointments!.add(event);
  //   notifyListeners(CalendarDataSourceAction.add, <EventModel>[event]);
  // }
  //
  // // 이벤트 업데이트 메소드
  // void updateEvent(EventModel oldEvent, EventModel newEvent) {
  //   int index = appointments!.indexOf(oldEvent);
  //   if (index != -1) {
  //     appointments![index] = newEvent;
  //     notifyListeners(CalendarDataSourceAction.reset, <EventModel>[newEvent]);
  //   }
  // }
  //
  // // 이벤트 삭제 메소드
  // void removeEvent(EventModel event) {
  //   appointments!.remove(event);
  //   notifyListeners(CalendarDataSourceAction.remove, <EventModel>[event]);
  // }
  //
  // // 모든 이벤트 새로고침 메소드
  // void refreshEvents() {
  //   List<EventModel> events = ObjectBoxService.getAllEvents();
  //   appointments = events;
  //   notifyListeners(CalendarDataSourceAction.reset, events);
  // }

  EventModel _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    if (meeting is EventModel) {
      return meeting;
    }
    throw TypeError(); // 또는 기본값 반환 또는 다른 예외 처리
  }
}

//  ObjectBox에서 이벤트 데이터를 가져와 'SfCalendar가 이해할 수 있는 EventDataSource' 형태로 변환
// EventDataSource getCalendarDataSource() {
//   // ObjectBoxService에서 모든 이벤트 가져와서 Event List로 만들고, 그걸 아래 EventDataSource 메소드에 넣어 SF캘린더에 보낼 수 있게 변환
//   List<EventModel> events = ObjectBoxService.getAllEvents();
//   // 이벤트가 없는 경우 빈 리스트 반환
//   if (events.isEmpty) {
//     events = <EventModel>[];
//   }
//   return EventDataSource(events);
// }


