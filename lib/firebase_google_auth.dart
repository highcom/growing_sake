import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:growing_sake/login_home.dart';

class FirebaseGoogleAuth extends StatelessWidget {

  // Google 認証
  final _google_signin  = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);
  late GoogleSignInAccount googleUser;
  late GoogleSignInAuthentication googleAuth;
  late AuthCredential credential;

  // Firebase 認証
  final _auth = FirebaseAuth.instance;
  late UserCredential result;
  late User user;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: RaisedButton(
                  child: const Text('Google認証',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                  textColor: Colors.white,
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  onPressed: () async {

                    // Google認証の部分
                    googleUser = (await _google_signin.signIn())!;
                    googleAuth = await googleUser.authentication;

                    credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );

                    // Google認証を通過した後、Firebase側にログイン　※emailが存在しなければ登録
                    try {
                      result = await _auth.signInWithCredential(credential);
                      user = result.user!;

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginHome(user_id: user.uid),
                          )
                      );

                    } catch (e) {
                      print(e);
                    }
                  }
              ),
            ),

            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: RaisedButton(
                  child: const Text('Google認証ログアウト',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                  textColor: Colors.white,
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  onPressed: () {
                    _auth.signOut();
                    _google_signin.signOut();
                    print('サインアウトしました。');
                  }
              ),
            ),

            const Text('別のGoogleアカウントでログインしたい場合、一回ログアウトする必要がある。'),

          ],
        ),
      ),
    );
  }
}