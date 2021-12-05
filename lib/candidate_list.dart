import 'package:flutter/material.dart';
import 'package:growing_sake/app_theme_color.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:growing_sake/brand.dart';
import 'package:growing_sake/brewery.dart';
import 'package:growing_sake/area.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert' show json;
@JsonSerializable()

class CandidateListWidget extends StatefulWidget {
  final arguments;
  const CandidateListWidget({Key? key, required this.arguments}) : super(key: key);

  @override
  State<CandidateListWidget> createState() => _CandidateListState();
}

class _CandidateListState extends State<CandidateListWidget> {
  List<String> _defaultParams = [];
  List<Brand> allBrands = [];
  List<Brand> searchBrands = [];
  List<Brewery> breweries = [];
  List<Area> areas = [];
  String? _title = '';
  final TextEditingController? _nameController = TextEditingController();

  Map<String, String> result = {};

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sake Detail'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(onPressed: () {Navigator.of(context).pop(result);}, icon: const Icon(Icons.check)),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              enabled: true,
              maxLines: 1,
              controller: _nameController,
              onChanged: (value) {
                _runFilter(value);
              },
              decoration: InputDecoration(
                labelText: _title,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                filled: true,
                fillColor: AppThemeColor.baseColor.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),

              ),
            ),
          ),
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
        ],
      ),
    );
  }

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
}
