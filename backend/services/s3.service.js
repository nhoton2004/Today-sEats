const {
  PutObjectCommand,
  DeleteObjectCommand,
  GetObjectCommand
} = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { s3Client, s3Config } = require('../config/aws.config');
const crypto = require('crypto');
const path = require('path');

class S3Service {
  constructor() {
    this.client = s3Client;
    this.bucket = s3Config.bucket;
    this.region = s3Config.region;
  }

  // Generate unique filename
  generateFileName(originalName) {
    const ext = path.extname(originalName);
    const timestamp = Date.now();
    const randomString = crypto.randomBytes(8).toString('hex');
    return `dishes/${timestamp}-${randomString}${ext}`;
  }

  // Upload file to S3
  async uploadFile(file, folder = 'dishes') {
    try {
      const fileName = this.generateFileName(file.originalname);
      const key = `${folder}/${fileName}`;

      const command = new PutObjectCommand({
        Bucket: this.bucket,
        Key: key,
        Body: file.buffer,
        ContentType: file.mimetype,
        // ACL: 'public-read', // ACLs are often disabled in modern buckets, rely on Bucket Policy or Origin Access
      });

      await this.client.send(command);

      // Generate region appropriate URL
      // If region is us-east-1, it can be s3.amazonaws.com, but s3.us-east-1 works too.
      // Generic format: https://<bucket>.s3.<region>.amazonaws.com/<key>
      const url = `https://${this.bucket}.s3.${this.region}.amazonaws.com/${key}`;

      // console.log(`✅ Uploaded to S3: ${url}`);

      return {
        success: true,
        url,
        key,
        fileName,
      };
    } catch (error) {
      console.error('S3 Upload Error:', error);
      throw new Error(`Failed to upload file: ${error.message}`);
    }
  }

  // Delete file from S3
  async deleteFile(key) {
    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucket,
        Key: key,
      });

      await this.client.send(command);

      return {
        success: true,
        message: 'File deleted successfully',
      };
    } catch (error) {
      console.error('S3 Delete Error:', error);
      throw new Error(`Failed to delete file: ${error.message}`);
    }
  }

  // Get presigned URL for temporary access
  async getPresignedUrl(key, expiresIn = 3600) {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucket,
        Key: key,
      });

      const url = await getSignedUrl(this.client, command, { expiresIn });

      return {
        success: true,
        url,
        expiresIn,
      };
    } catch (error) {
      console.error('S3 Presigned URL Error:', error);
      throw new Error(`Failed to generate presigned URL: ${error.message}`);
    }
  }

  // Check if S3 is configured
  isConfigured() {
    return !!(
      process.env.AWS_ACCESS_KEY_ID &&
      process.env.AWS_SECRET_ACCESS_KEY &&
      process.env.AWS_S3_BUCKET
    );
  }
}

module.exports = new S3Service();
