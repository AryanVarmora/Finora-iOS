//
// routes/expenses.js
// Expense CRUD routes
//

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Expense = require('../models/Expense');
const { verifyToken } = require('../middleware/auth');

// All routes require authentication
router.use(verifyToken);

// GET /api/expenses - Get all expenses for user
router.get('/', async (req, res) => {
  try {
    const { startDate, endDate, category } = req.query;
    
    const query = { userId: req.userId };
    
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }
    
    if (category) {
      query.category = category;
    }
    
    const expenses = await Expense.find(query).sort({ date: -1 });
    
    res.json({
      success: true,
      count: expenses.length,
      expenses
    });
  } catch (error) {
    console.error('Get expenses error:', error);
    res.status(500).json({
      error: 'Failed to fetch expenses',
      message: error.message
    });
  }
});

// GET /api/expenses/:id - Get single expense
router.get('/:id', async (req, res) => {
  try {
    const expense = await Expense.findOne({
      _id: req.params.id,
      userId: req.userId
    });
    
    if (!expense) {
      return res.status(404).json({
        error: 'Expense not found'
      });
    }
    
    res.json({
      success: true,
      expense
    });
  } catch (error) {
    console.error('Get expense error:', error);
    res.status(500).json({
      error: 'Failed to fetch expense',
      message: error.message
    });
  }
});

// POST /api/expenses - Create new expense
router.post('/', [
  body('title').trim().notEmpty(),
  body('amount').isFloat({ min: 0 }),
  body('category').notEmpty(),
  body('currency').optional(),
  body('date').optional().isISO8601()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        errors: errors.array()
      });
    }
    
    const { title, amount, category, currency, date, notes, convertedAmount, deviceId } = req.body;
    
    const expense = new Expense({
      userId: req.userId,
      title,
      amount,
      category,
      currency: currency || 'USD',
      date: date ? new Date(date) : new Date(),
      notes,
      convertedAmount: convertedAmount || amount,
      deviceId
    });
    
    await expense.save();
    
    res.status(201).json({
      success: true,
      message: 'Expense created successfully',
      expense
    });
  } catch (error) {
    console.error('Create expense error:', error);
    res.status(500).json({
      error: 'Failed to create expense',
      message: error.message
    });
  }
});

// PUT /api/expenses/:id - Update expense
router.put('/:id', [
  body('title').optional().trim().notEmpty(),
  body('amount').optional().isFloat({ min: 0 }),
  body('category').optional().notEmpty(),
  body('date').optional().isISO8601()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        errors: errors.array()
      });
    }
    
    const expense = await Expense.findOne({
      _id: req.params.id,
      userId: req.userId
    });
    
    if (!expense) {
      return res.status(404).json({
        error: 'Expense not found'
      });
    }
    
    const allowedUpdates = ['title', 'amount', 'category', 'currency', 'date', 'notes', 'convertedAmount'];
    allowedUpdates.forEach(field => {
      if (req.body[field] !== undefined) {
        expense[field] = req.body[field];
      }
    });
    
    expense.lastModified = new Date();
    await expense.save();
    
    res.json({
      success: true,
      message: 'Expense updated successfully',
      expense
    });
  } catch (error) {
    console.error('Update expense error:', error);
    res.status(500).json({
      error: 'Failed to update expense',
      message: error.message
    });
  }
});

// DELETE /api/expenses/:id - Delete expense
router.delete('/:id', async (req, res) => {
  try {
    const expense = await Expense.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId
    });
    
    if (!expense) {
      return res.status(404).json({
        error: 'Expense not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Expense deleted successfully'
    });
  } catch (error) {
    console.error('Delete expense error:', error);
    res.status(500).json({
      error: 'Failed to delete expense',
      message: error.message
    });
  }
});

// POST /api/expenses/sync - Batch sync expenses
router.post('/sync', async (req, res) => {
  try {
    const { expenses, lastSync } = req.body;
    
    if (!Array.isArray(expenses)) {
      return res.status(400).json({
        error: 'Invalid request',
        message: 'expenses must be an array'
      });
    }
    
    const query = { userId: req.userId };
    if (lastSync) {
      query.lastModified = { $gt: new Date(lastSync) };
    }
    
    const serverExpenses = await Expense.find(query);
    
    const results = {
      created: [],
      updated: [],
      conflicts: []
    };
    
    for (const expenseData of expenses) {
      if (expenseData._id) {
        const existing = await Expense.findOne({
          _id: expenseData._id,
          userId: req.userId
        });
        
        if (existing) {
          if (existing.lastModified > new Date(expenseData.lastModified)) {
            results.conflicts.push(existing);
          } else {
            Object.assign(existing, expenseData);
            existing.lastModified = new Date();
            await existing.save();
            results.updated.push(existing);
          }
        }
      } else {
        const newExpense = new Expense({
          ...expenseData,
          userId: req.userId
        });
        await newExpense.save();
        results.created.push(newExpense);
      }
    }
    
    res.json({
      success: true,
      message: 'Sync completed',
      results: {
        created: results.created.length,
        updated: results.updated.length,
        conflicts: results.conflicts.length,
        serverExpenses: serverExpenses.length
      },
      serverExpenses,
      conflicts: results.conflicts
    });
  } catch (error) {
    console.error('Sync error:', error);
    res.status(500).json({
      error: 'Sync failed',
      message: error.message
    });
  }
});

module.exports = router;
