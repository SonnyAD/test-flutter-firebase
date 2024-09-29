import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({
    super.key,
  });

  static const routeName = '/forgot-password';

  @override
  PasswordPageState createState() {
    return PasswordPageState();
  }
}

class PasswordPageState extends State<PasswordPage> {
  final emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? forceErrorText;
  bool isLoading = false;
  bool requestSent = false;

  String? emailValidator(String? value) {
    if (value == null) {
      return 'The email address is required';
    }

    if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value) ==
        false) {
      return 'The emaill address is malformed or invalid';
    }

    return null;
  }

  void onChanged(String value) {
    if (forceErrorText != null) {
      setState(() {
        forceErrorText = null;
      });
    }
  }

  Future<void> onSave() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);

    String? errorText;
    bool success = false;

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      success = true;
    } catch (e) {
      errorText = 'Request could not be processed';
      print(errorText);
    }

    if (context.mounted) {
      setState(() => isLoading = false);
      setState(() => requestSent = success);
      if (errorText != null) {
        setState(() {
          forceErrorText = errorText;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(),
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                const SizedBox(height: 20.0),
                GradientText(
                  'You forgot your passord?',
                  style: TextStyle(
                    fontSize: 40,
                  ),
                  colors: [
                    const Color(0xFF00DBDE),
                    const Color(0xFFFC00FF),
                  ],
                ),
                const SizedBox(height: 20.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                forceErrorText: forceErrorText,
                                autocorrect: true,
                                controller: emailController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                ),
                                validator: emailValidator,
                                onChanged: onChanged,
                              ),
                              const SizedBox(height: 20.0),
                              if (isLoading)
                                const CircularProgressIndicator()
                              else if (!requestSent)
                                ElevatedButton(
                                    onPressed: onSave,
                                    child: Text(
                                      'Request Password Reset',
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.fontSize,
                                      ),
                                    ))
                              else if (requestSent)
                                Text('Request sent, check your emailbox'),
                              const SizedBox(height: 10.0),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(),
          ),
        ],
      ),
    );
  }
}
