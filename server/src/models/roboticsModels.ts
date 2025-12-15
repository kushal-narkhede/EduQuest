import mongoose, { Schema, Document } from 'mongoose';

export interface BaseMeta {
  version: number;
  last_updated: Date;
}

export interface Taggable {
  tags: string[]; // domain/subtopic etc.
  difficulty: 'Beginner' | 'Intermediate' | 'Advanced';
  modes: string[]; // Lightning | Survival | Memory Master | Puzzle Quest | Treasure Hunt | FRQ
}

export interface CourseDoc extends Document, Taggable {
  title: string;
  shortDescription: string;
  longDescription: string;
  audience: string;
  estimatedDuration: string;
  prerequisites: string[];
  outcomes: string[];
  metadata: BaseMeta;
}

const CourseSchema = new Schema<CourseDoc>({
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

export const CourseModel = mongoose.model<CourseDoc>('Course', CourseSchema);

export interface ModuleDoc extends Document, Taggable {
  courseId: mongoose.Types.ObjectId;
  title: string;
  summary: string;
  glossary: { term: string; definition: string }[];
  metadata: BaseMeta;
}

const ModuleSchema = new Schema<ModuleDoc>({
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

export const ModuleModel = mongoose.model<ModuleDoc>('Module', ModuleSchema);

export interface AssessmentDoc extends Document, Taggable {
  moduleId: mongoose.Types.ObjectId;
  type: 'MCQ' | 'Concept' | 'FRQ' | 'CodingFRQ' | 'ProblemSet' | 'Treasure';
  prompt: string;
  options?: string[];
  correctAnswer?: string;
  rubric?: any;
  rationale?: any;
  powerUps?: Record<string, boolean>;
  metadata: BaseMeta;
}

const AssessmentSchema = new Schema<AssessmentDoc>({
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

export const AssessmentModel = mongoose.model<AssessmentDoc>('Assessment', AssessmentSchema);

export interface StudySetDoc extends Document, Taggable {
  title: string;
  description: string;
  items: { type: 'term' | 'formula' | 'qa'; front: string; back: string }[];
  metadata: BaseMeta;
}

const StudySetSchema = new Schema<StudySetDoc>({
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

export const StudySetModel = mongoose.model<StudySetDoc>('StudySet', StudySetSchema);

export interface GameAssetDoc extends Document {
  kind: 'Puzzle' | 'TreasureMap' | 'Image' | 'Mask';
  path?: string;
  data?: any;
  tags: string[];
  metadata: BaseMeta;
}

const GameAssetSchema = new Schema<GameAssetDoc>({
  kind: { type: String, required: true },
  path: String,
  data: Schema.Types.Mixed,
  tags: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const GameAssetModel = mongoose.model<GameAssetDoc>('GameAsset', GameAssetSchema);

export interface AchievementDoc extends Document {
  title: string;
  description: string;
  points: number;
  tags: string[];
  metadata: BaseMeta;
}

const AchievementSchema = new Schema<AchievementDoc>({
  title: { type: String, required: true },
  description: String,
  points: { type: Number, default: 0 },
  tags: [String],
  metadata: {
    version: { type: Number, default: 1 },
    last_updated: { type: Date, default: () => new Date() },
  },
}, { timestamps: true });

export const AchievementModel = mongoose.model<AchievementDoc>('Achievement', AchievementSchema);
