import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:growing_sake/brand.dart';
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
  String? _title = '';
  final TextEditingController? _nameController = TextEditingController();

  Future<List<Brand>> fetchBrands() async {
    final response = await http.get(Uri.parse('https://muro.sakenowa.com/sakenowa-data/api/brands')).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      List<Brand> brands = [];
      Map<String, dynamic> decodeJson = json.decode(response.body);
      List<dynamic> brandList = decodeJson['brands'];
      brandList.forEach((element) {
        brands.add(Brand.fromJson(element));
      });
      return brands;
    } else {
      throw Exception('Failed to load brand');
    }
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
          IconButton(onPressed: () {Navigator.of(context).pop(_nameController!.text);}, icon: const Icon(Icons.check)),
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
                setState(() {
                  _nameController!.text = value;
                });
              },
              decoration: InputDecoration(
                labelText: _title,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                filled: true,
                fillColor: Colors.blue.shade100,
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
                      return _candidateItem(searchBrands[index].name);
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

  Widget _candidateItem(String title) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))
      ),
      child:ListTile(
        title: Text(
          title,
          style: const TextStyle(
              color:Colors.black,
              fontSize: 18.0
          ),
        ),
        onTap: () {
          _nameController!.text = title;
        }, // タップ
      ),
    );
  }
}
