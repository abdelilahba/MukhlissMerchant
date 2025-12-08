import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

class GetclientByuniquecode {
  final CaissierRepository repository;
  GetclientByuniquecode({required this.repository});
  Future<Client> execute({
    required int uniqueCode,
  }) {
    return repository.getClientByCodeUnique(uniqueCode: uniqueCode);
  }
}
