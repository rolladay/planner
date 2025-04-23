import 'package:objectbox/objectbox.dart';

@Entity()
class EventModel {
  @Id()
  int id = 0;
  final String eventName;
  final DateTime from;
  final DateTime to;
  final bool isAllDay;
  final String notes; // 메모 속성 추가

  EventModel({
    // 오브젝트박스에서는 id가 0이면 새로운 객체로 인식, id를 부여. 그렇지않으면 기존 객체로 인식
    this.id = 0,
    required this.eventName,
    required this.from,
    required this.to,
    required this.isAllDay,
    this.notes = '', // 기본값 설정
  });
}

//이 이벤트 모델이 현재 내가 개발하는 초기단계의 이벤트(일정) 객체인데... 여기에 Tag(운동/공부/업무/오락 등) 같은 것도 구분지을 수 있게 지원하나?
// 그리고 반복 (매일/일주일/매달/매년)도 지원하나? 또 TodoList도 지원하나?  > 다 지원함 나중에 익숙해지고 적용하자.