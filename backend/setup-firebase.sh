#!/bin/bash
# Script hỗ trợ setup Firebase Service Account Key

echo "🔥 Firebase Service Account Setup Helper"
echo "=========================================="
echo ""
echo "Bước 1: Download Firebase Service Account Key"
echo "  1. Truy cập: https://console.firebase.google.com/"
echo "  2. Chọn project: Today's Eats"
echo "  3. Vào: Project Settings → Service Accounts"
echo "  4. Click: Generate New Private Key"
echo ""
echo "Bước 2: Copy file vào đây"
echo "  Đường dẫn hiện tại: $(pwd)"
echo ""
read -p "Bạn đã download file chưa? (y/n): " downloaded

if [ "$downloaded" = "y" ]; then
    echo ""
    echo "Nhập tên file vừa download (để trong ~/Downloads/):"
    echo "  Ví dụ: today-s-eats-firebase-adminsdk-xxxxx.json"
    read -p "Tên file: " filename
    
    source_file="$HOME/Downloads/$filename"
    
    if [ -f "$source_file" ]; then
        # Copy file vào backend
        cp "$source_file" "$(pwd)/$filename"
        
        # Xóa symlink cũ nếu có
        rm -f serviceAccountKey.json
        
        # Tạo symlink mới
        ln -s "$(pwd)/$filename" serviceAccountKey.json
        
        echo ""
        echo "✅ Hoàn tất! Firebase Service Account đã được cấu hình."
        echo "   File: $(pwd)/$filename"
        echo "   Symlink: serviceAccountKey.json → $filename"
        echo ""
        echo "🔄 Restart backend để áp dụng thay đổi:"
        echo "   Nhấn Ctrl+C trong terminal đang chạy 'npm start'"
        echo "   Sau đó chạy: npm start"
    else
        echo ""
        echo "❌ Không tìm thấy file: $source_file"
        echo "   Vui lòng kiểm tra lại tên file và thử lại."
    fi
else
    echo ""
    echo "📝 Hãy download file trước, sau đó chạy lại script này:"
    echo "   bash setup-firebase.sh"
fi
