


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/domain/entities/user.dart';
import 'package:maintai/domain/usecase/authorizations.dart';
import 'package:maintai/presentation/bloc/auth_event.dart';
import 'package:maintai/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;

  AuthBloc(this.loginUseCase, this.signupUseCase) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.email, event.password);
        emit(AuthSuccess('Login successful: ${user.email}'));
      } catch (e) {
        emit(AuthFailure('Login failed: $e'));
      }
    });

    on<SignupEvent>((event, emit) async {
  emit(AuthLoading());
  try {
    final user = await signupUseCase(event.user);
    emit(AuthSuccess('Signup successful: ${user.email}'));
  } catch (e) {
    emit(AuthFailure('Signup failed: $e'));
  }
});
  }
}