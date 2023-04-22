import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class QuranService {
  final String apiUrl = "https://api.quran.com/chapters/{chapter_id}/verses";
  final String cacheKey = 'quran_data';
  final int cacheExpirationHours = 24; // Cache expiration time in hours
  final String logFileName = 'quran_app.log'; // Log file name

  // Logger for logging requests and errors
  Logger logger = Logger('QuranApp');

  // Fetch verses data for the selected chapter from the quran.com REST API
  Future<List<Map<String, dynamic>>> fetchVerses(int chapterId) async {
    // Check if data is available in cache
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      final decodedData = jsonDecode(cachedData);
      final timestamp = decodedData['timestamp'];
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceLastFetch = (now - timestamp) ~/ (1000 * 60 * 60); // Convert milliseconds to hours
      if (hoursSinceLastFetch < cacheExpirationHours) {
        // Data is still valid, return cached data
        logger.fine('Fetching verses data from cache');
        return decodedData['data'];
      }
    }

    // Data is not available in cache or has expired, fetch from API
    final url = '$apiUrl/chapters/$chapterId/verses';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Update cache with fetched data and timestamp
        final dataToCache = {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'data': responseData['verses'],
        };
        prefs.setString(cacheKey, jsonEncode(dataToCache));
        logger.fine('Fetched verses data from API and updated cache');
        return responseData['verses'];
      } else {
        logger.warning('Failed to fetch verses data from API. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch verses data from API');
      }
    } catch (e) {
      logger.warning('Failed to fetch verses data from API: $e');
      throw Exception('Failed to fetch verses data from API');
    }
  }

  // Get the log file path
  Future<String> getLogFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$logFileName';
  }

  // Initialize logger for logging requests and errors
  void initLogger() async {
    final logFilePath = await getLogFilePath();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      final logMessage = '${record.time}: ${record.level.name}: ${record.message}';
      File(logFilePath).writeAsString(logMessage, mode: FileMode.append);
    });
  }
}
