import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:growing_sake/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

///
/// FirebaseでのGoogle認証によるログイン
///
class FirebaseGoogleAuth extends StatefulHookConsumerWidget {
  const FirebaseGoogleAuth({Key? key}) : super(key: key);

  @override
  ConsumerState<FirebaseGoogleAuth> createState() => _FirebaseGoogleAuthState();
}

class _FirebaseGoogleAuthState extends ConsumerState<FirebaseGoogleAuth> {

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


  // アプリ情報
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  ///
  /// ユーザー画像を取得する
  ///
  ImageProvider getUserImage(String? userImage) {
    if (userImage != null && userImage != "") {
      return NetworkImage(userImage);
    } else {
      return const AssetImage("images/account_black.png");
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(uidProvider);
    user = _auth.currentUser;

    _initPackageInfo();

    String? userImage;
    String userName;
    String loginState;
    bool loginButtonEnable;
    if (uid.compareTo("") == 0) {
      userImage = "";
      userName = "";
      loginState = 'ログアウト中';
      loginButtonEnable = true;
    } else {
      userImage = user?.photoURL;
      userName = user?.displayName ?? "";
      loginState = 'ログイン中';
      loginButtonEnable = false;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Container(
                color: const Color(0xfff0f0f0),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Column(
                  children: [
                    ///
                    /// ログイン状態の場合はアイコンも表示する
                    ///
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: getUserImage(userImage),
                        ),
                      ),
                    ),

                    ///
                    /// ログイン状態の場合はユーザー名も表示する
                    ///
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(userName == "" ? loginState : userName),
                    ),

                    ///
                    /// 認証ボタンを横に並べる
                    ///
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ///
                        /// Google認証によるログイン処理ボタン
                        ///
                        ButtonTheme(
                          height: 60.0,
                          child: RaisedButton(
                            child: const Text('Google認証\nログイン',
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
                        ///
                        ButtonTheme(
                          height: 60.0,
                          child: RaisedButton(
                              child: const Text('Google認証\nログアウト',
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
                  ],
                ),
              ),
            ),

            ///
            /// アプリバージョン
            ///
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Container(
                color: const Color(0xfff0f0f0),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('アプリバージョン ${_packageInfo.version}'),
                  ],
                ),
              ),
            ),

            ///
            /// プライバシーポリシーへのリンク
            ///
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Container(
                color: const Color(0xfff0f0f0),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: const Text("プライバシーポリシー",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 255)),
                      ),
                      onTap: () async {
                        if (await canLaunch("https://high-commu.amebaownd.com/pages/2891722/page_201905200001")) {
                          await launch("https://high-commu.amebaownd.com/pages/2891722/page_201905200001");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            ///
            /// 開発者サイトへのリンク
            ///
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Container(
                color: const Color(0xfff0f0f0),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: const Text("開発者ウェブサイト",
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 255)),
                      ),
                      onTap: () async {
                        if (await canLaunch("https://high-commu.amebaownd.com/")) {
                          await launch("https://high-commu.amebaownd.com/");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}