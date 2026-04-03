import 'package:url_launcher/url_launcher.dart';
import 'data.dart';

class AmazonUtils {
  static Future<void> launch(String query) async {
    final sanitizedQuery = Uri.encodeComponent(query);
    final url = 'https://www.amazon.in/s?k=$sanitizedQuery&tag=${TripData.amazonTag}';
    
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}
