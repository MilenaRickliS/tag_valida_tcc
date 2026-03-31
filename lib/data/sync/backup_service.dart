import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../local/app_db.dart';

class BackupService {
  static Future<File> exportBackup() async {
    final db = await AppDb.instance.db;
    final sourceFile = File(db.path);

    if (!await sourceFile.exists()) {
      throw Exception('Banco de dados não encontrado.');
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${docsDir.path}/backups');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final fileName =
        'backup_tagvalida_${DateTime.now().millisecondsSinceEpoch}.db';
    final backupFile = File('${backupDir.path}/$fileName');

    return sourceFile.copy(backupFile.path);
  }

  static Future<void> restoreBackup(String backupPath) async {
    final db = await AppDb.instance.db;
    final backupFile = File(backupPath);

    if (!await backupFile.exists()) {
      throw Exception('Arquivo de backup não encontrado.');
    }

    await db.close();
    await backupFile.copy(db.path);

    AppDb.instance;
  }
}