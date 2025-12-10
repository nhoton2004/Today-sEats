# 🚀 Hướng Dẫn Deploy Backend Today's Eats

## 📋 Tổng Quan

Backend Today's Eats có thể deploy lên nhiều nền tảng khác nhau. Dưới đây là các option phổ biến.

---

## Option 1: Railway (Khuyến nghị ⭐)

### Ưu điểm:
- ✅ Miễn phí $5/tháng credit
- ✅ Tự động deploy từ GitHub
- ✅ Hỗ trợ environment variables
- ✅ HTTPS tự động
- ✅ Logs và monitoring tốt

### Các bước:

#### 1. Chuẩn bị code
```bash
# Tạo file .gitignore nếu chưa có
cat > .gitignore << 'EOF'
node_modules/
.env
.DS_Store
serviceAccountKey.json
*.log
EOF

# Commit code
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

#### 2. Deploy lên Railway

1. Truy cập [railway.app](https://railway.app)
2. **Sign up** bằng GitHub
3. Click **New Project** → **Deploy from GitHub repo**
4. Chọn repo `Today-sEats`
5. Railway sẽ tự động detect Node.js project

#### 3. Configure Environment Variables

Vào **Variables** tab và thêm:

```env
PORT=5000
NODE_ENV=production
MONGODB_URI=mongodb+srv://admin_backend_todayseats:7powIkXvbBVl7fNJ@cluster0.t4exz8c.mongodb.net/todays_eats?retryWrites=true&w=majority&appName=Cluster0
AWS_ACCESS_KEY_ID=todays-eats-s3-user-at-106189426512
AWS_SECRET_ACCESS_KEY=ABSKdG9kYXlzLWVhdHMtczMtdXNlci1hdC0xMDYxODk0MjY1MTI6MUNuK2V0NE15YU9EN1ZmTkE5Si9hZktOaEF5RjFuNjdEM2E0MUJlZktpSkpiNHdoL0xmZCtuS28xYW89
AWS_REGION=ap-southeast-1
AWS_S3_BUCKET=todays-eats-images
JWT_SECRET=todays_eats_secret_key_2024_change_in_production
CORS_ORIGIN=*
```

#### 4. Configure Start Command

Vào **Settings** → **Build** → **Start Command**:
```bash
node backend/server-mongodb.js
```

Hoặc tạo file `Procfile` trong root:
```
web: cd backend && node server-mongodb.js
```

#### 5. Deploy

Railway sẽ tự động build và deploy. Sau khi xong:
- URL sẽ hiện ở tab **Deployments**
- Ví dụ: `https://todays-eats.up.railway.app`

#### 6. Test API

```bash
curl https://todays-eats.up.railway.app/api/health
curl https://todays-eats.up.railway.app/api/dishes
```

---

## Option 2: Render.com

### Ưu điểm:
- ✅ Free tier tốt
- ✅ Tự động sleep sau 15 phút không hoạt động (free tier)
- ✅ Dễ setup

### Các bước:

