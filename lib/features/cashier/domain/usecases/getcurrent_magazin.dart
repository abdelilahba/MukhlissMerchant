import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';

class GetCurrentMagazin {
  final CaissierRepository repository;
  GetCurrentMagazin({required this.repository});

  Future<MagasinModel> execute() async {
    return await repository.currentMagazin();
  }
}