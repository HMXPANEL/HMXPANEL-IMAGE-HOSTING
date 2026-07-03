import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveImageToGallery(String url) async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  await Dio().download(url, path);
  await ImageGallerySaverPlus.saveFile(path);
  await File(path).delete();
}
