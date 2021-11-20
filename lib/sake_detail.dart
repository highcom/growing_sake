import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:growing_sake/sake_line_chart.dart';
import 'package:growing_sake/sake_radar_chart.dart';

const gridColor = Color(0xff68739f);
const titleColor = Color(0xff8c95db);

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
//  画像
// 詳細
//  酒舗
//  産地
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
  String _brewery = '';
  String _area = '';
  String _specific = '';
  String _polishing = '';
  String _material = '';
  String _capacity = '';
  String _temperture = '';
  String _drinking = '';

  int selectedDataSetIndex = -1;

  void _handleVisible() {
    setState(() {
      if (_height > 0) {
        _height = 0;
        _iconData = Icons.add;
      } else {
        _height = 617;
        _iconData = Icons.remove;
      }
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
              onChanged: (value) {setState(() {_title = value;});},
              decoration: TextFieldDecoration('銘柄名'),
            ),
          ),
          Container(
            height: 45,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: (value) {setState(() {_subTitle = value;});},
              decoration: TextFieldDecoration('サブ銘柄名'),
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
                    onChanged: (value) {setState(() {_brewery = value;});},
                    decoration: TextFieldDecoration('酒舗'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: (value) {setState(() {_area = value;});},
                    decoration: TextFieldDecoration('産地(県名)'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: (value) {setState(() {_specific = value;});},
                    decoration: TextFieldDecoration('特定名称'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: (value) {setState(() {_polishing = value;});},
                    decoration: TextFieldDecoration('精米歩合'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: (value) {setState(() {_material = value;});},
                    decoration: TextFieldDecoration('原材料'),
                  ),
                ),
                Container(
                  height: 45,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    enabled: true,
                    maxLines:1 ,
                    onChanged: (value) {setState(() {_capacity = value;});},
                    decoration: TextFieldDecoration('内容量'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDataSetIndex = -1;
                          });
                        },
                        child: Text(
                          'Categories'.toUpperCase(),
                          style: const TextStyle(
                            color: titleColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: SakeRadarChart().rawDataSets()
                            .asMap()
                            .map((index, value) {
                          final isSelected = index == selectedDataSetIndex;
                          return MapEntry(
                            index,
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDataSetIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? gridColor.withOpacity(0.5)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(46),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInToLinear,
                                      padding: EdgeInsets.all(isSelected ? 8 : 6),
                                      decoration: BoxDecoration(
                                        color: value.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInToLinear,
                                      style: TextStyle(
                                        color: isSelected ? value.color : gridColor,
                                      ),
                                      child: Text(value.title),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                            .values
                            .toList(),
                      ),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: RadarChart(
                          RadarChartData(
                            radarTouchData: RadarTouchData(
                                touchCallback: (FlTouchEvent event, response) {
                                  if (!event.isInterestedForInteractions) {
                                    setState(() {
                                      selectedDataSetIndex = -1;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    selectedDataSetIndex =
                                        response?.touchedSpot?.touchedDataSetIndex ?? -1;
                                  });
                                }),
                            dataSets: SakeRadarChart().showingDataSets(selectedDataSetIndex),
                            radarBackgroundColor: Colors.transparent,
                            borderData: FlBorderData(show: false),
                            radarBorderData: const BorderSide(color: Colors.transparent),
                            titlePositionPercentageOffset: 0.2,
                            titleTextStyle:
                            const TextStyle(color: titleColor, fontSize: 14),
                            getTitle: (index) {
                              switch (index) {
                                case 0:
                                  return '甘味';
                                case 1:
                                  return '酸味';
                                case 2:
                                  return '辛味';
                                case 3:
                                  return '苦味';
                                case 4:
                                  return '渋味';
                                default:
                                  return '';
                              }
                            },
                            tickCount: 1,
                            ticksTextStyle:
                            const TextStyle(color: Colors.transparent, fontSize: 10),
                            tickBorderData: const BorderSide(color: Colors.transparent),
                            gridBorderData: const BorderSide(color: gridColor, width: 2),
                          ),
                          swapAnimationDuration: const Duration(milliseconds: 400),
                        ),
                      ),
                    ],
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
              onChanged: (value) {setState(() {_temperture = value;});},
              decoration: TextFieldDecoration('保管温度'),
            ),
          ),
          Container(
            height: 45,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: TextField(
              enabled: true,
              maxLines:1 ,
              onChanged: (value) {setState(() {_drinking = value;});},
              decoration: TextFieldDecoration('飲み方'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.70,
                  child: Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                        color: Color(0xff232d37)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 18.0, left: 12.0, top: 24, bottom: 12),
                      child: LineChart(SakeLineChart().mainData()),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
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
