import 'package:return_success_or_error/src/core/service.dart';
import 'package:test/test.dart';

void main() {
  test('Service.to deve ser singleton (sempre a mesma instância)', () {
    expect(identical(Service.to, Service.to), isTrue);
  });

  test('initDependencies deve executar o callback de registro', () async {
    var registered = false;
    await Service.to.initDependencies(() async {
      registered = true;
    });
    expect(registered, isTrue);
  });

  test('initServices deve aguardar todos os serviços concluírem', () async {
    final completed = <int>[];

    await Service.to.initServices([
      Future<void>.delayed(
        const Duration(milliseconds: 30),
        () => completed.add(1),
      ),
      Future<void>.delayed(
        const Duration(milliseconds: 10),
        () => completed.add(2),
      ),
    ]);

    expect(completed, containsAll(<int>[1, 2]));
    expect(completed.length, equals(2));
  });

  test('initServices com lista vazia deve completar sem erro', () async {
    await expectLater(Service.to.initServices([]), completes);
  });
}
