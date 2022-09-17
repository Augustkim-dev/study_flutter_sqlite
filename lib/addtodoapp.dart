import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_sample/todo.dart';

class AddTodoApp extends StatefulWidget {
  final Future<Database> db;
  const AddTodoApp({Key? key, required this.db}) : super(key: key);

  @override
  State<AddTodoApp> createState() => _AddTodoAppState();
}

class _AddTodoAppState extends State<AddTodoApp> {
  TextEditingController? titleController;
  TextEditingController? contentController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController = new TextEditingController();
    contentController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Add'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: '내용'),
              ),
              ElevatedButton(
                onPressed: () {
                  Todo todo = Todo(
                    title: titleController!.value.text,
                    content: contentController!.value.text,
                    active: 0,
                  );
                  Navigator.of(context).pop(todo);
                },
                child: Text('저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
