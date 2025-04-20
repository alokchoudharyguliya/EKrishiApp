import 'package:hive/hive.dart';
import 'package:newscalendar/models/events.dart';

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    return Event.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.write(obj.toJson());
  }
}
