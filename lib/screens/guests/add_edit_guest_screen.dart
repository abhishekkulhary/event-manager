import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../database_helper.dart';
import '../../models/guest.dart';

class AddEditGuestScreen extends StatefulWidget {
  final Guest? guest;

  const AddEditGuestScreen({super.key, this.guest});

  @override
  State<AddEditGuestScreen> createState() => _AddEditGuestScreenState();
}

class _AddEditGuestScreenState extends State<AddEditGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  String _selectedCategory = 'Cards Distribution';
  String _selectedPlace = 'Colony';
  bool _status = false;

  @override
  void initState() {
    super.initState();
    if (widget.guest != null) {
      _nameController.text = widget.guest!.name;
      _numberController.text = widget.guest!.number.toString();
      _relationController.text = widget.guest!.relation;
      _selectedCategory = widget.guest!.category;
      _selectedPlace = widget.guest!.place;
      _status = widget.guest!.status;
    }
  }

  void _saveGuest(void Function() navigateBack) async {
    if (_formKey.currentState!.validate()) {
      final guest = Guest(
        id: widget.guest?.id,
        name: _nameController.text,
        place: _selectedPlace,
        relation: _relationController.text,
        number: _numberController.text == ''
            ? 0
            : int.parse(_numberController.text),
        category: _selectedCategory,
        status: _status,
      );

      if (widget.guest == null) {
        await DatabaseHelper.instance.insertGuest(guest);
      } else {
        await DatabaseHelper.instance.updateGuest(guest);
      }

      navigateBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.guest == null ? 'Add Guest' : 'Edit Guest')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedPlace,
                decoration: InputDecoration(labelText: 'Place'),
                items: places
                    .map((place) =>
                        DropdownMenuItem(value: place, child: Text(place)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPlace = value!),
              ),
              TextFormField(
                controller: _relationController,
                decoration: InputDecoration(labelText: 'Relation'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a relation' : null,
              ),
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(labelText: 'Number'),
                validator: (value) => value!.isEmpty ? 'Enter a number' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: categories
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _status,
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  Text('Done')
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveGuest(
                  () => Navigator.pop(context, true),
                ),
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
