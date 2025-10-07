import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      // TODO: Load profile from Firebase
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Replace with actual user data from repository
      // Mock - emit error until repository is implemented
      emit(const ProfileError(message: 'Profile loading not yet implemented'));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    try {
      // TODO: Update profile in Firebase
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Replace with actual update logic
      // Mock - emit updated with user from event
      emit(ProfileUpdated(user: event.user));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}