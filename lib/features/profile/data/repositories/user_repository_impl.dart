
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/features/profile/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {


final ProfileRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  UserRepositoryImpl(
    this.remoteDataSource,
    this.authRepository,
  );

  @override
  Future<MagasinModel> getuser() async {
    final currentUser = await this.authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('No current user found');
    }
    final magasin = await remoteDataSource.getCurrentMagasin();
    if (magasin == null) {
      throw Exception('No magasin found for current user');
    }
    return magasin;
  }

  @override
  Future<void> updateuser(MagasinModel magasindata)async {
   final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('No current user found');
    }
    await remoteDataSource.UpdatecurrentMagasin(magasindata);
  }



}