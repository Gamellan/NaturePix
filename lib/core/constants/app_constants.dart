import '../../constants.dart';

class AppConstants {
  AppConstants._();

  static const String unsplashBaseUrl = 'https://api.unsplash.com';

  // Keep AdMob integration identical to WaifuPix.
  static const String admobAppId =
      'ca-app-pub-6761615013970031~1035279446';
  static const String bannerAdUnitId =
      'ca-app-pub-6761615013970031/9918600075';
  static const String interstitialAdUnitId =
      'ca-app-pub-6761615013970031/8530626083';

  static const int interstitialFrequency = 3;
  static const int pageSize = 20;

  static const List<Map<String, String>> sortingOptions = [
    {'key': 'forest waterfall', 'label': 'forest waterfall', 'icon': '*'},
    {'key': 'mountain sunset landscape', 'label': 'mountain sunset landscape', 'icon': '*'},
    {'key': 'ocean waves beach', 'label': 'ocean waves beach', 'icon': '*'},
    {'key': 'cherry blossom spring', 'label': 'cherry blossom spring', 'icon': '*'},
    {'key': 'northern lights aurora', 'label': 'northern lights aurora', 'icon': '*'},
    {'key': 'desert golden hour', 'label': 'desert golden hour', 'icon': '*'},
  ];

  static const List<String> popularTags = AppConfig.categories;
  static const String appName = AppConfig.appName;
}



