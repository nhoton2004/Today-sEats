const express = require('express');
const router = express.Router();
const geminiService = require('../services/gemini.service');

router.get('/health', async (req, res) => {
    const health = await geminiService.checkHealth();
    res.status(health.ok ? 200 : 503).json(health);
});

router.post('/suggest-from-ingredients', async (req, res) => {
    try {
        const { ingredients } = req.body;

        if (!ingredients || ingredients.trim() === '') {
            return res.status(400).json({
                error: 'Vui lòng nhập nguyên liệu'
            });
        }

        console.log('🤖 AI request:', ingredients);

        const suggestions = await geminiService.suggestDishesFromIngredients(ingredients);

        console.log('✅ AI response:', JSON.stringify(suggestions, null, 2));

        res.json(suggestions);
    } catch (error) {
        console.error('❌ AI suggestion error:', error);
        res.status(500).json({
            error: 'Không thể kết nối với AI. Vui lòng thử lại sau.'
        });
    }
});

module.exports = router;
