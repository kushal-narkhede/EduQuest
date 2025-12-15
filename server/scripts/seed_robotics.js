#!/usr/bin/env node

import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import {
  CourseModel,
  ModuleModel,
  AssessmentModel,
  AchievementModel,
} from '../src/models/roboticsModels.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, '../.env');
dotenv.config({ path: envPath });

const MONGODB_URI = process.env.MONGODB_URI;

if (!MONGODB_URI) {
  console.error('MONGODB_URI not set in .env');
  process.exit(1);
}

const seedDatabase = async () => {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing Robotics data
    await CourseModel.deleteMany({});
    await ModuleModel.deleteMany({});
    await AssessmentModel.deleteMany({});
    await AchievementModel.deleteMany({});
    console.log('🗑️ Cleared existing Robotics data');

    // Seed course
    const course = await CourseModel.create({
      title: 'Robotics',
      shortDescription: 'Hands-on introduction to building, programming, and controlling robots.',
      longDescription: 'Comprehensive coverage of mechanical design, electronics, sensing, control, kinematics, ROS, and competitions.',
      audience: 'High school to early undergraduate',
      estimatedDuration: '40–60 hours',
      prerequisites: ['Basic programming', 'Algebra', 'Basic physics'],
      outcomes: [
        'Implement closed-loop control for mobile robots',
        'Model and solve kinematic equations',
        'Integrate sensor fusion',
        'Design and test robot behavior trees',
      ],
      tags: ['Robotics', 'Engineering', 'Hands-on'],
      difficulty: 'Beginner',
      modes: ['Lightning', 'Survival', 'Memory Master', 'Puzzle Quest', 'FRQ'],
      metadata: { version: 1, last_updated: new Date() },
    });
    console.log(`✅ Seeded course: ${course.title}`);

    // Seed modules
    const modules = await ModuleModel.insertMany([
      {
        courseId: course._id,
        title: 'Foundations',
        summary: 'Robot types, components, coordinate frames.',
        tags: ['Fundamentals'],
        difficulty: 'Beginner',
        modes: ['Lightning', 'Memory Master'],
        glossary: [
          { term: 'Actuator', definition: 'Device that converts energy to motion.' },
          { term: 'Sensor', definition: 'Device that measures physical quantities.' },
        ],
        metadata: { version: 1, last_updated: new Date() },
      },
      {
        courseId: course._id,
        title: 'Control',
        summary: 'Open vs closed loop, PID, tuning.',
        tags: ['Control Theory'],
        difficulty: 'Intermediate',
        modes: ['Survival', 'FRQ'],
        metadata: { version: 1, last_updated: new Date() },
      },
    ]);
    console.log(`✅ Seeded ${modules.length} modules`);

    // Seed assessments
    const assessments = await AssessmentModel.insertMany([
      {
        moduleId: modules[0]._id,
        type: 'MCQ',
        prompt: 'Which is an actuator?',
        options: ['Motor', 'Sensor', 'Camera', 'Wire'],
        correct: 'A',
        rationale: {
          correct: 'Motor converts electrical energy to motion.',
          distractors: {
            A: 'Correct',
            B: 'Sensor measures, not actuates.',
            C: 'Sensor, not actuator.',
            D: 'Passive component.',
          },
        },
        tags: { difficulty: 'Beginner', modes: ['Lightning'] },
        metadata: { version: 1, last_updated: new Date() },
      },
      {
        moduleId: modules[1]._id,
        type: 'FRQ',
        prompt: 'Explain PID control and tuning strategies.',
        rubric: {
          criteria: ['Definition', 'Tuning approach', 'Stability'],
          scale: '0-4',
          levels: {
            0: 'No attempt',
            1: 'Partial definition',
            2: 'Definition + some tuning',
            3: 'Clear definition, tuning method, stability discussed',
            4: 'Exemplary with implementation details',
          },
        },
        tags: { difficulty: 'Intermediate', modes: ['FRQ', 'Survival'] },
        metadata: { version: 1, last_updated: new Date() },
      },
    ]);
    console.log(`✅ Seeded ${assessments.length} assessments`);

    // Seed achievements
    const achievements = await AchievementModel.insertMany([
      {
        title: 'Gear Guru',
        description: 'Master mechanics and gearing concepts.',
        points: 100,
        tags: ['Robotics', 'Mechanics'],
        metadata: { version: 1, last_updated: new Date() },
      },
      {
        title: 'Control Sage',
        description: 'Perfect a PID controller.',
        points: 150,
        tags: ['Robotics', 'Control'],
        metadata: { version: 1, last_updated: new Date() },
      },
    ]);
    console.log(`✅ Seeded ${achievements.length} achievements`);

    console.log('🌱 Seed data import complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed error:', error);
    process.exit(1);
  }
};

seedDatabase();
