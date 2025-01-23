// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:lastdance_f/decrypt_data.dart';
import 'package:lastdance_f/main.dart';
import 'package:lastdance_f/screen/auth_succeeded.dart';
import 'package:lastdance_f/student.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ignore: must_be_immutable
class QRScanner extends StatelessWidget {
  QRScanner({
    this.dio,
    this.secretKey,
    super.key,
  });

  final MobileScannerController controller = MobileScannerController();
  final Dio? dio;
  final String? secretKey;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _studentAdded = false;

  String getServerURL() {
    return kIsWeb
        ? dotenv.env['FETCH_SERVER_URL2']!
        : dotenv.env['FETCH_SERVER_URL']!;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDio = dio ?? Dio();
    final effectiveSecretKey = secretKey ?? dotenv.get("QRCODE_SECRET_KEY");
    String effectiveServerURL = getServerURL();

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
                await _storeQRData(result.data!);
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => AuthSucceeded(student: student)),
                );
              } else {
                _showAuthFailedDialog(context);
              }
            } else {
              _showAuthFailedDialog(context);
            }
          } catch (e) {
            _showAuthFailedDialog(context);
          } finally {
            await controller.stop();
            controller.dispose();
          }
        }
      },
    );
  }

  Future<void> _storeQRData(String qrData) async {
    final DateTime nextMarch = DateTime(DateTime.now().year + 1, 3, 1);
    final String expirationDate = DateFormat('yyyy-MM-dd').format(nextMarch);
    await storage.write(key: 'qrData', value: qrData);
    await storage.write(key: 'expirationDate', value: expirationDate);
  }

  void _showAuthFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "앗!",
            style: TextStyle(fontFamily: "NamuL"),
          ),
          content: const Text(
            "QR 코드 인식에 실패했어요.",
            style: TextStyle(fontSize: 16, fontFamily: "NamuL"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MyApp())),
              // Close the dialog
              child: const Text(
                "확인",
                style: TextStyle(fontFamily: "NamuL"),
              ),
            ),
          ],
        );
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

        if (!_studentAdded) {
          await _addStudent(student, dio, serverURL, classId);
        }

        return student.classId == classId &&
            student.teacherId == teacherId &&
            student.year == yearOfClassCreated;
      }
    } catch (e) {
      throw Exception("Validation error.");
    }
    return false;
  }

  Future<void> _addStudent(
      Student student, Dio dio, String serverURL, int classId) async {
    if (_studentAdded) return;

    try {
      _studentAdded = true;
      await dio.post('$serverURL/api/students/add', queryParameters: {
        'studentNo': student.studentInfo.studentNo,
        'studentName': student.studentInfo.studentName,
        'classId': classId,
      });
    } catch (e) {
      throw Exception("ERROR in addStudent: $e");
    }
  }
}
