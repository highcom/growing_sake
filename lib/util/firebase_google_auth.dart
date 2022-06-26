import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:growing_sake/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

///
/// FirebaseでのGoogle認証によるログイン
///
class FirebaseGoogleAuth extends HookConsumerWidget {

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
  User? user;

  FirebaseGoogleAuth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider);
    String loginState;
    bool loginButtonEnable;
    if (uid.compareTo("") == 0) {
      loginState = 'ログアウト中';
      loginButtonEnable = true;
    } else {
      String? userName = user?.displayName ?? "";
      loginState = 'ログイン中\n' + userName;
      loginButtonEnable = false;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            ///
            /// ログイン状態かどうかを明示しておく
            ///
            Text(loginState),

            ///
            /// Google認証によるログイン処理ボタン
            ///
            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: RaisedButton(
                  child: const Text('Google認証',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                  textColor: Colors.white,
                  color: loginButtonEnable ? Colors.lightGreen : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  onPressed: () async {
                    if (!loginButtonEnable) return;
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
                      user = result.user;
                      ref.read(uidProvider.notifier).state = user!.uid;

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ようこそ' + user!.displayName!)));
                    } catch (e) {
                      print(e);
                    }
                  }
              ),
            ),

            ///
            /// Google認証によるログアウト処理ボタン
            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: RaisedButton(
                  child: const Text('Google認証ログアウト',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                  textColor: Colors.white,
                  color: loginButtonEnable ? Colors.grey : Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  onPressed: () {
                    if (loginButtonEnable) return;
                    _auth.signOut();
                    _google_signin.signOut();
                    ref.read(uidProvider.notifier).state = "";
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ログアウトしました')));
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}