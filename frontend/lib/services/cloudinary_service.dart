import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'dpfxtypn2',       // 👈 à remplacer
    'senDomicile_v2',    // 👈 à remplacer
    cache: false,
  );


  Future<String?> uploadImage(File file) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('❌ Erreur upload Cloudinary: $e');
      return null;
    }
  }
}
