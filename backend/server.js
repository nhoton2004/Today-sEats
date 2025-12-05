const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Initialize Firebase Admin
let db;
let useFirebase = false;
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

try {
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`
    });
    db = admin.firestore();
    useFirebase = true;
    console.log('✅ Firebase Admin initialized with serviceAccountKey.json');
  } else {
    console.log('⚠️  serviceAccountKey.json not found. Running in demo mode with mock data.');
  }
} catch (error) {
  console.log('⚠️  Firebase Admin initialization failed:', error.message);
  console.log('Running in demo mode with mock data.');
}

const app = express();
const PORT = process.env.PORT || 5000;

// Mock data for development
const mockDishes = [
  {
    id: 'dish-1',
    name: 'Phở Bò',
    category: 'Món chính',
    imageUrl: 'https://via.placeholder.com/300x200?text=Pho+Bo',
    status: 'active',
    rating: 4.8
  },
  {
    id: 'dish-2',
    name: 'Bánh Mì',
    category: 'Bánh/Bánh mì',
    imageUrl: 'https://via.placeholder.com/300x200?text=Banh+Mi',
    status: 'active',
    rating: 4.6
  },
  {
    id: 'dish-3',
    name: 'Cơm Tấm',
    category: 'Món chính',
    imageUrl: 'https://via.placeholder.com/300x200?text=Com+Tam',
    status: 'active',
    rating: 4.5
  }
];

const mockUsers = [
  {
    id: 'user-1',
    displayName: 'Nguyễn Văn Admin',
    email: 'admin@example.com',
    role: 'admin',
    createdAt: { seconds: Math.floor(Date.now() / 1000) }
  },
  {
    id: 'user-2',
    displayName: 'Trần Thị Người Dùng',
    email: 'user@example.com',
    role: 'user',
    createdAt: { seconds: Math.floor(Date.now() / 1000) - 86400 }
  }
];

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Serve admin dashboard
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

// ===== API Routes =====

// Get all dishes
app.get('/api/dishes', async (req, res) => {
  try {
    if (useFirebase && db) {
      const snapshot = await db.collection('dishes').get();
      const dishes = [];
      snapshot.forEach(doc => {
        dishes.push({ id: doc.id, ...doc.data() });
      });
      res.json(dishes);
    } else {
      res.json(mockDishes);
    }
  } catch (error) {
    console.error('Error fetching dishes:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get single dish
app.get('/api/dishes/:id', async (req, res) => {
  try {
    if (useFirebase && db) {
      const doc = await db.collection('dishes').doc(req.params.id).get();
      if (!doc.exists) {
        return res.status(404).json({ error: 'Dish not found' });
      }
      res.json({ id: doc.id, ...doc.data() });
    } else {
      const dish = mockDishes.find(d => d.id === req.params.id);
      if (!dish) {
        return res.status(404).json({ error: 'Dish not found' });
      }
      res.json(dish);
    }
  } catch (error) {
    console.error('Error fetching dish:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create dish
app.post('/api/dishes', async (req, res) => {
  try {
    const { name, category, imageUrl, status } = req.body;

    if (!name || !category) {
      return res.status(400).json({ error: 'Name and category are required' });
    }

    if (useFirebase && db) {
      const docRef = await db.collection('dishes').add({
        name,
        category,
        imageUrl: imageUrl || '',
        status: status || 'active',
        rating: 0,
        createdAt: new Date()
      });
      res.status(201).json({ id: docRef.id, name, category, imageUrl, status });
    } else {
      const newDish = {
        id: `dish-${Date.now()}`,
        name,
        category,
        imageUrl: imageUrl || 'https://via.placeholder.com/300x200?text=' + name,
        status: status || 'active',
        rating: 0
      };
      mockDishes.push(newDish);
      res.status(201).json(newDish);
    }
  } catch (error) {
    console.error('Error creating dish:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update dish
app.put('/api/dishes/:id', async (req, res) => {
  try {
    const { name, category, imageUrl, status } = req.body;

    if (useFirebase && db) {
      await db.collection('dishes').doc(req.params.id).update({
        name,
        category,
        imageUrl,
        status,
        updatedAt: new Date()
      });
      res.json({ id: req.params.id, name, category, imageUrl, status });
    } else {
      const dishIndex = mockDishes.findIndex(d => d.id === req.params.id);
      if (dishIndex === -1) {
        return res.status(404).json({ error: 'Dish not found' });
      }
      mockDishes[dishIndex] = {
        ...mockDishes[dishIndex],
        name,
        category,
        imageUrl,
        status
      };
      res.json(mockDishes[dishIndex]);
    }
  } catch (error) {
    console.error('Error updating dish:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete dish
app.delete('/api/dishes/:id', async (req, res) => {
  try {
    if (useFirebase && db) {
      await db.collection('dishes').doc(req.params.id).delete();
      res.json({ success: true, id: req.params.id });
    } else {
      const dishIndex = mockDishes.findIndex(d => d.id === req.params.id);
      if (dishIndex === -1) {
        return res.status(404).json({ error: 'Dish not found' });
      }
      mockDishes.splice(dishIndex, 1);
      res.json({ success: true, id: req.params.id });
    }
  } catch (error) {
    console.error('Error deleting dish:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get all users
app.get('/api/users', async (req, res) => {
  try {
    if (useFirebase && db) {
      const snapshot = await db.collection('users').get();
      const users = [];
      snapshot.forEach(doc => {
        users.push({ id: doc.id, ...doc.data() });
      });
      res.json(users);
    } else {
      res.json(mockUsers);
    }
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get app statistics
app.get('/api/stats', async (req, res) => {
  try {
    if (useFirebase && db) {
      const dishesSnapshot = await db.collection('dishes').get();
      const usersSnapshot = await db.collection('users').get();
      
      const activeDishes = dishesSnapshot.docs.filter(doc => doc.data().status === 'active').length;
      
      res.json({
        totalDishes: dishesSnapshot.size,
        activeDishes: activeDishes,
        inactiveDishes: dishesSnapshot.size - activeDishes,
        totalUsers: usersSnapshot.size,
        timestamp: new Date().toISOString()
      });
    } else {
      const activeDishes = mockDishes.filter(d => d.status === 'active').length;
      res.json({
        totalDishes: mockDishes.length,
        activeDishes: activeDishes,
        inactiveDishes: mockDishes.length - activeDishes,
        totalUsers: mockUsers.length,
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    firebaseEnabled: useFirebase
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
  console.log(`📊 Admin dashboard: http://localhost:${PORT}`);
  console.log(`📁 Database mode: ${useFirebase ? 'Firebase' : 'Mock (Demo)'}`);
});
