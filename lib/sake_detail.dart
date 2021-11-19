import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SakeDetailWidget extends StatelessWidget {
  SakeDetailWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sake Detail'),
        ),
        body: const Center(
          child: SakeDetail(),
        ),
      ),
    );
  }
}

class SakeDetail extends StatefulWidget {
  const SakeDetail({Key? key}) : super(key: key);

  @override
  State<SakeDetail> createState() => _SakeDetailState();
}

// 基本
//  銘柄名
//  サブ銘柄名
//  酒舗
//  産地
//  画像
// 詳細
//  特定名称
//  精米歩合
//  原材料
//  内容量
//  五味
// 育て方
//  保管温度
//  飲み方
//  香りグラフ
class _SakeDetailState extends State<SakeDetail> {
  double _height = 0;
  IconData _iconData = Icons.add;
  String _title = '';
  String _subTitle = '';

  void _handleVisible() {
    setState(() {
      if (_height > 0) {
        _height = 0;
        _iconData = Icons.add;
      } else {
        _height = 225;
        _iconData = Icons.remove;
      }
    });
  }

  void _handleTitleText(String e) {
    setState(() {
      _title = e;
    });
  }

  void _handleSubTitleText(String e) {
    setState(() {
      _title = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: _handleTitleText,
              decoration: TextFieldDecoration('銘柄名'),
            ),
          ),
          Container(
            height: 45,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: _handleSubTitleText,
              decoration: TextFieldDecoration('サブ銘柄名'),
            ),
          ),
          Container(
            height: 45,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: _handleSubTitleText,
              decoration: TextFieldDecoration('酒舗'),
            ),
          ),
          Container(
            height: 45,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: _handleSubTitleText,
              decoration: TextFieldDecoration('産地(県名)'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset('images/ic_sake.png'),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            alignment: Alignment.centerLeft,
            child: ButtonTheme(
              child: OutlineButton.icon(
                color: Colors.blue,
                icon: Icon(_iconData,
                  color: Colors.blue,
                ),
                label: const Text('詳細表示',
                  style: TextStyle(color: Colors.blue),
                ),
                shape: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onPressed: _handleVisible,
              ),
            ),
          ),
          AnimatedContainer(
            height: _height,
            duration: const Duration(milliseconds: 1000),
            child: Column(
              children: [
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: _handleSubTitleText,
                    decoration: TextFieldDecoration('特定名称'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: _handleSubTitleText,
                    decoration: TextFieldDecoration('精米歩合'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: _handleSubTitleText,
                    decoration: TextFieldDecoration('原材料'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: _handleSubTitleText,
                    decoration: TextFieldDecoration('内容量'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: _handleSubTitleText,
                    decoration: TextFieldDecoration('五味'),
                  ),
                ),
              ],
            )
          ),
          Container(
            height: 45,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: _handleSubTitleText,
              decoration: TextFieldDecoration('保管温度'),
            ),
          ),
          Container(
            height: 45,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: _handleSubTitleText,
              decoration: TextFieldDecoration('飲み方'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text('香りグラフ'),
                SizedBox(
                  height: 250,
                  child: charts.TimeSeriesChart(
                    _createAromaData(aromaList),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final aromaList = <AromaData>[
    AromaData(DateTime(2020, 10, 2), 50),
    AromaData(DateTime(2020, 10, 3), 53),
    AromaData(DateTime(2020, 10, 4), 40)
  ];

  List<charts.Series<AromaData, DateTime>> _createAromaData(
      List<AromaData> aromaList) {
    return [
      charts.Series<AromaData, DateTime>(
        id: 'Muscles',
        data: aromaList,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (AromaData aromaData, _) => aromaData.date,
        measureFn: (AromaData aromaData, _) => aromaData.level,
      )
    ];
  }
}

class TextFieldDecoration extends InputDecoration {
  TextFieldDecoration(String text) : super(
    labelText: text,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: Colors.blue.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}

class AromaData {
  final DateTime date;
  final double level;

  AromaData(this.date, this.level);
}
