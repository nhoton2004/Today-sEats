const { S3Client } = require('@aws-sdk/client-s3');

// Ensure Region is set, default to us-east-1 if missing
const region = (process.env.AWS_REGION || 'us-east-1').trim();
const accessKeyId = (process.env.AWS_ACCESS_KEY_ID || '').trim();
const secretAccessKey = (process.env.AWS_SECRET_ACCESS_KEY || '').trim();
const bucket = (process.env.AWS_S3_BUCKET || '').trim();

console.log('🔌 AWS Log:');
console.log(`   - Region: [${region}]`);
console.log(`   - Bucket: [${bucket}]`);
console.log(`   - AccessKey: [${accessKeyId.substring(0, 5)}...${accessKeyId.slice(-4)}]`);
console.log(`   - SecretKey: [${secretAccessKey ? 'Loaded & Trimmed' : 'MISSING'}]`);

const s3Client = new S3Client({
  region: region,
  credentials: {
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
  },
});

const s3Config = {
  bucket: bucket || 'todays-eats-images',
  region: region,
};

module.exports = { s3Client, s3Config };
