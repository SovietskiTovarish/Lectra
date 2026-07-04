import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:lectra/core/database/app_database.dart';
import 'package:lectra/core/theme/subject_colors.dart';
import 'package:lectra/features/subjects/model.dart';

/// Repository responsible for all Subject-related database operations.
///
/// This class is the only layer that communicates directly with Drift.
/// Controllers and UI should depend only on this repository.
class SubjectsRepository {
  SubjectsRepository(this._db);

  final AppDatabase _db;

  // ===========================================================================
  // READ
  // ===========================================================================

  /// Returns all subjects ordered alphabetically.
  Future<List<SubjectItem>> fetchAll() async {
    final rows = await (_db.select(_db.subjects)
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.name,
                ),
          ]))
        .get();

    return rows.map(_mapSubject).toList();
  }

  /// Returns a single subject.
  Future<SubjectItem?> fetchById(int id) async {
    final row = await (_db.select(_db.subjects)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();

    return row == null ? null : _mapSubject(row);
  }

  // ===========================================================================
  // CREATE
  // ===========================================================================

  Future<int> addSubject({
    required String name,
    String? code,
    String? nickname,
    String? facultyName,
    int? accentColor,
  }) async {
    final resolvedColor = accentColor ?? await _nextAutoColor();

    return _db.into(_db.subjects).insert(
          SubjectsCompanion.insert(
            name: name.trim(),
            code: Value(_clean(code)),
            nickname: Value(_clean(nickname)),
            facultyName: Value(_clean(facultyName)),
            accentColor: resolvedColor,
          ),
        );
  }

  // ===========================================================================
  // UPDATE
  // ===========================================================================

  Future<void> updateSubject({
    required int id,
    required String name,
    String? code,
    String? nickname,
    String? facultyName,
    int? accentColor,
  }) async {
    await (_db.update(_db.subjects)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      SubjectsCompanion(
        name: Value(name.trim()),
        code: Value(_clean(code)),
        nickname: Value(_clean(nickname)),
        facultyName: Value(_clean(facultyName)),
        accentColor: accentColor == null
            ? const Value.absent()
            : Value(accentColor),
      ),
    );
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  Future<void> deleteSubject(int id) async {
    await (_db.delete(_db.subjects)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Future<int> _nextAutoColor() async {
    final subjects = await _db.select(_db.subjects).get();
    return SubjectColors.assign(subjects.length);
  }

  String? _clean(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  SubjectItem _mapSubject(Subject row) {
    return SubjectItem(
      id: row.id,
      name: row.name,
      code: row.code,
      nickname: row.nickname,
      facultyName: row.facultyName,
      accentColor: Color(row.accentColor),
    );
  }
}