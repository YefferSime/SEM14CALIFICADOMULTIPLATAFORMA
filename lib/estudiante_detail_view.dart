import 'package:flutter/material.dart';
import 'package:sem14/estudiante.dart';
import 'package:sem14/estudiante_database.dart';

class StudentDetailView extends StatefulWidget {
  final Estudiante? student;

  const StudentDetailView({Key? key, this.student}) : super(key: key);

  @override
  _StudentDetailViewState createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _carreraController = TextEditingController();
  TextEditingController _fechaIngresoController = TextEditingController();
  TextEditingController _edadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _nombreController.text = widget.student!.nombre;
      _carreraController.text = widget.student!.carrera;
      _fechaIngresoController.text = _formatDate(widget.student!.fechaIngreso);
      _edadController.text = widget.student!.edad.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900], // Fondo gris oscuro
        appBarTheme: AppBarTheme(
          color: Colors.grey[900], // Barra de aplicación gris oscuro
          elevation: 0, toolbarTextStyle: TextTheme(
            headline6: TextStyle(
              color: Colors.white, // Texto del título en blanco
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ).bodyText2, titleTextStyle: TextTheme(
            headline6: TextStyle(
              color: Colors.white, // Texto del título en blanco
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ).headline6,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.student == null ? 'Agregar Estudiante' : 'Editar Estudiante'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nombreController,
                  style: TextStyle(color: Colors.white), // Color del texto blanco
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Colors.white), // Color del label blanco
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Borde blanco cuando no está enfocado
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue), // Borde azul cuando está enfocado
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _carreraController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Carrera',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _fechaIngresoController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Fecha de Ingreso (dd/mm/yyyy)',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _fechaIngresoController.text = _formatDate(pickedDate);
                    }
                  },
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _edadController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Edad',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    _saveStudent();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Color de fondo azul del botón
                  ),
                  child: Text(widget.student == null ? 'Agregar' : 'Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveStudent() {
    String nombre = _nombreController.text.trim();
    String carrera = _carreraController.text.trim();
    String fechaIngresoStr = _fechaIngresoController.text.trim();
    int edad = int.tryParse(_edadController.text.trim()) ?? 0;

    // Parsear fecha según el formato "dd/mm/yyyy"
    DateTime fechaIngreso;
    try {
      List<String> parts = fechaIngresoStr.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        fechaIngreso = DateTime(year, month, day);
      } else {
        throw FormatException('Formato de fecha incorrecto');
      }
    } catch (e) {
      print('Error al parsear fecha: $e');
      // Manejar el error de formato de fecha aquí
      return;
    }

    if (widget.student == null) {
      // Crear un nuevo estudiante
      Estudiante newStudent = Estudiante(
        nombre: nombre,
        carrera: carrera,
        fechaIngreso: fechaIngreso,
        edad: edad,
      );

      // Guardar en la base de datos
      EstudianteDatabase.instance.create(newStudent.toMap()).then((id) {
        Navigator.pop(context, true); // Regresar a la pantalla anterior
      });
    } else {
      // Actualizar estudiante existente
      Estudiante updatedStudent = Estudiante(
        id: widget.student!.id,
        nombre: nombre,
        carrera: carrera,
        fechaIngreso: fechaIngreso,
        edad: edad,
      );

      // Actualizar en la base de datos
      EstudianteDatabase.instance.update(widget.student!.id!, updatedStudent.toMap()).then((rowsAffected) {
        Navigator.pop(context, true); // Regresar a la pantalla anterior
      });
    }
  }
}
