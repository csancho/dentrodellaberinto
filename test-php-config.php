<?php
// Test PHP configuration for PrestaShop requirements

echo "<h2>PrestaShop PHP Configuration Test</h2>";

// Test PDO MySQL extension
echo "<h3>1. PDO MySQL Extension</h3>";
if (extension_loaded('pdo_mysql')) {
    echo "✅ PDO MySQL extension is loaded<br>";
} else {
    echo "❌ PDO MySQL extension is NOT loaded<br>";
}

// Test MySQLi extension
echo "<h3>2. MySQLi Extension</h3>";
if (extension_loaded('mysqli')) {
    echo "✅ MySQLi extension is loaded<br>";
} else {
    echo "❌ MySQLi extension is NOT loaded<br>";
}

// Test Intl extension
echo "<h3>3. Intl Extension</h3>";
if (extension_loaded('intl')) {
    echo "✅ Intl extension is loaded<br>";
    echo "ICU Version: " . INTL_ICU_VERSION . "<br>";
    echo "ICU Data Version: " . INTL_ICU_DATA_VERSION . "<br>";
} else {
    echo "❌ Intl extension is NOT loaded<br>";
}

// Test short_open_tag setting
echo "<h3>4. short_open_tag Setting</h3>";
$short_open_tag = ini_get('short_open_tag');
if ($short_open_tag) {
    echo "❌ short_open_tag is ON (should be OFF)<br>";
} else {
    echo "✅ short_open_tag is OFF<br>";
}

// Other important settings
echo "<h3>5. Other PHP Settings</h3>";
echo "Memory Limit: " . ini_get('memory_limit') . "<br>";
echo "Upload Max Filesize: " . ini_get('upload_max_filesize') . "<br>";
echo "Post Max Size: " . ini_get('post_max_size') . "<br>";
echo "Max Execution Time: " . ini_get('max_execution_time') . "<br>";
echo "Max Input Vars: " . ini_get('max_input_vars') . "<br>";

// Test database connection
echo "<h3>6. Database Connection Test</h3>";
try {
    $pdo = new PDO('mysql:host=mysql;dbname=prestashop', 'prestashop', 'prestashop');
    echo "✅ Database connection successful<br>";
} catch (PDOException $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "<br>";
}

phpinfo();
?>