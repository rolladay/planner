

import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../calendar_features/event_service.dart';


final EventService eventService = EventService();

void showDeleteConfirmationDialog(dynamic appointment, BuildContext context) {
  // appointment를 EventModel로 캐스팅
  final event = appointment as EventModel;

  EventService eventService = EventService();

  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Text(
            '일정 삭제',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('\'${event.eventName}\' 일정을 삭제하시겠습니까?'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () {
                  eventService.deleteEvent(event.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  '삭제',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  );
}
