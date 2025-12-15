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
import User from './models/User.js'; // Assuming this User model is correctly defined
import { v4 as uuidv4 } from 'uuid'; // Import a unique ID generator
import roboticsRouter from './routes/robotics.js';

// --- Initialization and Configuration ---

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
app.use('/robotics', roboticsRouter);

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
  .then(() => console.log('✅ MongoDB connected'))
  .catch((err) => {
    console.error('❌ Mongo connect error', err.message);
    console.error(`[Mongo] Tried URI: ${maskUri(MONGODB_URI)}`);
    process.exit(1);
  });

// --- Email Configuration and Helpers ---

const getEmailTransporter = () => {
  const emailService = process.env.EMAIL_SERVICE || 'gmail';
  const emailUser = process.env.EMAIL_USER;
  const emailPassword = process.env.EMAIL_PASSWORD;

  if (!emailUser || !emailPassword) {
    console.warn('⚠️ [Email] EMAIL_USER or EMAIL_PASSWORD not set - email notifications disabled');
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
    console.error('❌ [Email] Failed to send welcome email:', error.message);
    return false;
  }
};

// Helper to find user or throw error
const ensureUser = async (username) => {
  const user = await User.findOne({ username });
  if (!user) {
    const error = new Error(`User not found: ${username}`);
    error.status = 404; // Add status for better error handling if needed
    throw error;
  }
  return user;
};

// --- API Routes ---

// Root endpoint to confirm backend is alive
app.get('/', (req, res) => {
  res.send('EduQuest API is running!');
});

// Health
app.get('/health', (req, res) => {
  res.json({ ok: true, uptime: process.uptime() });
});

