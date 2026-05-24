import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/presentation/body_composition_providers.dart';
import '../../sphere_ai/presentation/ai_chat_providers.dart';
import 'recovery_providers.dart';

part 'recovery_ai_providers.g.dart';

class AiInsight {
  const AiInsight({required this.recovery, required this.nutrition, this.context = ''});
  final List<String> recovery;
  final List<String> nutrition;
  final String context;
}

@riverpod
Future<AiInsight> recoveryAiInsight(RecoveryAiInsightRef ref) async {
  final bodyComp = ref.watch(myBodyCompositionProvider).valueOrNull ?? [];
  final latest = bodyComp.isNotEmpty ? bodyComp.first : null;
  final todayLog = ref.watch(todayRecoveryLogProvider).valueOrNull;

  final bmi = latest?.bmi;
  final weightKg = latest?.weightKg;
  final bodyFatPct = latest?.bodyFatPct;
  final wellnessScore = todayLog?.wellnessScore;

  final bmiStr = bmi?.toStringAsFixed(1) ?? 'unknown';
  final bmiCategory = bmi == null
      ? ''
      : bmi < 18.5
          ? 'underweight'
          : bmi < 25.0
              ? 'normal weight'
              : bmi < 30.0
                  ? 'overweight'
                  : 'obese';

  final contextLine = [
    if (bmi != null) 'BMI $bmiStr',
    if (wellnessScore != null) 'wellness ${wellnessScore}%',
  ].join(' · ');

  final prompt = '''You are a sports recovery and nutrition specialist for football/futsal players. Give brief, practical, sport-specific advice based on this player's biometrics:

BMI: $bmiStr${bmiCategory.isNotEmpty ? ' ($bmiCategory)' : ''}
${weightKg != null ? 'Weight: ${weightKg.toStringAsFixed(1)} kg' : ''}
${bodyFatPct != null ? 'Body fat: ${bodyFatPct.toStringAsFixed(1)}%' : ''}
${wellnessScore != null ? 'Today wellness score: $wellnessScore%' : 'No wellness check-in logged today — use general guidance'}

Reply in this EXACT format only — no preamble, no markdown, no extra text:
RECOVERY:
• [concise tip]
• [concise tip]
• [concise tip]
NUTRITION:
• [concise tip]
• [concise tip]
• [concise tip]''';

  final repo = ref.watch(aiChatRepositoryProvider);
  final stream = repo.streamMessage(
    messages: [
      {'role': 'user', 'text': prompt}
    ],
    threadId: 'recovery-${DateTime.now().millisecondsSinceEpoch}',
    surface: 'club',
  );

  final buffer = StringBuffer();
  await for (final chunk in stream) {
    buffer.write(chunk);
  }

  return _parseInsight(buffer.toString(), contextLine);
}

AiInsight _parseInsight(String raw, String context) {
  final recovery = <String>[];
  final nutrition = <String>[];
  var inRecovery = false;
  var inNutrition = false;

  for (final line in raw.split('\n')) {
    final t = line.trim();
    if (t.toUpperCase().startsWith('RECOVERY:')) {
      inRecovery = true;
      inNutrition = false;
      continue;
    }
    if (t.toUpperCase().startsWith('NUTRITION:')) {
      inNutrition = true;
      inRecovery = false;
      continue;
    }
    if (t.startsWith('•') || t.startsWith('-') || t.startsWith('*')) {
      final text = t.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim();
      if (text.isEmpty) continue;
      if (inRecovery) recovery.add(text);
      else if (inNutrition) nutrition.add(text);
    }
  }

  return AiInsight(recovery: recovery, nutrition: nutrition, context: context);
}
