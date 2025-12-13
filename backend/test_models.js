require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

const modelsToTest = [
    'gemini-2.0-flash-exp',
    'gemini-2.0-flash-lite',
    'gemini-flash-latest',
    'gemini-pro-latest'
];

async function testModels() {
    console.log('🔍 Testing models for availability...');
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

    for (const modelName of modelsToTest) {
        process.stdout.write(`Testing ${modelName}... `);
        try {
            const model = genAI.getGenerativeModel({ model: modelName });
            const result = await model.generateContent('Hello');
            await result.response;
            console.log('✅ OK');

            // If we find one that works, print it clearly
            console.log(`\n🎉 FOUND WORKING MODEL: ${modelName}`);
            process.exit(0);
        } catch (error) {
            console.log(`❌ FAIL (${error.status || error.message})`);
            if (error.message.includes('429')) console.log('   -> Quota Exceeded / Limit 0');
        }
    }
    console.log('\n❌ All models failed.');
}

testModels();
