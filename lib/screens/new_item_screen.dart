import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/category_data.dart';
import 'package:shopping_list_app/models/category_model.dart';

class NewItemScreen extends StatefulWidget{
  const NewItemScreen({super.key,required this.loadItem});

  final void Function() loadItem;

  @override
  State<NewItemScreen> createState(){
    return _NewItemScreenState();
  }
}

class _NewItemScreenState extends State<NewItemScreen>{

  final _formkey= GlobalKey<FormState>();
  String  _enteredName='';
  int _enteredQuantity=1;
  CategoriesType _enteredField=CategoriesType.vegetables;

  bool _isSending=false; //for sending http request

  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
      ),
      body: Form(
        key: _formkey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value){
                  if(value==null||value.trim().length<=1||value.trim().length>50){
                    return 'Name must contain 2 to 50 characters';
                  }
                  else{
                    return null;
                  }
                },
                onSaved: (value){
                  _enteredName=value!;
                },
                style: const TextStyle(
                  color: Colors.white
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value){
                        if(value==null||int.tryParse(value)!<1){
                          return 'Quantity should be positive ';
                        }
                        else{
                          return null;
                        }
                      },
                      onSaved: (value){
                        _enteredQuantity=int.parse(value!);
                      },
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownButtonFormField(
                      value: _enteredField,
                        items: CategoriesType.values.map((item){
                          return DropdownMenuItem(
                            value: item,
                            child: Row(
                              children: [
                                Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: categories[item]!.catColor,
                                    ),
                                  ),
                                const SizedBox(width: 10,),
                                Text(item.name,
                                  style: const TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value){
                        _enteredField=value!;
                        },
                      dropdownColor: const Color(0xFF1F2334),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton(
                      onPressed: _isSending ? null : (){
                        _formkey.currentState!.reset();
                      },
                      child: const Text('Reset'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                      onPressed: _isSending? null : () async {
                        if(_formkey.currentState!.validate()){
                          setState(() {
                            _isSending=true;
                          });
                          _formkey.currentState!.save();
                          final url = Uri.https('shopping-list-app-62861-default-rtdb.firebaseio.com','shopping-list.json');
                          final response = await http.post(url,  headers: {'Content-type':'application/json',},
                            body: json.encode({
                              'name':_enteredName,
                              'quantity':_enteredQuantity,
                              'category':categories[_enteredField]!.catName,
                            }),
                          );
                          if(!context.mounted){
                            return;
                          }
                          if(response.statusCode>=400){
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 2),
                                    content: Text('error adding to database')
                                )
                            );
                            return;
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 2),
                                    content: Text('Item added to database')
                                )
                            );
                          }
                          widget.loadItem();
                          Navigator.of(context).pop();
                        }
                      },
                      child: _isSending ? const Center(child: CircularProgressIndicator(),) : const Text('Add')
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}