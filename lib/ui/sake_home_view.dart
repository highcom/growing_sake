import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growing_sake/main.dart';
import 'package:growing_sake/model/uid_docid_args.dart';
import 'package:growing_sake/util/firebase_storage_access.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

///
/// 日本酒一覧表示画面
/// Firestoreから自分が登録した日本酒を取得して一覧で表示する
///
class SakeHomeViewWidget extends HookConsumerWidget {
  final Color color;
  final String title;
  int prevUpdateCount = 0;

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

  SakeHomeViewWidget({Key? key, required this.color, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final String uid = ref.watch(uidProvider);
    // 新規作成や詳細画面で更新があった場合を監視するために更新カウンタを確認する
    final int updateCount = ref.watch(updateDetailProvider);
    if (prevUpdateCount != updateCount) {
      prevUpdateCount = updateCount;
    }
    return Scaffold(
      body: uid == "" ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Text("ログインをして始めましょう！"),
              ),
              SizedBox(
                width: 230,
                height: 55,
                // Inkwell
                child: InkWell(
                  radius: 100,
                  onTap: () async {
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
                  },
                  child: Ink.image(
                    fit: BoxFit.cover,
                    image: const AssetImage('images/ic_google_rogo.png'),
                  ),
                ),
              ),
            ],
          ),
      ) : StreamBuilder(
        stream: FirebaseFirestore.instance.collection('HomeData').doc('UserList').collection(uid).orderBy('createAt', descending: true).snapshots(),
        builder: (BuildContext context,
          // データ取得中は処理中のプログレスを表示
          AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          ///
          /// Firestoreから取得したデータをGグリッド表示で並べる
          ///
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0, // 縦
                mainAxisSpacing: 5.0, // 横
                childAspectRatio: 0.75),
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            itemBuilder: (BuildContext context, int index) {
              // タップされた日本酒に対する詳細画面への遷移処理を定義
              return Container(
                child: GestureDetector(
                  onTap: () {
                    // タップされた場合は詳細画面に遷移する
                    Navigator.of(context).pushNamed('/sake_detail_reference', arguments: UidDocIdArgs(uid, snapshot.data!.docs[index].id, true));
                  },
                  onLongPress: () {
                    // 長押しされた場合は削除ダイアログを表示する
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(snapshot.data!.docs[index]['title']),
                          content: const Text("削除しますか？"),
                          actions: <Widget>[
                            // ボタン領域
                            FlatButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FlatButton(
                              child: const Text("OK"),
                              onPressed: () async {
                                FirebaseStorageAccess.deleteFile('UserData/' + uid + '/' + snapshot.data!.docs[index].id + '_1.JPG');
                                FirebaseStorageAccess.deleteFile('UserData/' + uid + '/' + snapshot.data!.docs[index].id + '_2.JPG');
                                await snapshot.data!.docs[index].reference.delete();
                                // タイムラインにも存在していた場合は併せて削除する
                                QuerySnapshot timelineSnapshot = await FirebaseFirestore.instance.collection('Timeline').where("orgDocId", isEqualTo: snapshot.data!.docs[index].id).get();
                                for (QueryDocumentSnapshot doc in timelineSnapshot.docs) {
                                  doc.reference.delete();
                                }
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Column(
                    children: <Widget>[
                      FutureBuilder<String?>(
                        future: FirebaseStorageAccess.downloadFile('UserData/' + uid + '/' + snapshot.data!.docs[index].id + '_1.JPG'),
                        builder: (context, imageSnapshot) => imageSnapshot.hasData ? InkWell(
                          child: Image.network(
                            imageSnapshot.data as String,
                            fit: BoxFit.cover,
                          ),
                        ) : Image.asset('images/ic_sake.png', fit: BoxFit.cover,),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Row(
                          children: [
                            Image.asset('images/sakura.png', height: 24, width: 24,),
                            Flexible(child: Text(
                                snapshot.data!.docs[index]['title'],
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1.0, 1.0),
                      blurRadius: 1.0,
                    )
                  ],
                ),
              );
            },
          );
        }),
    );
  }
}
