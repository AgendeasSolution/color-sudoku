class GameModel {
  final String name;
  final String image;
  final String playstoreUrl;
  final String appstoreUrl;

  GameModel({
    required this.name,
    required this.image,
    required this.playstoreUrl,
    required this.appstoreUrl,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      name: json['name'] as String,
      image: json['image'] as String,
      playstoreUrl: json['playstore_url'] as String,
      appstoreUrl: json['appstore_url'] as String,
    );
  }
}

class GamesResponse {
  final bool success;
  final int count;
  final List<GameModel> data;

  GamesResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory GamesResponse.fromJson(Map<String, dynamic> json) {
    return GamesResponse(
      success: json['success'] as bool,
      count: json['count'] as int,
      data: (json['data'] as List<dynamic>)
          .map((item) => GameModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

