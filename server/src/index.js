import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import bcrypt from 'bcryptjs';
import nodemailer from 'nodemailer';
import User from './models/User.js';

// Robust .env loading regardless of where the process is started from
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, '../.env');
dotenv.config({ path: envPath });

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI;

// Validate MONGODB_URI early with friendly errors
const maskUri = (uri) => {
  try {
    if (!uri) return '(not set)';
    const u = new URL(uri.replace('mongodb+srv://', 'http://').replace('mongodb://', 'http://'));
    const host = u.host;
    return `mongodb(+srv)://${host}/...`;
  } catch {
    return '(invalid)';
  }
};

if (!MONGODB_URI || /<.+>/.test(MONGODB_URI)) {
  console.error('[Startup] MONGODB_URI is missing or contains placeholders.');
  console.error(`[Startup] .env path: ${envPath}`);
  console.error(`[Startup] Current value summary: ${maskUri(MONGODB_URI)}`);
  console.error('[Startup] Set MONGODB_URI in server/.env to your Atlas connection string.');
  process.exit(1);
}

// DB connect
mongoose
  .connect(MONGODB_URI, { serverSelectionTimeoutMS: 8000 })
  .then(() => console.log('MongoDB connected'))
  .catch((err) => {
    console.error('Mongo connect error', err.message);
    console.error(`[Mongo] Tried URI: ${maskUri(MONGODB_URI)}`);
    process.exit(1);
  });

// Email Configuration
const getEmailTransporter = () => {
  const emailService = process.env.EMAIL_SERVICE || 'gmail';
  const emailUser = process.env.EMAIL_USER;
  const emailPassword = process.env.EMAIL_PASSWORD;

  console.log('[Email Debug] EMAIL_USER:', emailUser ? 'SET' : 'NOT SET');
  console.log('[Email Debug] EMAIL_PASSWORD:', emailPassword ? 'SET' : 'NOT SET');
  console.log('[Email Debug] .env path:', envPath);

  if (!emailUser || !emailPassword) {
    console.warn('[Email] EMAIL_USER or EMAIL_PASSWORD not set - email notifications disabled');
    return null;
  }

  return nodemailer.createTransport({
    service: emailService,
    auth: {
      user: emailUser,
      pass: emailPassword,
    },
  });
};

const sendWelcomeEmail = async (email, username) => {
  const transporter = getEmailTransporter();
  if (!transporter) return false;

  try {
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Welcome to EduQuest! 🎓',
      html: `
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <h2>Welcome to EduQuest, ${username}!</h2>
          <p>Your account has been created successfully!</p>
          <p>You're now ready to start your learning journey with our interactive study platform.</p>
          <div style="background-color: #f4f4f4; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <p><strong>Account Details:</strong></p>
            <p>Username: <code>${username}</code></p>
            <p>Email: <code>${email}</code></p>
          </div>
          <p>Log in to the EduQuest app to:</p>
          <ul>
            <li>Create and customize study sets</li>
            <li>Practice with interactive quizzes</li>
            <li>Earn points and unlock themes</li>
            <li>Track your learning progress</li>
          </ul>
          <p>If you didn't create this account, please ignore this email.</p>
          <hr style="margin-top: 30px; border: none; border-top: 1px solid #ccc;">
          <p style="font-size: 12px; color: #666;">EduQuest Learning Platform | Making education fun and engaging</p>
        </div>
      `,
    });
    return true;
  } catch (error) {
    console.error('[Email] Failed to send welcome email:', error.message);
    return false;
  }
};

// Helpers
const ensureUser = async (username) => {
  let user = await User.findOne({ username });
  if (!user) {
    // Auto-provision user with default password 'password' when accessed indirectly
    const passwordHash = await bcrypt.hash('password', 10);
    user = await User.create({ username, passwordHash });
  }
  return user;
};

// Root endpoint to confirm backend is alive
app.get('/', (req, res) => {
  res.send('EduQuest API is running!');
});

// Health
app.get('/health', (req, res) => {
  res.json({ ok: true, uptime: process.uptime() });
});

