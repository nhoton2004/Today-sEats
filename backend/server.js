const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Import MongoDB connection
const connectMongoDB = require('./config/mongodb.config');

// Import routes
const dishesRoutes = require('./routes/dishes.routes');
const usersRoutes = require('./routes/users.routes');
const aiRoutes = require('./routes/ai.routes');
const userDishesRoutes = require('./routes/user-dishes.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Initialize Firebase Admin (for authentication only)
let useFirebase = false;
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

try {
  // Resolve symlink to actual file path
  const realPath = fs.realpathSync(serviceAccountPath);

  if (fs.existsSync(realPath)) {
    // Clear require cache to ensure fresh load
    delete require.cache[require.resolve(realPath)];

    const serviceAccount = require(realPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    useFirebase = true;
    console.log('✅ Firebase Admin initialized (Auth only)');
    console.log(`   Service Account: ${path.basename(realPath)}`);
  } else {
    console.log('⚠️  serviceAccountKey.json not found. Firebase Auth disabled.');
  }
} catch (error) {
  console.log('⚠️  Firebase Admin initialization failed:', error.message);
}

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Connect to MongoDB
connectMongoDB();

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    database: 'MongoDB',
    firebase: useFirebase ? 'enabled' : 'disabled',
    s3: process.env.AWS_S3_BUCKET ? 'configured' : 'not configured',
  });
});

// API Routes
app.use('/api/dishes', dishesRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/user-dishes', userDishesRoutes);

// Statistics endpoint
app.get('/api/stats', async (req, res) => {
  try {
    const Dish = require('./models/Dish.model');
    const User = require('./models/User.model');

    const [totalDishes, activeDishes, totalUsers] = await Promise.all([
      Dish.countDocuments(),
      Dish.countDocuments({ status: 'active' }),
      User.countDocuments(),
    ]);

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
  console.log('='.repeat(50));
  console.log('🚀 Server is running');
  console.log('='.repeat(50));
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`📊 Admin: http://localhost:${PORT}`);
  console.log(`💾 Database: MongoDB`);
  console.log(`🔐 Firebase Auth: ${useFirebase ? 'Enabled' : 'Disabled'}`);
  console.log(`☁️  AWS S3: ${process.env.AWS_S3_BUCKET || 'Not configured'}`);
  console.log('='.repeat(50));
});
