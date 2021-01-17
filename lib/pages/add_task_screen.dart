import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_todo_app/helpers/database_helpers.dart';
import 'package:my_todo_app/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  var type;
  final Function updateTaskList;
  AddTaskScreen({this.updateTaskList,this.task,this.type});
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formkey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _dateTime = DateTime.now();
  TextEditingController _dateController = new TextEditingController();
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date != null && date != _dateTime) {
      setState(() {
        _dateTime = date;
      });
      _dateController.text = _dateFormat.format(date);
    }
  }

  void _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);

  }


  void _submit() {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      print('$_title,$_dateTime,$_priority');

      var formatter = new DateFormat('dd-MM-yyyy');
      //String formattedTime = DateFormat('kk:mm:a').format(_dateTime);
      String formattedDate = formatter.format(_dateTime);

      //_dateTime = formattedDate;

      Task task = Task(title: _title,date : formattedDate,priority:_priority);
      if(widget.task == null){
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
        Fluttertoast.showToast(msg: "Inserted");

      }else{
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
        Fluttertoast.showToast(msg: "Updated");
      }

      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();


    if(widget.task!=null){
      _title = widget.task.title;
      //_dateTime = widget.task.date;
      _dateController.text = widget.task.date;
      _priority = widget.task.priority;
    }else{
      _dateController.text = _dateFormat.format(_dateTime);
    }


    /*if(widget.task.date.isEmpty){
      Fluttertoast.showToast(msg: "emty");
     // _dateController.text=_dateFormat.format(_dateTime);
    }else{
      Fluttertoast.showToast(msg: "no");
     // _dateController.text = widget.task.date;
    }*/

  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 30.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
               widget.task == null? 'Add Task' : 'Update Task',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formkey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                            labelText: "Title",
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        validator: (input) => input.trim().isEmpty
                            ? 'Please enter a title'
                            : null,
                        onSaved: (input) => _title = input,
                        initialValue: _title,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: _dateController,
                        onTap: _handleDatePicker,
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: DropdownButtonFormField(
                        isDense: true,
                        icon: Icon(Icons.arrow_drop_down_circle),
                        iconSize: 22.0,
                        iconEnabledColor: Theme.of(context).primaryColor,
                        items: _priorities.map((String priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(
                              priority,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                            labelText: "Priority",
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        validator: (input) => _priority == null
                            ? 'Please select a priority level'
                            : null,
                        onChanged: (value) {
                          setState(() {
                            _priority = value;
                          });
                        },
                        value: _priority,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: FlatButton(
                        onPressed: _submit,
                        child: Text(
                          widget.task == null ? 'Add' : 'Update',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
                    widget.task!= null ? Container(  margin: EdgeInsets.symmetric(vertical: 20.0),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: FlatButton(
                        onPressed: _delete,
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),) : SizedBox.shrink()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
