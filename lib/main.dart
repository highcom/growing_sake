import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:growing_sake/model/uid_docid_args.dart';
import 'package:growing_sake/util/app_theme_color.dart';
import 'package:growing_sake/component/ad_banner.dart';
import 'package:growing_sake/component/candidate_list.dart';
import 'package:growing_sake/ui/sake_detail_reference.dart';
import 'package:growing_sake/ui/sake_detail_edit.dart';
import 'package:growing_sake/ui/sake_home_view.dart';
import 'package:growing_sake/ui/sake_timeline_view.dart';
import 'package:growing_sake/util/firebase_google_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const ProviderScope(child: GrowingSakeApp()));
}

// ユーザーIDプロバイダ
final uidProvider = StateProvider<String>((ref) => "");
// 既存データ更新状態プロバイダ
final updateDetailProvider = StateProvider<int>((ref) => 0);

///
/// メイン画面のウィジェット
/// 画面遷移のためのルーティングを定義する
///
class GrowingSakeApp extends StatelessWidget {
  const GrowingSakeApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growing Sake',
      theme: ThemeData(
        primarySwatch: AppThemeColor.baseColor,
      ),
      onGenerateRoute: (RouteSettings settings) {
        var routes = <String, WidgetBuilder>{
          '/sake_detail_edit': (BuildContext context) => SakeDetailEditWidget(arguments: settings.arguments),
          '/sake_detail_reference': (BuildContext context) => SakeDetailReferenceWidget(arguments: settings.arguments),
          '/candidate_list': (BuildContext context) => CandidateListWidget(arguments: settings.arguments),
        };

        WidgetBuilder builder = routes[settings.name] ?? routes['/sake_detail_edit']!;

        return MaterialPageRoute(builder: (ctx) => builder(ctx));
      },
      home: const GrowingSakeWidget(title: 'Growing Sake App'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("en"),
        Locale("ja"),
      ],
    );
  }
}

class GrowingSakeWidget extends StatefulHookConsumerWidget {
  const GrowingSakeWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  ConsumerState<GrowingSakeWidget> createState() => _GrowingSakeWidgetState();
}

///
/// 画面下部のメニュー項目を定義する
///
class _GrowingSakeWidgetState extends ConsumerState<GrowingSakeWidget> {
  int _currentIndex = 0;
  final _auth = FirebaseAuth.instance;
  User? _user;
  String uid = "";
  String? userImage;
  bool _fabVisible = false;
  final _pageWidgets = [
    SakeHomeViewWidget(color:Colors.white, title:'Home'),
    SakeTimelineViewWidget(color:Colors.white, title:'Timeline'),
    FirebaseGoogleAuth(),
  ];

  void _DetailSakeTransition() {
    setState(() {
      Navigator.of(context).pushNamed("/sake_detail_edit", arguments: UidDocIdArgs('Base', 'defaultDoc', false));
    });
  }

  @override
  void initState() {
    // 既に認証済みの状態であればuidを保持しておく
    if (_user != null) {
      ref.read(uidProvider.notifier).state = _user?.uid ?? "";
      uid = _user?.uid ?? "";
      userImage = _user?.photoURL;
    }
    _setFabVisible();
    super.initState();
  }

  ///
  /// ユーザー画像を取得する
  ///
  ImageProvider getUserImage(String? userImage) {
    if (userImage != null && userImage != "") {
      return NetworkImage(userImage);
    } else {
      return const AssetImage("images/account_white.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    uid = ref.watch(uidProvider);
    _user = _auth.currentUser;

    if (uid.compareTo("") == 0) {
      userImage = "";
    } else {
      userImage = _user?.photoURL;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: getUserImage(userImage),
                ),
              ),
            ),
            const Text('日本酒を育てる'),
          ],
        ),
      ),
      body: _pageWidgets.elementAt(_currentIndex),
      // 画面下部のナビゲーションバーを定義
      bottomNavigationBar: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: AdSize.getAnchoredAdaptiveBannerAdSize(Orientation.portrait,
                  MediaQuery.of(context).size.width.truncate()),
              builder: (
                  BuildContext context,
                  AsyncSnapshot<AnchoredAdaptiveBannerAdSize?> snapshot,
                  ) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  if (data != null) {
                    return Container(
                      height: 70,
                      color: Colors.white70,
                      child: AdBanner(size: data),
                    );
                  } else {
                    return Container(
                      height: 70,
                      color: Colors.white70,
                    );
                  }
                } else {
                  return Container(
                    height: 70,
                    color: Colors.white70,
                  );
                }
              },
            ),
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Timeline'),
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
              ],
              currentIndex: _currentIndex,
              fixedColor: AppThemeColor.baseColor,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          ],
      ),
      floatingActionButton:
        Visibility(
          visible: _fabVisible,
          child: FloatingActionButton(
            onPressed: _DetailSakeTransition,
            tooltip: 'Transition',
            child: const Icon(Icons.add),
          ),
        ),
    );
  }

  ///
  /// 下部メニュータップ時の処理
  /// タップされたメニューに応じたIDを設定する
  ///
  void _onItemTapped(int index) => setState(() {
    _currentIndex = index;
    _setFabVisible();
  });

  ///
  /// アイテム追加用のフローティングボタンの表示・非表示の定義
  /// ナビゲーションメニューのIDである[index]がホームでユーザー認証済みの場合のみ表示する
  ///
  void _setFabVisible() {
    if (_currentIndex == 0 && uid.compareTo("") != 0) {
      _fabVisible = true;
    } else {
      _fabVisible = false;
    }
  }
}
