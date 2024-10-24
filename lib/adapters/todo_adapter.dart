import 'package:hive/hive.dart';
import 'package:namer_app/main.dart';

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final typeId = 1;

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      title: reader.readString(),
      dueDate: DateTime.parse(reader.readString()),
      isCompleted: reader.readBool(),
      category: reader.read() as Category, // Read Category using its adapter
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.dueDate.toIso8601String());
    writer.writeBool(obj.isCompleted);
    writer.write(obj.category); // Write Category using its adapter
  }
}
