const { S3Client } = require('@aws-sdk/client-s3');

const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'ap-southeast-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
  },
});

const s3Config = {
  bucket: process.env.AWS_S3_BUCKET || 'todays-eats-images',
  region: process.env.AWS_REGION || 'ap-southeast-1',
};

module.exports = { s3Client, s3Config };
