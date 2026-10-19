import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../features/get_the_app/get_the_app_screen.dart';
import '../features/get_the_app/get_the_app_strings.dart';
import '../features/get_the_app/build_stamp.dart';
import '../models/statistic.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'guests/guest_list_screen.dart';
import 'money/item_list_screen.dart';

/// Dashboard: invitation progress and the money balance at a glance.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Statistic> _guestTotals = [];
  List<Statistic> _guestDone = [];
  List<Statistic> _money = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    await db.seedSampleGuestsIfEmpty();
    final totals = await db.getTotalNumbersByCategory();
    final done = await db.getCompletedNumbersByCategory();
    final money = await db.getMoneyItemStatistics();
    if (!mounted) return;
    setState(() {
      _guestTotals = totals;
      _guestDone = done;
      _money = money;
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  num _sum(List<Statistic> s, num Function(Statistic) f) => s.fold<num>(0, (a, b) => a + f(b));

  num _moneyTotal(String type, [String? status]) => _sum(
        _money.where((s) => s.category.startsWith(type) && (status == null || s.category.endsWith(status))).toList(),
        (s) => s.total,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final families = _sum(_guestTotals, (s) => s.count);
    final familiesDone = _sum(_guestDone, (s) => s.count);
    final people = _sum(_guestTotals, (s) => s.total);
    final income = _moneyTotal('income');
    final expense = _moneyTotal('expense');
    final unpaid = _moneyTotal('income', 'notPaid') + _moneyTotal('expense', 'notPaid');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              children: [
                Row(children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: EmColors.accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: EmColors.magenta.withValues(alpha: .4), blurRadius: 20, spreadRadius: -6)],
                    ),
                    child: const Icon(Icons.mark_email_read_rounded, color: EmColors.background, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      GradientText('Event Manager', style: theme.textTheme.headlineMedium),
                      Text('Guests, invitations and gifts — on this device.', style: theme.textTheme.bodyMedium),
                    ]),
                  ),
                ]),
                const SizedBox(height: 32),
                const SectionLabel('Guests'),
                GlassCard(
                  onTap: () => _open(const GuestListScreen()),
                  padding: const EdgeInsets.all(22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('Invitations', style: theme.textTheme.titleLarge),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_rounded, color: EmColors.muted),
                    ]),
                    const SizedBox(height: 18),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      GradientText('$familiesDone', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 6),
                        child: Text('of $families families done', style: theme.textTheme.bodyMedium),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    GradientProgress(value: families == 0 ? 0 : familiesDone / families, height: 8),
                    const SizedBox(height: 16),
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      _Chip(icon: Icons.groups_rounded, label: '$people people'),
                      _Chip(icon: Icons.hourglass_bottom_rounded, label: '${families - familiesDone} pending'),
                      _Chip(icon: Icons.category_rounded, label: '${_guestTotals.length} categories'),
                    ]),
                  ]),
                ),
                const SizedBox(height: 28),
                const SectionLabel('Money'),
                GlassCard(
                  onTap: () => _open(const ItemListScreen()),
                  padding: const EdgeInsets.all(22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('Balance', style: theme.textTheme.titleLarge),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_rounded, color: EmColors.muted),
                    ]),
                    const SizedBox(height: 14),
                    GradientText(formatMoney(income - expense),
                        style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: _Figure(label: 'Income', value: formatMoney(income), color: EmColors.mint)),
                      Expanded(child: _Figure(label: 'Expenses', value: formatMoney(expense), color: EmColors.coral)),
                      Expanded(child: _Figure(label: 'Unpaid', value: formatMoney(unpaid), color: EmColors.amber)),
                    ]),
                  ]),
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 28),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.download_outlined),
                      label: Text(GetTheAppStrings.of(context).getTheApp),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GetTheAppScreen(appName: 'Event Manager')),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Center(
                  child: BuildStamp(
                    style: TextStyle(fontSize: 12, color: EmColors.muted, letterSpacing: 0.3),
                    accent: EmColors.magenta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: EmColors.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: EmColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: EmColors.amber),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: EmColors.text)),
        ]),
      );
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, required this.color});

  final String label;
  final String value;
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
          child: Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: EmColors.text)),
        ),
      ]);
}
