import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../data/sample_guests.dart';
import '../../database_helper.dart';
import '../../models/guest.dart';
import '../../models/statistic.dart';
import 'add_edit_guest_screen.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  List<Guest> _guests = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _selectedPlace = 'All';
  final String _selectedRelation = 'All';
  List<String> relations = [];
  List<Statistic> totalNumbersByCategory = [];
  List<Statistic> completedNumbersByCategory = [];

  @override
  void initState() {
    super.initState();
    _loadGuests(initDBGuest: true);
    _loadRelations();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    totalNumbersByCategory =
        await DatabaseHelper.instance.getTotalNumbersByCategory();
    completedNumbersByCategory =
        await DatabaseHelper.instance.getCompletedNumbersByCategory();
    setState(() {});
  }

  Statistic getCompletedNumberByCategory(String category) {
    return completedNumbersByCategory.firstWhere(
      (stat) => stat.category.contains(category),
      orElse: () => Statistic(
        category: category,
        total: 0,
        count: 0,
      ),
    );
  }

  Future<void> _loadRelations() async {
    var allRelations = (await DatabaseHelper.instance
            .getFilteredGuests('', 'All', 'All', 'All', 'All'))
        .map((guest) => guest.relation)
        .toSet();
    setState(() {
      relations = allRelations.toList();
    });
  }

  Future<void> _loadGuests({bool initDBGuest = false}) async {
    if (initDBGuest) {
      var allGuests = await DatabaseHelper.instance
          .getFilteredGuests('', 'All', 'All', 'All', 'All');
      if (allGuests.isEmpty) {
        await DatabaseHelper.instance.initGuests(sampleGuests);
      }
    }

    final guests = await DatabaseHelper.instance.getFilteredGuests(_searchQuery,
        _selectedCategory, _selectedStatus, _selectedPlace, _selectedRelation);
    setState(() {
      _guests = guests;
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
      await DatabaseHelper.instance.importGuestsFromCSV(utf8.decode(bytes));
      _loadGuests();
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
        title: Text('Guest List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Guest',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditGuestScreen()),
              ).then((value) {
                if (value != null && value) {
                  _loadGuests();
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
                _loadGuests();
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
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadGuests();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: _selectedCategory,
                items: [
                  'All',
                  ...categories,
                ]
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                  _loadGuests();
                },
              ),
              DropdownButton<String>(
                value: _selectedPlace,
                items: [
                  'All',
                  ...places,
                ]
                    .map((place) =>
                        DropdownMenuItem(value: place, child: Text(place)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlace = value!;
                  });
                  _loadGuests();
                },
              ),
              // DropdownButton<String>(
              //   value: _selectedRelation,
              //   items: [
              //     'All',
              //     ..._relations,
              //   ]
              //       .map((relation) => DropdownMenuItem(
              //           value: relation, child: Text(relation)))
              //       .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedRelation = value!;
              //     });
              //     _loadGuests();
              //   },
              // ),
              DropdownButton<String>(
                value: _selectedStatus,
                items: ['All', ...statuses]
                    .map((status) =>
                        DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                  _loadGuests();
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _guests.length,
              itemBuilder: (context, index) {
                final guest = _guests[index];
                return ListTile(
                  title: Text(guest.name),
                  subtitle: Text(
                      'Category: ${guest.category}; Relation: ${guest.relation}; Place: ${guest.place}; Status: ${guest.status ? 'Done' : 'Not Done'}'),
                  leading: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(guest.number.toString(),
                        style: TextStyle(fontSize: 20)),
                  ),
                  onTap: () {
                    DatabaseHelper.instance.updateGuest(guest.copyWith(
                      status: !guest.status,
                    ));
                    _loadGuests();
                    _loadStatistics();
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                          value: guest.status,
                          onChanged: (status) {
                            DatabaseHelper.instance.updateGuest(guest.copyWith(
                              status: status!,
                            ));
                            _loadGuests();
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
                                      AddEditGuestScreen(guest: guest)),
                            ).then((value) {
                              if (value != null && value) {
                                _loadGuests();
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
                children: totalNumbersByCategory.map((totalNumberByCategory) {
                  final completedNumber = getCompletedNumberByCategory(
                      totalNumberByCategory.category);

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
                        Text(
                            'Total Count & Number: ${totalNumberByCategory.count} & ${totalNumberByCategory.total}',
                            style: TextStyle(fontSize: 12)),
                        Text(
                            'Completed Count & Numbers: ${completedNumber.count} & ${completedNumber.total}',
                            style: TextStyle(fontSize: 12)),
                        Text(
                            'Pending Count & Numbers: ${totalNumberByCategory.count - completedNumber.count} & ${totalNumberByCategory.total - completedNumber.total}',
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
