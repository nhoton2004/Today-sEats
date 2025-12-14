const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '../.env') });

const s3Service = require('../services/s3.service');

async function testUpload() {
    console.log('🧪 Testing S3 Upload...');

    const mockFile = {
        originalname: 'test_server_upload.jpg',
        mimetype: 'image/jpeg',
        buffer: Buffer.from('mock_image_data_for_testing'),
    };

    try {
        if (!s3Service.isConfigured()) {
            console.error('❌ S3 not configured (Missing ENV variables).');
            return;
        }

        const result = await s3Service.uploadFile(mockFile, 'test_uploads');
        console.log('✅ Upload Success!');
        console.log('   URL:', result.url);
        console.log('   Key:', result.key);
    } catch (error) {
        console.error('❌ Upload Failed:', error.message);
        if (error.message.includes('SignatureDoesNotMatch')) {
            console.error('👉 TIP: Check your .env file for trailing spaces in AccessKey/SecretKey.');
        }
        if (error.message.includes('Endpoint')) {
            console.error('👉 TIP: Check your AWS_REGION setting.');
        }
    }
}

testUpload();
