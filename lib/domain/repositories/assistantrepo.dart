
import 'package:maintai/domain/entities/machines.dart';

abstract class AssistantRepository {
  Future<List<Machines>> getMachines();
}