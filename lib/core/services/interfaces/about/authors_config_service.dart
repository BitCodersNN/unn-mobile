import 'package:unn_mobile/core/models/about/author.dart';

abstract interface class AuthorsConfigService {
  Future<Map<String, List<Author>>?> getAuthors();
}
