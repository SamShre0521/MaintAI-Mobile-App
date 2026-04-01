
import 'package:maintai/domain/entities/user.dart';
import 'package:maintai/domain/repositories/authrepo.dart';

class LoginUseCase{

  final Authrepo authrepo;
  LoginUseCase(this.authrepo);

  Future<User> call(String email, String password) async{
    return await authrepo.login(email, password);
  }
}


class SignupUseCase {
  final Authrepo repository;

  SignupUseCase(this.repository);

  Future<User> call(String email, String password) {
    return repository.signup(email, password);
  }
}
