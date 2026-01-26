import mongoose from 'mongoose';

const PowerupsSchema = new mongoose.Schema({}, { strict: false, _id: false });

const FriendRequestSchema = new mongoose.Schema({
  fromUsername: String,
  toUsername: String,
  status: { type: String, enum: ['pending', 'accepted', 'declined'], default: 'pending' },
  createdAt: { type: Date, default: Date.now }
}, { _id: false });

const MessageSchema = new mongoose.Schema({
  id: { type: String, default: () => Math.random().toString(36).substr(2, 9) },
  type: { type: String, enum: ['system', 'friend_request', 'direct_message'], default: 'system' },
  fromUsername: String,
  subject: String,
  content: String,
  isRead: { type: Boolean, default: false },
  isArchived: { type: Boolean, default: false },
  metadata: mongoose.Schema.Types.Mixed, // for storing extra info like request ID
  createdAt: { type: Date, default: Date.now }
}, { _id: false });

const QuestionHistorySchema = new mongoose.Schema({
  questionId: String,
  course: String,
  chapter: String,
  isCorrect: Boolean,
  timestamp: { type: Date, default: Date.now },
  timeSpent: Number, // seconds
  reviewDate: Date, // for spaced repetition
  easeFactor: { type: Number, default: 2.5 }, // for spaced repetition
  interval: { type: Number, default: 1 }, // days until next review
  repetitions: { type: Number, default: 0 }
}, { _id: false });

const UserSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true, index: true },
    // email: { type: String, required: true, unique: true, index: true }, // REMOVED: Email no longer required
    passwordHash: { type: String, required: true },
    points: { type: Number, default: 0 },
    currentTheme: { type: String, default: 'space' },
    themesOwned: { type: [String], default: ['space'] },
    powerups: { type: Map, of: Number, default: {} },
    importedSets: { type: [String], default: [] },
    friendList: { type: [String], default: [] }, // list of friend usernames
    friendRequests: { type: [FriendRequestSchema], default: [] }, // incoming + outgoing
    inbox: { type: [MessageSchema], default: [] },
    blockedUsers: { type: [String], default: [] },
    lastSeen: { type: Date, default: Date.now },
    // Study progress tracking
    studyProgress: { type: Map, of: Map, default: {} }, // course -> chapter -> progress data
    questionHistory: { type: [QuestionHistorySchema], default: [] },
    bookmarkedQuestions: { type: [String], default: [] }, // question IDs
    weakAreas: { type: Map, of: [String], default: {} } // course -> array of weak chapter names
  },
  { timestamps: true }
);

export default mongoose.model('User', UserSchema);
