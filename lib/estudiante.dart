class Estudiante {
  final int? id;
  final String nombre;
  final String carrera;
  final DateTime fechaIngreso;
  final int edad;

  Estudiante({
    this.id,
    required this.nombre,
    required this.carrera,
    required this.fechaIngreso,
    required this.edad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'carrera': carrera,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'edad': edad,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'],
      nombre: map['nombre'],
      carrera: map['carrera'],
      fechaIngreso: DateTime.parse(map['fechaIngreso']),
      edad: map['edad'],
    );
  }
}