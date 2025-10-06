import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  final String userId;

  const ProfileLoaded({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated();
}