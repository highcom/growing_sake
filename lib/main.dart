import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:growing_sake/candidate_list.dart';
import 'package:growing_sake/sake_detail.dart';
import 'package:growing_sake/sake_grid_view.dart';
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
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder> {
        '/sake_detail': (BuildContext context) => const SakeDetailWidget(),
        '/candidate_list': (BuildContext context) => const CandidateListWidget(),
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
  final _pageWidgets = [
    const SakeGridViewWidget(color:Colors.white, title:'Home'),
    const SakeGridViewWidget(color:Colors.blue, title:'Timeline'),
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
        title: const Text('Growing Sake App'),
      ),
      body: _pageWidgets.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), title: Text('Timeline')),
          BottomNavigationBarItem(icon: Icon(Icons.menu), title: Text('Menu')),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _DetailSakeTransition,
        tooltip: 'Transition',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index );
}