// DEBUG: List all users
app.get('/debug/users', async (req, res) => {
  try {
    const users = await User.find({}, 'username email points passwordHash').lean();
    const usersInfo = users.map(u => ({
      username: u.username,
      email: u.email,
      points: u.points,
      hasPassword: !!u.passwordHash,
      passwordHash: u.passwordHash ? u.passwordHash.substring(0, 20) + '...' : 'none'
    }));
    return res.json({ users: usersInfo, count: users.length });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// --- AUTH ---

// Check if username exists (for registration validation)
app.get('/auth/username-exists/:username', async (req, res) => {
  try {
    const { username } = req.params;
    const user = await User.findOne({ username });
    return res.json({ exists: !!user });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

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
      console.error('❌ [Registration] Email sending failed:', err);
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
    if (!transporter) {
      console.warn('⚠️ [Verification] Email service not configured');
      return res.status(503).json({ ok: false, error: 'Email service unavailable' });
    }

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
    console.error('❌ [Verification] Error sending email:', e);
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

// --- USER DATA (POINTS, THEMES, POWERUPS, IMPORTED SETS) ---

// POINTS
app.get('/users/:username/points', async (req, res) => {
  try {
    const { username } = req.params;
    const user = await ensureUser(username);
    return res.json({ points: user.points || 0 });
  } catch (e) {
    console.error(e);
    // Handle 404 from ensureUser
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// POWERUPS
app.get('/users/:username/powerups', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const map = {};
    // Convert Map to a plain object for JSON response
    for (const [k, v] of user.powerups.entries()) {
      map[k] = v;
    }
    return res.json({ powerups: map });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    
    // Decrement or delete the powerup entry
    const newCount = current - 1;
    if (newCount > 0) user.powerups.set(powerupId, newCount);
    else user.powerups.delete(powerupId);
    
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
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
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// --- FRIENDS & MESSAGING ---

// Get friend list
app.get('/users/:username/friends', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    return res.json({ friends: user.friendList || [] });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Send friend request
// FIX: Changed req.params.fromUsername to req.params.username
app.post('/users/:username/friend-request', async (req, res) => {
  try {
    const fromUsername = req.params.username; // FIX: Correctly get the sender's username from the URL param
    const { toUsername } = req.body;
    console.log(`[Friend Request] From: ${fromUsername}, To: ${toUsername}`);
    if (!toUsername) return res.status(400).json({ error: 'Missing toUsername' });

    const fromUser = await ensureUser(fromUsername);
    const toUser = await User.findOne({ username: toUsername });
    if (!toUser) {
      console.log(`[Friend Request] Recipient not found: ${toUsername}`);
      return res.status(404).json({ error: `User not found: ${toUsername}` });
    }
    if (fromUsername === toUsername) return res.status(400).json({ error: 'Cannot befriend yourself' });
    if (fromUser.friendList.includes(toUsername)) return res.status(400).json({ error: 'Already friends' });
    if (fromUser.blockedUsers.includes(toUsername)) return res.status(400).json({ error: 'User is blocked' });
    
    // Check if the recipient has blocked the sender (crucial)
    if (toUser.blockedUsers.includes(fromUsername)) return res.status(400).json({ error: 'Cannot send request, you are blocked by this user' });


    // Check for existing pending request (either direction)
    const existingReq = toUser.friendRequests.find(
      (r) => r.fromUsername === fromUsername && r.status === 'pending'
    );
    if (existingReq) return res.status(400).json({ error: 'Request already sent' });

    // Add friend request to recipient
    toUser.friendRequests.push({
      fromUsername,
      toUsername,
      status: 'pending',
      createdAt: new Date()
    });

    // Add message to recipient's inbox
    // FIX: Add a unique ID for the message to allow for lookup/management
    toUser.inbox.push({
      id: uuidv4(), 
      type: 'friend_request',
      fromUsername,
      subject: `${fromUsername} sent you a friend request`,
      content: `${fromUsername} wants to be your friend.`,
      isRead: false,
      metadata: { fromUsername }
    });

    await toUser.save();

    console.log(`[Friend Request] Successfully sent from ${fromUsername} to ${toUsername}`);
    return res.json({ ok: true });
  } catch (e) {
    console.error('[Friend Request Error]', e.message, e.stack);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Accept friend request
app.post('/users/:username/friend-request/accept', async (req, res) => {
  try {
    const { username } = req.params;
    const { fromUsername } = req.body;
    if (!fromUsername) return res.status(400).json({ error: 'Missing fromUsername' });

    const user = await ensureUser(username);
    const friend = await ensureUser(fromUsername);

    // Find and update the request
    const reqIdx = user.friendRequests.findIndex(
      (r) => r.fromUsername === fromUsername && r.status === 'pending'
    );
    if (reqIdx === -1) return res.status(404).json({ error: 'Friend request not found or not pending' });

    user.friendRequests[reqIdx].status = 'accepted';
    if (!user.friendList.includes(fromUsername)) user.friendList.push(fromUsername);
    if (!friend.friendList.includes(username)) friend.friendList.push(username);

    // Mark friend request message as read
    user.inbox = user.inbox.map((msg) => {
      if (msg.type === 'friend_request' && msg.fromUsername === fromUsername && !msg.isRead) {
        return { ...msg, isRead: true };
      }
      return msg;
    });

    await Promise.all([user.save(), friend.save()]);

    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Decline friend request
app.post('/users/:username/friend-request/decline', async (req, res) => {
  try {
    const { username } = req.params;
    const { fromUsername } = req.body;
    if (!fromUsername) return res.status(400).json({ error: 'Missing fromUsername' });

    const user = await ensureUser(username);

    const reqIdx = user.friendRequests.findIndex(
      (r) => r.fromUsername === fromUsername && r.status === 'pending'
    );
    if (reqIdx === -1) return res.status(404).json({ error: 'Friend request not found or not pending' });

    user.friendRequests[reqIdx].status = 'declined';

    // Mark friend request message as read
    user.inbox = user.inbox.map((msg) => {
      if (msg.type === 'friend_request' && msg.fromUsername === fromUsername && !msg.isRead) {
        return { ...msg, isRead: true };
      }
      return msg;
    });

    await user.save();

    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Get friend requests (pending + history)
app.get('/users/:username/friend-requests', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    return res.json({ requests: user.friendRequests || [] });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Get inbox
app.get('/users/:username/inbox', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const messages = user.inbox.filter((m) => !m.isArchived) || []; // Only show non-archived
    const unreadCount = messages.filter((m) => !m.isRead).length;
    return res.json({ messages, unreadCount });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Direct messaging: get conversation between two users
app.get('/users/:username/conversations/:peer', async (req, res) => {
  try {
    const { username, peer } = req.params;
    const user = await ensureUser(username);
    await ensureUser(peer); // ensure peer exists

    const messages = (user.inbox || [])
      .filter(
        (m) =>
          m.type === 'direct_message' &&
          m.metadata &&
          m.metadata.withUsername === peer
      )
      .sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));

    return res.json({ messages });
  } catch (e) {
    console.error('[Direct Message] Fetch error', e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Direct messaging: send message to a peer (requires friendship and not blocked)
app.post('/users/:username/conversations/:peer', async (req, res) => {
  try {
    const { username, peer } = req.params;
    const { message } = req.body;
    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({ error: 'Message is required' });
    }

    const sender = await ensureUser(username);
    const recipient = await ensureUser(peer);

    // Block checks
    if (sender.blockedUsers.includes(peer) || recipient.blockedUsers.includes(username)) {
      return res.status(403).json({ error: 'Messaging blocked between users' });
    }

    // Require friendship before chatting
    if (!sender.friendList.includes(peer) || !recipient.friendList.includes(username)) {
      return res.status(400).json({ error: 'You must be friends to chat' });
    }

    const trimmed = message.trim();
    const outgoing = {
      id: uuidv4(),
      type: 'direct_message',
      fromUsername: username,
      subject: `Message to ${peer}`,
      content: trimmed,
      isRead: true, // sender has seen their own message
      isArchived: false,
      metadata: { withUsername: peer, direction: 'outgoing' },
      createdAt: new Date(),
    };

    const incoming = {
      ...outgoing,
      id: uuidv4(),
      subject: `Message from ${username}`,
      isRead: false,
      metadata: { withUsername: username, direction: 'incoming' },
    };

    sender.inbox.push(outgoing);
    recipient.inbox.push(incoming);

    await Promise.all([sender.save(), recipient.save()]);

    return res.json({ ok: true });
  } catch (e) {
    console.error('[Direct Message] Send error', e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Mark message as read
// FIX: Ensure lookup uses the 'id' property we added to the message object
app.put('/users/:username/inbox/:messageId/read', async (req, res) => {
  try {
    const { username, messageId } = req.params;
    const user = await ensureUser(username);

    user.inbox = user.inbox.map((msg) => {
      // FIX: Use message.id for lookup
      if (msg.id === messageId && !msg.isRead) { 
        return { ...msg, isRead: true };
      }
      return msg;
    });

    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Archive message
// FIX: Ensure lookup uses the 'id' property we added to the message object
app.put('/users/:username/inbox/:messageId/archive', async (req, res) => {
  try {
    const { username, messageId } = req.params;
    const user = await ensureUser(username);

    user.inbox = user.inbox.map((msg) => {
      // FIX: Use message.id for lookup
      if (msg.id === messageId) {
        return { ...msg, isArchived: true };
      }
      return msg;
    });

    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Delete message
// FIX: Ensure lookup uses the 'id' property we added to the message object
app.delete('/users/:username/inbox/:messageId', async (req, res) => {
  try {
    const { username, messageId } = req.params;
    const user = await ensureUser(username);

    // FIX: Filter based on message.id
    user.inbox = user.inbox.filter((msg) => msg.id !== messageId); 

    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Block user
app.post('/users/:username/block', async (req, res) => {
  try {
    const { username } = req.params;
    const { blockUsername } = req.body;
    if (!blockUsername) return res.status(400).json({ error: 'Missing blockUsername' });
    if (username === blockUsername) return res.status(400).json({ error: 'Cannot block yourself' });

    const user = await ensureUser(username);
    // Ensure the user to be blocked exists, although not strictly necessary for the block list itself
    await ensureUser(blockUsername).catch(() => { /* continue even if user doesn't exist */ }); 
    
    if (!user.blockedUsers.includes(blockUsername)) {
      user.blockedUsers.push(blockUsername);
    }
    
    // Remove from friend list and pending requests upon blocking
    user.friendList = user.friendList.filter((u) => u !== blockUsername);
    user.friendRequests = user.friendRequests.filter((r) => r.fromUsername !== blockUsername && r.toUsername !== blockUsername);

    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// Unblock user
app.delete('/users/:username/block/:blockUsername', async (req, res) => {
  try {
    const { username, blockUsername } = req.params;
    const user = await ensureUser(username);

    user.blockedUsers = user.blockedUsers.filter((u) => u !== blockUsername);

    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    if (e.status === 404) return res.status(404).json({ error: e.message });
    return res.status(500).json({ error: 'Server error' });
  }
});

// --- Server Startup ---

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 API listening on all interfaces on port :${PORT}`);
});