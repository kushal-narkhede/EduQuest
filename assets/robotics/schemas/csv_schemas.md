# CSV Schemas

## study_sets.csv
- id,title,description,tags.module,tags.lesson,tags.difficulty,tags.estimatedTime,tags.modes,items
- items format: `type|front|back` separated by `;`

## mcq_bank.csv
- id,module,lesson,difficulty,cognitive_level,stem,optionA,optionB,optionC,optionD,correct,rationale_correct,rationale_A,rationale_B,rationale_C,rationale_D,modes,flags
- modes: `Lightning|Survival`
- flags: `fifty_fifty_eligible:true|false`

## concept_checks.csv
- id,module,lesson,difficulty,prompt,expected,rubric_conceptPresence,rubric_clarity,rubric_keyTerms,memory_master_eligible

## frq_bank.csv
- id,module,lesson,type,difficulty,prompt,rubric_criteria,rubric_scale,rubric_levels_json,ai_keywords,ai_steps,ai_common_errors,powerUps_skip,powerUps_doublePoints,powerUps_timeFreeze,modes_survivalEligible
- `rubric_levels_json`: JSON string of level descriptors

## coding_frq.csv
- id,module,lesson,difficulty,language,prompt,starterCode,test1_name,test1_input_json,test1_expected_json,test2_name,test2_input_json,test2_expected_json,test3_name,test3_input_json,test3_expected_json,edge_name,edge_input_json,edge_expected_json,rubric_criteria,rubric_scale

## problem_sets.csv
- id,module,lesson,difficulty,prompt,solution,tags_application,tags_puzzleQuestEligible

## treasure_map.csv
- id,campaign,theme,node_id,node_type,required_score,reward_points,reward_powerUps_json,links_module,links_type,difficulty,lore

## puzzle_assets.csv
- id,module,puzzle_title,pieces_count,image_path,mask_paths_json,unlock_sequence_json,reward_text,link_item_ids_json,difficulty,theme
