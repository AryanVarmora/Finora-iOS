//
// models/Income.js
// Income model for MongoDB
//

const mongoose = require('mongoose');

const incomeSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  source: {
    type: String,
    required: true,
    trim: true
  },
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  frequency: {
    type: String,
    required: true,
    enum: ['one-time', 'daily', 'weekly', 'bi-weekly', 'monthly', 'quarterly', 'yearly'],
    default: 'monthly'
  },
  date: {
    type: Date,
    required: true,
    default: Date.now
  },
  category: {
    type: String,
    enum: ['Salary', 'Freelance', 'Investment', 'Business', 'Gift', 'Other'],
    default: 'Other'
  },
  currency: {
    type: String,
    default: 'USD'
  },
  notes: {
    type: String,
    trim: true
  },
  isRecurring: {
    type: Boolean,
    default: false
  },
  lastModified: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for efficient queries
incomeSchema.index({ userId: 1, date: -1 });
incomeSchema.index({ userId: 1, frequency: 1 });

// Update lastModified on save
incomeSchema.pre('save', function(next) {
  this.lastModified = new Date();
  next();
});

module.exports = mongoose.model('Income', incomeSchema);