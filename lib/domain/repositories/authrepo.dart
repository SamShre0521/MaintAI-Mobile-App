
import 'package:maintai/domain/entities/user.dart';

abstract class Authrepo {

  Future<User> login(String email, String password);
  Future<User> signup(User user); 
}