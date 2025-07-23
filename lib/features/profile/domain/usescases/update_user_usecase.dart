
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/features/profile/domain/repositories/user_repository.dart';

class UpdateUserUsecase {
 final UserRepository userrepo;

   
   UpdateUserUsecase( this.userrepo);

   Future<void> execute (MagasinModel magasin) async {
    return userrepo.updateuser(magasin);
   }

}