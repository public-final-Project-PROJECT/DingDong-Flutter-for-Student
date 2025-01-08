import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lastdance_f/decryptData.dart';
import 'package:lastdance_f/student.dart';
import 'package:lastdance_f/auth_succeeded.dart';
import 'package:lastdance_f/auth_failed.dart';

class QRScanner extends StatelessWidget {
  QRScanner({
    this.dio,
    this.secretKey,
    this.serverURL,
    super.key,
  });

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
            final result = decryptData(barcode.rawValue!, effectiveSecretKey);

            if (result.isSuccess) {
              final student = _decodeStudent(result.data!);
              final isValid = await _validateStudent(
                  student, effectiveDio, effectiveServerURL);

              if (isValid) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => AuthSucceeded(student: student)),
                );
              }
            } else {
              _redirectToAuthFailed(context);
            }
          } catch (e) {
            _redirectToAuthFailed(context);
          } finally {
            await controller.stop();
            controller.dispose();
          }
        }
      },
    );
  }

  void _redirectToAuthFailed(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthFailed()),
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
      throw Exception("Validation error.");
    }
    return false;
  }
}
