import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/repositories/assistantrepo.dart';

class GetMachines {
  final AssistantRepository repository;

  GetMachines(this.repository);

  Future<List<Machines>> call() {
    return repository.getMachines();
  }
}