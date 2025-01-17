import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lastdance_f/decrypt_data.dart';
import 'package:lastdance_f/student.dart';
import 'package:lastdance_f/screen/auth_succeeded.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

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
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
                await _storeQRData(result.data!); // Store QR data for skipping login
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
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("앗"),
          content: const Text(
            "QR 코드 인식에 실패했어요.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("확인"),
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
