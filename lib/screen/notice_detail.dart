// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:lastdance_f/model/notice_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class NoticeDetailPage extends StatefulWidget {
  final dynamic noticeId;

  const NoticeDetailPage({super.key, required this.noticeId});

  @override
  State<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  static bool isInitialized = false;
  NoticeModel _noticeModel = NoticeModel();
  List<dynamic> noticeList = [];

  @override
  void initState() {
    super.initState();
    _loadNoticeDetail();
    if (!isInitialized) {
      FlutterDownloader.initialize(debug: true);
      isInitialized = true;
    }
  }

  void _loadNoticeDetail() async {
    List<dynamic> noticeData = await _noticeModel.searchNoticeDetail(widget.noticeId);
    setState(() {
      noticeList = noticeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (noticeList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("공지사항"),
          backgroundColor: Color(0xffF4F4F4),
          shape: const Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              )),
        ),
        backgroundColor: Color(0xffF4F4F4),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final notice = noticeList[0];
    String formattedCreateAt = _formatDate(notice['createdAt']);
    String formattedUpdatedAt = _formatDate(notice['updatedAt']);

    String displayDate = "";
    if (notice['updatedAt'] != null &&
        notice['updatedAt'].isNotEmpty &&
        notice['createdAt'] != notice['updatedAt']) {
      formattedUpdatedAt = _formatDate(notice['updatedAt']);
      displayDate = "수정일: $formattedUpdatedAt";
    } else {
      formattedCreateAt = _formatDate(notice['createdAt']);
      displayDate = "작성일: $formattedCreateAt";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("공지사항"),
        backgroundColor: Color(0xffF4F4F4),
        shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            )),
      ),
      backgroundColor: Color(0xffF4F4F4),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${notice['noticeTitle']}",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                if (notice['noticeFile'] != null)
                  ElevatedButton.icon(
                    onPressed: () async {
                      String fileUrl =
                          "http://112.221.66.174:6892/download${notice['noticeFile']}";
                      await _downloadFile(fileUrl, context);
                    },
                    icon: Icon(Icons.file_download),
                    label: Text("첨부 파일"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  ),
              ],
            ),
            Text(displayDate ,style: TextStyle(fontSize: 12),),
            Text("${notice['noticeCategory']}", style: TextStyle(fontSize: 14,color: Colors.orangeAccent),),
            SizedBox(height: 8),
            Container(
              width: 393,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color(0xFFB8B8B8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // 이미지 섬네일 표시
            if (notice['noticeImg'] != null && notice['noticeImg'].isNotEmpty)
              Image.network(
                "http://112.221.66.174:6892${notice['noticeImg']}",
                fit: BoxFit.fill,
                width: double.infinity,
                height: 300,
              ),
            SizedBox(height: 10),

            Text("${notice['noticeContent']}",style: TextStyle(fontSize: 20),),
            SizedBox(height: 10),

            if (notice['noticeFile'] != null && notice['noticeFile'].isNotEmpty)
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  getFileName(getFileName(notice['noticeFile'])),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted) {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs == null || externalDirs.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('외부 저장소를 찾을 수 없습니다.')));
          return;
        }

        final downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: downloadsDirectory.path,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('다운로드가 완료되었습니다.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('저장소 권한을 허용해주세요.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('파일 다운로드 중 오류가 발생했습니다: $e')));
    }
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    return formattedDate;
  }

  String getFileName(String filePath) {
    String fileName = filePath.split('/').last;

    String processedFileName;
    if (fileName.contains('%')) {
      processedFileName = Uri.encodeFull(fileName);
    } else {
      processedFileName = fileName;
    }

    int underscoreIndex = processedFileName.indexOf('_');
    if (underscoreIndex != -1) {
      return processedFileName.substring(underscoreIndex + 1);
    } else {
      return processedFileName;
    }
  }
}
