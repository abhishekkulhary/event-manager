import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import '../../database_helper.dart';
import '../../models/guest.dart';
import '../../ui/theme.dart';
import '../../ui/widgets.dart';

class AddEditGuestScreen extends StatefulWidget {
  final Guest? guest;

  const AddEditGuestScreen({super.key, this.guest});

  @override
  State<AddEditGuestScreen> createState() => _AddEditGuestScreenState();
}

class _AddEditGuestScreenState extends State<AddEditGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController(text: '1');
  final TextEditingController _relationController = TextEditingController(text: 'N/A');
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

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final guest = Guest(
      id: widget.guest?.id,
      name: _nameController.text.trim(),
      place: _selectedPlace,
      relation: _relationController.text.trim().isEmpty ? 'N/A' : _relationController.text.trim(),
      number: int.parse(_numberController.text),
      category: _selectedCategory,
      status: _status,
    );
    if (widget.guest == null) {
      await DatabaseHelper.instance.insertGuest(guest);
    } else {
      await DatabaseHelper.instance.updateGuest(guest);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EmColors.surfaceHigh,
        title: const Text('Delete guest?'),
        content: Text('${widget.guest!.name} will be removed from the list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: EmColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await DatabaseHelper.instance.deleteGuest(widget.guest!.id!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guest == null ? 'Add guest' : 'Edit guest'),
        actions: [
          if (widget.guest?.id != null)
            IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline_rounded), onPressed: _delete),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
                ),
                gap,
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _relationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Relation', prefixIcon: Icon(Icons.diversity_3_rounded)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'People'),
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'At least 1' : null,
                    ),
                  ),
                ]),
                gap,
                DropdownButtonFormField<String>(
                  initialValue: _selectedPlace,
                  decoration: const InputDecoration(labelText: 'Place', prefixIcon: Icon(Icons.place_outlined)),
                  items: [for (final p in places) DropdownMenuItem(value: p, child: Text(p))],
                  onChanged: (value) => setState(() => _selectedPlace = value!),
                ),
                gap,
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                  items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
                gap,
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  glow: _status,
                  child: SwitchListTile(
                    value: _status,
                    onChanged: (v) => setState(() => _status = v),
                    title: const Text('Invitation done', style: TextStyle(color: EmColors.text, fontWeight: FontWeight.w500)),
                    subtitle: const Text('The card has been delivered'),
                  ),
                ),
                const SizedBox(height: 28),
                GradientButton(label: 'Save', icon: Icons.check_rounded, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
