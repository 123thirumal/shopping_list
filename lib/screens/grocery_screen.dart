import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/category_data.dart';
import 'package:shopping_list_app/models/category_model.dart';
import 'package:shopping_list_app/screens/new_item_screen.dart';
import 'package:http/http.dart' as http;
import '../models/grocery_item_model.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() {
    return _GroceryScreenState();
  }
}

class _GroceryScreenState extends State<GroceryScreen> {
  List<GroceryItemModel> groceryItems = [];

  bool _iserror = false;

  bool _isEmpty = false;

  bool _loading=true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final url = Uri.https('shopping-list-app-62861-default-rtdb.firebaseio.com',
        'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _iserror = true;
      });
    }
    else {
      if(response.body=='null'){
        setState(() {
          _isEmpty=true;
          _loading=false;
        });
        return;
      }

      final Map<String, dynamic> listdata = json.decode(response.body);

      List<GroceryItemModel> tempItems = [];
      for (var item in listdata.entries) {
        final CategoryModel tempcategory =
            categories.entries.firstWhere((element) {
          return element.value.catName == item.value['category'];
        }).value;
        tempItems.add(GroceryItemModel(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: tempcategory));
      }
      setState(() {
        groceryItems = tempItems;
        _loading=false;
        if(response.body!='null'){
          setState(() {
            _loading=false;
            _isEmpty=false;
          });
        }
      });
    }
  }

  void showSnackBar(int remindex, GroceryItemModel remitem) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Grocery removed'),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          final url = Uri.https(
              'shopping-list-app-62861-default-rtdb.firebaseio.com',
              'shopping-list.json');
          final response = await http.post(
            url,
            headers: {
              'Content-type': 'application/json',
            },
            body: json.encode({
              'name': remitem.name,
              'quantity': remitem.quantity,
              'category': remitem.category.catName,
            }),
          );

          if (!context.mounted) {
            return;
          }
          if (response.statusCode >= 400) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('error adding back to database')));
            _loadItem();
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item added back to database')));
            _loadItem();
          }
        },
      ),
    ));
  }

  @override
  Widget build(context) {
    Widget content = const Center(
      child: CircularProgressIndicator(),
    );

    if (_iserror) {
      content = const Center(
        child: Text(
          'Failed to load...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      );
    }
    else if (_isEmpty) {
      content = const Center(
            child: Text(
              'List is empty. Press + to add items.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
      );
    }
    else if(!_loading){
      content = ListView.builder(
          itemCount: groceryItems.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(groceryItems[index].id),
              onDismissed: (direction) async {
                int remindex = index;
                GroceryItemModel remitem = groceryItems[index];
                final urlForDelete = Uri.https(
                    'shopping-list-app-62861-default-rtdb.firebaseio.com',
                    'shopping-list/${groceryItems[index].id}.json');
                setState(() {
                  groceryItems.removeAt(index);
                });
                final responseForDelete = await http.delete(urlForDelete);
                if (!context.mounted) {
                  return;
                }
                if (responseForDelete.statusCode >= 400) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to Delete...')));
                  _loadItem();
                } else {
                  showSnackBar(remindex, remitem);
                _loadItem();
                }
              },
              direction: DismissDirection.startToEnd,
              background: Card(
                color: Colors.red,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
              child: Card(
                color: const Color(0xFF072736),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: groceryItems[index].category.catColor),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          groceryItems[index].name,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          groceryItems[index].quantity.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NewItemScreen(
                    loadItem: _loadItem,
                  );
                }));
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: RefreshIndicator(onRefresh:() async {
          await _loadItem();
        },
            child: content
        )
    );
  }
}
