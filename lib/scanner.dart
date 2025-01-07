import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lastdance_f/decryptData.dart';
import 'package:lastdance_f/home_screen.dart';
import 'package:lastdance_f/student.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner extends StatelessWidget {
  QRScanner({
    required this.setResult,
    this.dio,
    this.secretKey,
    this.serverURL,
    super.key,
  });

  final Function setResult;
  final MobileScannerController controller = MobileScannerController();
  final Dio? dio;
  final String? secretKey;
  final String? serverURL;

  @override
  Widget build(BuildContext context) {
    final effectiveDio = dio ?? Dio();
    final effectiveSecretKey = secretKey ?? dotenv.get("QRCODE_SECRET_KEY");
    final effectiveServerURL = serverURL ?? dotenv.get("FETCH_SERVER_URL");

    return MobileScanner(
      controller: controller,
      onDetect: (BarcodeCapture capture) async {
        final List<Barcode> barcodes = capture.barcodes;

        if (barcodes.isEmpty) return;

        final barcode = barcodes.first;
        if (barcode.rawValue != null) {
          try {
            final decryptedData =
                decryptData(barcode.rawValue!, effectiveSecretKey);

            final student = _decodeStudent(decryptedData);
            final isValid = await _validateStudent(
                student, effectiveDio, effectiveServerURL);

            if (isValid) {
              setResult("로딩 중...");
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(student: student)),
              );
            } else {
              setResult("인증 실패!");
            }
          } catch (e) {
            setResult("Error: ${e.toString()}");
            if (kDebugMode) print(e);
          } finally {
            await controller.stop();
            controller.dispose();
          }
        }
      },
    );
  }

  Student _decodeStudent(String decryptedData) {
    try {
      final codeData = jsonDecode(decryptedData) as Map<String, dynamic>;
      return Student.fromJson(codeData);
    } catch (e) {
      throw Exception("Invalid QR code data format.");
    }
  }

  Future<bool> _validateStudent(
      Student student, Dio dio, String serverURL) async {
    try {
      final response = await dio.get('$serverURL/class/${student.classId}');
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        final int classId = responseData['classId'];
        final Map<String, dynamic> teacherInfo = responseData['id'];
        final int teacherId = teacherInfo['id'];
        final String classCreated = responseData['classCreated'];
        final int yearOfClassCreated = int.parse(classCreated.substring(0, 4));

        return student.classId == classId &&
            student.teacherId == teacherId &&
            student.year == yearOfClassCreated;
      }
    } catch (e) {
      if (kDebugMode) print("Validation error: $e");
    }
    return false;
  }
}
