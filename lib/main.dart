import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:growing_sake/app_theme_color.dart';
import 'package:growing_sake/candidate_list.dart';
import 'package:growing_sake/sake_detail.dart';
import 'package:growing_sake/sake_home_view.dart';
import 'package:growing_sake/sake_timeline_view.dart';
import 'package:growing_sake/firebase_google_auth.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GrowingSakeApp());
}

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
          '/sake_detail': (BuildContext context) => SakeDetailWidget(arguments: settings.arguments),
          '/candidate_list': (BuildContext context) => CandidateListWidget(arguments: settings.arguments),
        };

        WidgetBuilder builder = routes[settings.name] ?? routes['/sake_detail']!;

        return MaterialPageRoute(builder: (ctx) => builder(ctx));
      },
      home: const GrowingSakeWidget(title: 'Growing Sake App'),
    );
  }
}

class GrowingSakeWidget extends StatefulWidget {
  const GrowingSakeWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<GrowingSakeWidget> createState() => _GrowingSakeWidgetState();
}

class _GrowingSakeWidgetState extends State<GrowingSakeWidget> {
  int _currentIndex = 0;
  bool _fabVisible = true;
  final _pageWidgets = [
    const SakeHomeViewWidget(color:Colors.white, title:'Home'),
    const SakeTimelineViewWidget(color:Colors.white, title:'Timeline'),
    FirebaseGoogleAuth(),
  ];

  void _DetailSakeTransition() {
    setState(() {
      Navigator.of(context).pushNamed("/sake_detail");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日本酒を育てる'),
      ),
      body: _pageWidgets.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), title: Text('Timeline')),
          BottomNavigationBarItem(icon: Icon(Icons.menu), title: Text('Menu')),
        ],
        currentIndex: _currentIndex,
        fixedColor: AppThemeColor.baseColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
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

  void _onItemTapped(int index) => setState(() {
    _currentIndex = index;
    if (_currentIndex == 0) {
      _fabVisible = true;
    } else {
      _fabVisible = false;
    }
  });
}
