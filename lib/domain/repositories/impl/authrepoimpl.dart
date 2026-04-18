import 'package:dio/dio.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/user.dart';
import 'package:maintai/domain/repositories/authrepo.dart';
import 'package:maintai/storage/tokenStorage.dart';

class Authrepoimpl implements Authrepo {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  Authrepoimpl(this.apiClient, this.tokenStorage);

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {"email": email, "password": password},
      );
       final token = response.data["token"];
      await tokenStorage.saveToken(token);
      return User(
        response.data["user"]["email"] ?? "",
        response.data["user"]["name"] ?? "",
        response.data["user"]["role"] ?? "",
        "",
      );
    } catch (e) {
      print("Login error: $e");
      throw Exception("Failed to login: $e");
    }
  }

  @override
  Future<User> signup(User user) async {
    print(
      "Signup called with email: ${user.email}, name: ${user.name}, role: ${user.role}",
    );

    try {
      final response = await apiClient.dio.post(
        '/auth/signup',
        data: {
          "name": user.name,
          "email": user.email,
          "password": user.password,
          "role": user.role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data["user"];
        final token = response.data["token"];

        await tokenStorage.saveToken(token);


        return User(
          userData["email"] ?? "",
          userData["name"] ?? "",
          userData["role"] ?? "",
          "",
        );
      } else {
        throw Exception("Failed to signup");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Signup failed");
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}
