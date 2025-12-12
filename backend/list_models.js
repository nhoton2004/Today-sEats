require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

async function listModels() {
    if (!process.env.GEMINI_API_KEY) {
        console.error('❌ GEMINI_API_KEY missing');
        return;
    }

    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

    try {
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' }); // Dummy init to access client? 
        // Actually the SDK doesn't expose listModels directly on the top class usually, 
        // but deeper down or via specific manager. 
        // Wait, let's just try to call a known working model or fetch models list if possible.
        // The error message suggests calling ListModels.
        // In the Node SDK, it might not be directly exposed easily in high level.

        // Let's try a direct REST call to be sure, using the key.
        const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${process.env.GEMINI_API_KEY}`;
        const response = await fetch(url);
        const data = await response.json();

        if (data.models) {
            console.log('✅ Available Models:');
            data.models.forEach(m => {
                if (m.supportedGenerationMethods && m.supportedGenerationMethods.includes('generateContent')) {
                    console.log(`- ${m.name}`);
                }
            });
        } else {
            console.error('❌ Error listing models:', data);
        }

    } catch (error) {
        console.error('❌ Exception:', error);
    }
}

listModels();
