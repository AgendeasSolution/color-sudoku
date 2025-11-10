import 'dart:io';
import 'package:flutter/material.dart';

class FgtpApp {
  final String name;
  final String imageUrl;
  final String playstoreUrl;
  final String appstoreUrl;

  FgtpApp({
    required this.name,
    required this.imageUrl,
    required this.playstoreUrl,
    required this.appstoreUrl,
  });

  factory FgtpApp.fromJson(Map<String, dynamic> json) {
    return FgtpApp(
      name: json['name'] as String,
      imageUrl: json['image'] as String,
      playstoreUrl: json['playstore_url'] as String,
      appstoreUrl: json['appstore_url'] as String,
    );
  }

  List<String> get availableStoreUrls => [playstoreUrl, appstoreUrl];

  String? primaryStoreUrl(TargetPlatform platform) {
    if (platform == TargetPlatform.iOS) {
      return appstoreUrl;
    } else if (platform == TargetPlatform.android) {
      return playstoreUrl;
    }
    return null;
  }
}

