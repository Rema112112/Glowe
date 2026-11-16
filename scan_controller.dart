import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:glowe/services/image_scanner_service.dart';
import 'package:glowe/services/barcode_scanner_service.dart';
import 'package:glowe/screens/analysis_result_screen.dart';

class ScanController {
  final ImageScannerService _imageService = ImageScannerService();
  final BarcodeScannerService _barcodeService = BarcodeScannerService();
  final ImagePicker _picker = ImagePicker();

  // Railway backend URL
  static const String baseUrl =
      'https://glowebackend-production.up.railway.app';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 60);

  // --------------------------------------------------
  // 1. INGREDIENT ANALYSIS (OCR, BARCODE, OR TEXT)
  // --------------------------------------------------
// Add this flag at the top of your ScanController class:
  bool _isPicking = false;

  // --------------------------------------------------
  // 3. PICK AND COMPRESS FACE IMAGE
  // --------------------------------------------------


  Future<Map<String, dynamic>> analyzeIngredients(String scannedText) async {
    if (scannedText.trim().isEmpty) {
      throw Exception('No ingredient text was provided.');
    }

    final url = Uri.parse('$baseUrl/analyze');

    try {
      debugPrint('Sending ingredient analysis request...');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'prompt': scannedText.trim()}),
          )
          .timeout(requestTimeout);

      debugPrint('Ingredient status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected response format from backend.');
        }

        // Support both direct JSON and wrapped JSON responses.
        if (decoded['response'] is String) {
          final nested = jsonDecode(decoded['response']);

          if (nested is Map<String, dynamic>) {
            return nested;
          }

          throw Exception('Invalid nested analysis response.');
        }

        return decoded;
      }

      throw Exception(
        'Ingredient analysis failed '
        '(${response.statusCode}): ${response.body}',
      );
    } on SocketException {
      throw Exception('No internet connection. Please try again.');
    } on HttpException {
      throw Exception('Could not communicate with Glowe server.');
    } on FormatException {
      throw Exception('The server returned an invalid JSON response.');
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('Ingredient analysis error: $e');
      throw Exception('Unexpected analysis error: $e');
    }
  }

 // --------------------------------------------------
  // 2. FACE SKIN ANALYSIS (IMAGE UPLOAD)
  // --------------------------------------------------

  Future<Map<String, dynamic>> analyzeSkin(File imageFile) async {
    if (!await imageFile.exists()) {
      throw Exception('Selected image could not be found.');
    }

    final url = Uri.parse('$baseUrl/analyze-skin');

    try {
      debugPrint('Starting skin analysis...');

      final result = await (() async {
        final request = http.MultipartRequest('POST', url);

        request.headers['Accept'] = 'application/json';

        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

        debugPrint('Image attached: ${request.files.length}');

        final streamedResponse = await request.send();

        return await http.Response.fromStream(streamedResponse);
      })().timeout(requestTimeout);

      debugPrint('Skin analysis status: ${result.statusCode}');

      if (result.statusCode == 200) {
        final decoded = jsonDecode(result.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected skin analysis response format.');
        }

        // Handle case where backend might wrap the JSON string inside a 'response' key
        if (decoded['response'] is String) {
          final nested = jsonDecode(decoded['response']);
          if (nested is Map<String, dynamic>) {
            return nested;
          }
        }

        // Return the decoded map directly
        return decoded;
      }

      throw Exception(
        'Skin analysis failed '
        '(${result.statusCode}): ${result.body}',
      );
    } on SocketException {
      throw Exception('No internet connection. Please try again.');
    } on HttpException {
      throw Exception('Could not communicate with Glowe server.');
    } on FormatException {
      throw Exception('Invalid response received from the server.');
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('Skin analysis error: $e');
      throw Exception('Unexpected skin analysis error: $e');
    }
  }
  // --------------------------------------------------
  // 3. PICK AND COMPRESS FACE IMAGE
  // --------------------------------------------------

Future<File?> pickImageForSkinAnalysis(ImageSource source) async {
    if (_isPicking) return null; // Prevents overlapping calls if double-tapped

    _isPicking = true;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Image selection error: $e');
      return null; // Gracefully catch the exception instead of crashing the app
    } finally {
      _isPicking = false; // Always unlock when finished
    }
  }
  Future<void> scanLabelWithCamera(BuildContext context) async {
    final String? extractedText = await _imageService.scanTextFromCamera();

    if (extractedText != null &&
        extractedText.trim().isNotEmpty &&
        context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(
            queryOrText: extractedText,
            type: AnalysisType.imageOcr,
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // 5. OCR - GALLERY
  // --------------------------------------------------

  Future<void> scanLabelFromGallery(BuildContext context) async {
    final String? extractedText = await _imageService.scanTextFromGallery();

    if (extractedText != null &&
        extractedText.trim().isNotEmpty &&
        context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(
            queryOrText: extractedText,
            type: AnalysisType.imageOcr,
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // 6. BARCODE SCANNER
  // --------------------------------------------------

  Future<void> scanBarcode(BuildContext context) async {
    await _barcodeService.scanBarcode(context);
  }
}
