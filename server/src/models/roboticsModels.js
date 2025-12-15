import mongoose, { Schema } from 'mongoose';

const CourseSchema = new Schema({
  title: { type: String, required: true },
  shortDescription: String,
  longDescription: String,
  audience: String,
  estimatedDuration: String,
  prerequisites: [String],
  outcomes: [String],
  tags: [String],
  difficulty: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], default: 'Beginner' },
  modes: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const CourseModel = mongoose.model('Course', CourseSchema);

const ModuleSchema = new Schema({
  courseId: { type: Schema.Types.ObjectId, ref: 'Course', required: true },
  title: { type: String, required: true },
  summary: String,
  glossary: [{ term: String, definition: String }],
  tags: [String],
  difficulty: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], default: 'Beginner' },
  modes: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const ModuleModel = mongoose.model('Module', ModuleSchema);

const AssessmentSchema = new Schema({
  moduleId: { type: Schema.Types.ObjectId, ref: 'Module', required: true },
  type: { type: String, required: true },
  prompt: { type: String, required: true },
  options: [String],
  correctAnswer: String,
  rubric: Schema.Types.Mixed,
  rationale: Schema.Types.Mixed,
  powerUps: Schema.Types.Mixed,
  tags: [String],
  difficulty: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], default: 'Beginner' },
  modes: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const AssessmentModel = mongoose.model('Assessment', AssessmentSchema);

const StudySetSchema = new Schema({
  title: { type: String, required: true },
  description: String,
  items: [{ type: { type: String }, front: String, back: String }],
  tags: [String],
  difficulty: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced'], default: 'Beginner' },
  modes: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const StudySetModel = mongoose.model('StudySet', StudySetSchema);

const GameAssetSchema = new Schema({
  kind: { type: String, required: true },
  path: String,
  data: Schema.Types.Mixed,
  tags: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const GameAssetModel = mongoose.model('GameAsset', GameAssetSchema);

const AchievementSchema = new Schema({
  title: { type: String, required: true },
  description: String,
  points: { type: Number, default: 0 },
  tags: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const AchievementModel = mongoose.model('Achievement', AchievementSchema);
