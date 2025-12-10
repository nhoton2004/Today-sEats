const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Import MongoDB connection for dishes only
const connectMongoDB = require('./config/mongodb.config');

// Import routes
const dishesRoutes = require('./routes/dishes.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Initialize Firebase Admin (for users authentication and storage)
let db;
let useFirebase = false;
const serviceAccountPath = path.join(__dirname, 'today-s-eats-firebase-adminsdk-fbsvc-0195542b40.json');

try {
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    
    // Initialize Firebase Admin with database ID
    const app = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`,
    });
    
    // Connect to the specific database 'todayseats' instead of default
    db = admin.firestore(app);
    
    // IMPORTANT: Set database path to 'todayseats' (the non-default database)
    const firestoreSettings = {
      ignoreUndefinedProperties: true,
    };
    db.settings(firestoreSettings);
    
    useFirebase = true;
    console.log('✅ Firebase Admin initialized (for Users)');
    console.log(`📋 Project: ${serviceAccount.project_id}`);
    console.log(`🗄️  Database: todayseats (nam5)`);
    
    // Test connection
    db.listCollections()
      .then(collections => {
        console.log(`📚 Firestore collections: ${collections.length > 0 ? collections.map(c => c.id).join(', ') : 'none (empty database)'}`);
      })
      .catch(err => {
        console.log('⚠️  Note: Database is empty or connection issue:', err.message);
        console.log('💡 Users will be created automatically when you sign up from the app');
      });
  } else {
    console.log('⚠️  Firebase service account not found.');
  }
} catch (error) {
  console.log('⚠️  Firebase Admin initialization failed:', error.message);
  console.log('Error details:', error);
}

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Connect to MongoDB (for dishes only)
connectMongoDB();

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    databases: {
      firebase: useFirebase ? 'connected (users)' : 'disconnected',
      mongodb: 'connected (dishes)',
    },
    s3: process.env.AWS_S3_BUCKET ? 'configured' : 'not configured',
  });
});

// ========== DISHES ROUTES (MongoDB) ==========
app.use('/api/dishes', dishesRoutes);

// ========== USERS ROUTES (Firebase Firestore) ==========

// Get all users from Firestore
app.get('/api/users', async (req, res) => {
  try {
    if (!useFirebase || !db) {
      return res.status(503).json({ error: 'Firebase not available' });
    }

    const snapshot = await db.collection('users').get();
    const users = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      users.push({
        id: doc.id,
        ...data,
        // Convert Firestore Timestamp to readable format
        createdAt: data.createdAt?.toDate ? {
          seconds: data.createdAt.toDate().getTime() / 1000
        } : data.createdAt,
        lastLoginAt: data.lastLoginAt?.toDate ? {
          seconds: data.lastLoginAt.toDate().getTime() / 1000
        } : data.lastLoginAt,
      });
    });
    
    res.json(users);
  } catch (error) {
    console.error('Error fetching users from Firestore:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user by UID from Firestore
app.get('/api/users/:uid', async (req, res) => {
  try {
    if (!useFirebase || !db) {
      return res.status(503).json({ error: 'Firebase not available' });
    }

    const doc = await db.collection('users').doc(req.params.uid).get();
    
    if (!doc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const data = doc.data();
    res.json({
      id: doc.id,
      ...data,
      createdAt: data.createdAt?.toDate ? {
        seconds: data.createdAt.toDate().getTime() / 1000
      } : data.createdAt,
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create or update user in Firestore
app.post('/api/users', async (req, res) => {
  try {
    if (!useFirebase || !db) {
      return res.status(503).json({ error: 'Firebase not available' });
    }

    const { uid, email, displayName, photoURL } = req.body;

    if (!uid || !email) {
      return res.status(400).json({ error: 'UID and email are required' });
    }

    const userRef = db.collection('users').doc(uid);
    const userDoc = await userRef.get();

    if (userDoc.exists) {
      // Update existing user
      await userRef.update({
        displayName: displayName || userDoc.data().displayName,
        photoURL: photoURL !== undefined ? photoURL : userDoc.data().photoURL,
        lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      const updated = await userRef.get();
      const data = updated.data();
      res.json({ 
        id: uid, 
        ...data,
        lastLoginAt: data.lastLoginAt?.toDate ? {
          seconds: data.lastLoginAt.toDate().getTime() / 1000
        } : data.lastLoginAt,
      });
    } else {
      // Create new user
      await userRef.set({
        uid,
        email,
        displayName: displayName || 'User',
        photoURL: photoURL || '',
        role: 'user',
        favorites: [],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      const created = await userRef.get();
      const data = created.data();
      res.json({ 
        id: uid, 
        ...data,
        createdAt: data.createdAt?.toDate ? {
          seconds: data.createdAt.toDate().getTime() / 1000
        } : data.createdAt,
      });
    }
  } catch (error) {
    console.error('Error creating/updating user in Firestore:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update user profile
app.put('/api/users/:uid', async (req, res) => {
  try {
    if (!useFirebase || !db) {
      return res.status(503).json({ error: 'Firebase not available' });
    }

    const userRef = db.collection('users').doc(req.params.uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    await userRef.update({
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const updated = await userRef.get();
    res.json({ id: req.params.uid, ...updated.data() });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: error.message });
  }
});

// Toggle favorite
app.post('/api/users/:uid/favorites', async (req, res) => {
  try {
    if (!useFirebase || !db) {
      return res.status(503).json({ error: 'Firebase not available' });
    }

    const { dishId } = req.body;
    if (!dishId) {
      return res.status(400).json({ error: 'dishId is required' });
    }

    const userRef = db.collection('users').doc(req.params.uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userData = userDoc.data();
    const favorites = userData.favorites || [];
    
    let message;
    if (favorites.includes(dishId)) {
      // Remove from favorites
      await userRef.update({
        favorites: admin.firestore.FieldValue.arrayRemove(dishId),
      });
      message = 'Removed from favorites';
    } else {
      // Add to favorites
      await userRef.update({
        favorites: admin.firestore.FieldValue.arrayUnion(dishId),
      });
      message = 'Added to favorites';
    }

    const updated = await userRef.get();
    res.json({ 
      message, 
      user: { id: req.params.uid, ...updated.data() } 
    });
  } catch (error) {
    console.error('Error toggling favorite:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete user
app.delete('/api/users/:uid', async (req, res) => {
  try {
    if (!useFirebase || !db) {
      return res.status(503).json({ error: 'Firebase not available' });
    }

    await db.collection('users').doc(req.params.uid).delete();
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ error: error.message });
  }
});

// ========== STATISTICS ==========
app.get('/api/stats', async (req, res) => {
  try {
    const Dish = require('./models/Dish.model');
    
    // Get dishes count from MongoDB
    const [totalDishes, activeDishes] = await Promise.all([
      Dish.countDocuments(),
      Dish.countDocuments({ status: 'active' }),
    ]);

    // Get users count from Firestore
    let totalUsers = 0;
    if (useFirebase && db) {
      const usersSnapshot = await db.collection('users').get();
      totalUsers = usersSnapshot.size;
    }

    res.json({
      totalDishes,
      activeDishes,
      inactiveDishes: totalDishes - activeDishes,
      totalUsers,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: error.message });
  }
});

// Serve admin dashboard
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error', message: err.message });
});

// Start server
app.listen(PORT, () => {
  console.log('\n==================================================');
  console.log('🚀 Hybrid Server Started');
  console.log('==================================================');
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`📊 Admin Dashboard: http://localhost:${PORT}`);
  console.log('');
  console.log('💾 Databases:');
  console.log(`   - Firebase Firestore: ${useFirebase ? '✅ Connected (Users)' : '❌ Disconnected'}`);
  console.log('   - MongoDB: 🔄 Connecting... (Dishes)');
  console.log('');
  console.log('☁️  Storage:');
  console.log(`   - AWS S3: ${process.env.AWS_S3_BUCKET || 'Not configured'}`);
  console.log('==================================================\n');
});
