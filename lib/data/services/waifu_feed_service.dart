import 'dart:math';

import 'package:dio/dio.dart';

import '../../constants.dart';
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

class WaifuFeedService {
  final Dio _dio;
  final Map<String, List<WallpaperModel>> _pageCache = {};

  WaifuFeedService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.unsplashBaseUrl,
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'User-Agent': '${AppConfig.appName} Android/1.0',
              'Accept': 'application/json',
            },
          ),
        );

  Future<List<WallpaperModel>> getWallpapers({
    String sorting = '',
    String? query,
    int page = 1,
  }) async {
    final normalizedQuery = query?.trim() ?? '';
    final category = _normalizeCategory(sorting);
    final effectiveQuery = normalizedQuery.isNotEmpty ? normalizedQuery : category;

    final cacheKey = '$effectiveQuery|$page';
    final cached = _pageCache[cacheKey];
    if (cached != null) return cached;

    final fetched = await _fetchUnsplash(query: effectiveQuery);
    _pageCache[cacheKey] = fetched;
    return fetched;
  }

  String _normalizeCategory(String sorting) {
    final s = sorting.trim().toLowerCase();
    return AppConfig.categories.firstWhere(
      (c) => c.toLowerCase() == s,
      orElse: () => AppConfig.categories.first,
    );
  }

  Future<List<WallpaperModel>> _fetchUnsplash({required String query}) async {
    final out = <WallpaperModel>[];
    var attempts = 0;

    while (out.length < AppConstants.pageSize && attempts < 6) {
      attempts++;
      final remaining = AppConstants.pageSize - out.length;
      final count = min(remaining, 20);

      try {
        final response = await _dio.get(
          '/photos/random',
          queryParameters: {
            'query': query,
            'orientation': 'portrait',
            'count': count,
            'client_id': AppConfig.unsplashAccessKey,
          },
        );

        final data = response.data;
        final list = data is List ? data : [data];

        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          if (AppConfig.filterLightImages && _isLightHexColor((item['color'] ?? '').toString())) {
            continue;
          }
          final model = _mapUnsplash(item);
          if (model.path.isNotEmpty && out.every((e) => e.path != model.path)) {
            out.add(model);
          }
        }
      } on DioException {
        break;
      }
    }

    return List<WallpaperModel>.unmodifiable(out);
  }

  bool _isLightHexColor(String hex) {
    if (!hex.startsWith('#') || hex.length != 7) return false;
    try {
      final r = int.parse(hex.substring(1, 3), radix: 16);
      final g = int.parse(hex.substring(3, 5), radix: 16);
      final b = int.parse(hex.substring(5, 7), radix: 16);
      final brightness = (r + g + b) / 3;
      return brightness > 100;
    } catch (_) {
      return false;
    }
  }

  String _withUtm(String? rawUrl) {
    final base = rawUrl?.trim() ?? '';
    if (base.isEmpty) return '';
    final sep = base.contains('?') ? '&' : '?';
    return '$base${sep}utm_source=${AppConfig.utmSource}&utm_medium=referral';
  }

  WallpaperModel _mapUnsplash(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final urls = (json['urls'] as Map<String, dynamic>?) ?? const {};
    final links = (json['links'] as Map<String, dynamic>?) ?? const {};
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final userLinks = (user['links'] as Map<String, dynamic>?) ?? const {};

    final path = (urls['full'] ?? urls['regular'] ?? '').toString();
    final thumbLarge = (urls['regular'] ?? urls['small'] ?? path).toString();
    final thumbSmall = (urls['thumb'] ?? urls['small'] ?? thumbLarge).toString();

    final width = (json['width'] as num?)?.toInt() ?? 0;
    final height = (json['height'] as num?)?.toInt() ?? 0;
    final artistName = (user['name'] ?? '').toString();

    return WallpaperModel(
      id: 'unsplash_$id',
      path: path,
      thumbLarge: thumbLarge,
      thumbSmall: thumbSmall,
      width: width,
      height: height,
      resolution: (width > 0 && height > 0) ? '${width}x$height' : '',
      views: 0,
      favorites: (json['likes'] as num?)?.toInt() ?? 0,
      colors: [
        (json['color'] ?? '').toString(),
      ].where((c) => c.isNotEmpty).toList(),
      fileType: 'image/jpeg',
      createdAt: (json['created_at'] ?? '').toString(),
      sourcePlatform: 'Unsplash',
      sourceUrl: _withUtm((links['html'] ?? '').toString()),
      artistName: artistName,
      artistProfile: _withUtm((userLinks['html'] ?? '').toString()),
      copyrightNotice: 'Photo by $artistName on Unsplash',
      tags: const [],
    );
  }
}
