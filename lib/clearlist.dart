import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_sample/todo.dart';

class ClearListApp extends StatefulWidget {
  const ClearListApp({Key? key, required this.database}) : super(key: key);
  final Future<Database> database;

  @override
  State<ClearListApp> createState() => _ClearListAppState();
}

class _ClearListAppState extends State<ClearListApp> {
  Future<List<Todo>>? clearList;

  Future<List<Todo>> getClearList() async {
    final Database database = await widget.database;
    List<Map<String, dynamic>> maps = await database
        .rawQuery('select title, content, id from todos where active = 1');

    return List.generate(maps.length, (index) {
      return Todo(
        title: maps[index]['title'].toString(),
        content: maps[index]['content'].toString(),
        id: maps[index]['id'],
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clearList = getClearList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('완료한 일들')),
      body: Container(
        child: Center(
          child: FutureBuilder(
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return CircularProgressIndicator();
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                case ConnectionState.active:
                  return CircularProgressIndicator();
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
                            child: Column(
                              children: [
                                Text(todo.content!),
                                Container(
                                  height: 1,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: (snapshot.data as List<Todo>).length,
                    );
                  } else {
                    return Text('No Data');
                  }
              }
            },
            future: clearList,
          ),
        ),
      ),
    );
  }
}
