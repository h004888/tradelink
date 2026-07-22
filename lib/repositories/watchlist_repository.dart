import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/api_client.dart';
import '../core/result.dart';
import '../models/listing_model.dart';

/// Watchlist lưu HOÀN TOÀN LOCAL trên máy qua SQLite — không gọi API server.
/// Mỗi user (theo userId hiện tại) có danh sách riêng, dùng chung 1 database
/// trên thiết bị (an toàn khi nhiều tài khoản đăng nhập chung máy).
class WatchlistRepository {
  static Database? _db;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'tradelink_watchlist.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE watchlist (
            user_id TEXT NOT NULL,
            listing_id TEXT NOT NULL,
            listing_json TEXT NOT NULL,
            saved_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, listing_id)
          )
        ''');
      },
    );
    return _db!;
  }

  String get _userId => ApiClient.instance.getUserId() ?? 'anonymous';

  Future<Result<bool>> isSaved(String listingId) async {
    final db = await _database();
    final rows = await db.query(
      'watchlist',
      where: 'user_id = ? AND listing_id = ?',
      whereArgs: [_userId, listingId],
      limit: 1,
    );
    return ResultSuccess<bool>(rows.isNotEmpty);
  }

  /// Toggle trạng thái lưu: nếu đang lưu thì bỏ, ngược lại thì lưu.
  Future<Result<bool>> toggleSave(Listing listing, bool currentlySaved) async {
    return currentlySaved ? await unsave(listing.id) : await save(listing);
  }

  /// Lưu snapshot đầy đủ của listing (không chỉ id) để màn Watchlist hiển thị
  /// được ảnh/tên/giá mà không cần gọi mạng.
  Future<Result<bool>> save(Listing listing) async {
    final db = await _database();
    await db.insert(
      'watchlist',
      {
        'user_id': _userId,
        'listing_id': listing.id,
        'listing_json': jsonEncode(listing.toJson()),
        'saved_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return const ResultSuccess<bool>(true);
  }

  Future<Result<bool>> unsave(String listingId) async {
    final db = await _database();
    await db.delete(
      'watchlist',
      where: 'user_id = ? AND listing_id = ?',
      whereArgs: [_userId, listingId],
    );
    return const ResultSuccess<bool>(true);
  }

  Future<Result<List<Listing>>> getAll() async {
    final db = await _database();
    final rows = await db.query(
      'watchlist',
      where: 'user_id = ?',
      whereArgs: [_userId],
      orderBy: 'saved_at DESC',
    );
    final items = rows
        .map((r) => Listing.fromJson(
            jsonDecode(r['listing_json'] as String) as Map<String, dynamic>))
        .toList();
    return ResultSuccess<List<Listing>>(items);
  }
}
