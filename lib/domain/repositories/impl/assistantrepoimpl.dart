

import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/repositories/assistantrepo.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  @override
  Future<List<Machines>> getMachines() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      Machines(id: 'CB-2021-A', name: 'Conveyor Belt A'),
      Machines(id: 'CB-2021-B', name: 'Conveyor Belt B'),
      Machines(id: 'CB-2021-C', name: 'Conveyor Belt C'),
      Machines(id: 'CB-2021-D', name: 'Conveyor Belt D'),
    ];
  }
}