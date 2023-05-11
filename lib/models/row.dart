import 'seat.dart';

class Row{
  int id;
  int index;
  List<Seat> seats;

  Row({required this.id, required this.index, required this.seats});

  @override
  String toString() {
    return 'Row{id: $id, index: $index, seats: $seats}';
  }
}