import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveImageToGallery(String url) async {
  final dir = await getTemporaryDirectory();
  final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  await Dio().download(url, path);
  await Gal.putImage(path);
  await File(path).delete();
}
