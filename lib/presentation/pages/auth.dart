import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/domain/repositories/impl/assistantrepoimpl.dart';
import 'package:maintai/domain/usecase/getMachines.dart';
import 'package:maintai/presentation/bloc/assistant_chat_event.dart';
import 'package:maintai/presentation/bloc/assitant_chat_bloc.dart';
import 'package:maintai/presentation/bloc/auth_event.dart';
import 'package:maintai/presentation/bloc/auth_state.dart';
import 'package:maintai/presentation/pages/assistant_chat_page.dart';
import '../bloc/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool obscurePassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (isLogin) {
      context.read<AuthBloc>().add(
        LoginEvent(emailController.text.trim(), passwordController.text.trim()),
      );
    } else {
      context.read<AuthBloc>().add(
        SignupEvent(
          emailController.text.trim(),
          passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          // listener: (context, state) {
          //   if (state is AuthSuccess) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(content: Text(state.message)),
          //     );
          //   } else if (state is AuthFailure) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(content: Text(state.error)),
          //     );
          //   }
          // },
          listener: (context, state) async{
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              await Future.delayed(Duration(seconds: 2));


              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => AssistantChatBloc(
                      GetMachines(AssistantRepositoryImpl()),
                    )..add(LoadMachinesEvent()),
                    child: const AssistantChatPage(),
                  ),
                ),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Robot image
                      Image.asset(
                        'assets/images/robolight.png',
                        height: 220,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 20),

                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: 'Welcome to '),
                            TextSpan(
                              text: 'SmartAssist',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Your Knowledge Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      _buildTextField(
                        controller: emailController,
                        hintText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      state is AuthLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    228,
                                    213,
                                    47,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: const Color(0x332F6FE4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  isLogin ? 'Login' : 'Sign Up',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2F6FE4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFFD1D5DB),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                            children: [
                              TextSpan(
                                text: isLogin
                                    ? "Don't have an account? "
                                    : "Already have an account? ",
                              ),
                              TextSpan(
                                text: isLogin ? 'Sign Up' : 'Login',
                                style: const TextStyle(
                                  color: Color(0xFF2F6FE4),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 18),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF6B7280)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}
