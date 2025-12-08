import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

/// Use case to retrieve a client by their unique code.
///
/// This is used when scanning QR codes to identify clients.
class GetclientByuniquecode {
  final CaissierRepository repository;

  GetclientByuniquecode({required this.repository});

  /// Execute the use case to get client by unique code.
  ///
  /// [uniqueCode] - The unique identifier code of the client.
  /// Returns the [Client] entity if found.
  Future<Client> execute({required int uniqueCode}) {
    return repository.getClientByCodeUnique(uniqueCode: uniqueCode);
  }
}