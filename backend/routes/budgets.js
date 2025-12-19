//
// routes/budgets.js
// Budget CRUD routes
//

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Budget = require('../models/Budget');
const { verifyToken } = require('../middleware/auth');

router.use(verifyToken);

// GET /api/budgets
router.get('/', async (req, res) => {
  try {
    const budgets = await Budget.find({ userId: req.userId }).sort({ category: 1 });
    res.json({ success: true, count: budgets.length, budgets });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch budgets', message: error.message });
  }
});

// POST /api/budgets
router.post('/', async (req, res) => {
  try {
    const { category, limit, period, startDate } = req.body;
    const budget = new Budget({
      userId: req.userId,
      category,
      limit,
      period: period || 'monthly',
      startDate: startDate ? new Date(startDate) : new Date()
    });
    await budget.save();
    res.status(201).json({ success: true, budget });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create budget', message: error.message });
  }
});

// PUT /api/budgets/:id
router.put('/:id', async (req, res) => {
  try {
    const budget = await Budget.findOneAndUpdate(
      { _id: req.params.id, userId: req.userId },
      { ...req.body, lastModified: new Date() },
      { new: true }
    );
    if (!budget) return res.status(404).json({ error: 'Budget not found' });
    res.json({ success: true, budget });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update budget', message: error.message });
  }
});

// DELETE /api/budgets/:id
router.delete('/:id', async (req, res) => {
  try {
    const budget = await Budget.findOneAndDelete({ _id: req.params.id, userId: req.userId });
    if (!budget) return res.status(404).json({ error: 'Budget not found' });
    res.json({ success: true, message: 'Budget deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete budget', message: error.message });
  }
});

module.exports = router;