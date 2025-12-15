import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'robotics_assets_loader.dart';

class RoboticsValidator {
  static const List<String> validDifficulties = ['Beginner', 'Intermediate', 'Advanced'];
  static const List<String> validCognitiveLevels = ['recall', 'concept', 'application'];
  static const List<String> validModes = [
    'Lightning',
    'Survival',
    'Memory Master',
    'Puzzle Quest',
    'Treasure Hunt',
    'FRQ'
  ];
  static const List<String> validDomains = [
    'Foundations',
    'Mechanics',
    'Electronics',
    'Sensors',
    'Control',
    'Programming',
    'Kinematics',
    'ROS',
    'Mobile Robots',
    'Manipulators',
    'Vision',
    'Autonomy',
    'Safety & Ethics',
    'Competition Prep'
  ];

  static List<String> validatePayload(Map<String, dynamic> payload) {
    final issues = <String>[];

    // Course validation
    if (payload['course'] != null) {
      issues.addAll(_validateCourse(payload['course']));
    }

    // Modules validation
    if (payload['modules'] is List) {
      for (int i = 0; i < (payload['modules'] as List).length; i++) {
        issues.addAll(_validateModule((payload['modules'] as List)[i], i));
      }
    }

    // Assessments validation
    if (payload['assessments'] is List) {
      for (int i = 0; i < (payload['assessments'] as List).length; i++) {
        issues.addAll(_validateAssessment((payload['assessments'] as List)[i], i));
      }
    }

    return issues;
  }

  static List<String> _validateCourse(Map<String, dynamic> course) {
    final issues = <String>[];
    if (course['title'] == null) issues.add('Course: missing title');
    if (course['outcomes'] == null || (course['outcomes'] as List).isEmpty) {
      issues.add('Course: missing or empty outcomes');
    }
    if (course['metadata'] == null || course['metadata']['version'] == null) {
      issues.add('Course: missing metadata.version');
    }
    return issues;
  }

  static List<String> _validateModule(Map<String, dynamic> module, int index) {
    final issues = <String>[];
    if (module['title'] == null) issues.add('Module[$index]: missing title');
    if (module['tags'] == null || (module['tags'] as Map).isEmpty) {
      issues.add('Module[$index]: missing tags');
    } else {
      if (module['tags']['difficulty'] == null || !validDifficulties.contains(module['tags']['difficulty'])) {
        issues.add('Module[$index]: invalid or missing difficulty');
      }
      if (module['tags']['modes'] == null || (module['tags']['modes'] as List).isEmpty) {
        issues.add('Module[$index]: missing or empty modes');
      }
      if (module['tags']['domains'] == null || (module['tags']['domains'] as List).isEmpty) {
        issues.add('Module[$index]: missing or empty domains');
      }
    }
    return issues;
  }

