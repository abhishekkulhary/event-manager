import 'package:event_manager/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import '../../database_helper.dart';
import '../../ui/theme.dart';
import '../../ui/widgets.dart';

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

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = Item(
      id: widget.item?.id,
      description: _descriptionController.text.trim(),
      type: _selectedType,
      amount: num.parse(_amountController.text),
      status: _selectedStatus,
      // Keep the original date when editing; new items are dated now.
      date: widget.item?.date ?? DateTime.now(),
    );
    if (widget.item == null) {
      await DatabaseHelper.instance.insertMoneyItem(item);
    } else {
      await DatabaseHelper.instance.updateMoneyItem(item);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EmColors.surfaceHigh,
        title: const Text('Delete entry?'),
        content: Text('"${widget.item!.description}" will be removed from the ledger.'),
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
    await DatabaseHelper.instance.deleteMoneyItem(widget.item!.id!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add entry' : 'Edit entry'),
        actions: [
          if (widget.item?.id != null)
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
                SegmentedButton<ItemType>(
                  segments: const [
                    ButtonSegment(value: ItemType.income, label: Text('Income'), icon: Icon(Icons.south_west_rounded)),
                    ButtonSegment(value: ItemType.expense, label: Text('Expense'), icon: Icon(Icons.north_east_rounded)),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (s) => setState(() => _selectedType = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: EmColors.magenta,
                    selectedForegroundColor: EmColors.background,
                    side: const BorderSide(color: EmColors.border),
                  ),
                ),
                gap,
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes_rounded)),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a description' : null,
                ),
                gap,
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '$currencySymbol '),
                  validator: (v) => (num.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter an amount above 0' : null,
                ),
                gap,
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  glow: _selectedStatus == PaymentStatus.paid,
                  child: SwitchListTile(
                    value: _selectedStatus == PaymentStatus.paid,
                    onChanged: (v) => setState(() => _selectedStatus = v ? PaymentStatus.paid : PaymentStatus.notPaid),
                    title: const Text('Paid', style: TextStyle(color: EmColors.text, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Money has changed hands'),
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
