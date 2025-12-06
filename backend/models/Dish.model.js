const mongoose = require('mongoose');

const dishSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    index: true,
  },
  category: {
    type: String,
    required: true,
    enum: ['Món chính', 'Món phụ', 'Đồ uống', 'Tráng miệng', 'Bánh/Bánh mì', 'Món ăn vặt'],
  },
  imageUrl: {
    type: String,
    default: '',
  },
  imageKey: {
    type: String, // AWS S3 key for deletion
    default: '',
  },
  status: {
    type: String,
    enum: ['active', 'inactive'],
    default: 'active',
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
  },
  ratingCount: {
    type: Number,
    default: 0,
  },
  description: {
    type: String,
    default: '',
  },
  ingredients: [{
    type: String,
  }],
  preparationTime: {
    type: Number, // in minutes
    default: 0,
  },
  difficulty: {
    type: String,
    enum: ['easy', 'medium', 'hard'],
    default: 'medium',
  },
  tags: [{
    type: String,
  }],
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
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

// Indexes for better query performance
dishSchema.index({ name: 'text', description: 'text' });
dishSchema.index({ category: 1, status: 1 });
dishSchema.index({ rating: -1 });

// Virtual for formatted rating
dishSchema.virtual('formattedRating').get(function() {
  return this.rating.toFixed(1);
});

module.exports = mongoose.model('Dish', dishSchema);
