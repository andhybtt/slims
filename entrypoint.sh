#!/bin/sh

# 1. Buat file env.php (untuk menentukan environment production/dev)
cat <<EOF >/var/www/html/config/env.php
<?php
\$env = '${ENV:-production}';
EOF

# 2. Buat file sysconfig.local.inc.php 
# Ini adalah cara paling kompatibel agar SLiMS mendeteksi database di Dokploy
cat <<EOF >/var/www/html/config/sysconfig.local.inc.php
<?php
define('DB_HOST', '${DB_HOST}');
define('DB_PORT', '${DB_PORT:-3306}');
define('DB_NAME', '${DB_NAME}');
define('DB_USERNAME', '${DB_USER}');
define('DB_PASSWORD', '${DB_PASS}');
EOF

echo "Konfigurasi SLiMS berhasil dibuat dari Environment Variables Dokploy."

# 3. Fix Permissions (Penting agar tidak Error 500)
chown -R www-data:www-data /var/www/html/config
chown -R www-data:www-data /var/www/html/repository
chown -R www-data:www-data /var/www/html/images

# Jalankan Apache
exec "$@"
