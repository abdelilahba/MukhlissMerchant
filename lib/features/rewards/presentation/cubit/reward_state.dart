import 'package:equatable/equatable.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

abstract class RewardState extends Equatable {
  const RewardState();
  
  @override
  List<Object> get props => [];
}

class RewardInitial extends RewardState {}

class RewardLoading extends RewardState {}

class RewardsLoaded extends RewardState {
  final List<Reward> rewards;
  const RewardsLoaded(this.rewards);

  @override
  List<Object> get props => [rewards];
}

class RewardOperationSuccess extends RewardState {
  final String message;
  const RewardOperationSuccess([this.message = '']);

  @override
  List<Object> get props => [message];
}

class RewardError extends RewardState {
  final String message;
  const RewardError(this.message);

  @override
  List<Object> get props => [message];
}

class RewardDetailLoaded extends RewardState {
  final Reward reward;
  const RewardDetailLoaded(this.reward);

  @override
  List<Object> get props => [reward];
}