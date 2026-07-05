class Machines {
  final String id;
  final String name;
  final String specifications;
  final String department;

  const Machines({
    required this.id,
    required this.name,
    this.specifications = '',
    this.department = '',
  });

  factory Machines.fromJson(Map<String, dynamic> json) {
    return Machines(
      id: json['_id'] ?? '',
      name: json['machineName'] ?? '',
      specifications: json['specifications'] ?? '',
      department: json['department'] ?? '',
    );
  }
}