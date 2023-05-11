import 'package:flutter_final/models/room.dart';
import 'package:time_span/time_span.dart';

class Session{
  int id;
  int date;
  String type;
  int minPrice;
  Room room;


  Session({required this.id, required this.date, required this.type, required this.minPrice, required this.room});

  @override
  String toString() {
    return 'Session{id: $id, date: $date, type: $type, minPrice: $minPrice, room: $room}';
  }
}