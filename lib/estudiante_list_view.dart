import 'package:flutter/material.dart';
import 'estudiante.dart';
import 'estudiante_database.dart';
import 'estudiante_detail_view.dart';

class StudentListView extends StatefulWidget {
  @override
  _StudentListViewState createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  List<Estudiante> students = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final db = EstudianteDatabase.instance;
    final studentMaps = await db.readAll();
    setState(() {
      students = studentMaps.map((map) => Estudiante.fromMap(map)).toList();
    });
  }

  Future<void> deleteStudent(int id) async {
    final db = EstudianteDatabase.instance;
    await db.delete(id);
    fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estudiantes')),
      body: students.isEmpty
          ? Center(child: Text('Estudiantes no encontrados'))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.nombre,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text('Carrera: ${student.carrera}'),
                        SizedBox(height: 4.0),
                        Text('Fecha de Ingreso: ${_formatDate(student.fechaIngreso)}'),
                        SizedBox(height: 4.0),
                        Text('Edad: ${student.edad}'),
                        SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetailView(student: student),
                                  ),
                                ).then((value) => fetchStudents());
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmar eliminación'),
                                      content: Text('¿Estás seguro que quieres eliminar al estudiante ${student.nombre}?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancelar'),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Eliminar'),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmDelete == true) {
                                  await deleteStudent(student.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentDetailView()),
          ).then((value) => fetchStudents());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}