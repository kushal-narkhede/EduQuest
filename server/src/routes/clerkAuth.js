import { Router } from 'express';
import { clerkClient } from '@clerk/clerk-sdk-node';

const router = Router();

// Middleware to verify Clerk session token
export const requireAuth = async (req, res, next) => {
  try {
    const sessionToken = req.headers.authorization?.replace('Bearer ', '');
    
    if (!sessionToken) {
      return res.status(401).json({ error: 'No session token provided' });
    }

    // Verify the session token with Clerk
    const session = await clerkClient.sessions.verifySession(sessionToken);
    
    if (!session) {
      return res.status(401).json({ error: 'Invalid session' });
    }

    // Get user details from Clerk
    const user = await clerkClient.users.getUser(session.userId);
    
    // Attach user info to request
    req.clerkUser = user;
    req.userId = user.id;
    req.username = user.username || user.emailAddresses[0]?.emailAddress.split('@')[0];
    
    next();
  } catch (error) {
    console.error('[Clerk Auth] Error:', error);
    return res.status(401).json({ error: 'Authentication failed' });
  }
};

// Webhook endpoint for Clerk events (user creation, updates, etc.)
router.post('/webhook', async (req, res) => {
  try {
    const { type, data } = req.body;
    
    console.log('[Clerk Webhook] Event:', type);
    
    switch (type) {
      case 'user.created':
        console.log('[Clerk] New user created:', data.id);
        // You can sync user data to your MongoDB here if needed
        break;
        
      case 'user.updated':
        console.log('[Clerk] User updated:', data.id);
        break;
        
      case 'session.created':
        console.log('[Clerk] Session created for user:', data.user_id);
        break;
        
      default:
        console.log('[Clerk] Unhandled event type:', type);
    }
    
    res.json({ received: true });
  } catch (error) {
    console.error('[Clerk Webhook] Error:', error);
    res.status(400).json({ error: 'Webhook processing failed' });
  }
});

// Get current user info
router.get('/me', requireAuth, async (req, res) => {
  try {
    res.json({
      id: req.clerkUser.id,
      username: req.username,
      email: req.clerkUser.emailAddresses[0]?.emailAddress,
      firstName: req.clerkUser.firstName,
      lastName: req.clerkUser.lastName,
      profileImageUrl: req.clerkUser.profileImageUrl,
    });
  } catch (error) {
    console.error('[Clerk] Error getting user:', error);
    res.status(500).json({ error: 'Failed to get user info' });
  }
});

export default router;
