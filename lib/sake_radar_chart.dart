import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const artColor = Color(0xff63e7e5);
const baseColor = Color(0x44afafaf);

class SakeRadarChart extends StatefulWidget {
  final String title;
  const SakeRadarChart({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SakeRadarChartState();
}

const gridColor = Color(0xff68739f);
const titleColor = Color(0xff8c95db);

class PrimitiveParameter {
  int param;
  PrimitiveParameter({required this.param});
}

class FiveFlavorParameter {
  final PrimitiveParameter _sweetness = PrimitiveParameter(param: 3);
  final PrimitiveParameter _sourness = PrimitiveParameter(param: 3);
  final PrimitiveParameter _pungent = PrimitiveParameter(param: 3);
  final PrimitiveParameter _bitterness = PrimitiveParameter(param: 3);
  final PrimitiveParameter _astringent = PrimitiveParameter(param: 3);
}

class RawDataSet {
  final String title;
  final Color color;
  final List<double> values;

  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });
}

class _SakeRadarChartState extends State<SakeRadarChart> {

  int selectedDataSetIndex = -1;

  FiveFlavorParameter _fiveFlavorParameter = FiveFlavorParameter();

  List<RadarDataSet> showingDataSets(int selectedDataSetIndex) {
    return rawDataSets().asMap().entries.map((entry) {
      var index = entry.key;
      var rawDataSet = entry.value;

      final isSelected = index == selectedDataSetIndex
          ? true
          : selectedDataSetIndex == -1
          ? true
          : false;

      return RadarDataSet(
        fillColor: isSelected
            ? rawDataSet.color.withOpacity(0.2)
            : rawDataSet.color.withOpacity(0.05),
        borderColor:
        isSelected ? rawDataSet.color : rawDataSet.color.withOpacity(0.25),
        entryRadius: isSelected ? 3 : 2,
        dataEntries:
        rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: isSelected ? 2.3 : 2,
      );
    }).toList();
  }

  List<RawDataSet> rawDataSets() {
    return [
      RawDataSet(
        title: widget.title,
        color: artColor,
        values: [
          _fiveFlavorParameter._sweetness.param.toDouble(),
          _fiveFlavorParameter._sourness.param.toDouble(),
          _fiveFlavorParameter._pungent.param.toDouble(),
          _fiveFlavorParameter._bitterness.param.toDouble(),
          _fiveFlavorParameter._astringent.param.toDouble(),
        ],
      ),
      RawDataSet(
        title: '最大',
        color: baseColor,
        values: [
          5,
          5,
          5,
          5,
          5,
        ],
      ),
      RawDataSet(
        title: '最小',
        color: baseColor,
        values: [
          1,
          1,
          1,
          1,
          1,
        ],
      ),
    ];
  }

  Widget roundRaisedButton(IconData icon, StateSetter stateSetter, PrimitiveParameter parameter, int value) {
    return RaisedButton(
      child: Icon(icon),
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      onPressed: () {
        stateSetter(() {
          if ((value < 0 && parameter.param > 1) || (value > 0 && parameter.param < 5)) {
            parameter.param += value;
          }
        });
      },
    );
  }

  Future<FiveFlavorParameter?> showInputDialog(BuildContext context, FiveFlavorParameter params) {
    FiveFlavorParameter _fiveFlavor = FiveFlavorParameter();
    _fiveFlavor = params;

    return showDialog<FiveFlavorParameter>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('AlertDialog Title'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text('甘味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor._sweetness, -1),
                          Text(_fiveFlavor._sweetness.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor._sweetness, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('酸味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor._sourness, -1),
                          Text(_fiveFlavor._sourness.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor._sourness, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('辛味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor._pungent, -1),
                          Text(_fiveFlavor._pungent.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor._pungent, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('苦味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor._bitterness, -1),
                          Text(_fiveFlavor._bitterness.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor._bitterness, 1),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('渋味'),
                          roundRaisedButton(Icons.remove, setState, _fiveFlavor._astringent, -1),
                          Text(_fiveFlavor._astringent.param.toString()),
                          roundRaisedButton(Icons.add, setState, _fiveFlavor._astringent, 1),
                        ],
                      ),
                    ], // コンテンツ
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _fiveFlavor),
                child: const Text('OK'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDataSetIndex = -1;
            });
          },
          child: const Text(
            '五味',
            style: TextStyle(
              color: titleColor,
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rawDataSets()
              .asMap()
              .map((index, value) {
            final isSelected = index ==
                selectedDataSetIndex;
            return MapEntry(
              index,
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDataSetIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(
                      milliseconds: 300),
                  margin: const EdgeInsets.symmetric(
                      vertical: 2),
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? gridColor.withOpacity(0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                        46),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 400),
                        curve: Curves.easeInToLinear,
                        padding: EdgeInsets.all(
                            isSelected ? 8 : 6),
                        decoration: BoxDecoration(
                          color: value.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(
                            milliseconds: 300),
                        curve: Curves.easeInToLinear,
                        style: TextStyle(
                          color: isSelected
                              ? value.color
                              : gridColor,
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
                  touchCallback: (FlTouchEvent event,
                      response) async {
                    if (!event.isInterestedForInteractions) {
                      setState(() {
                        selectedDataSetIndex = -1;
                      });
                      if (response != null) {
                        FiveFlavorParameter? returnParams = await showInputDialog(context, _fiveFlavorParameter);
                        setState(() {
                          if (returnParams != null) {
                            _fiveFlavorParameter = returnParams;
                          }
                        });
                      }
                      return;
                    }
                    setState(() {
                      selectedDataSetIndex =
                          response?.touchedSpot
                              ?.touchedDataSetIndex ?? -1;
                    });
                  }),
              dataSets: showingDataSets(
                  selectedDataSetIndex),
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(
                  color: Colors.transparent),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle:
              const TextStyle(
                  color: titleColor, fontSize: 14),
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
              const TextStyle(color: Colors.transparent,
                  fontSize: 10),
              tickBorderData: const BorderSide(
                  color: Colors.transparent),
              gridBorderData: const BorderSide(
                  color: gridColor, width: 2),
            ),
            swapAnimationDuration: const Duration(
                milliseconds: 400),
          ),
        ),
      ],
    );
  }
}