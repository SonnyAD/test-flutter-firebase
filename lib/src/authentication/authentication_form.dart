import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter_firebase/src/authentication/authentication_page.dart';
import 'package:test_flutter_firebase/src/password/password_page.dart';

import '../home/home.dart';

enum Mode { signIn, signUp }

class AuthenticationForm extends StatefulWidget {
  final Mode mode;
  const AuthenticationForm({
    super.key,
    this.mode = Mode.signIn,
  });

  @override
  AuthenticationFormState createState() {
    return AuthenticationFormState();
  }
}

class AuthenticationFormState extends State<AuthenticationForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? forceErrorText;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

  String? passwordValidator(String? value) {
    if (value == null) {
      return 'The password is required';
    }

    if (value.length < 8) {
      return 'The password should be at least 8 characters long';
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

  Future<void> onSave(Mode mode) async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() => isLoading = true);

    String? errorText;

    if (mode == Mode.signIn) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, HomePage.routeName, (r) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          errorText = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorText = 'Wrong password provided for that user.';
        } else {
          errorText = e.message;
        }
      } catch (e) {
        errorText = e.toString();
        print(errorText);
      }
    } else {
      // Mode.signUp
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await credential.user?.sendEmailVerification();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, HomePage.routeName, (r) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          errorText = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorText = 'The account already exists for that email.';
        } else {
          errorText = e.message;
        }
      } catch (e) {
        errorText = e.toString();
        print(errorText);
      }
    }

    if (context.mounted) {
      setState(() => isLoading = false);

      if (errorText != null) {
        setState(() {
          forceErrorText = errorText;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Stack(
                    children: [
                      TextFormField(
                        autocorrect: false,
                        controller: passwordController,
                        autofocus: false,
                        enableSuggestions: false,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: passwordValidator,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Forgot password?',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.restorablePushNamed(
                                      context,
                                      PasswordPage.routeName,
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                        onPressed: () => onSave(widget.mode),
                        child: Text(
                          widget.mode == Mode.signIn ? 'Sign in' : 'Sign up',
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.fontSize,
                          ),
                        )),
                  const SizedBox(height: 10.0),
                  if (widget.mode == Mode.signIn)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'You don\'t have an account yet? ',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.labelSmall?.color,
                            ),
                          ),
                          TextSpan(
                            text: 'Create an account',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.restorablePushNamed(
                                  context,
                                  AuthenticationPage.routeName,
                                  arguments: <String, String>{'mode': 'signUp'},
                                );
                              },
                          ),
                        ],
                      ),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'You have an account already? ',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.labelSmall?.color,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.restorablePushNamed(
                                  context,
                                  AuthenticationPage.routeName,
                                  arguments: <String, String>{'mode': 'signin'},
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                ],
              )),
        ),
      ),
    );
  }
}
