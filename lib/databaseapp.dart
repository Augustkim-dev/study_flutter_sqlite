import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_sample/todo.dart';

class DatabaseApp extends StatefulWidget {
  final Future<Database> db;
  const DatabaseApp({Key? key, required this.db}) : super(key: key);

  @override
  State<DatabaseApp> createState() => _DatabaseAppState();
}

class _DatabaseAppState extends State<DatabaseApp> {
  Future<List<Todo>>? todoList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoList = getTodos();
  }

  // 디비에 todo 저장
  void _insertTodo(Todo todo) async {
    final Database database = await widget.db;
    await database.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    setState(() {
      todoList = getTodos();
    });
  }

  // 디비에 있는 todo 가져오기
  Future<List<Todo>> getTodos() async {
    final Database database = await widget.db;
    final List<Map<String, dynamic>> maps = await database.query('todos');

    return List.generate(maps.length, (index) {
      int active = maps[index]['active'] == 1 ? 1 : 0;
      return Todo(
        title: maps[index]['title'].toString(),
        content: maps[index]['content'].toString(),
        active: active,
        id: maps[index]['id'],
      );
    });
  }

  // todo 수정하기
  void _updateTodo(Todo todo) async {
    final Database database = await widget.db;

    await database.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
    setState(() {
      todoList = getTodos();
    });
  }

  // todo 삭제하기
  void _deleteTodo(Todo todo) async {
    final Database database = await widget.db;

    await database.delete('todos', where: 'id = ?', whereArgs: [todo.id]);

    setState(() {
      todoList = getTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Example')),
      body: Container(
        child: Center(
          child: FutureBuilder(
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const CircularProgressIndicator();
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                case ConnectionState.active:
                  return const CircularProgressIndicator();
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemBuilder: (context, index) {
                          Todo todo = (snapshot.data as List<Todo>)[index];
                          return ListTile(
                            title: Text(
                              todo.title!,
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: Container(
                              child: Column(children: [
                                Text(todo.content!),
                                Text(
                                    '체크 : ${todo.active == 1 ? 'true' : 'false'}'),
                                Container(
                                  height: 1,
                                  color: Colors.blue,
                                ),
                              ]),
                            ),
                            onTap: () async {
                              TextEditingController controller =
                                  TextEditingController(text: todo.content);

                              Todo result = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('${todo.id} : ${todo.title}'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.text,
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            todo.active == 1
                                                ? todo.active = 0
                                                : todo.active = 1;

                                            todo.content =
                                                controller.value.text;

                                            Navigator.of(context).pop(todo);
                                          },
                                          child: Text('예')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(todo);
                                          },
                                          child: Text('아니오')),
                                    ],
                                  );
                                },
                              );
                              _updateTodo(result);
                            },
                            onLongPress: () async {
                              Todo result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('${todo.id} : ${todo.title}'),
                                      content:
                                          Text('${todo.content}를 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(todo);
                                            },
                                            child: Text('예')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('아니오')),
                                      ],
                                    );
                                  });
                              _deleteTodo(result);
                            },
                          );
                        },
                        itemCount: (snapshot.data as List<Todo>).length);
                  } else {
                    return Text('No Data');
                  }
              }
              return CircularProgressIndicator();
            },
            future: todoList,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final todo = await Navigator.of(context).pushNamed('/add');
          if (todo != null) {
            // print('-=-=-=-=-=-=- insertTodo ');
            _insertTodo(todo as Todo);
          }
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
