


import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';

abstract class UserRepository {
  Future<MagasinModel> getuser();
  Future<void> updateuser(MagasinModel magazin);
}