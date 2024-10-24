import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:namer_app/main.dart';

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final typeId = 2;

  @override
  Category read(BinaryReader reader) {
    return Category(
      name: reader.readString(),
      color: Color(reader.readInt()), // Read color as int and convert to Color
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.color.value); // Write Color as int
  }
}
