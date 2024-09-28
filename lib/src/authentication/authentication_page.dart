import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:test_flutter_firebase/src/authentication/authentication_form.dart';
import 'package:test_flutter_firebase/src/authentication/authentication_list.dart';
import 'authentication_method.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({
    super.key,
    this.items = const [
      AuthenticationMethodAvailable('google', 'assets/images/google_logo.svg')
    ],
    required this.mode,
  });

  static const routeName = '/';

  final List<AuthenticationMethodAvailable> items;
  final String mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 40,
                  ),
                  colors: [
                    const Color(0xFF00DBDE),
                    const Color(0xFFFC00FF),
                  ],
                ),
                const SizedBox(height: 20.0),
                AuthenticationForm(
                    mode: mode != Mode.signUp.name ? Mode.signIn : Mode.signUp),
                if (mode != Mode.signUp.name)
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ),
                        Text(' or '),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (mode != Mode.signUp.name) AuthenticationListView(),
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
