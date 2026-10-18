import 'package:event_manager/extensions/string_extension.dart';
import 'package:event_manager/models/item.dart';
import 'package:flutter/material.dart';

import '../../database_helper.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  ItemType _selectedType = ItemType.expense;
  PaymentStatus _selectedStatus = PaymentStatus.notPaid;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _descriptionController.text = widget.item!.description;
      _amountController.text = widget.item!.amount.toString();
      _selectedType = widget.item!.type;
      _selectedStatus = widget.item!.status;
    }
  }

  void _saveGuest(void Function() navigateBack) async {
    if (_formKey.currentState!.validate()) {
      final item = Item(
        id: widget.item?.id,
        description: _descriptionController.text,
        type: _selectedType,
        amount: num.parse(_amountController.text),
        status: _selectedStatus,
        date: DateTime.now(),
      );

      if (widget.item == null) {
        await DatabaseHelper.instance.insertMoneyItem(item);
      } else {
        await DatabaseHelper.instance.updateMoneyItem(item);
      }

      navigateBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.item == null ? 'Add Item' : 'Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a description' : null,
              ),
              DropdownButtonFormField<ItemType>(
                initialValue: _selectedType,
                decoration: InputDecoration(labelText: 'Type'),
                items: ItemType.values
                    .map((type) => DropdownMenuItem(
                        value: type, child: Text(type.name.capitalize())))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _selectedStatus == PaymentStatus.paid,
                    onChanged: (value) => setState(() => _selectedStatus =
                        value! ? PaymentStatus.paid : PaymentStatus.notPaid),
                  ),
                  Text('Paid'),
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
