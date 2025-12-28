import 'package:get/get.dart';
import 'package:exui/exui.dart';
import 'package:flutter/material.dart';
import 'package:genesis/widgets/actions/form_button.dart';
import 'package:genesis/widgets/actions/form_input.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
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
                      "Join Us",
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

                    "Create Account".text(
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    "Enter your details to get started".text(
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    34.gapHeight,
                    // Name Field
                    GFormInput(label: "Full Name", controller: _nameController),
                    20.gapHeight,

                    GFormInput(
                      label: "Company",
                      controller: _companyController,
                    ),
                    20.gapHeight,
                    GFormInput(
                      label: "Country",
                      controller: _countryController,
                    ),
                    20.gapHeight,
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
                      label: 'Create Account',
                      onPress: _createAccount,
                      isLoading: false,
                    ),
                    24.gapHeight,
                    Center(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "Log in",
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

  void _createAccount() {}
}
