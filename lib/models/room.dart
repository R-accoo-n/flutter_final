import 'package:flutter_final/models/row.dart';

class Room{
  int id;
  String name;
  List<Row> rows;

  Room({required this.id, required this.name, required this.rows});

  @override
  String toString() {
    return 'Room{id: $id, name: $name, rows: $rows}';
  }
}