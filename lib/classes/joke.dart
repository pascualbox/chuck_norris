import 'package:norris/utilities/urls.dart';

class Joke {
  final String icon;
  final String value;
  final String id;
  final String url;

  const Joke({
    required this.icon,
    required this.value,
    required this.id,
    required this.url,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      icon: "${NorrisUrls.avatars}${json['id']}.jpg",
      value: json['value'].toString(),
      id: json['id'].toString(),
      url: json['url'].toString(),
    );
  }
}
