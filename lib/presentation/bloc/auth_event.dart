import 'package:maintai/domain/entities/user.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}

class SignupEvent extends AuthEvent {
  final User user;

  SignupEvent(this.user);
}