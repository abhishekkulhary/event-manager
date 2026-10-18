import 'dart:convert';

import 'package:event_manager/extensions/string_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../database_helper.dart';
import '../../models/item.dart';
import '../../models/statistic.dart';
import '../../ui/theme.dart';
import '../../ui/widgets.dart';
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
    _loadMoneyItems();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    totalsByCategory = await DatabaseHelper.instance.getMoneyItemStatistics();
    if (mounted) setState(() {});
  }

  Future<void> _loadMoneyItems() async {
    final items = await DatabaseHelper.instance
        .getFilteredMoneyItems(query: _searchQuery, type: _selectedType, status: _selectedStatus);
    // Newest first.
    items.sort((a, b) => b.date.compareTo(a.date));
    if (mounted) setState(() => _items = items);
  }

  Future<void> _refresh() async {
    await _loadMoneyItems();
    await _loadStatistics();
  }

  Future<void> _importCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    await DatabaseHelper.instance.importMoneyItemsFromCSV(utf8.decode(bytes));
    await _refresh();
    _toast('CSV imported');
  }

  Future<void> _exportCSV() async {
    await DatabaseHelper.instance.exportMoneyItemsToCSV();
    _toast('Export completed');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit([Item? item]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditItemScreen(item: item)),
    );
    if (changed ?? false) await _refresh();
  }

  Future<void> _togglePaid(Item item, bool paid) async {
    await DatabaseHelper.instance
        .updateMoneyItem(item.copyWith(status: paid ? PaymentStatus.paid : PaymentStatus.notPaid));
    await _refresh();
  }

  num _total(String type, [String? status]) => totalsByCategory
      .where((s) => s.category.startsWith(type) && (status == null || s.category.endsWith(status)))
      .fold<num>(0, (a, s) => a + s.total);

  @override
  Widget build(BuildContext context) {
    final income = _total('income');
    final expense = _total('expense');
    final unpaid = _total('income', 'notPaid') + _total('expense', 'notPaid');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) => v == 'import' ? _importCSV() : _exportCSV(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'import', child: ListTile(leading: Icon(Icons.file_upload_outlined), title: Text('Import CSV'))),
              PopupMenuItem(value: 'export', child: ListTile(leading: Icon(Icons.file_download_outlined), title: Text('Export CSV'))),
            ],
          ),
        ],
      ),
      floatingActionButton: GradientButton(label: 'Add entry', icon: Icons.add_rounded, onPressed: () => _edit()),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Expanded(child: _Total(label: 'Income', value: income, color: EmColors.mint)),
                      Expanded(child: _Total(label: 'Expenses', value: expense, color: EmColors.coral)),
                      Expanded(child: _Total(label: 'Unpaid', value: unpaid, color: EmColors.amber)),
                    ]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Search entries', prefixIcon: Icon(Icons.search_rounded)),
                    onChanged: (value) {
                      _searchQuery = value;
                      _loadMoneyItems();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(children: [
                    PillMenu<ItemType?>(
                      label: 'Type',
                      value: _selectedType,
                      options: const [null, ...ItemType.values],
                      optionLabel: (v) => v?.name.capitalize() ?? 'All',
                      onSelected: (v) {
                        _selectedType = v;
                        _loadMoneyItems();
                      },
                    ),
                    const SizedBox(width: 8),
                    PillMenu<PaymentStatus?>(
                      label: 'Payment',
                      value: _selectedStatus,
                      options: const [null, ...PaymentStatus.values],
                      optionLabel: (v) => switch (v) {
                        null => 'All',
                        PaymentStatus.paid => 'Paid',
                        PaymentStatus.notPaid => 'Not paid',
                      },
                      onSelected: (v) {
                        _selectedStatus = v;
                        _loadMoneyItems();
                      },
                    ),
                  ]),
                ),
              ),
              if (_items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No entries yet. Add gifts received and event expenses to track the balance.',
                          textAlign: TextAlign.center, style: TextStyle(color: EmColors.muted)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  sliver: SliverList.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return _ItemTile(item: item, onTogglePaid: (paid) => _togglePaid(item, paid), onEdit: () => _edit(item));
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, required this.color});

  final String label;
  final num value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ]),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(formatMoney(value), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: EmColors.text)),
        ),
      ]);
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.onTogglePaid, required this.onEdit});

  final Item item;
  final ValueChanged<bool> onTogglePaid;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final income = item.type == ItemType.income;
    final color = income ? EmColors.mint : EmColors.coral;
    final paid = item.status == PaymentStatus.paid;
    return GlassCard(
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
          child: Icon(income ? Icons.south_west_rounded : Icons.north_east_rounded, color: color),
        ),
        const SizedBox(width: 14),
        // Description gets the full width; amount sits on the date line so
        // nothing truncates on a phone.
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: EmColors.text)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text('${formatDate(item.date)} · ${paid ? 'Paid' : 'Not paid'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: paid ? EmColors.muted : EmColors.amber)),
              ),
              Text('${income ? '+' : '−'}${formatMoney(item.amount)}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
            ]),
          ]),
        ),
        const SizedBox(width: 12),
        StatusToggle(done: paid, onChanged: onTogglePaid, tooltip: paid ? 'Paid — tap to undo' : 'Mark paid'),
      ]),
    );
  }
}
