const { GoogleGenerativeAI } = require('@google/generative-ai');

class GeminiService {
  constructor() {
    if (!process.env.GEMINI_API_KEY) {
      console.warn('⚠️  GEMINI_API_KEY not found in environment');
      this.genAI = null;
      return;
    }
    console.log('✅ Gemini Service initialized with API Key');
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    this.model = this.genAI.getGenerativeModel({
      model: 'gemini-2.0-flash',
      generationConfig: {
        maxOutputTokens: 1000, // Optimize token usage
        temperature: 0.7,
      }
    });
    this.cache = new Map(); // Simple in-memory cache
  }

  // Helper: Cache Clean up (simplest form)
  _cleanCache() {
    const now = Date.now();
    for (const [key, value] of this.cache.entries()) {
      if (now > value.expiry) this.cache.delete(key);
    }
  }

  // Helper: Retry with Exponential Backoff
  async _retryOperation(operation, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (error) {
        if (i === maxRetries - 1) throw error; // Last attempt failed

        // Only retry on 429 or 503
        if (error.status === 429 || error.status === 503 || error.message.includes('429')) {
          const delay = Math.pow(2, i + 1) * 1000; // 2s, 4s, 8s
          console.log(`⚠️ Retry ${i + 1}/${maxRetries} after ${delay}ms due to ${error.status}`);
          await new Promise(resolve => setTimeout(resolve, delay));
        } else {
          throw error; // Don't retry other errors
        }
      }
    }
  }

  async checkHealth() {
    if (!this.genAI) {
      return { ok: false, service: 'gemini', message: 'Missing API Key' };
    }

    const start = Date.now();
    try {
      // Minimal token generation to test connection
      const result = await this.model.generateContent('Hi');
      await result.response;
      const latency = Date.now() - start;

      return {
        ok: true,
        service: 'gemini',
        model: 'gemini-2.0-flash',
        latencyMs: latency
      };
    } catch (error) {
      console.error('❌ Gemini Health Check Failed:', error);

      let friendlyMessage = error.message;
      let code = error.status || 500;

      if (error.message.includes('429') || error.message.includes('Too Many Requests') || error.status === 429) {
        friendlyMessage = 'Server quá tải (429). Vui lòng đợi 30s.';
        code = 429;
      } else if (error.message.includes('404') || error.status === 404) {
        friendlyMessage = 'Lỗi Model (404). Backend cần update model mới.';
        code = 404;
      }

      return {
        ok: false,
        service: 'gemini',
        errorCode: code,
        message: friendlyMessage
      };
    }
  }

  async suggestDishesFromIngredients(ingredients) {
    if (!this.genAI) {
      console.error('❌ Gemini API Key is missing');
      return { dishes: [] }; // Fallback
    }

    // 1. Check Cache
    this._cleanCache();
    const sortedIngredients = ingredients.split(',').map(s => s.trim().toLowerCase()).sort().join(',');
    const cacheKey = `dish_suggestion_${sortedIngredients}`;

    if (this.cache.has(cacheKey)) {
      const cached = this.cache.get(cacheKey);
      if (Date.now() < cached.expiry) {
        console.log('⚡ Serving from cache:', cacheKey);
        return cached.data;
      }
    }

    const prompt = `Bạn là đầu bếp Việt. Gợi ý 3 món ăn từ: ${ingredients}.
Trả về JSON (không markdown):
{
  "dishes": [
    {
      "name": "Tên món",
      "match_percent": 80,
      "missing_ingredients": ["a", "b"],
      "additionalIngredients": ["a", "b"],
      "quick_steps": ["B1...", "B2..."],
      "cookingInstructions": [{"step":1, "instruction":"...", "duration":5}],
      "cookingTime": 30,
      "servings": 2,
      "score": 0.8
    }
  ]
}`;

    try {
      const data = await this._retryOperation(async () => {
        const result = await this.model.generateContent(prompt);
        const response = await result.response;
        let text = response.text();
        text = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
        return JSON.parse(text);
      });

      // 2. Save to Cache (TTL 5 mins)
      this.cache.set(cacheKey, {
        data: data,
        expiry: Date.now() + 5 * 60 * 1000
      });

      return data;
    } catch (error) {
      console.error('❌ Gemini API error:', error);

      // Throw structured error for Frontend
      if (error.status === 429 || error.message.includes('429')) {
        throw {
          status: 429,
          message: 'Server đang bận (429). Vui lòng đợi.',
          retryAfter: 30
        };
      }

      throw error; // Re-throw generic
    }
  }
}

module.exports = new GeminiService();
