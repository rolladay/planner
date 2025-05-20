import '../../models/event_model.dart';
import '../objectbox/objectbox_service.dart';


class EventService {
  static final EventService _instance = EventService._internal();

  factory EventService() {
    // 싱글톤 패턴 - factory EventService()는 새로운 인스턴스를 만들지 않고, 이미 만들어진 _instance를 반환
    return _instance;
  }
  //Private 생성자로 실제 인스턴스를 만드는 것. 이걸 저 위에 6행에서 쓰는거야.
  EventService._internal();

  // Create - 여기 보브젝트박스/파베 들어가야함
  // SFCalendar와는 상관없음
  Future<EventModel> createEvent({
    required String eventName,
    required DateTime from,
    required DateTime to,
    required bool isAllDay,
    required bool isCompleted,
  }) async {
    final newEvent = EventModel(
      eventName: eventName.isNotEmpty ? eventName : '새 일정',
      from: from,
      to: to,
      isAllDay: isAllDay,
      isCompleted: false,
    );
    // ObjectBoxService를 통해 이벤트 저장
    ObjectBoxService.addEvent(newEvent);
    return newEvent;
  }

  // Modify
  Future<EventModel> modifyEvent({
    required int id,
    required String eventName,
    required DateTime from,
    required DateTime to,
    required bool isAllDay,
    required bool isCompleted,
  }) async {
    final updatedEvent = EventModel(
      eventName: eventName.isNotEmpty ? eventName : '수정된 일정',
      from: from,
      to: to,
      isAllDay: isAllDay,
      isCompleted : isCompleted,
    );
    ObjectBoxService.updateEvent(updatedEvent);
    return updatedEvent;
  }

  // Delete
  Future<void> deleteEvent(int id) async {
    ObjectBoxService.deleteEvent(id);
  }

// 기타 필요한 메서드들...
}