  static List<String> _validateAssessment(Map<String, dynamic> assessment, int index) {
    final issues = <String>[];
    final id = assessment['id'] ?? 'Unknown';

    // Required fields
    if (assessment['module'] == null) issues.add('Assessment[$id]: missing module');
    if (assessment['lesson'] == null) issues.add('Assessment[$id]: missing lesson');
    if (assessment['prompt'] == null) issues.add('Assessment[$id]: missing prompt');
    if (assessment['type'] == null) issues.add('Assessment[$id]: missing type');

    final type = assessment['type'];

    // MCQ-specific validations
    if (type == 'MCQ') {
      if (assessment['options'] == null || (assessment['options'] as List).length < 4) {
        issues.add('Assessment[$id]: MCQ must have ≥4 options');
      }
      if (assessment['correct'] == null) issues.add('Assessment[$id]: MCQ missing correct answer');
      if (assessment['rationale'] == null) {
        issues.add('Assessment[$id]: MCQ missing rationale');
      } else {
        if (assessment['rationale']['correct'] == null) {
          issues.add('Assessment[$id]: MCQ rationale missing correct explanation');
        }
      }
    }

    // FRQ-specific validations
    if (type == 'FRQ') {
      if (assessment['rubric'] == null) {
        issues.add('Assessment[$id]: FRQ missing rubric');
      } else {
        final rubric = assessment['rubric'];
        if (rubric['criteria'] == null || (rubric['criteria'] as List).length < 3) {
          issues.add('Assessment[$id]: FRQ rubric must have ≥3 criteria');
        }
        if (rubric['levels'] == null || (rubric['levels'] as Map).isEmpty) {
          issues.add('Assessment[$id]: FRQ rubric missing level descriptors');
        }
      }
    }

    // Coding FRQ-specific validations
    if (type == 'CodingFRQ') {
      if (assessment['tests'] == null || (assessment['tests'] as List).length < 3) {
        issues.add('Assessment[$id]: CodingFRQ must have ≥3 tests');
      } else {
        bool hasEdgeCase = (assessment['tests'] as List).any((t) => t['name'] != null && t['name'].toString().toLowerCase().contains('edge'));
        if (!hasEdgeCase) {
          issues.add('Assessment[$id]: CodingFRQ missing edge case test');
        }
      }
    }

    // Tags validation
    if (assessment['tags'] != null) {
      final tags = assessment['tags'];
      if (tags['difficulty'] != null && !validDifficulties.contains(tags['difficulty'])) {
        issues.add('Assessment[$id]: invalid difficulty');
      }
      if (tags['modes'] is List) {
        for (final mode in tags['modes']) {
          if (!validModes.contains(mode)) {
            issues.add('Assessment[$id]: invalid mode: $mode');
          }
        }
      }
    }

    return issues;
  }
}

class RoboticsRepository {
  final Map<String, dynamic> _cache = {};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _cache.addAll(await RoboticsAssetsLoader.loadAll());
    _loaded = true;
  }

  Map<String, dynamic> getCurriculum() => _cache['curriculum'] ?? {};
  Map<String, dynamic> getMCQBank() => _cache['mcq_bank'] ?? {};
  Map<String, dynamic> getConceptChecks() => _cache['concept_checks'] ?? {};
  Map<String, dynamic> getFRQBank() => _cache['frq_bank'] ?? {};
  Map<String, dynamic> getCodingFRQ() => _cache['coding_frq'] ?? {};
  Map<String, dynamic> getProblemSets() => _cache['problem_sets'] ?? {};
  Map<String, dynamic> getStudySets() => _cache['study_sets'] ?? {};
  Map<String, dynamic> getMemoryMasterCards() => _cache['memory_master'] ?? {};
  Map<String, dynamic> getChapters() => _cache['chapters'] ?? {};
  Map<String, dynamic> getReadings() => _cache['readings'] ?? {};
  Map<String, dynamic> getLabs() => _cache['labs'] ?? {};
  Map<String, dynamic> getCodingExercises() => _cache['coding_exercises'] ?? {};
  Map<String, dynamic> getCompetitionsPrep() => _cache['competitions_prep'] ?? {};
  Map<String, dynamic> getTreasureHunt() => _cache['treasure_hunt'] ?? {};

  List<Map<String, dynamic>> getAssessmentsByModule(String module, {String? type, String? difficulty}) {
    final mcqBank = getMCQBank();
    final frqBank = getFRQBank();
    final allItems = <Map<String, dynamic>>[];

    if (mcqBank['items'] is List) {
      allItems.addAll((mcqBank['items'] as List).cast<Map<String, dynamic>>());
    }
    if (frqBank['items'] is List) {
      allItems.addAll((frqBank['items'] as List).cast<Map<String, dynamic>>());
    }

    return allItems.where((item) {
      if (item['module'] != module) return false;
      if (type != null && item['type'] != type) return false;
      if (difficulty != null && item['difficulty'] != difficulty) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> filterByMode(List<Map<String, dynamic>> items, String mode) {
    return items.where((item) {
      if (item['modes'] is List) {
        return (item['modes'] as List).contains(mode);
      }
      return false;
    }).toList();
  }
}
