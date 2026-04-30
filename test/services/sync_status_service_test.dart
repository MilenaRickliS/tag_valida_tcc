import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tag_valida/services/sync_status_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('deve iniciar com status pending', () async {
    final status = await SyncStatusService.getStatus();

    expect(status['status'], 'pending');
    expect(status['lastSync'], null);
  });

  test('deve definir status como pending', () async {
    await SyncStatusService.setPending();

    final status = await SyncStatusService.getStatus();

    expect(status['status'], 'pending');
  });

  test('deve definir status como success e salvar data', () async {
    await SyncStatusService.setSuccess();

    final status = await SyncStatusService.getStatus();

    expect(status['status'], 'success');
    expect(status['lastSync'], isNotNull);
    expect(status['lastSync'], isA<DateTime>());
  });

  test('deve definir status como error', () async {
    await SyncStatusService.setError();

    final status = await SyncStatusService.getStatus();

    expect(status['status'], 'error');
  });

  test('deve atualizar data após sucesso', () async {
    await SyncStatusService.setSuccess();
    final primeiro = await SyncStatusService.getStatus();

    await Future.delayed(const Duration(milliseconds: 10));

    await SyncStatusService.setSuccess();
    final segundo = await SyncStatusService.getStatus();

    expect(segundo['lastSync'].isAfter(primeiro['lastSync']), true);
  });
}