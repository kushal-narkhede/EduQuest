import 'dart:convert';
import 'package:flutter/services.dart';

class RoboticsAssetsLoader {
  static const String assetsPath = 'assets/robotics';

  static Future<Map<String, dynamic>> loadCurriculum() async {
    final json = await rootBundle.loadString('$assetsPath/curriculum.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadMCQBank() async {
    final json = await rootBundle.loadString('$assetsPath/mcq_bank.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadConceptChecks() async {
    final json = await rootBundle.loadString('$assetsPath/concept_checks.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadFRQBank() async {
    final json = await rootBundle.loadString('$assetsPath/frq_bank.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadCodingFRQ() async {
    final json = await rootBundle.loadString('$assetsPath/coding_frq.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadProblemSets() async {
    final json = await rootBundle.loadString('$assetsPath/problem_sets.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadStudySets() async {
    final json = await rootBundle.loadString('$assetsPath/study_sets.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadMemoryMasterCards() async {
    final json = await rootBundle.loadString('$assetsPath/memory_master_cards.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadChapters() async {
    final json = await rootBundle.loadString('$assetsPath/chapters.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadReadings() async {
    final json = await rootBundle.loadString('$assetsPath/readings.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadLabs() async {
    final json = await rootBundle.loadString('$assetsPath/labs.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadCodingExercises() async {
    final json = await rootBundle.loadString('$assetsPath/coding_exercises.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadCompetitionsPrep() async {
    final json = await rootBundle.loadString('$assetsPath/competitions_prep.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadTreasureHunt() async {
    final json = await rootBundle.loadString('$assetsPath/treasure_hunt.json');
    return jsonDecode(json);
  }

  static Future<Map<String, dynamic>> loadTagVocabularies() async {
    final json = await rootBundle.loadString('$assetsPath/schemas/tag_vocabularies.json');
    return jsonDecode(json);
  }

  // Loads all assets in batch; useful for cache/preload scenarios
  static Future<Map<String, Map<String, dynamic>>> loadAll() async {
    return {
      'curriculum': await loadCurriculum(),
      'mcq_bank': await loadMCQBank(),
      'concept_checks': await loadConceptChecks(),
      'frq_bank': await loadFRQBank(),
      'coding_frq': await loadCodingFRQ(),
      'problem_sets': await loadProblemSets(),
      'study_sets': await loadStudySets(),
      'memory_master': await loadMemoryMasterCards(),
      'chapters': await loadChapters(),
      'readings': await loadReadings(),
      'labs': await loadLabs(),
      'coding_exercises': await loadCodingExercises(),
      'competitions_prep': await loadCompetitionsPrep(),
      'treasure_hunt': await loadTreasureHunt(),
      'tag_vocabularies': await loadTagVocabularies(),
    };
  }
}
