import 'dart:convert';

import 'package:api_project/screen/add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading=true;
  List items = [];
  @override
  void initState(){
    super.initState();
    fetchTodo();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child:Center(child: CircularProgressIndicator(),),
        replacement:RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible:  items.isNotEmpty,
            replacement: Center(child: Text(
              "No ToDo Item",
              style: Theme.of(context).textTheme.headline3,
              ),),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id']as String;
              return Card(
                child: ListTile(
                     leading: CircleAvatar(child: Text('${index +1}'),),
                     title: Text(item['title']),
                     subtitle: Text(item['description']),
                     trailing: PopupMenuButton(
                      onSelected: (value) {
                        if(value=='edit'){
                          //open edit page
                          navigateToEditPage(item);
                        }else if(value=='delete'){
                          //delete page will open
                          deleteById(id);
                        }
                      },
                      itemBuilder:((context) {
                        return [
                           PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                            ),
                           PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                            ),
                        ];
                      }) 
                      ),
                ),
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage, label: Text("Add Todo")
        ),
    );
  }


  Future<void> navigateToEditPage(Map item)async{
   final route =MaterialPageRoute(
    builder: (context) => AddTodoPage(todo:item),
   );
   //await Navigator.push(context,route);
   await Navigator.push(context,route);
   setState(() {
     isLoading = true;
   });
   fetchTodo();
  }
  Future<void> navigateToAddPage()async{
   final route =MaterialPageRoute(builder: ((context) => AddTodoPage())
   );
   await Navigator.push(context,route);
   setState(() {
     isLoading = true;
   });
   fetchTodo();
  }
   //error message in the screen bottom
    void errorSuccessMessage(String message){
      final snackBar =SnackBar(content: Text(message,
      style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  
  Future<void> deleteById(String id)async{
    //Delete the item
    final url = "http://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final respone =await http.delete(uri);
    if(respone.statusCode == 200){
        final filtered = items.where((element) => element['_id'] !=id).toList();
        setState(() {
          items = filtered;
        });
    }else{
      errorSuccessMessage('Deletion Failed');
    }
    //remove the item
  }

  Future<void> fetchTodo()async{
    final url ='http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri =Uri.parse(url);
    final response =await http.get(uri);
      if(response.statusCode== 200){
        final json = jsonDecode(response.body)as Map;
        final result = json['items']as List;
        setState(() {
          items = result;
        });
      }

      setState(() {
        isLoading = false;
      });
  }

}