// Migrated to OpenRouter (DeepSeek R1)
// Using native fetch (Node 18+)
const fetch = global.fetch;

class GeminiService { // Keeping Class Name to avoid breaking imports in other files
  constructor() {
    if (!process.env.OPENROUTER_API_KEY) {
      console.warn('⚠️  OPENROUTER_API_KEY not found in environment');
      this.apiKey = null;
      return;
    }
    console.log('✅ AI Service initialized with OpenRouter Key');
    this.apiKey = process.env.OPENROUTER_API_KEY;
    // Model from screenshot
    this.model = 'tngtech/deepseek-r1t2-chimera:free';
    this.endpoint = 'https://openrouter.ai/api/v1/chat/completions';
    this.cache = new Map();
  }

  _cleanCache() {
    const now = Date.now();
    for (const [key, value] of this.cache.entries()) {
      if (now > value.expiry) this.cache.delete(key);
    }
  }

  async _retryOperation(operation, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (error) {
        if (i === maxRetries - 1) throw error;
        if (error.status === 429 || error.status === 503 || (error.message && error.message.includes('429'))) {
          const delay = Math.pow(2, i + 1) * 1000;
          console.log(`⚠️ Retry ${i + 1}/${maxRetries} after ${delay}ms due to ${error.status}`);
          await new Promise(resolve => setTimeout(resolve, delay));
        } else {
          throw error;
        }
      }
    }
  }

  async _callOpenRouter(messages) {
    if (!fetch) throw new Error('Node.js version too old (requires Node 18+ for native fetch)');

    const response = await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://todays-eats.app',
        'X-Title': 'Todays Eats'
      },
      body: JSON.stringify({
        model: this.model,
        messages: messages,
        temperature: 0.6,
        max_tokens: 4000
      })
    });

    if (!response.ok) {
      const errorBody = await response.text();
      throw {
        status: response.status,
        message: `OpenRouter Error: ${response.statusText}`,
        details: errorBody
      };
    }

    const data = await response.json();
    if (!data.choices || data.choices.length === 0) {
      throw new Error('OpenRouter returned no choices');
    }
    return data.choices[0].message.content;
  }

  async checkHealth() {
    if (!this.apiKey) {
      return { ok: false, service: 'openrouter', message: 'Missing API Key' };
    }

    const start = Date.now();
    try {
      await this._callOpenRouter([{ role: 'user', content: 'Hi' }]);
      const latency = Date.now() - start;

      return {
        ok: true,
        service: 'OpenRouter (DeepSeek R1)',
        model: this.model,
        latencyMs: latency
      };
    } catch (error) {
      console.error('❌ AI Health Check Failed:', error);
      return {
        ok: false,
        service: 'openrouter',
        errorCode: error.status || 500,
        message: error.message
      };
    }
  }

  async suggestDishesFromIngredients(ingredients) {
    if (!this.apiKey) {
      return { suggestions: [], message: "Missing API Key" };
    }

    // 1. Check Cache
    this._cleanCache();
    const sortedIngredients = ingredients.split(',').map(s => s.trim().toLowerCase()).sort().join(',');
    const cacheKey = `dish_or_v3_${sortedIngredients}`; // Bump version to v3 for Schema v4

    if (this.cache.has(cacheKey)) {
      const cached = this.cache.get(cacheKey);
      if (Date.now() < cached.expiry) {
        console.log('⚡ Serving from cache:', cacheKey);
        return cached.data;
      }
    }

    const prompt = `Bạn là “Bếp trưởng AI” cho ứng dụng di động Today’s Eats.

MỤC TIÊU:
Giúp người dùng trả lời câu hỏi:
“Hôm nay nấu món gì?” dựa trên nguyên liệu có sẵn trong tủ lạnh.

NGUYÊN TẮC BẮT BUỘC:
1. CHỈ sử dụng nguyên liệu người dùng cung cấp.
2. KHÔNG bịa thêm nguyên liệu chính không có trong danh sách.
3. Gia vị cơ bản LUÔN CÓ SẴN: muối, tiêu, dầu ăn, nước mắm, nước tương.
4. Nếu thiếu nguyên liệu quan trọng, liệt kê rõ trong missingIngredients.
5. Ưu tiên:
   - Món Việt Nam
   - Dễ nấu
   - Ít bước
   - Thời gian ngắn
6. Không quảng cáo, không lan man, không giải thích ngoài JSON.
7. KHÔNG dùng markdown.
8. BẮT BUỘC trả về JSON hợp lệ để ứng dụng parse trực tiếp.

PHONG CÁCH:
- Thân thiện như bếp trưởng
- Ngắn gọn
- Phù hợp người không rành nấu ăn

PROMPT CHỐNG AI “NGÁO”:
Nếu thông tin không đủ để nấu món hoàn chỉnh, trả về dishes rỗng.
Tuyệt đối không đoán mò hoặc bịa món.

USER PROMPT (dữ liệu):
Bữa ăn: Tự do (Sáng / Trưa / Tối)
Nguyên liệu trong tủ lạnh:
${ingredients}

Yêu cầu:
- Gợi ý tối đa 5 món ăn
- Không thêm nguyên liệu ngoài danh sách
- Nếu thiếu nguyên liệu, liệt kê trong missingIngredients
- Ưu tiên món dễ nấu

OUTPUT JSON (Bắt buộc đúng format):
{
  "meal": "Trưa",
  "ingredients": ["..."],
  "dishes": [
    {
      "name": "Tên món",
      "matchPercent": 80,
      "difficulty": "dễ",
      "timeMinutes": 15,
      "missingIngredients": ["tỏi"],
      "shortDescription": "Mô tả ngắn gọn...",
      "quickSteps": ["B1...", "B2..."]
    }
  ],
  "message": "Lời khuyên..."
}`;

    try {
      const data = await this._retryOperation(async () => {
        let text = await this._callOpenRouter([{ role: 'user', content: prompt }]);

        // Clean DeepSeek <think> tags if present
        text = text.replace(/<think>[\s\S]*?<\/think>/g, '');

        // Clean Code Blocks
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
      console.error('❌ OpenRouter API error:', error);

      if (error.status === 429 || (error.message && error.message.includes('429'))) {
        throw {
          status: 429,
          message: 'Server AI đang quá tải (429). Vui lòng đợi.',
          retryAfter: 30
        };
      }
      throw error;
    }
  }
}

module.exports = new GeminiService();
