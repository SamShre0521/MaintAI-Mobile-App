import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/repositories/impl/authrepoimpl.dart';
import 'package:maintai/domain/usecase/authorizations.dart';
import 'package:maintai/presentation/bloc/auth_bloc.dart';
import 'package:maintai/presentation/pages/auth.dart';
import 'package:maintai/storage/tokenStorage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage);
    final repository = Authrepoimpl(apiClient, tokenStorage);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartAssist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => AuthBloc(
          LoginUseCase(repository),
          SignupUseCase(repository),
        ),
        child: const AuthPage(),
      ),
    );
  }
}