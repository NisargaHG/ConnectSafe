import 'api_service.dart';

class AIService {
  AIService._();

  static final AIService instance = AIService._();

  final ApiService _api = ApiService.instance;

  Future<Map<String, dynamic>> getAIRouting(
      int messageId,
      ) async {
    final response = await _api.post(
      'ai-routing/$messageId/',
      {},
    );

    return Map<String, dynamic>.from(response);
  }
}