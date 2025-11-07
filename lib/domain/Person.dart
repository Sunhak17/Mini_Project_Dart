class Person {
  String name;
  String id;
  int age;
  String gender;

  Person({required this.name, required this.id, required this.age, required this.gender});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'age': age,
      'gender': gender,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      id: json['id'],
      age: json['age'],
      gender: json['gender'],
    );
  }
}