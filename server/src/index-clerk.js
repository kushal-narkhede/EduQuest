import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { clerkClient, ClerkExpressRequireAuth } from '@clerk/clerk-sdk-node';
import clerkAuthRoutes from './routes/clerkAuth.js';
import User from './models/User.js';

// Load environment variables - try default location first
dotenv.config();

// If that didn't work, try explicit path
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, '../.env');
if (!process.env.CLERK_SECRET_KEY) {
  console.log('[Debug] Trying explicit path:', envPath);
  dotenv.config({ path: envPath });
}

console.log('[Debug] Environment loaded. Has CLERK_SECRET_KEY:', !!process.env.CLERK_SECRET_KEY);

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI;
const CLERK_SECRET_KEY = process.env.CLERK_SECRET_KEY;

// Validate environment variables
if (!MONGODB_URI) {
  console.error('[Startup] MONGODB_URI is missing');
  process.exit(1);
}

if (!CLERK_SECRET_KEY) {
  console.error('[Startup] CLERK_SECRET_KEY is missing. Get it from https://dashboard.clerk.com');
  process.exit(1);
}

// Connect to MongoDB
mongoose
  .connect(MONGODB_URI, { serverSelectionTimeoutMS: 8000 })
  .then(() => console.log('MongoDB connected'))
  .catch((err) => {
    console.error('Mongo connect error', err.message);
    process.exit(1);
  });

// Helper to get or create user in MongoDB based on Clerk user
const ensureUserFromClerk = async (clerkUserId, username) => {
  let user = await User.findOne({ clerkId: clerkUserId });
  if (!user) {
    // Create new user linked to Clerk
    user = await User.create({
      clerkId: clerkUserId,
      username: username,
      passwordHash: '', // Not needed with Clerk
    });
    console.log('[User] Created new user from Clerk:', username);
  }
  return user;
};

// Middleware to extract Clerk user and sync with MongoDB
const syncClerkUser = async (req, res, next) => {
  try {
    if (req.auth && req.auth.userId) {
      const clerkUser = await clerkClient.users.getUser(req.auth.userId);
      const username = clerkUser.username || clerkUser.emailAddresses[0]?.emailAddress.split('@')[0] || 'user';
      req.user = await ensureUserFromClerk(req.auth.userId, username);
      req.username = username;
    }
    next();
  } catch (error) {
    console.error('[Sync] Error syncing Clerk user:', error);
    next();
  }
};

// Root endpoint
app.get('/', (req, res) => {
  res.send('EduQuest API with Clerk is running!');
});

// Health check
app.get('/health', (req, res) => {
  res.json({ ok: true, uptime: process.uptime(), auth: 'clerk' });
});

// Clerk authentication routes
app.use('/auth/clerk', clerkAuthRoutes);

// Public endpoint - no auth required
app.get('/public/info', (req, res) => {
  res.json({ message: 'This is a public endpoint' });
});

// Protected routes - require Clerk authentication
app.use(ClerkExpressRequireAuth(), syncClerkUser);

// POINTS
app.get('/users/:username/points', async (req, res) => {
  try {
    const { username } = req.params;
    const user = await ensureUserFromClerk(req.auth.userId, username);
    return res.json({ points: user.points || 0 });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.put('/users/:username/points', async (req, res) => {
  try {
    const { username } = req.params;
    const { points } = req.body;
    if (typeof points !== 'number') return res.status(400).json({ error: 'points must be number' });
    const user = await ensureUserFromClerk(req.auth.userId, username);
    user.points = Math.max(0, Math.trunc(points));
    await user.save();
    return res.json({ points: user.points });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// THEME
app.get('/users/:username/theme', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    return res.json({ theme: user.currentTheme || 'space' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.put('/users/:username/theme', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const { theme } = req.body;
    if (!theme) return res.status(400).json({ error: 'Missing theme' });
    if (!user.themesOwned.includes(theme)) user.themesOwned.push(theme);
    user.currentTheme = theme;
    await user.save();
    return res.json({ theme: user.currentTheme });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.get('/users/:username/themes', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const themes = Array.from(new Set(['space', ...user.themesOwned]));
    return res.json({ themes });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/themes/purchase', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const { theme } = req.body;
    if (!theme) return res.status(400).json({ error: 'Missing theme' });
    if (!user.themesOwned.includes(theme)) user.themesOwned.push(theme);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// POWERUPS
app.get('/users/:username/powerups', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const map = {};
    for (const [k, v] of user.powerups.entries()) {
      map[k] = v;
    }
    return res.json({ powerups: map });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/powerups/purchase', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const { powerupId } = req.body;
    if (!powerupId) return res.status(400).json({ error: 'Missing powerupId' });
    const current = user.powerups.get(powerupId) || 0;
    user.powerups.set(powerupId, current + 1);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/powerups/use', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const { powerupId } = req.body;
    if (!powerupId) return res.status(400).json({ error: 'Missing powerupId' });
    const current = user.powerups.get(powerupId) || 0;
    if (current <= 0) return res.status(400).json({ error: 'No powerups left' });
    if (current - 1 > 0) user.powerups.set(powerupId, current - 1);
    else user.powerups.delete(powerupId);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// IMPORTED SETS
app.get('/users/:username/imported-sets', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const sets = user.importedSets.map((name) => ({ name }));
    return res.json({ sets });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/imported-sets', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const { setName } = req.body;
    if (!setName) return res.status(400).json({ error: 'Missing setName' });
    if (!user.importedSets.includes(setName)) user.importedSets.push(setName);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.delete('/users/:username/imported-sets/:setName', async (req, res) => {
  try {
    const user = await ensureUserFromClerk(req.auth.userId, req.params.username);
    const { setName } = req.params;
    user.importedSets = user.importedSets.filter((n) => n !== setName);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.listen(PORT, () => {
  console.log(`API with Clerk authentication listening on :${PORT}`);
  console.log(`Clerk integration enabled`);
});
