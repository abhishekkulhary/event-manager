import 'dart:convert';

import 'package:event_manager/extensions/string_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../database_helper.dart';
import '../../models/item.dart';
import '../../models/statistic.dart';
import 'add_edit_item_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<Item> _items = [];
  String _searchQuery = '';
  ItemType? _selectedType;
  PaymentStatus? _selectedStatus;

  List<Statistic> totalsByCategory = [];

  @override
  void initState() {
    super.initState();
    _loadMoneyItems(initDB: true);
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    totalsByCategory = await DatabaseHelper.instance.getMoneyItemStatistics();
    setState(() {});
  }

  Future<void> _loadMoneyItems({bool initDB = false}) async {
    var allItems = await DatabaseHelper.instance.getFilteredMoneyItems(
        query: _searchQuery, type: _selectedType, status: _selectedStatus);
    if (initDB && allItems.isEmpty) {
      allItems = await DatabaseHelper.instance.getFilteredMoneyItems(
          query: _searchQuery, type: _selectedType, status: _selectedStatus);
    }

    setState(() {
      _items = allItems;
    });
  }

  void _importCSV(void Function() showSnackbar) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes != null) {
      await DatabaseHelper.instance.importMoneyItemsFromCSV(utf8.decode(bytes));
      _loadMoneyItems();
      _loadStatistics();
      showSnackbar();
    }
  }

  void _exportCSV(void Function() showSnackbar) async {
    await DatabaseHelper.instance.exportGuestsToCSV();
    showSnackbar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Item',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditItemScreen()),
              ).then((value) {
                if (value != null && value) {
                  _loadMoneyItems();
                  _loadStatistics();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: 'Export CSV',
            onPressed: () => _exportCSV(
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export completed')),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            tooltip: 'Import CSV',
            onPressed: () => _importCSV(
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV Imported Successfully')),
                );
                _loadMoneyItems();
                _loadStatistics();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by description',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadMoneyItems();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<ItemType>(
                value: _selectedType,
                items: [
                  null,
                  ...ItemType.values,
                ]
                    .map((typ) => DropdownMenuItem(
                        value: typ,
                        child: Text(typ?.name.capitalize() ?? 'All')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                  _loadMoneyItems();
                },
              ),
              DropdownButton<PaymentStatus>(
                value: _selectedStatus,
                items: [
                  null,
                  ...PaymentStatus.values,
                ]
                    .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status?.name.capitalize() ?? 'All')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  _loadMoneyItems();
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item.description),
                  subtitle: Text(
                      '${item.type.name.capitalize()}: ${item.status.name.capitalize()}'),
                  leading: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(item.date.toLocal().toIso8601String(),
                        style: TextStyle(fontSize: 20)),
                  ),
                  onTap: () {
                    DatabaseHelper.instance.updateMoneyItem(item.copyWith(
                      status: item.status == PaymentStatus.paid
                          ? PaymentStatus.notPaid
                          : PaymentStatus.paid,
                    ));
                    _loadMoneyItems();
                    _loadStatistics();
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                          value: item.status == PaymentStatus.paid,
                          onChanged: (value) {
                            DatabaseHelper.instance
                                .updateMoneyItem(item.copyWith(
                              status: value!
                                  ? PaymentStatus.paid
                                  : PaymentStatus.notPaid,
                            ));
                            _loadMoneyItems();
                            _loadStatistics();
                          }),
                      SizedBox(
                        width: 5,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditItemScreen(item: item)),
                            ).then((value) {
                              if (value != null && value) {
                                _loadMoneyItems();
                                _loadStatistics();
                              }
                            });
                          },
                          icon: Icon(Icons.edit))
                    ],
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                spacing: 5,
                children: totalsByCategory.map((totalNumberByCategory) {
                  return Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text('${totalNumberByCategory.category}: ',
                            style: TextStyle(fontSize: 16)),
                        Text('Total: ${totalNumberByCategory.total}',
                            style: TextStyle(fontSize: 12)),
                        Text('Total Count: ${totalNumberByCategory.count}',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
