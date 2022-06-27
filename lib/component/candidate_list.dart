import 'package:flutter/material.dart';
import 'package:growing_sake/util/app_theme_color.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:growing_sake/model/brand.dart';
import 'package:growing_sake/model/brewery.dart';
import 'package:growing_sake/model/area.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert' show json;
@JsonSerializable()

///
/// 日本酒銘柄一覧ウィジェット
/// さけのわAPIを利用して日本酒の銘柄を取得する
///
class CandidateListWidget extends StatefulWidget {
  // 選択された銘柄名
  final arguments;
  const CandidateListWidget({Key? key, required this.arguments}) : super(key: key);

  @override
  State<CandidateListWidget> createState() => _CandidateListState();
}

class _CandidateListState extends State<CandidateListWidget> {
  final _focusNode = FocusNode();

  // 銘柄名の初期値
  List<String> _defaultParams = [];
  // 全銘柄名のリスト
  List<Brand> allBrands = [];
  // 検索銘柄名のリスト
  List<Brand> searchBrands = [];
  // 酒舗リスト
  List<Brewery> breweries = [];
  // 地域リスト
  List<Area> areas = [];
  // 日本酒銘柄名
  String? _title = '';
  // テキストフィールドのカーソル位置をコントロールする
  final TextEditingController? _nameController = TextEditingController();

  // 選択された銘柄に対する酒舗と地域の結果
  Map<String, String> result = {};

  ///
  /// さけのわAPIを利用して銘柄、酒舗、地域の一覧を取得
  ///
  Future<List<Brand>> fetchBrands() async {
    List<Brand> brands = [];

    final brandUrl = http.get(Uri.parse('https://muro.sakenowa.com/sakenowa-data/api/brands')).timeout(const Duration(seconds: 5));
    final breweryUrl = http.get(Uri.parse('https://muro.sakenowa.com/sakenowa-data/api/breweries')).timeout(const Duration(seconds: 5));
    final areaUrl = http.get(Uri.parse('https://muro.sakenowa.com/sakenowa-data/api/areas')).timeout(const Duration(seconds: 5));
    final futureWait = Future.wait([brandUrl, breweryUrl, areaUrl]);
    final response = await futureWait;

    for (final data in response) {
      if (data.statusCode == 200) {
        Map<String, dynamic> decodeJson = json.decode(data.body);
        if (decodeJson['brands'] != null) {
          List<dynamic> list = decodeJson['brands'];
          for (var element in list) {brands.add(Brand.fromJson(element));}
        } else if (decodeJson['breweries'] != null) {
          List<dynamic> list = decodeJson['breweries'];
          for (var element in list) {breweries.add(Brewery.fromJson(element));}
        } else if (decodeJson['areas'] != null) {
          List<dynamic> list = decodeJson['areas'];
          for (var element in list) {areas.add(Area.fromJson(element));}
        }
      } else {
        throw Exception('Failed to load brand');
      }
    }

    return brands;
  }

  ///
  /// 入力された文字列で日本酒銘柄をフィルタする処理
  ///
  void _runFilter(String enteredKeyword) {
    List<Brand> results = [];
    if (enteredKeyword.isEmpty) {
      results = allBrands;
    } else {
      results = allBrands
          .where((list) =>
          list.name.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    }

    // Refresh the UI
    setState(() {
      searchBrands = results;
    });
  }

  @override
  void initState() {
    super.initState();
    _defaultParams = widget.arguments;
    _title = _defaultParams[0];
    _nameController!.text = _defaultParams[1];
    result['brand'] = '';
    result['brewery'] = '';
    result['area'] = '';
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        result['brand'] = _nameController!.text;
        Navigator.of(context).pop(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // フォーカスを外す方でpopするので戻るボタンは無効化する
        _focusNode.unfocus();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('銘柄名一覧'),
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            ///
            /// 日本酒銘柄検索用テキストフィールド
            ///
            Container(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  final FocusScopeNode currentScope = FocusScope.of(context);
                  if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                    FocusManager.instance.primaryFocus!.unfocus();
                  }
                },
                child: TextField(
                  enabled: true,
                  autofocus: true,
                  maxLines: 1,
                  focusNode: _focusNode,
                  controller: _nameController,
                  onChanged: (value) {
                    _runFilter(value);
                  },
                  decoration: const InputDecoration(
                    hintText: '未記入',
                    hintStyle: TextStyle(color: Color(0xFFC0C0C0)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
            ),
            ///
            /// 日本酒銘柄一覧表示リスト
            /// 文字列検索でフィルタされた一覧を表示する
            ///
            Flexible(child:
              FutureBuilder<List<Brand>> (
                future: fetchBrands(),
                builder: (BuildContext context, AsyncSnapshot<List<Brand>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    allBrands = snapshot.data!;
                    return ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return _candidateItem(searchBrands[index]);
                      },
                      itemCount: searchBrands.length,
                    );
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: const Text("さけのわデータ",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 255)),
                    ),
                    onTap: () async {
                      if (await canLaunch("https://sakenowa.com")) {
                        await launch("https://sakenowa.com");
                      }
                    },
                  ),
                  const Text("を利用しています"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 日本酒銘柄項目作成
  /// 一覧に表示する日本酒銘柄名の表示と対応する酒舗と地域を保持する
  ///
  Widget _candidateItem(Brand brand) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
      ),
      child:ListTile(
        title: Text(
          brand.name,
          style: const TextStyle(
              color:Colors.black,
              fontSize: 18.0
          ),
        ),
        onTap: () {
          result.clear();
          _nameController!.text = brand.name;
          _nameController!.selection = TextSelection.fromPosition(TextPosition(offset: _nameController!.text.length));
          result['brand'] = brand.name;
          for (var brewery in breweries) {
            if (brewery.id == brand.breweryId) {
              result['brewery'] = brewery.name;
              for (var area in areas) {
                if (area.id == brewery.areaId) {
                  result['area'] = area.name;
                  break;
                }
              }
              break;
            }
          }
        }, // タップ
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
