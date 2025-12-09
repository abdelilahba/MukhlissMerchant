import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';

import 'package:mukhlissmagasin/features/profile/domain/usescases/get_user_usecase.dart';
import 'package:mukhlissmagasin/features/profile/domain/usescases/update_user_usecase.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final MagasinModel profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated();

  @override
  List<Object> get props => [];
}

class UpdateProfileError extends ProfileState {
  final String errorMessage;
  const UpdateProfileError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class ProfileCubit extends Cubit<ProfileState> {
  final UpdateUserUsecase updateprofileusecase;
  final GetUserUsecase getusercase;
  ProfileCubit(this.updateprofileusecase, this.getusercase)
      : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await getusercase.execute();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // update user
  Future<void> updateUser(MagasinModel updatedProfile) async {
    emit(ProfileUpdated());
    try {
      await updateprofileusecase.execute(updatedProfile);
      emit(ProfileUpdated());

      // Recharge le profil après mise à jour
      await loadProfile();
    } catch (e) {
      emit(UpdateProfileError(e.toString()));
      // Recharge les anciennes données en cas d'erreur
      if (state is ProfileLoaded) {
        emit(ProfileLoaded((state as ProfileLoaded).profile));
      }
    }
  }
}
