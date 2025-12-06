const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    lowercase: true,
    trim: true,
  },
  displayName: {
    type: String,
    required: true,
    trim: true,
  },
  photoURL: {
    type: String,
    default: '',
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'moderator'],
    default: 'user',
  },
  favorites: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Dish',
  }],
  preferences: {
    categories: [{
      type: String,
    }],
    allergies: [{
      type: String,
    }],
  },
  stats: {
    dishesCreated: {
      type: Number,
      default: 0,
    },
    ratingsGiven: {
      type: Number,
      default: 0,
    },
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  lastLoginAt: {
    type: Date,
    default: Date.now,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

// Indexes
userSchema.index({ email: 1 }, { unique: true });
userSchema.index({ uid: 1 }, { unique: true });

module.exports = mongoose.model('User', userSchema);
