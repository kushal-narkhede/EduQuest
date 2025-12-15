import test from 'ava';
import { RoboticsValidator } from '../helpers/robotics_validator';

test('MCQ without rationale fails validation', (t) => {
  const mcq = {
    id: 'test-1',
    module: 'Control',
    lesson: 'PID',
    type: 'MCQ',
    prompt: 'What is PID?',
    options: ['A', 'B', 'C', 'D'],
    correct: 'A',
    // Missing rationale
    tags: { difficulty: 'Beginner', modes: ['Lightning'] },
  };

  const issues = RoboticsValidator.validateAssessment(mcq);
  t.true(issues.some((i) => i.includes('rationale')));
});

test('FRQ with <3 criteria fails validation', (t) => {
  const frq = {
    id: 'test-2',
    module: 'Control',
    lesson: 'PID',
    type: 'FRQ',
    prompt: 'Explain PID.',
    rubric: { criteria: ['correctness'], levels: { 0: 'Wrong', 1: 'Ok' } },
    tags: { difficulty: 'Intermediate', modes: ['FRQ'] },
  };

  const issues = RoboticsValidator.validateAssessment(frq);
  t.true(issues.some((i) => i.includes('≥3 criteria')));
});

test('CodingFRQ without edge case test fails validation', (t) => {
  const coding = {
    id: 'test-3',
    module: 'Programming',
    lesson: 'Python',
    type: 'CodingFRQ',
    prompt: 'Write a loop.',
    tests: [
      { name: 'basic', input: {}, expected: {} },
      { name: 'large', input: {}, expected: {} },
    ],
    tags: { difficulty: 'Beginner', modes: ['Lightning'] },
  };

  const issues = RoboticsValidator.validateAssessment(coding);
  t.true(issues.some((i) => i.includes('edge case')));
});

test('Valid MCQ passes validation', (t) => {
  const mcq = {
    id: 'test-4',
    module: 'Mechanics',
    lesson: 'Gears',
    type: 'MCQ',
    prompt: 'Which increases torque?',
    options: ['High ratio', 'Low ratio', 'Direct', 'Belt'],
    correct: 'A',
    rationale: {
      correct: 'High ratio multiplies torque.',
      distractors: { A: 'Correct', B: 'Reduces torque', C: 'No gain', D: 'Variable' },
    },
    tags: { difficulty: 'Beginner', modes: ['Lightning'] },
  };

  const issues = RoboticsValidator.validateAssessment(mcq);
  t.is(issues.length, 0);
});
