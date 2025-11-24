

import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/features/profile/domain/repositories/user_repository.dart';

class GetUserUsecase {
  final UserRepository userrepo;
 

   GetUserUsecase(

      this.userrepo
   ) ;

   Future<MagasinModel> execute() async {
    return await userrepo.getuser(); // Replace 'getUser' with the actual method name that returns MagasinModel
   }


}