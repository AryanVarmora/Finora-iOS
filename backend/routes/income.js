//
// routes/income.js
// Income CRUD routes
//

const express = require('express');
const router = express.Router();
const Income = require('../models/Income');
const { verifyToken } = require('../middleware/auth');

router.use(verifyToken);

// GET /api/income
router.get('/', async (req, res) => {
  try {
    const income = await Income.find({ userId: req.userId }).sort({ date: -1 });
    res.json({ success: true, count: income.length, income });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch income', message: error.message });
  }
});

// POST /api/income
router.post('/', async (req, res) => {
  try {
    const { source, amount, frequency, date, category, currency } = req.body;
    const income = new Income({
      userId: req.userId,
      source,
      amount,
      frequency: frequency || 'monthly',
      date: date ? new Date(date) : new Date(),
      category: category || 'Other',
      currency: currency || 'USD'
    });
    await income.save();
    res.status(201).json({ success: true, income });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create income', message: error.message });
  }
});

// PUT /api/income/:id
router.put('/:id', async (req, res) => {
  try {
    const income = await Income.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      { ...req.body, lastModified: new Date() },
      { new: true }
    );
    if (!income) return res.status(404).json({ error: 'Income not found' });
    res.json({ success: true, income });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update income', message: error.message });
  }
});

// DELETE /api/income/:id
router.delete('/:id', async (req, res) => {
  try {
    const income = await Income.findOneAndDelete({ _id: req.params.id, userId: req.userId });
    if (!income) return res.status(404).json({ error: 'Income not found' });
    res.json({ success: true, message: 'Income deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete income', message: error.message });
  }
});

module.exports = router;