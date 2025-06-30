// features/offers/presentation/cubit/offer_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/add_offer_usecase.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/delete_offer_usecase.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/edit_offer_usecase.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/get_offers_usecase.dart';

// États
abstract class OfferState extends Equatable {
  const OfferState();
  
  @override
  List<Object> get props => [];
}

class OfferInitial extends OfferState {}
class OfferLoading extends OfferState {}

// Modified to accept offers list
class OffersLoaded extends OfferState {
  final List<Offer> offers;
  const OffersLoaded(this.offers);

  @override
  List<Object> get props => [offers];
}

// For single operation success (add/edit/delete)
class OperationSuccess extends OfferState {
  final String message;
  const OperationSuccess([this.message = '']);

  @override
  List<Object> get props => [message];
}

class OfferError extends OfferState {
  final String message;
  const OfferError(this.message);

  @override
  List<Object> get props => [message];
}
// Cubit
class OfferCubit extends Cubit<OfferState> {
  final AddOfferUseCase addOfferUseCase;
  final GetOffersUseCase getOffersUseCase;
  final DeleteOfferUseCase deleteOfferUseCase;
  final UpdateOfferUseCase updateOfferUseCase; 

  OfferCubit({
    required this.addOfferUseCase,
    required this.getOffersUseCase,
    required this.deleteOfferUseCase,
    required this.updateOfferUseCase,
  }) : super(OfferInitial());

  Future<void> addOffer({
    required double amount,
    required int points,
  }) async {
    emit(OfferLoading());
    try {
      await addOfferUseCase.execute(
        minAmount: amount,
        pointsGiven: points,
      );
      emit(OperationSuccess('Offre ajoutée avec succès'));
      await loadOffers(); // Rafraîchit la liste
    } catch (e) {
      emit(OfferError(e.toString()));
    }
  }

  Future<void> loadOffers() async {
    emit(OfferLoading());
    try {
      final offers = await getOffersUseCase.execute();
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OfferError('Erreur de chargement: ${e.toString()}'));
    }
  }
 Future<void> deleteOffer(String id) async {
    emit(OfferLoading());
    try {
      await deleteOfferUseCase.execute(id);
      emit(OperationSuccess('Offre supprimée avec succès'));
      await loadOffers(); // Refresh the list
    } catch (e) {
      emit(OfferError('Erreur de suppression: ${e.toString()}'));
    }
  }
  Future<void> updateOffer({
    required String id,
    required double amount,
    required int points,
  }) async {
    emit(OfferLoading());
    try {
      print('Updating offer with id: $id, amount: $amount, points: $points');
      // You'll need to implement this in your repository
      await updateOfferUseCase.execute(
        id: id,
        minAmount: amount,
        pointsGiven: points,
      );
      emit(OperationSuccess('Offre modifiée avec succès'));
      await loadOffers();
    } catch (e) {
      emit(OfferError('Erreur de modification: ${e.toString()}'));
    }
  }

}