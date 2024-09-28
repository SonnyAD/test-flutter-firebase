import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_flutter_firebase/src/utils/strings.dart';

import '../home/home.dart';
import 'authentication_method.dart';

class AuthenticationListView extends StatefulWidget {
  const AuthenticationListView({super.key});

  @override
  State<AuthenticationListView> createState() => _AuthenticationListViewState();
}

class _AuthenticationListViewState extends State<AuthenticationListView> {
  _AuthenticationListViewState({
    this.items = const [
      AuthenticationMethodAvailable('google', 'assets/images/google_logo.svg')
    ],
  });

  final List<AuthenticationMethodAvailable> items;
  ValueNotifier userCredential = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: items
          .map<Widget>((v) =>
              CustomAuthenticationListButton(name: v.name, svgLogo: v.logo))
          .toList(),
      /*itemBuilder: (BuildContext context, int index) {
        final item = items[index];

        return ListTile(
          title: Text('Sign in with ${item.name}'),
          leading: SvgPicture.asset(
            item.logo,
            semanticsLabel: 'Sign in with ${item.name}',
          ),
          onTap: () async {
            userCredential.value = await signInWithGoogle();
            if (userCredential.value != null) {
              print(userCredential.value.user!.email);
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (r) => false);
            }
          },
        );
      },*/
    );
  }
}

class CustomAuthenticationListButton extends StatelessWidget {
  const CustomAuthenticationListButton({
    super.key,
    required this.name,
    required this.svgLogo,
  });

  final String name;
  final String svgLogo;

  String label() {
    return 'Sign in with ${name.toCapitalized}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: () async {
          final cred = await signInWithGoogle();
          if (cred != null) {
            print(cred.user!.email);
            Navigator.pushNamedAndRemoveUntil(
                context, HomePage.routeName, (r) => false);
          }
        },
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  svgLogo,
                  semanticsLabel: label(),
                ),
              ),
              Text(
                label(),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on Exception catch (e) {
    // TODO
    print('exception->$e');
  }
}
