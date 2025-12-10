const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccountPath = path.join(__dirname, 'today-s-eats-firebase-adminsdk-fbsvc-0195542b40.json');
const serviceAccount = require(serviceAccountPath);

const app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Get Firestore instance - it will connect to 'todayseats' database
const db = admin.firestore(app);
db.settings({ ignoreUndefinedProperties: true });

async function testFirestore() {
  try {
    console.log('🔍 Testing Firestore connection...\n');
    
    // Test 1: Try to create a test document
    console.log('📝 Test 1: Creating test document...');
    const testRef = db.collection('_test').doc('connection-test');
    await testRef.set({
      message: 'Hello from backend',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      test: true,
    });
    console.log('✅ Test document created successfully!\n');
    
    // Test 2: Read the document back
    console.log('📖 Test 2: Reading test document...');
    const doc = await testRef.get();
    if (doc.exists) {
      console.log('✅ Document data:', doc.data());
      console.log('');
    }
    
    // Test 3: List all collections
    console.log('📚 Test 3: Listing collections...');
    const collections = await db.listCollections();
    console.log(`Found ${collections.length} collections:`, collections.map(c => c.id).join(', '));
    console.log('');
    
    // Test 4: Create a test user
    console.log('👤 Test 4: Creating test user...');
    const userRef = db.collection('users').doc('test-user-123');
    await userRef.set({
      uid: 'test-user-123',
      email: 'test@todayseats.com',
      displayName: 'Test User',
      photoURL: '',
      role: 'user',
      favorites: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log('✅ Test user created!\n');
    
    // Test 5: List users
    console.log('👥 Test 5: Listing users...');
    const usersSnapshot = await db.collection('users').get();
    console.log(`Found ${usersSnapshot.size} user(s):`);
    usersSnapshot.forEach(doc => {
      console.log(`  - ${doc.id}: ${doc.data().displayName} (${doc.data().email})`);
    });
    
    console.log('\n🎉 All tests passed! Firestore is working correctly.');
    
    // Cleanup
    console.log('\n🧹 Cleaning up test data...');
    await testRef.delete();
    console.log('✅ Cleanup complete.');
    
  } catch (error) {
    console.error('❌ Error:', error.code, error.message);
    console.error('Full error:', error);
  } finally {
    process.exit(0);
  }
}

testFirestore();
