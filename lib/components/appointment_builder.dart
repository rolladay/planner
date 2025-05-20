import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/event_model.dart';


//Day Planner에서 쓸 이벤트들 어떻게 보여지게 할지 정의하는 위젯
Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final dynamic appointment = calendarAppointmentDetails.appointments.first;

  // isAllDay가 true인 경우 null을 반환하여 기본 스타일 적용
  if (appointment is EventModel && appointment.isAllDay) {
    return Container(
        color: Colors.grey,
        child: Row(
          children: [
            const SizedBox(
              width: 8,
            ),
            Text(appointment.eventName),
          ],
        )); // null을 반환하면 기본 렌더링 사용
  }

  // isAllDay가 아닌 이벤트만 커스텀 스타일 적용
  if (appointment is EventModel) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 오버플로우 방지
      children: [
        Expanded(
          child: Container(
            width: calendarAppointmentDetails.bounds.width,
            height: calendarAppointmentDetails.bounds.height / 2,
            color: Colors.black54,
            child: const Center(
              child: Icon(
                Icons.group,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: calendarAppointmentDetails.bounds.width,
            height: calendarAppointmentDetails.bounds.height / 2,
            color: Colors.black54,
            child: Text(
              '${appointment.eventName}${DateFormat(' (hh:mm a').format(appointment.from)}-${DateFormat('hh:mm a)').format(appointment.to)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  // 기본 렌더링 사용
  return Container();
}
