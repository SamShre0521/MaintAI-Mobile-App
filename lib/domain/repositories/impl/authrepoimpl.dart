import 'package:maintai/domain/entities/user.dart';
import 'package:maintai/domain/repositories/authrepo.dart';

class Authrepoimpl implements Authrepo{
  @override
  Future<User> login(String email, String password) async{
    // TODO: implement login
    await Future.delayed(Duration(seconds: 2));
    if (email == "test@test.com" && password == "123456") {
      return User(email);
    } else {
      throw Exception("Invalid credentials");
    }
    
  }

  @override
  Future<User> signup(String email, String password) async{
    await Future.delayed(Duration(seconds: 2));
    if (password.length >= 6) {
      return User(email);
    } else {
      throw Exception("Weak password");
    }
  }
}