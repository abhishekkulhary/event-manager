import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:universal_html/html.dart' as html;

import 'constants.dart';
import 'models/guest.dart';
import 'models/item.dart';
import 'models/statistic.dart';

// Database Helper
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _guestDatabase;
  static Database? _moneyDatabase;

  DatabaseHelper._init();

  Future<Database> get guestDatabase async {
    if (_guestDatabase != null) return _guestDatabase!;
    _guestDatabase = await _initDB('guests.db', '''
      CREATE TABLE guests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        place TEXT,
        address TEXT,
        relation TEXT,
        number INTEGER,
        category TEXT,
        status INTEGER
      )
    ''');
    return _guestDatabase!;
  }

  Future<Database> get moneyDatabase async {
    if (_moneyDatabase != null) return _moneyDatabase!;
    _moneyDatabase = await _initDB('money.db', '''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        type TEXT,
        amount REAL,
        date TEXT,
        status TEXT
      )
    ''');
    return _moneyDatabase!;
  }

  Future<void> deleteAllGuests() async {
    final db = await instance.guestDatabase;
    await db.delete('guests');
  }

  Future<void> deleteAllMoneyItems() async {
    final db = await instance.moneyDatabase;
    await db.delete('items');
  }

  Future<void> deleteGuest(int id) async {
    final db = await instance.guestDatabase;
    await db.delete('guests', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMoneyItem(num id) async {
    final db = await instance.moneyDatabase;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> exportGuestsToCSV() async {
    for (var category in categories) {
      for (var place in places) {
        final List<List<dynamic>> rows = [];
        final List<Guest> guests =
            await getFilteredGuests('', category, 'All', place, 'All');
        rows.add([
          'ID',
          'Name',
          'Place',
          'Relation',
          'Number',
          'Category',
          'Status'
        ]);
        for (var guest in guests) {
          rows.add([
            guest.id,
            guest.name,
            guest.place,
            guest.relation,
            guest.number,
            guest.category,
            guest.status ? 'Done' : 'Not Done'
          ]);
        }
        final String csvData = const ListToCsvConverter().convert(rows);

        if (kIsWeb) {
          final bytes = utf8.encode(csvData);
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute('download', 'guests_${category}_$place.csv')
            ..click();
          html.Url.revokeObjectUrl(url);
        } else {
          final Directory directory = await getApplicationDocumentsDirectory();
          final File file =
              File('${directory.path}/guests_${category}_$place.csv');
          await file.writeAsString(csvData);
        }
      }
    }
  }

  Future<void> exportMoneyItemsToCSV() async {
    final List<List<dynamic>> rows = [];
    final List<Item> items = await getFilteredMoneyItems(query: '');
    rows.add(['ID', 'Description', 'Type', 'Amount', 'Date', 'Payment Status']);
    for (var item in items) {
      rows.add([
        item.id,
        item.description,
        item.type.name,
        item.amount,
        item.date.toIso8601String(),
        item.status.name,
      ]);
    }
    final String csvData = const ListToCsvConverter().convert(rows);

    var fileName = 'money_items.csv';
    if (kIsWeb) {
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/$fileName');
      await file.writeAsString(csvData);
    }
  }

  Future<List<Statistic>> getCompletedNumbersByCategory() async {
    final db = await instance.guestDatabase;
    final result = await db.rawQuery(
        'SELECT category, SUM(number) as total_numbers, COUNT(*) as total_count FROM guests WHERE status = 1 GROUP BY category');
    return result
        .map((row) => Statistic(
              category: row['category'] as String,
              total: row['total_numbers'] as int,
              count: row['total_count'] as int,
            ))
        .toList();
  }

  Future<List<Guest>> getFilteredGuests(String query, String category,
      String status, String place, String relation) async {
    final db = await instance.guestDatabase;
    String whereClause = '1=1';
    List<String> whereArgs = [];

    if (query.isNotEmpty) {
      whereClause += ' AND name LIKE ?';
      whereArgs.add('%$query%');
    }
    if (category.isNotEmpty && category != 'All') {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }
    if (status.isNotEmpty && status != 'All') {
      whereClause += ' AND status = ?';
      whereArgs.add(status == 'Done' ? '1' : '0');
    }
    if (place.isNotEmpty && place != 'All') {
      whereClause += ' AND place = ?';
      whereArgs.add(place);
    }

    if (relation.isNotEmpty && relation != 'All') {
      whereClause += ' AND relation = ?';
      whereArgs.add(relation);
    }

    final result =
        await db.query('guests', where: whereClause, whereArgs: whereArgs);
    return result
        .map((json) => Guest(
              id: json['id'] as int?,
              name: json['name'] as String,
              place: json['place'] as String,
              relation: json['relation'] as String,
              number: json['number'] as int,
              category: json['category'] as String,
              status: json['status'] as int == 1,
            ))
        .toList();
  }

  Future<List<Item>> getFilteredMoneyItems({
    required String query,
    ItemType? type,
    DateTime? date,
    PaymentStatus? status,
  }) async {
    final db = await instance.moneyDatabase;
    String whereClause = '1=1';
    List<String> whereArgs = [];

    if (query.isNotEmpty) {
      whereClause += ' AND description LIKE ?';
      whereArgs.add('%$query%');
    }
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.name);
    }
    if (date != null) {
      whereClause += ' AND date = ?';
      whereArgs.add(date.toIso8601String());
    }
    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status.name);
    }

    final result =
        await db.query('items', where: whereClause, whereArgs: whereArgs);
    return result
        .map((json) => Item(
              id: json['id'] as int?,
              description: json['description'] as String,
              type: ItemType.values.byName(json['type'] as String),
              amount: json['amount'] as num,
              date: DateTime.parse(json['date'] as String),
              status: PaymentStatus.values.byName(json['status'] as String),
            ))
        .toList();
  }

  Future<List<Statistic>> getTotalNumbersByCategory() async {
    final db = await instance.guestDatabase;
    final result = await db.rawQuery(
        'SELECT category, SUM(number) as total_numbers, COUNT(*) as total_count FROM guests GROUP BY category');
    return result
        .map((row) => Statistic(
              category: row['category'] as String,
              total: row['total_numbers'] as int,
              count: row['total_count'] as int,
            ))
        .toList();
  }

  Future<List<Statistic>> getMoneyItemStatistics() async {
    final db = await instance.moneyDatabase;
    final result = await db.rawQuery(
        'SELECT type, status, SUM(amount) as total_amount, COUNT(*) as total_count FROM items GROUP BY type, status');
    return result
        .map((row) => Statistic(
              category: '${row['type'] as String} - ${row['status'] as String}',
              total: row['total_amount'] as num,
              count: row['total_count'] as num,
            ))
        .toList();
  }

  Future<void> importGuestsFromCSV(String csvString) async {
    final List<List<dynamic>> csvRows =
        const CsvToListConverter().convert(csvString);

    if (csvRows.isNotEmpty) {
      csvRows.removeAt(0);
      for (var row in csvRows) {
        final guest = Guest(
          id: row[0] as int,
          name: row[1],
          place: row[2],
          relation: row[3],
          number: row[4],
          category: row[5],
          status: row[6] == 'Done',
        );
        await updateGuest(guest);
      }
    }
  }

  Future<void> importMoneyItemsFromCSV(String csvString) async {
    final List<List<dynamic>> csvRows =
        const CsvToListConverter().convert(csvString);

    if (csvRows.isNotEmpty) {
      csvRows.removeAt(0);
      for (var row in csvRows) {
        final item = Item(
          id: row[0] as int,
          description: row[1],
          type: ItemType.values.byName(row[2] as String),
          amount: row[3],
          date: DateTime.parse(row[4]),
          status: PaymentStatus.values.byName(row[5] as String),
        );

        await updateMoneyItem(item);
      }
    }
  }

  Future<void> initGuests(List<Guest> guests) async {
    final db = await instance.guestDatabase;
    final batch = db.batch();
    for (final guest in guests) {
      batch.insert('guests', guest.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> initMoneyItems(List<Item> items) async {
    final db = await instance.moneyDatabase;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('items', item.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertGuest(Guest guest) async {
    final db = await instance.guestDatabase;
    await db.insert('guests', guest.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertMoneyItem(Item item) async {
    final db = await instance.moneyDatabase;
    await db.insert('items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateGuest(Guest guest) async {
    final db = await instance.guestDatabase;
    await db.update('guests', guest.toMap(),
        where: 'id = ?', whereArgs: [guest.id]);
  }

  Future<void> updateMoneyItem(Item item) async {
    final db = await instance.moneyDatabase;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<Database> _initDB(String filePath, String createScript) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path,
        version: 1,
        onCreate: (db, version) async => await db.execute(createScript));
  }
}
