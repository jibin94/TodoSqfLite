import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_todo_app/helpers/database_helpers.dart';
import 'package:my_todo_app/models/task_model.dart';
import 'package:my_todo_app/pages/add_task_screen.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {

  Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  Widget _buildTask(Task task){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(task.title,style: TextStyle(
              fontSize: 18.0,
              decoration: task.status == 0? TextDecoration.none : TextDecoration.lineThrough,
            ),),
            subtitle:Text("${(task.date)} - ${task.priority}",style: TextStyle(
              fontSize: 15.0,
              decoration: task.status == 0? TextDecoration.none : TextDecoration.lineThrough,
            ),),
            trailing: Checkbox(
              onChanged: (value){
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              },
              activeColor: Theme.of(context).primaryColor,
              value: task.status == 1 ? true : false,
            ),
            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskScreen(updateTaskList: _updateTaskList,task: task,type: "update",))),
          ),
          Divider(),
        ],
      ),
    );
  }

  _updateTaskList(){
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen(updateTaskList: _updateTaskList,type: "add",)),
          );
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context,snapshot) {

          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final int completedTaskCount = snapshot.data.where((Task task) => task.status ==1).toList().length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'My Tasks',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '$completedTaskCount of ${snapshot.data.length}',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }
              return _buildTask(snapshot.data[index-1]);
            },
          );
        },
      ),
    );
  }
}