1. **Sign up** tại [render.com](https://render.com)
2. **New** → **Web Service**
3. Connect GitHub repo
4. Cấu hình:
   - **Name**: todays-eats-backend
   - **Environment**: Node
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && node server-mongodb.js`
   - **Instance Type**: Free

5. **Environment Variables** (giống Railway)

6. Deploy và test!

---

## Option 3: AWS EC2 (Production)

### Ưu điểm:
- ✅ Kiểm soát hoàn toàn
- ✅ Hiệu năng tốt
- ✅ Không bị sleep

### Các bước:

#### 1. Tạo EC2 Instance

1. Vào AWS Console → EC2
2. **Launch Instance**
3. Chọn **Ubuntu 22.04 LTS**
4. Instance type: **t2.micro** (free tier)
5. Create key pair (download `.pem` file)
6. Security Group:
   - Port 22 (SSH)
   - Port 5000 (Custom TCP)
   - Port 80 (HTTP)
   - Port 443 (HTTPS)

#### 2. Connect to EC2

```bash
chmod 400 your-key.pem
ssh -i "your-key.pem" ubuntu@your-ec2-ip
```

#### 3. Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Git
sudo apt install -y git

# Install PM2 (process manager)
sudo npm install -g pm2
```

#### 4. Clone và Setup Project

```bash
# Clone repo
git clone https://github.com/nhoton2004/Today-sEats.git
cd Today-sEats/backend

# Install dependencies
npm install

# Create .env file
nano .env
# Paste environment variables từ local .env

# Test server
node server-mongodb.js
```

#### 5. Setup PM2 (Auto-restart)

```bash
# Start with PM2
pm2 start server-mongodb.js --name todays-eats

# Save PM2 config
pm2 save

# Auto-start on boot
pm2 startup
# Copy-paste command từ output

# Check status
pm2 status
pm2 logs todays-eats
```

#### 6. Setup Nginx Reverse Proxy

```bash
# Install Nginx
sudo apt install -y nginx

# Create config
sudo nano /etc/nginx/sites-available/todays-eats
```

Paste config:
```nginx
server {
    listen 80;
    server_name your-domain.com;  # Hoặc dùng IP

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/todays-eats /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 7. Setup SSL với Let's Encrypt (Optional)

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## Option 4: Vercel (Serverless)

### Lưu ý:
- ❌ Vercel miễn phí chỉ hỗ trợ serverless functions
- ⚠️ Cần chuyển Express app sang serverless format
- ⚠️ MongoDB connection có thể timeout

### Các bước:

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Tạo `vercel.json`:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "backend/server-mongodb.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "backend/server-mongodb.js"
    }
  ]
}
```

3. Deploy:
```bash
vercel --prod
```

---

## 🔧 Cấu Hình Flutter App

Sau khi deploy, cập nhật `lib/core/services/api_service.dart`:

```dart
class ApiService {
  // Development
  // static const String baseUrl = 'http://localhost:5000/api';
  
  // Production (Railway)
  static const String baseUrl = 'https://todays-eats.up.railway.app/api';
  
  // Production (AWS)
  // static const String baseUrl = 'http://your-ec2-ip:5000/api';
  
  // ...
}
```

---

## 📊 Monitoring

### Railway
- Logs: Railway Dashboard → Logs tab
- Metrics: Railway Dashboard → Metrics tab

### Render
- Logs: Render Dashboard → Logs
- Metrics: Render Dashboard → Metrics

### AWS EC2
```bash
# PM2 logs
pm2 logs todays-eats

# PM2 status
pm2 status

# PM2 monitoring
pm2 monit

# System resources
htop
```

---

## 🐛 Troubleshooting

### MongoDB Connection Failed
```bash
# Check MONGODB_URI format
echo $MONGODB_URI

# Test connection từ server
node -e "require('mongoose').connect(process.env.MONGODB_URI).then(() => console.log('OK')).catch(console.error)"
```

### AWS S3 Upload Failed
```bash
# Check credentials
echo $AWS_ACCESS_KEY_ID
echo $AWS_REGION

# Verify S3 bucket exists
aws s3 ls s3://todays-eats-images
```

### Port Already in Use
```bash
# Find process using port 5000
lsof -i :5000
# hoặc
netstat -tulpn | grep 5000

# Kill process
kill -9 <PID>
```

### PM2 Not Starting
```bash
# Delete PM2 cache
pm2 delete all
pm2 kill

# Start again
pm2 start server-mongodb.js --name todays-eats
```

---

## 📝 Best Practices

1. **Security**
   - ✅ Không commit `.env` lên Git
   - ✅ Dùng strong JWT_SECRET
   - ✅ Enable CORS chỉ cho domain cụ thể (production)
   - ✅ Rate limiting API

2. **Performance**
   - ✅ Enable MongoDB indexes
   - ✅ Cache static assets
   - ✅ Compress responses (gzip)
   - ✅ PM2 cluster mode (multiple instances)

3. **Monitoring**
   - ✅ Setup error tracking (Sentry)
   - ✅ Monitor API latency
   - ✅ Alert when server down
   - ✅ Regular backups

---

## 🎯 Next Steps

1. **Setup CI/CD**
   - GitHub Actions auto-deploy
   - Run tests before deploy
   - Automatic rollback on errors

2. **Add Features**
   - Real-time updates (Socket.io)
   - Email notifications (SendGrid)
   - Push notifications (Firebase Cloud Messaging)

3. **Scale**
   - Load balancer
   - Multiple instances
   - CDN for images
   - Redis caching

---

## 📞 Support

Nếu gặp vấn đề:
1. Check logs trên platform
2. Test API với `curl`
3. Verify environment variables
4. Check MongoDB Atlas Network Access (whitelist IP `0.0.0.0/0`)

**Happy Deploying! 🚀**
