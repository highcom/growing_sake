import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:growing_sake/app_theme_color.dart';
import 'package:numberpicker/numberpicker.dart';

class SakeLineChart extends StatefulWidget {
  const SakeLineChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SakeLineChartState();
}

class _SakeLineChartState extends State<SakeLineChart> with SingleTickerProviderStateMixin {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showPicker = false;
  late AnimationController _controller;
  IconData _iconData = Icons.add;

  List<FlSpot> aromaDataList = [];
  late DateTime _selectDateTime;
  final TextEditingController _selectDate = TextEditingController();
  int _currentDate = 0;
  int _currentAromaLevel = 1;

  @override
  void initState() {
    Intl.defaultLocale = 'ja_JP';
    initializeDateFormatting();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // aromaDataList.add(const FlSpot(0, 3));
    super.initState();
  }

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

  void setFocusScope(BuildContext context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

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

  LineChartData mainData() {
    return LineChartData(
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
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'MAR';
              case 5:
                return 'JUN';
              case 8:
                return 'SEP';
            }
            return '';
          },
          margin: 8,
        ),
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
              case 1:
                return '10k';
              case 3:
                return '30k';
              case 5:
                return '50k';
            }
            return '';
          },
          reservedSize: 32,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: aromaDataList,
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
          color: Color(0xffa9c6fd)),
      child: Column(
        children: [
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
          SizeTransition(
            sizeFactor: _controller,
            child: Row(
              children: [
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
                        decoration: TextFieldDecoration('日付'),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text('香り'),
                ),
                NumberPicker(
                  itemHeight: 40,
                  itemWidth: 50,
                  value: _currentAromaLevel,
                  minValue: 0,
                  maxValue: 10,
                  onChanged: (value) => setState(() => _currentAromaLevel = value),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                  child: RaisedButton(
                    child: const Text('追加'),
                    color: AppThemeColor.baseColor.shade50,
                    shape: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    onPressed: () {
                      aromaDataList.add(FlSpot(_currentDate.toDouble(), _currentAromaLevel.toDouble()));
                      // TODO:日付の初期位置からの相対位置を計算する
                      _currentDate++;
                    },
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.70,
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18),
                      ),
                      color: Color(0xffa9c6fd)),
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

class TextFieldDecoration extends InputDecoration {
  TextFieldDecoration(String text) : super(
    labelText: text,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: AppThemeColor.baseColor.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
