class Patient {
  const Patient({
    required this.patientId,
    required this.name,
    required this.age,
    required this.weight,
  });

  final String patientId;
  final String name;
  final int age;
  final double weight;

  bool get isComplete =>
      patientId.trim().isNotEmpty &&
      name.trim().isNotEmpty &&
      age > 0 &&
      weight > 0;
}
