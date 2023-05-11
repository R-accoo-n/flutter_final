class Seat{
  int id;
  int index;
  int type;
  int price;
  bool isAvailable;

  Seat({required this.id, required this.index, required this.type, required this.price, required this.isAvailable});

  @override
  String toString() {
    return 'Seat{id: $id, index: $index, type: $type, price: $price, isAvailable: $isAvailable}';
  }
}