import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../models/event_model.dart';
import '../../objectbox.g.dart';


/// ObjectBox 데이터베이스 서비스를 관리하는 싱글톤 클래스
class ObjectBoxService {
  // 싱글톤 인스턴스, static 선언된 얘들은 인스턴스 생성없이 다른 파일에서 바로 불러다 쓸 수 있음
  static final ObjectBoxService _instance = ObjectBoxService._internal();
  // 데이터베이스 스토어
  static late final Store _store;
  // 초기화 상태 플래그
  static bool _initialized = false;
  // 내부 생성자
  ObjectBoxService._internal();
  // 팩토리 생성자
  factory ObjectBoxService() => _instance;


  /// ObjectBox 데이터베이스 초기화 - init
  static Future<void> init() async {
    if (_initialized) return;

    //이게 documentDirectory 경로임 path의 join 메소드는 저장할 패스 밑에 하위디렉토리로 objectBox라는걸 만들어라 그의미
    //iOS: /var/mobile/Containers/Data/Application/<UUID>/Documents
    // Android: /data/user/0/<package_name>/app_flutter
    final docsDir = await getApplicationDocumentsDirectory();
    final storePath = p.join(docsDir.path, "objectbox");

    // 이 objectbox라는 폴더에 있는 데이터로의 진입점인가?
    _store = await openStore(directory: storePath);
    _initialized = true;
  }

  /// Store 객체 가져오기 - getter
  static Store get store {
    if (!_initialized) {
      throw StateError('ObjectBoxService가 초기화되지 않았습니다. 먼저 init()을 호출하세요.');
    }
    return _store;
  }

  /// 데이터베이스 연결 종료
  static void close() {
    if (_initialized) {
      _store.close();
      _initialized = false;
    }
  }

  /// 이벤트 추가
  static int addEvent(EventModel event) {
    final box = _store.box<EventModel>();
    return box.put(event);
  }

  /// 모든 이벤트 가져오기
  static List<EventModel> getAllEvents() {
    final box = _store.box<EventModel>();
    return box.getAll();
  }

  /// 특정 ID의 이벤트 가져오기
  static EventModel? getEvent(int id) {
    final box = _store.box<EventModel>();
    return box.get(id);
  }

  /// 이벤트 업데이트
  static int updateEvent(EventModel event) {
    final box = _store.box<EventModel>();
    return box.put(event);
  }

  /// 이벤트 삭제
  static bool deleteEvent(int id) {
    final box = _store.box<EventModel>();
    return box.remove(id);
  }

  /// 날짜 범위로 이벤트 검색
  static List<EventModel> getEventsByDateRange(DateTime start, DateTime end) {
    final box = _store.box<EventModel>();
    final query = box.query(
        EventModel_.from.greaterOrEqual(start.millisecondsSinceEpoch) &
        EventModel_.to.lessOrEqual(end.millisecondsSinceEpoch)
    ).build();

    final events = query.find();
    query.close();
    return events;
  }

  /// 모든 이벤트 삭제
  static void deleteAllEvents() {
    final box = _store.box<EventModel>();
    box.removeAll();
  }
}