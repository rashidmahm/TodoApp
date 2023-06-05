import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({
    super.key,
    this.todo
    });

  @override
 State<AddTodoPage>createState() => _AddTodoPage();
}

class _AddTodoPage extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController  = TextEditingController();
  bool isEdit=false;
  @override
  void initState(){
    super.initState();
    final todo = widget.todo;
    if(todo !=null){
      isEdit =  true;
      final title = todo['title'];
      final description =todo['description'];

      titleController.text = title;
      descriptionController.text = description;
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Todo' : "Add Page"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(

              hintText: 'Title'
            ),
          ),
          const SizedBox(
            height:20
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Description'
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height:20
          ),
          ElevatedButton(onPressed:isEdit ? UpdateData : submitData,
           
           child: Padding(
             padding: const EdgeInsets.all(15.0),
             child: Text(
              isEdit ? 'Update': 'Submit'),
           )),
        ],
      ),
    );
  }
   //success message in screen bottom
       void showSuccessMessage(String message){
        final snackBar =SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
   //error message in the screen bottom
    void errorSuccessMessage(String message){
      final snackBar =SnackBar(content: Text(message,
      style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  Future<void> UpdateData() async {
    
    final todo =widget.todo;
    if(todo == null){
      print('You can not call updated without todo data');
      return ;
    }
      final id            = todo['_id'];
      //final isCompleted   = todo['is_completed'];
      final title         = titleController.text;
      final description   = descriptionController.text;
      final body = {
            "title": title,
            "description": description,
            "is_completed": false
       };
            //Update data to the server
        final url = "http://api.nstack.in/v1/todos/$id";
        final uri = Uri.parse(url);
        final response= await http.put(
          uri, 
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json'},
      );
       
      if(response.statusCode == 200){
        titleController.text        = '';
        descriptionController.text  = '';
        print('Success');
        showSuccessMessage('Updation Success');
    }else{
      errorSuccessMessage('Updation Failed');

    }
  }

  Future<void> submitData() async {
    //Get data from form
      final title       = titleController.text;
      final description = descriptionController.text;
      final body = {
            "title": title,
            "description": description,
            "is_completed": false
      };
    //Submit data to the server
    final url = "http://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response= await http.post(
      uri, 
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'},
      );
     
    //Show success or fail message based on status
    if(response.statusCode == 201){
        titleController.text        = '';
        descriptionController.text  = '';
        print('Success');
        showSuccessMessage('Creation Success');
    }else{
      print('Creation Failed');
      errorSuccessMessage('Creation Failed');

    }
   
  }
}