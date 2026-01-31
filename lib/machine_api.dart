import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mock_data.dart';

class MachineApiService {
  static const String baseUrl = "http://10.0.2.2:5000";

  static Future<List<MachineData>> fetchMachines() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/getSlotDetails"),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map((json) => MachineData.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load machines");
    }
  }
}