// AUTH
app.post('/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;
    if (!username || !email || !password) return res.status(400).json({ ok: false, error: 'Missing fields' });
    const exists = await User.findOne({ $or: [{ username }, { email }] });
    if (exists) return res.status(409).json({ ok: false, error: 'User or email already exists' });
    const passwordHash = await bcrypt.hash(password, 10);
    await User.create({ username, email, passwordHash });
    
    // Send welcome email (non-blocking)
    sendWelcomeEmail(email, username).catch((err) => {
      console.error('[Registration] Email sending failed:', err);
    });
    
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ ok: false, error: 'Server error' });
  }
});

// Send verification code email
app.post('/auth/send-verification', async (req, res) => {
  try {
    const { email, username, code } = req.body;
    if (!email || !username || !code) {
      return res.status(400).json({ ok: false, error: 'Missing fields' });
    }

    const transporter = getEmailTransporter();
    
    // DEVELOPMENT MODE: If email is not configured, log code to console
    if (!transporter) {
      console.log('\n' + '='.repeat(60));
      console.log('📧 VERIFICATION CODE (Development Mode)');
      console.log('='.repeat(60));
      console.log(`Username: ${username}`);
      console.log(`Email: ${email}`);
      console.log(`Code: ${code}`);
      console.log('='.repeat(60) + '\n');
      return res.json({ ok: true, devMode: true });
    }

    // PRODUCTION MODE: Send actual email
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'EduQuest - Verify Your Email 🔐',
      html: `
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0;">EduQuest</h1>
            <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0;">Educational Excellence Awaits</p>
          </div>
          
          <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
            <h2 style="color: #333; margin-top: 0;">Welcome, ${username}!</h2>
            <p>Thank you for joining EduQuest. To complete your registration, please verify your email address.</p>
            
            <div style="background-color: white; border: 2px dashed #667eea; border-radius: 10px; padding: 20px; margin: 25px 0; text-align: center;">
              <p style="margin: 0 0 10px 0; color: #666; font-size: 14px;">Your Verification Code:</p>
              <p style="font-size: 36px; font-weight: bold; color: #667eea; letter-spacing: 5px; margin: 10px 0;">${code}</p>
              <p style="margin: 10px 0 0 0; color: #999; font-size: 12px;">This code will expire in 10 minutes</p>
            </div>
            
            <p style="color: #666; font-size: 14px; margin-top: 20px;">
              If you didn't create an account with EduQuest, you can safely ignore this email.
            </p>
            
            <hr style="border: none; border-top: 1px solid #ddd; margin: 25px 0;">
            
            <p style="color: #999; font-size: 12px; text-align: center; margin-bottom: 0;">
              This is an automated email from EduQuest. Please do not reply.
            </p>
          </div>
        </div>
      `,
    });

    return res.json({ ok: true });
  } catch (e) {
    console.error('[Verification] Error sending email:', e);
    return res.status(500).json({ ok: false, error: 'Failed to send verification email' });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).json({ ok: false, error: 'Missing fields' });
    const user = await User.findOne({ username });
    if (!user) return res.status(401).json({ ok: false, error: 'Invalid credentials' });
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ ok: false, error: 'Invalid credentials' });
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ ok: false, error: 'Server error' });
  }
});

// POINTS
app.get('/users/:username/points', async (req, res) => {
  try {
    const { username } = req.params;
    const user = await ensureUser(username);
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
    const user = await ensureUser(username);
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
    const user = await ensureUser(req.params.username);
    return res.json({ theme: user.currentTheme || 'space' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.put('/users/:username/theme', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const { theme } = req.body;
    if (!theme) return res.status(400).json({ error: 'Missing theme' });
    // Allow setting any theme; app logic ensures purchase when needed
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
    const user = await ensureUser(req.params.username);
    const themes = Array.from(new Set(['space', ...user.themesOwned]));
    return res.json({ themes });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/themes/purchase', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
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
    const user = await ensureUser(req.params.username);
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
    const user = await ensureUser(req.params.username);
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
    const user = await ensureUser(req.params.username);
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
    const user = await ensureUser(req.params.username);
    const sets = user.importedSets.map((name) => ({ name }));
    return res.json({ sets });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/imported-sets', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
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
    const user = await ensureUser(req.params.username);
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
  console.log(`API listening on :${PORT}`);
});
