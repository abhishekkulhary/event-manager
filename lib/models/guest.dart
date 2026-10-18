class Guest {
  final int? id;
  final String name;
  final String place;
  final String relation;
  final int number;
  final String category;
  final bool status;

  Guest({
    this.id,
    required this.name,
    required this.place,
    required this.relation,
    required this.number,
    required this.category,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'place': place,
      'relation': relation,
      'number': number,
      'category': category,
      'status': status ? 1 : 0,
    };
  }

  Guest copyWith({
    int? id,
    String? name,
    String? place,
    String? relation,
    int? number,
    String? category,
    bool? status,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      place: place ?? this.place,
      relation: relation ?? this.relation,
      number: number ?? this.number,
      category: category ?? this.category,
      status: status ?? this.status,
    );
  }
}
