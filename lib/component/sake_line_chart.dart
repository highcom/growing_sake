import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:growing_sake/util/app_theme_color.dart';
import 'package:numberpicker/numberpicker.dart';

///
/// 香りグラフ用ラインチャート
/// [elapsedList] x軸の値となる経過日数
/// [levelList] y軸の値となる香りレベル
///
class SakeLineChart extends StatefulWidget {
  final List<double> elapsedList;
  final List<double> levelList;
  final List<FlSpot> aromaDataList = [];

  SakeLineChart({Key? key, required this.elapsedList, required this.levelList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SakeLineChartState();
}

class _SakeLineChartState extends State<SakeLineChart> with SingleTickerProviderStateMixin {
  // 折れ線用のグラデーションカラー
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  // 香りデータ入力エリア表示・非表示設定
  bool showPicker = false;
  late AnimationController _controller;
  IconData _iconData = Icons.add;

  // 選択日付
  late DateTime _selectDateTime;
  // 選択日付表示用コントローラ
  final TextEditingController _selectDate = TextEditingController();
  // 現在の日付
  double _currentDate = 0;
  // 開始日
  double _startDate = 0;
  // 終了日
  double _endDate = 0;
  // 現在の香りレベル
  int _currentAromaLevel = 1;

  @override
  void initState() {
    Intl.defaultLocale = 'ja_JP';
    initializeDateFormatting();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // コンストラクタで渡されたパラメータをグラフデータリストに追加していく
    setState(() {
      for (int i = 0; i < widget.elapsedList.length && i < widget.levelList.length; i++) {
        FlSpot data = FlSpot(widget.elapsedList[i], widget.levelList[i]);
        widget.aromaDataList.add(data);
      }
      if (widget.elapsedList.isNotEmpty && widget.levelList.isNotEmpty) {
        widget.aromaDataList.sort((left, right) => left.x.compareTo(right.x));
        _startDate = widget.aromaDataList.first.x;
        _endDate = widget.aromaDataList.last.x;
      }
    });

    super.initState();
  }

  ///
  /// 香りデータ入力エリアの表示・非表示設定
  ///
  void _handleVisible() {
    setState(() {
      showPicker = !showPicker;
      if (showPicker) {
        _controller.forward();
        _iconData = Icons.remove;
      } else {
        _controller.reverse();
        _iconData = Icons.add;
      }
    });
  }

  ///
  /// テキストフィールドのフォーカス設定
  ///
  void setFocusScope(BuildContext context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  ///
  /// 日付選択
  /// 日付ピッカー画面を表示して日付を選択する
  ///
  Future<void> selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (selected != null) {
      setState(() {
        _selectDateTime = selected;
        _selectDate.text = (DateFormat.yMd()).format(_selectDateTime);
      });
    }
  }

  ///
  /// ラインチャートデータ作成処理メイン
  ///
  LineChartData mainData() {
    return LineChartData(
      ///
      /// グリッド表示設定
      ///
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      ///
      /// x軸y軸メモリ表示設定
      ///
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        // x軸のメモリ表示(日付)設定
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            for (var item in widget.aromaDataList) {
              if (item.x == value) {
                DateTime time = DateTime.fromMillisecondsSinceEpoch((value * (1000 * 60 * 60 * 24)).toInt());
                return time.month.toString() + "/" + time.day.toString();
              }
            }
            return "";
          },
          margin: 8,
          rotateAngle: 60.0,
        ),
        // y軸のメモリ表示(香りレベル)設定
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 5:
                return '5';
              case 10:
                return '10';
            }
            return '';
          },
          reservedSize: 32,
          margin: 12,
        ),
      ),
      ///
      /// 香りデータのラインチャート表示設定
      ///
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: _startDate,
      maxX: _endDate,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: widget.aromaDataList,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
            gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18),
        ),
        color: Color(0xfff0f0f0),
      ),
      child: Column(
        children: [
          ///
          /// データ入力エリア表示・非表示ボタン
          ///
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            alignment: Alignment.centerLeft,
            child: ButtonTheme(
              child: OutlineButton.icon(
                color: AppThemeColor.baseColor,
                icon: Icon(_iconData,
                  color: AppThemeColor.baseColor,
                ),
                label: const Text('データ入力',
                  style: TextStyle(color: AppThemeColor.baseColor),
                ),
                shape: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppThemeColor.baseColor),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onPressed: _handleVisible,
              ),
            ),
          ),
          ///
          /// データ入力エリア
          ///
          SizeTransition(
            sizeFactor: _controller,
            child: Row(
              children: [
                ///
                /// 日付入力テキストフィールド
                ///
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: GestureDetector(
                      onTap: () => setFocusScope(context),
                      child: TextField(
                        controller: _selectDate,
                        enabled: true,
                        readOnly: true,
                        maxLines: 1,
                        onTap: () => selectDate(context),
                        decoration: const TextFieldDecoration('日付'),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text('香り'),
                ),
                ///
                /// 香りレベル入力ピッカー
                ///
                NumberPicker(
                  itemHeight: 40,
                  itemWidth: 50,
                  value: _currentAromaLevel,
                  minValue: 0,
                  maxValue: 10,
                  onChanged: (value) => setState(() => _currentAromaLevel = value),
                ),
                ///
                /// 香りデータ設定ボタン
                ///
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                  child: RaisedButton(
                    child: const Text('追加'),
                    shape: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentDate = _selectDateTime.millisecondsSinceEpoch / (1000 * 60 * 60 * 24);
                        if (_startDate == 0) _startDate = _currentDate;
                        for (var aroma in widget.aromaDataList) {
                          // 同じ日付があった場合には一度削除してから登録し直す
                          if (aroma.x == _currentDate) {
                            widget.aromaDataList.remove(aroma);
                            break;
                          }
                        }
                        widget.aromaDataList.add(FlSpot(_currentDate, _currentAromaLevel.toDouble()));
                        widget.aromaDataList.sort((left, right) => left.x.compareTo(right.x));
                        _endDate = widget.aromaDataList.last.x;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          ///
          /// ラインチャート表示エリア
          ///
          Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.70,
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18),
                      ),
                      color: Color(0xfff0f0f0)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 18.0, left: 12.0, top: 24, bottom: 12),
                    child: LineChart(mainData()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///
/// テキストフィールドのデコレーション設定
///
class TextFieldDecoration extends InputDecoration {
  const TextFieldDecoration(String text) : super(
    labelText: text,
    hintText: '未入力',
    hintStyle: const TextStyle(color: Color(0xFFC0C0C0)),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    border: const UnderlineInputBorder(),
  );
}
