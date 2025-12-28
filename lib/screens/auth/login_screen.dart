import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/screens/auth/create_account.dart';
import 'package:genesis/screens/main/main_screen.dart';
import 'package:genesis/widgets/actions/form_button.dart';
import 'package:genesis/widgets/actions/form_input.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final Size size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 500;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1000 : 500,
            maxHeight: isDesktop ? 700 : double.infinity,
          ),
          margin: const EdgeInsets.all(24),
          decoration: isDesktop
              ? BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                )
              : null,
          child: [
            // Left Side: Informational/Branding (Desktop Only)
            if (isDesktop)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      height: 60,
                      width: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    16.gapHeight,
                    Text(
                      "Welcome Back",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Your one stop solution for ERP",
                      style: TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(
                              Icons.security,
                              color: Colors.blue,
                            ),
                          ),
                          12.gapWidth,
                          const Expanded(
                            child: Text(
                              "Your data is protected by industry-leading encryption.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).expanded1,
            // Right Side: Form
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 16,
                vertical: 32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isDesktop) ...[
                      [
                        Image.asset(
                          'assets/images/app_icon.png',
                          height: 108,
                          width: 108,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ].row(mainAxisAlignment: MainAxisAlignment.center),
                      14.gapHeight,
                    ],

                    "Login ".text(
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    "Login with your details".text(
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    34.gapHeight,
                    // Email Field
                    GFormInput(
                      label: "Email Address",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    20.gapHeight,
                    // Password Field
                    GFormInput(
                      label: "Password",
                      controller: _passwordController,
                      isPasswordField: true,
                    ),
                    32.gapHeight,
                    GFormButton(
                      label: 'Sign In',
                      onPress: _login,
                      isLoading: false,
                    ),
                    24.gapHeight,
                    Center(
                      child: TextButton(
                        onPressed: () => Get.to(() => CreateAccount()),
                        child: RichText(
                          text: TextSpan(
                            text: "Dont have an account? ",
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "Create Account",
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).expanded1,
          ].row(),
        ),
      ),
    );
  }

  void _login() {
    Get.to(() => MainScreen());
  }
}
