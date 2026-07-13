import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/repositories/impl/authrepoimpl.dart';
import 'package:maintai/domain/usecase/authorizations.dart';
import 'package:maintai/presentation/bloc/auth_bloc.dart';
import 'package:maintai/presentation/pages/auth.dart';
import 'package:maintai/storage/tokenStorage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Background notification: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  String? token = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM Token: $token");

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
      title: 'MaintAI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) =>
            AuthBloc(LoginUseCase(repository), SignupUseCase(repository)),
        child: const AuthPage(),
      ),
    );
  }
}
