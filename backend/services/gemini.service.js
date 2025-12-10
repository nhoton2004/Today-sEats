const { GoogleGenerativeAI } = require('@google/generative-ai');

class GeminiService {
    constructor() {
        if (!process.env.GEMINI_API_KEY) {
            console.warn('⚠️  GEMINI_API_KEY not found in environment');
            this.genAI = null;
            return;
        }

        this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        this.model = this.genAI.getGenerativeModel({ model: 'gemini-pro' });
    }

    async suggestDishesFromIngredients(ingredients) {
        if (!this.genAI) {
            throw new Error('Gemini AI not configured. Please set GEMINI_API_KEY');
        }

        const prompt = `Bạn là chuyên gia nấu ăn Việt Nam. Dựa trên các nguyên liệu sau:
${ingredients}

Hãy gợi ý 3-5 món ăn phù hợp và cung cấp thông tin chi tiết. Trả về ĐÚNG format JSON sau (KHÔNG thêm markdown, KHÔNG thêm \`\`\`json):

{
  "dishes": [
    {
      "name": "Tên món ăn",
      "additionalIngredients": ["nguyên liệu cần thêm 1", "nguyên liệu 2"],
      "cookingInstructions": [
        {
          "step": 1,
          "instruction": "Mô tả cách làm bước 1",
          "duration": 5
        },
        {
          "step": 2,
          "instruction": "Mô tả cách làm bước 2",
          "duration": 10,
          "tips": "Mẹo nấu ăn (optional)"
        }
      ],
      "cookingTime": 30,
      "servings": 2
    }
  ]
}

Lưu ý:
- Ưu tiên món Việt Nam
- additionalIngredients: chỉ liệt kê nguyên liệu CHƯA có trong danh sách đã cho
- duration: thời gian tính bằng phút
- cookingTime: tổng thời gian nấu (phút)
- Chỉ trả về JSON, không thêm giải thích`;

        try {
            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            let text = response.text();

            // Clean up response - remove markdown code blocks if present
            text = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();

            // Parse JSON
            const data = JSON.parse(text);
            return data;
        } catch (error) {
            console.error('Gemini API error:', error);

            // Fallback response if API fails
            return {
                dishes: [
                    {
                        name: 'Lỗi AI',
                        additionalIngredients: [],
                        cookingInstructions: [
                            {
                                step: 1,
                                instruction: 'Không thể kết nối với AI. Vui lòng thử lại sau.',
                                duration: 0
                            }
                        ],
                        cookingTime: 0,
                        servings: 0
                    }
                ]
            };
        }
    }
}

module.exports = new GeminiService();
