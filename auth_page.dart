import 'package:flutter/material.dart';
import 'package:healthcare_app/widgets/custom_button.dart';
import 'package:healthcare_app/widgets/custom_input.dart';
import 'location_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool isSignIn = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[300]!, Colors.blue[600]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        isSignIn ? 'Welcome Back' : 'Create Account',
                        key: ValueKey<bool>(isSignIn),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CustomInput(hint: 'Email'),
                    const SizedBox(height: 16),
                    const CustomInput(hint: 'Password', isPassword: true),
                    if (!isSignIn) ...[
                      const SizedBox(height: 16),
                      const CustomInput(
                          hint: 'Confirm Password', isPassword: true),
                    ],
                    const SizedBox(height: 32),
                    CustomButton(
                      text: isSignIn ? 'Sign In' : 'Sign Up',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const LocationPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      child: Text(
                        isSignIn
                            ? 'Create an account'
                            : 'Already have an account?',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          isSignIn = !isSignIn;
                        });
                        _animationController.forward(from: 0);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
