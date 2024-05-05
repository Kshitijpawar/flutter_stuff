import 'dart:convert';

import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/models/grocery_item.dart';
import 'package:expense_tracker/widgets/new_item.dart';
import 'package:flutter/material.dart';
// import 'package:expense_tracker/data/dummy_items.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  var _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-bda5b-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value["category"])
          .value;

      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category));
    }

    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    // _loadItems();

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _groceryItems.isEmpty
              ? const Center(
                  child: Text("Bruh no items added yet"),
                )
              : ListView.builder(
                  itemCount: _groceryItems.length,
                  itemBuilder: (ctx, index) => Dismissible(
                    key: ValueKey(_groceryItems[index]),
                    onDismissed: (direction) {
                      _removeItem(_groceryItems[index]);
                    },
                    child: ListTile(
                      title: Text(
                        _groceryItems[index].name,
                      ),
                      leading: Container(
                        width: 24,
                        height: 24,
                        color: _groceryItems[index].category.color,
                      ),
                      trailing: Text(
                        _groceryItems[index].quantity.toString(),
                      ),
                    ),
                  ),
                ),
    );
  }
}
