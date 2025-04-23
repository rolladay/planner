import '../../models/event_model.dart';
import '../objectbox/objectbox_service.dart';

class EventService {
  static final EventService _instance = EventService._internal();

  factory EventService() {
    return _instance;
  }
  EventService._internal();

  // Create
  Future<EventModel> createEvent({
    required String eventName,
    required DateTime from,
    required DateTime to,
    required bool isAllDay,
  }) async {
    final newEvent = EventModel(
      eventName: eventName.isNotEmpty ? eventName : '새 일정',
      from: from,
      to: to,
      isAllDay: isAllDay,
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
  }) async {
    final updatedEvent = EventModel(
      eventName: eventName.isNotEmpty ? eventName : '수정된 일정',
      from: from,
      to: to,
      isAllDay: isAllDay,
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