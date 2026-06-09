import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'ai_platform_service.dart';

class AiDiagnosisService {
  final AiPlatformService platform;

  const AiDiagnosisService(this.platform);

  Future<AiDailyDiagnosis?> generateDaily(AiDailyInput input) async {
    final json = await _post('/v1/diagnoses/daily', input.toJson());
    if (json == null) return null;
    try {
      return AiDailyDiagnosis.fromJson(_resultMap(json));
    } catch (_) {
      return null;
    }
  }

  Future<AiMonthlyDiagnosis?> generateMonthly(AiMonthlyInput input) async {
    final json = await _post('/v1/diagnoses/monthly', input.toJson());
    if (json == null) return null;
    try {
      return AiMonthlyDiagnosis.fromJson(_resultMap(json));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _resultMap(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! Map) throw const FormatException('Missing result.');
    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>?> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final credentials = await platform.requestCredentials();
    if (credentials == null) return null;

    final base = aiApiBaseUrl.endsWith('/')
        ? aiApiBaseUrl.substring(0, aiApiBaseUrl.length - 1)
        : aiApiBaseUrl;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.postUrl(Uri.parse('$base$path'));
      request.headers.contentType = ContentType.json;
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${credentials.idToken}',
      );
      final appCheckToken = credentials.appCheckToken;
      if (appCheckToken != null) {
        request.headers.set('X-Firebase-AppCheck', appCheckToken);
      }
      request.write(jsonEncode(body));

      final response = await request.close().timeout(
        const Duration(seconds: 25),
      );
      final responseBody = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'AI diagnosis request failed: ${response.statusCode} $responseBody',
        );
        return null;
      }
      final decoded = jsonDecode(responseBody);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on Object catch (error, stackTrace) {
      debugPrint('AI diagnosis request error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    } finally {
      client.close(force: true);
    }
  }
}

class AiAspectInput {
  final String leading;
  final String trailing;
  final String type;
  final double orb;

  const AiAspectInput({
    required this.leading,
    required this.trailing,
    required this.type,
    required this.orb,
  });

  Map<String, dynamic> toJson() => {
    'leading': leading,
    'trailing': trailing,
    'type': type,
    'orb': orb,
  };
}

class AiPlanLine {
  final String label;
  final String body;

  const AiPlanLine(this.label, this.body);

  factory AiPlanLine.fromJson(Map<String, dynamic> json) {
    return AiPlanLine(json['label'] as String, json['body'] as String);
  }

  Map<String, dynamic> toJson() => {'label': label, 'body': body};
}

class AiDailyInput {
  final String date;
  final String profileKey;
  final int score;
  final String monthlyRank;
  final String tone;
  final AiAspectInput? heroAspect;
  final String positionSeed;
  final String aspectSeed;
  final String actionSeed;
  final List<AiPlanLine> timePlan;
  final List<String> checklist;

  const AiDailyInput({
    required this.date,
    required this.profileKey,
    required this.score,
    required this.monthlyRank,
    required this.tone,
    required this.heroAspect,
    required this.positionSeed,
    required this.aspectSeed,
    required this.actionSeed,
    required this.timePlan,
    required this.checklist,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'profile_key': profileKey,
    'score': score,
    'monthly_rank': monthlyRank,
    'tone': tone,
    'hero_aspect': heroAspect?.toJson(),
    'position_seed': positionSeed,
    'aspect_seed': aspectSeed,
    'action_seed': actionSeed,
    'time_plan': timePlan.map((line) => line.toJson()).toList(),
    'checklist': checklist,
  };
}

class AiDailyDiagnosis {
  final String position;
  final String aspect;
  final String action;
  final List<AiPlanLine> timePlan;
  final List<String> checklist;

  const AiDailyDiagnosis({
    required this.position,
    required this.aspect,
    required this.action,
    required this.timePlan,
    required this.checklist,
  });

  factory AiDailyDiagnosis.fromJson(Map<String, dynamic> json) {
    return AiDailyDiagnosis(
      position: json['position'] as String,
      aspect: json['aspect'] as String,
      action: json['action'] as String,
      timePlan: (json['time_plan'] as List)
          .map(
            (item) =>
                AiPlanLine.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      checklist: (json['checklist'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'position': position,
    'aspect': aspect,
    'action': action,
    'time_plan': timePlan.map((line) => line.toJson()).toList(),
    'checklist': checklist,
  };
}

class AiMonthlyInput {
  final String month;
  final int averageScore;
  final int bestDay;
  final int bestScore;
  final int carefulDay;
  final int carefulScore;
  final List<Map<String, dynamic>> weeks;
  final List<Map<String, dynamic>> highlights;

  const AiMonthlyInput({
    required this.month,
    required this.averageScore,
    required this.bestDay,
    required this.bestScore,
    required this.carefulDay,
    required this.carefulScore,
    required this.weeks,
    required this.highlights,
  });

  Map<String, dynamic> toJson() => {
    'month': month,
    'average_score': averageScore,
    'best_day': bestDay,
    'best_score': bestScore,
    'careful_day': carefulDay,
    'careful_score': carefulScore,
    'weeks': weeks,
    'highlights': highlights,
  };
}

class AiMonthlyDiagnosis {
  final String title;
  final List<AiMonthlyBlock> blocks;

  const AiMonthlyDiagnosis({required this.title, required this.blocks});

  factory AiMonthlyDiagnosis.fromJson(Map<String, dynamic> json) {
    return AiMonthlyDiagnosis(
      title: json['title'] as String,
      blocks: (json['blocks'] as List)
          .map(
            (item) =>
                AiMonthlyBlock.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'blocks': blocks.map((block) => block.toJson()).toList(),
  };
}

class AiMonthlyBlock {
  final String title;
  final String body;

  const AiMonthlyBlock({required this.title, required this.body});

  factory AiMonthlyBlock.fromJson(Map<String, dynamic> json) {
    return AiMonthlyBlock(
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'body': body};
}
