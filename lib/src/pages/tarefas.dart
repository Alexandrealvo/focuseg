import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Tarefas extends StatefulWidget {
  @override
  _TarefasState createState() => _TarefasState();
}

class _TarefasState extends State<Tarefas> {
  final toDoController = TextEditingController();

  List toDoList = [];

  Map<String, dynamic> lastRemoved;

  int lastRemovedPos;

  @override
  void initState() {
    super.initState();
    readData().then((response) {
      setState(() {
        toDoList = json.decode(response);
      });
    });
  }

  void addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo['title'] = toDoController.text;
      toDoController.text = '';
      newToDo['ok'] = false;
      toDoList.add(newToDo);
      saveData();
    });
  }

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      toDoList.sort((a, b) {
        if (a['ok'] && !b['ok']) {
          return 1;
        } else if (!a['ok'] && b['ok']) {
          return -1;
        } else {
          return 0;
        }
      });

      saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff171f40),
          title:
              Text('Lista de tarefas', style: GoogleFonts.roboto(fontSize: 20)),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1, color: Color(0xff171f40)))),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 7, 5, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 55,
                        child: TextField(
                          controller: toDoController,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey)),
                              labelText: "Nova Tarefa",
                              labelStyle: GoogleFonts.roboto(
                                  fontSize: 20, color: Color(0xff171f40))),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 5),
                      child: RaisedButton(
                        color: Color(0xff171f40),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: addToDo,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: toDoList.length,
                  itemBuilder: buildItem),
            ))
          ],
        ));
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Color(0xff171f40),
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(Icons.delete_outline, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          lastRemoved = Map.from(toDoList[index]);
          lastRemovedPos = index;
          toDoList.removeAt(index);
          saveData();

          final snack = SnackBar(
            content: Text('Tarefa  \'${lastRemoved['title']}\' removida!',
                style: GoogleFonts.roboto(fontSize: 15)),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  toDoList.insert(lastRemovedPos, lastRemoved);
                  saveData();
                });
              },
            ),
            duration: Duration(seconds: 4),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
      child: CheckboxListTile(
        title: Text(
          toDoList[index]['title'],
          style: GoogleFonts.roboto(fontSize: 15),
        ),
        value: toDoList[index]['ok'],
        secondary: CircleAvatar(
          backgroundColor: Color(0xff171f40),
          radius: 15,
          child: Icon(
            toDoList[index]['ok'] ? Icons.check : Icons.error_outline,
            size: 25,
          ),
        ),
        onChanged: (c) {
          setState(() {
            toDoList[index]['ok'] = c;
            saveData();
          });
        },
      ),
    );
  }

  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File('${directory.path}/tasks.json');
  }

  Future<File> saveData() async {
    String data = json.encode(toDoList);

    final file = await getFile();
    return file.writeAsString(data);
  }

  Future<String> readData() async {
    try {
      final file = await getFile();

      return file.readAsString();
    } catch (e) {
      print(e);
    }
  }
}
