import 'package:drift/drift.dart';
import 'package:flutter/painting.dart';
import 'package:lectra/core/database/app_database.dart';
import 'package:lectra/features/subjects/model.dart';

/// Data access layer for subjects, backed by [AppDatabase].
class SubjectsRepository {
  SubjectsRepository(this._db);

  final AppDatabase _db;

  /// Returns all subjects ordered by name.
  Future<List<SubjectItem>> fetchAll() async {
    final rows = await (_db.select(_db.subjects)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows.map(_toItem).toList();
  }

  /// Inserts a new subject and returns its generated id.
  Future<int> addSubject({
    required String name,
    String code = '',
    int? colorValue,
  }) {
    return _db.into(_db.subjects).insert(
          SubjectsCompanion.insert(
            name: name,
            code: Value(code),
            colorValue: Value(colorValue),
          ),
        );
  }

  /// Deletes the subject with the given [id].
  Future<void> deleteSubject(int id) {
    return (_db.delete(_db.subjects)..where((t) => t.id.equals(id))).go();
  }

  SubjectItem _toItem(Subject row) {
    return SubjectItem(
      id: row.id,
      name: row.name,
      code: row.code,
      color: row.colorValue != null ? Color(row.colorValue!) : null,
    );
  }
}