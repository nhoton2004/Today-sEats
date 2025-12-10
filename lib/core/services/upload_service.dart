import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Upload image to S3 via backend
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/dishes/upload/image'),
      );

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'url': data['url'],
          'key': data['key'],
        };
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Upload image from bytes (for web)
  Future<Map<String, dynamic>> uploadImageBytes(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/dishes/upload/image'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'url': data['url'],
          'key': data['key'],
        };
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
