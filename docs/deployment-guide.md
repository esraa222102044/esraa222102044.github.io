# دليل النشر والتثبيت - نظام New Graphic ERP

<div dir="rtl">

## محتويات الدليل

1. [متطلبات الخادم](#متطلبات-الخادم)
2. [إعداد الخادم](#إعداد-الخادم)
3. [تثبيت التطبيق](#تثبيت-التطبيق)
4. [إعداد قاعدة البيانات](#إعداد-قاعدة-البيانات)
5. [إعداد خادم الويب](#إعداد-خادم-الويب)
6. [SSL Certificate](#ssl-certificate)
7. [النسخ الاحتياطي](#النسخ-الاحتياطي)
8. [الصيانة](#الصيانة)
9. [استكشاف الأخطاء](#استكشاف-الأخطاء)

---

## 1. متطلبات الخادم

### 1.1 متطلبات البرامج

| البرنامج | الإصدار المطلوب | ملاحظات |
|----------|-----------------|----------|
| Ubuntu Server | 20.04 LTS أو أحدث | موصى به |
| PHP | 8.0 أو أحدث | مع الإضافات المطلوبة |
| MySQL | 8.0 أو أحدث | أو PostgreSQL 15+ |
| Nginx | 1.18 أو أحدث | أو Apache 2.4+ |
| Composer | 2.x | لإدارة حزم PHP |
| Node.js | 16.x أو أحدث | لبناء Frontend |
| Git | 2.x | للنشر |

### 1.2 امتدادات PHP المطلوبة

```bash
- php8.1-cli
- php8.1-fpm
- php8.1-mysql
- php8.1-pgsql (إذا كنت تستخدم PostgreSQL)
- php8.1-mbstring
- php8.1-xml
- php8.1-bcmath
- php8.1-curl
- php8.1-gd
- php8.1-zip
- php8.1-intl
```

### 1.3 المتطلبات الأجهزة الموصى بها

| المورد | الحد الأدنى | الموصى به |
|--------|-------------|------------|
| المعالج | 2 Cores | 4 Cores |
| الذاكرة | 2 GB RAM | 4 GB RAM أو أكثر |
| التخزين | 20 GB | 50 GB أو أكثر |
| النطاق الترددي | 100 Mbps | 1 Gbps |

---

## 2. إعداد الخادم

### 2.1 تحديث النظام

```bash
sudo apt update
sudo apt upgrade -y
```

### 2.2 تثبيت PHP وامتداداته

```bash
# إضافة مستودع PHP
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# تثبيت PHP 8.1
sudo apt install -y php8.1 php8.1-fpm php8.1-cli \
  php8.1-mysql php8.1-mbstring php8.1-xml \
  php8.1-bcmath php8.1-curl php8.1-gd \
  php8.1-zip php8.1-intl

# التحقق من التثبيت
php -v
```

### 2.3 تثبيت Composer

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
```

### 2.4 تثبيت MySQL

```bash
sudo apt install -y mysql-server

# تأمين MySQL
sudo mysql_secure_installation

# الدخول إلى MySQL
sudo mysql
```

```sql
-- إنشاء قاعدة بيانات
CREATE DATABASE new_graphic_erp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- إنشاء مستخدم
CREATE USER 'erp_user'@'localhost' IDENTIFIED BY 'secure_password_here';

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON new_graphic_erp.* TO 'erp_user'@'localhost';

-- تطبيق التغييرات
FLUSH PRIVILEGES;

EXIT;
```

### 2.5 تثبيت Node.js و npm

```bash
# تثبيت من مستودع NodeSource
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# التحقق من التثبيت
node -v
npm -v
```

### 2.6 تثبيت Git

```bash
sudo apt install -y git
git --version
```

---

## 3. تثبيت التطبيق

### 3.1 إنشاء مستخدم للتطبيق

```bash
# إنشاء مستخدم
sudo adduser erp

# إضافة للمجموعة www-data
sudo usermod -aG www-data erp
```

### 3.2 استنساخ المشروع

```bash
# التبديل للمستخدم
sudo su - erp

# الانتقال لمجلد الويب
cd /var/www

# استنساخ المشروع
git clone https://github.com/esraa222102044/esraa222102044.github.io.git new-graphic-erp
cd new-graphic-erp
```

### 3.3 إعداد Backend

```bash
cd backend

# تثبيت الحزم
composer install --optimize-autoloader --no-dev

# نسخ ملف البيئة
cp .env.example .env

# تحرير ملف البيئة
nano .env
```

**تكوين ملف .env:**

```env
APP_NAME="New Graphic ERP"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://newgraphic.me

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=new_graphic_erp
DB_USERNAME=erp_user
DB_PASSWORD=secure_password_here

BROADCAST_DRIVER=log
CACHE_DRIVER=redis
FILESYSTEM_DISK=local
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="noreply@newgraphic.me"
MAIL_FROM_NAME="${APP_NAME}"
```

```bash
# توليد مفتاح التطبيق
php artisan key:generate

# إنشاء رابط التخزين
php artisan storage:link

# تعيين الصلاحيات
sudo chown -R erp:www-data /var/www/new-graphic-erp
sudo chmod -R 775 /var/www/new-graphic-erp/backend/storage
sudo chmod -R 775 /var/www/new-graphic-erp/backend/bootstrap/cache
```

### 3.4 إعداد Frontend

```bash
cd ../frontend

# تثبيت الحزم
npm install

# نسخ ملف البيئة
cp .env.example .env

# تحرير ملف البيئة
nano .env
```

**تكوين ملف .env:**

```env
VITE_API_URL=https://newgraphic.me/api
VITE_APP_NAME="New Graphic ERP"
```

```bash
# بناء للإنتاج
npm run build

# سيتم إنشاء المجلد dist/
```

---

## 4. إعداد قاعدة البيانات

```bash
cd /var/www/new-graphic-erp/backend

# تشغيل Migrations
php artisan migrate --force

# تشغيل Seeders (البيانات الأولية)
php artisan db:seed --force

# في حالة وجود ملف SQL
mysql -u erp_user -p new_graphic_erp < ../database/schemas/database-schema.sql
```

---

## 5. إعداد خادم الويب

### 5.1 تثبيت Nginx

```bash
sudo apt install -y nginx

# تمكين Nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 5.2 إنشاء ملف التكوين

```bash
sudo nano /etc/nginx/sites-available/newgraphic.me
```

**محتوى الملف:**

```nginx
# Frontend (Vue.js SPA)
server {
    listen 80;
    listen [::]:80;
    server_name newgraphic.me www.newgraphic.me;
    
    root /var/www/new-graphic-erp/frontend/dist;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/javascript application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Frontend routes (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API Backend
    location /api {
        alias /var/www/new-graphic-erp/backend/public;
        try_files $uri $uri/ @api;

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            include fastcgi_params;
        }
    }

    location @api {
        rewrite /api/(.*)$ /api/index.php?/$1 last;
    }

    # Static assets caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Deny access to sensitive files
    location ~ ^/(\.env|\.git|composer\.json|composer\.lock|package\.json) {
        deny all;
    }

    # Logs
    access_log /var/log/nginx/newgraphic_access.log;
    error_log /var/log/nginx/newgraphic_error.log;
}
```

### 5.3 تفعيل الموقع

```bash
# إنشاء رابط رمزي
sudo ln -s /etc/nginx/sites-available/newgraphic.me /etc/nginx/sites-enabled/

# اختبار التكوين
sudo nginx -t

# إعادة تشغيل Nginx
sudo systemctl reload nginx
```

---

## 6. SSL Certificate

### 6.1 تثبيت Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 6.2 الحصول على شهادة SSL

```bash
sudo certbot --nginx -d newgraphic.me -d www.newgraphic.me
```

اتبع التعليمات وأدخل البريد الإلكتروني.

### 6.3 التجديد التلقائي

```bash
# اختبار التجديد
sudo certbot renew --dry-run

# إضافة cron job للتجديد التلقائي
sudo crontab -e
```

أضف السطر التالي:

```
0 3 * * * certbot renew --quiet && systemctl reload nginx
```

---

## 7. إعداد Redis (اختياري - للأداء)

```bash
# تثبيت Redis
sudo apt install -y redis-server

# تشغيل Redis
sudo systemctl enable redis-server
sudo systemctl start redis-server

# التحقق
redis-cli ping
# يجب أن يرجع: PONG
```

---

## 8. إعداد Queue Worker

### 8.1 تثبيت Supervisor

```bash
sudo apt install -y supervisor
```

### 8.2 إنشاء ملف التكوين

```bash
sudo nano /etc/supervisor/conf.d/new-graphic-erp-worker.conf
```

**محتوى الملف:**

```ini
[program:new-graphic-erp-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/new-graphic-erp/backend/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=erp
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/new-graphic-erp/backend/storage/logs/worker.log
stopwaitsecs=3600
```

### 8.3 تفعيل Worker

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start new-graphic-erp-worker:*

# التحقق من الحالة
sudo supervisorctl status
```

---

## 9. إعداد Scheduled Tasks

```bash
# تحرير crontab للمستخدم erp
sudo crontab -u erp -e
```

أضف السطر التالي:

```
* * * * * cd /var/www/new-graphic-erp/backend && php artisan schedule:run >> /dev/null 2>&1
```

---

## 10. النسخ الاحتياطي

### 10.1 إنشاء سكريبت النسخ الاحتياطي

```bash
sudo nano /usr/local/bin/backup-erp.sh
```

**محتوى السكريبت:**

```bash
#!/bin/bash

# إعدادات
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/new-graphic-erp"
APP_DIR="/var/www/new-graphic-erp"
DB_NAME="new_graphic_erp"
DB_USER="erp_user"
DB_PASS="secure_password_here"

# إنشاء مجلد النسخ الاحتياطي
mkdir -p $BACKUP_DIR

# نسخ احتياطي لقاعدة البيانات
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz

# نسخ احتياطي للملفات
tar -czf $BACKUP_DIR/files_backup_$DATE.tar.gz $APP_DIR/backend/storage

# حذف النسخ الاحتياطية الأقدم من 30 يوم
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
```

```bash
# إعطاء صلاحية التنفيذ
sudo chmod +x /usr/local/bin/backup-erp.sh

# جدولة النسخ الاحتياطي اليومي
sudo crontab -e
```

أضف:

```
0 2 * * * /usr/local/bin/backup-erp.sh >> /var/log/erp-backup.log 2>&1
```

### 10.2 الاستعادة من النسخ الاحتياطي

```bash
# استعادة قاعدة البيانات
gunzip < /backups/new-graphic-erp/db_backup_YYYYMMDD_HHMMSS.sql.gz | \
  mysql -u erp_user -p new_graphic_erp

# استعادة الملفات
tar -xzf /backups/new-graphic-erp/files_backup_YYYYMMDD_HHMMSS.tar.gz -C /
```

---

## 11. الصيانة

### 11.1 تفعيل وضع الصيانة

```bash
cd /var/www/new-graphic-erp/backend
php artisan down --message="نظام قيد الصيانة" --retry=60
```

### 11.2 التحديثات

```bash
# السحب من Git
cd /var/www/new-graphic-erp
git pull origin main

# تحديث Backend
cd backend
composer install --optimize-autoloader --no-dev
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# تحديث Frontend
cd ../frontend
npm install
npm run build

# إعادة تشغيل Workers
sudo supervisorctl restart new-graphic-erp-worker:*

# إعادة تشغيل PHP-FPM
sudo systemctl restart php8.1-fpm

# إعادة تحميل Nginx
sudo systemctl reload nginx
```

### 11.3 إلغاء وضع الصيانة

```bash
php artisan up
```

---

## 12. مراقبة الأداء

### 12.1 مراقبة Logs

```bash
# Application logs
tail -f /var/www/new-graphic-erp/backend/storage/logs/laravel.log

# Nginx access log
tail -f /var/log/nginx/newgraphic_access.log

# Nginx error log
tail -f /var/log/nginx/newgraphic_error.log

# PHP-FPM log
tail -f /var/log/php8.1-fpm.log

# Worker log
tail -f /var/www/new-graphic-erp/backend/storage/logs/worker.log
```

### 12.2 مراقبة الموارد

```bash
# استخدام CPU والذاكرة
htop

# استخدام القرص
df -h

# حالة MySQL
sudo systemctl status mysql

# حالة Nginx
sudo systemctl status nginx

# حالة PHP-FPM
sudo systemctl status php8.1-fpm
```

---

## 13. استكشاف الأخطاء

### 13.1 خطأ 500 - Internal Server Error

**الأسباب المحتملة:**

1. صلاحيات الملفات غير صحيحة
2. خطأ في ملف .env
3. خطأ في قاعدة البيانات

**الحلول:**

```bash
# تحقق من صلاحيات الملفات
sudo chown -R erp:www-data /var/www/new-graphic-erp
sudo chmod -R 775 /var/www/new-graphic-erp/backend/storage
sudo chmod -R 775 /var/www/new-graphic-erp/backend/bootstrap/cache

# تحقق من logs
tail -f /var/www/new-graphic-erp/backend/storage/logs/laravel.log

# مسح الـ cache
cd /var/www/new-graphic-erp/backend
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
```

### 13.2 خطأ في قاعدة البيانات

```bash
# التحقق من الاتصال بقاعدة البيانات
mysql -u erp_user -p new_graphic_erp

# التحقق من ملف .env
cat /var/www/new-graphic-erp/backend/.env | grep DB_
```

### 13.3 Frontend لا يعمل

```bash
# التحقق من بناء Frontend
cd /var/www/new-graphic-erp/frontend
ls -la dist/

# إعادة البناء إذا لزم الأمر
npm run build

# التحقق من تكوين Nginx
sudo nginx -t

# إعادة تحميل Nginx
sudo systemctl reload nginx
```

### 13.4 Queue لا يعمل

```bash
# التحقق من حالة Worker
sudo supervisorctl status

# إعادة تشغيل Worker
sudo supervisorctl restart new-graphic-erp-worker:*

# التحقق من logs
tail -f /var/www/new-graphic-erp/backend/storage/logs/worker.log
```

---

## 14. الأمان

### 14.1 Firewall

```bash
# تثبيت UFW
sudo apt install -y ufw

# السماح بـ SSH
sudo ufw allow ssh

# السماح بـ HTTP و HTTPS
sudo ufw allow http
sudo ufw allow https

# تفعيل Firewall
sudo ufw enable

# التحقق من الحالة
sudo ufw status
```

### 14.2 تأمين MySQL

```bash
# تشغيل السكريبت
sudo mysql_secure_installation
```

اتبع التعليمات:
- تعيين كلمة مرور قوية لـ root
- حذف المستخدمين المجهولين
- منع تسجيل الدخول عن بُعد لـ root
- حذف قاعدة البيانات التجريبية

### 14.3 Fail2Ban (لحماية من هجمات Brute Force)

```bash
# تثبيت Fail2Ban
sudo apt install -y fail2ban

# إنشاء ملف تكوين
sudo nano /etc/fail2ban/jail.local
```

**محتوى الملف:**

```ini
[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 5
bantime = 3600
```

```bash
# تفعيل Fail2Ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# التحقق من الحالة
sudo fail2ban-client status
```

---

## 15. الدعم الفني

للحصول على المساعدة:

📧 **البريد الإلكتروني:** support@newgraphic.me

📞 **الهاتف:** [رقم الدعم الفني]

🌐 **الموقع:** https://newgraphic.me/support

📚 **الوثائق:** https://newgraphic.me/docs

---

**ملاحظة**: يُرجى الاحتفاظ بنسخة من هذا الدليل في مكان آمن والرجوع إليه عند الحاجة.

</div>
