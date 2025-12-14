const mongoose = require('mongoose');
const admin = require('firebase-admin');
const path = require('path');
const User = require('../models/User.model');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const createAdmin = async () => {
    try {
        // 1. Connect MongoDB
        console.log('🔌 Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ MongoDB Connected');

        // 2. Init Firebase
        const serviceAccountPath = path.join(__dirname, '../serviceAccountKey.json');
        if (!admin.apps.length) {
            admin.initializeApp({
                credential: admin.credential.cert(require(serviceAccountPath)),
            });
        }

        const email = 'admin@todayseats.com';
        const password = 'AdminPassword123!';
        const displayName = 'Super Admin';

        // 3. Create/Get Firebase User
        let uid;
        try {
            const userRecord = await admin.auth().getUserByEmail(email);
            uid = userRecord.uid;
            console.log('ℹ️  User exists in Firebase, updating password...');
            await admin.auth().updateUser(uid, { password });
        } catch (error) {
            if (error.code === 'auth/user-not-found') {
                console.log('🆕 Creating new Firebase user...');
                const userRecord = await admin.auth().createUser({
                    email,
                    password,
                    displayName,
                    emailVerified: true,
                });
                uid = userRecord.uid;
            } else {
                throw error;
            }
        }

        // 4. Update/Create Mongo User
        console.log('💾 Updating MongoDB user role...');
        await User.findOneAndUpdate(
            { uid },
            {
                uid,
                email,
                displayName,
                role: 'admin',
                isActive: true,
                photoURL: 'https://ui-avatars.com/api/?name=Super+Admin&background=6366f1&color=fff',
            },
            { upsert: true, new: true }
        );

        console.log('\n=============================================');
        console.log('✅ ADMIN ACCOUNT READY');
        console.log('=============================================');
        console.log(`📧 Email:    ${email}`);
        console.log(`🔑 Password: ${password}`);
        console.log('=============================================\n');

    } catch (error) {
        console.error('❌ Error:', error);
    } finally {
        await mongoose.disconnect();
        process.exit();
    }
};

createAdmin();
