import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../database_helper.dart';
import '../../models/guest.dart';
import '../../models/statistic.dart';
import '../../ui/theme.dart';
import '../../ui/widgets.dart';
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
  List<Statistic> totalNumbersByCategory = [];
  List<Statistic> completedNumbersByCategory = [];

  @override
  void initState() {
    super.initState();
    _loadGuests(initDBGuest: true);
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    totalNumbersByCategory = await DatabaseHelper.instance.getTotalNumbersByCategory();
    completedNumbersByCategory = await DatabaseHelper.instance.getCompletedNumbersByCategory();
    if (mounted) setState(() {});
  }

  Statistic getCompletedNumberByCategory(String category) {
    return completedNumbersByCategory.firstWhere(
      (stat) => stat.category.contains(category),
      orElse: () => Statistic(category: category, total: 0, count: 0),
    );
  }

  Future<void> _loadGuests({bool initDBGuest = false}) async {
    if (initDBGuest) {
      await DatabaseHelper.instance.seedSampleGuestsIfEmpty();
    }
    final guests = await DatabaseHelper.instance.getFilteredGuests(
        _searchQuery, _selectedCategory, _selectedStatus, _selectedPlace, _selectedRelation);
    if (mounted) setState(() => _guests = guests);
  }

  Future<void> _refresh() async {
    await _loadGuests();
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
    await DatabaseHelper.instance.importGuestsFromCSV(utf8.decode(bytes));
    await _refresh();
    _toast('CSV imported');
  }

  Future<void> _exportCSV() async {
    await DatabaseHelper.instance.exportGuestsToCSV();
    _toast('Export completed');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit([Guest? guest]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditGuestScreen(guest: guest)),
    );
    if (changed ?? false) await _refresh();
  }

  Future<void> _toggle(Guest guest, bool done) async {
    await DatabaseHelper.instance.updateGuest(guest.copyWith(status: done));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guests'),
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
      floatingActionButton: GradientButton(label: 'Add guest', icon: Icons.person_add_alt_1_rounded, onPressed: () => _edit()),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _StatsStrip(totals: totalNumbersByCategory, doneOf: getCompletedNumberByCategory)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Search guests', prefixIcon: Icon(Icons.search_rounded)),
                    onChanged: (value) {
                      _searchQuery = value;
                      _loadGuests();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(children: [
                    PillMenu<String>(
                      label: 'Category',
                      value: _selectedCategory,
                      options: ['All', ...categories],
                      optionLabel: (v) => v,
                      onSelected: (v) {
                        _selectedCategory = v;
                        _loadGuests();
                      },
                    ),
                    const SizedBox(width: 8),
                    PillMenu<String>(
                      label: 'Place',
                      value: _selectedPlace,
                      options: ['All', ...places],
                      optionLabel: (v) => v,
                      onSelected: (v) {
                        _selectedPlace = v;
                        _loadGuests();
                      },
                    ),
                    const SizedBox(width: 8),
                    PillMenu<String>(
                      label: 'Status',
                      value: _selectedStatus,
                      options: ['All', ...statuses],
                      optionLabel: (v) => v,
                      onSelected: (v) {
                        _selectedStatus = v;
                        _loadGuests();
                      },
                    ),
                  ]),
                ),
              ),
              if (_guests.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No guests match these filters.', style: TextStyle(color: EmColors.muted))),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  sliver: SliverList.separated(
                    itemCount: _guests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final guest = _guests[i];
                      return _GuestTile(
                        guest: guest,
                        onToggle: (done) => _toggle(guest, done),
                        onEdit: () => _edit(guest),
                      );
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

/// Per-category invitation progress, scrolling horizontally.
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.totals, required this.doneOf});

  final List<Statistic> totals;
  final Statistic Function(String category) doneOf;

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) return const SizedBox(height: 8);
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemCount: totals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final t = totals[i];
          final d = doneOf(t.category);
          return SizedBox(
            width: 196,
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.category, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: EmColors.text)),
                const Spacer(),
                Text.rich(TextSpan(children: [
                  TextSpan(text: '${d.count}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: EmColors.text)),
                  TextSpan(text: ' / ${t.count} families', style: const TextStyle(color: EmColors.muted)),
                ])),
                const SizedBox(height: 8),
                GradientProgress(value: t.count == 0 ? 0 : d.count / t.count),
                const SizedBox(height: 6),
                Text('${d.total} of ${t.total} people', style: const TextStyle(fontSize: 12, color: EmColors.muted)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _GuestTile extends StatelessWidget {
  const _GuestTile({required this.guest, required this.onToggle, required this.onEdit});

  final Guest guest;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final meta = [guest.category, guest.place, if (guest.relation != 'N/A') guest.relation];
    return GlassCard(
      glow: guest.status,
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: EmColors.accent),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: EmColors.surface),
            alignment: Alignment.center,
            child: Text(initials(guest.name), style: const TextStyle(fontWeight: FontWeight.w700, color: EmColors.text)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(guest.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: EmColors.text)),
            const SizedBox(height: 3),
            Text(meta.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: EmColors.muted)),
          ]),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: EmColors.surfaceHigh, borderRadius: BorderRadius.circular(999)),
          child: Text('×${guest.number}', style: const TextStyle(fontWeight: FontWeight.w700, color: EmColors.amber)),
        ),
        StatusToggle(
          done: guest.status,
          onChanged: onToggle,
          tooltip: guest.status ? 'Invited — tap to undo' : 'Mark invited',
        ),
      ]),
    );
  }
}
