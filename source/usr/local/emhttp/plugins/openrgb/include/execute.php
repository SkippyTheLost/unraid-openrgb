<?php
header('Content-Type: text/plain; charset=UTF-8');

$action = $_POST['action'] ?? '';
$allowedActions = ['save', 'start', 'stop', 'restart', 'status'];
if (!in_array($action, $allowedActions, true)) {
    http_response_code(400);
    exit("Invalid OpenRGB action.\n");
}

$configDir = '/boot/config/plugins/openrgb';
$configFile = $configDir.'/openrgb.cfg';
$control = '/usr/local/emhttp/plugins/openrgb/scripts/openrgbctl';

if ($action === 'save') {
    $enabled = ($_POST['ENABLED'] ?? 'no') === 'yes' ? 'yes' : 'no';
    $port = filter_var($_POST['SERVER_PORT'] ?? 6742, FILTER_VALIDATE_INT, [
        'options' => ['min_range' => 1, 'max_range' => 65535],
    ]);
    $port = $port === false ? 6742 : $port;
    $extraArgs = trim(str_replace(["\r", "\n"], '', (string) ($_POST['EXTRA_ARGS'] ?? '--server')));
    $extraArgs = $extraArgs === '' ? '--server' : preg_replace('/[^A-Za-z0-9_ .:=,\/+\-]/', '', $extraArgs);
    $i2c = ($_POST['ENABLE_I2C'] ?? 'yes') === 'yes' ? 'yes' : 'no';

    if (!is_dir($configDir) && !mkdir($configDir, 0755, true)) {
        http_response_code(500);
        exit("Unable to create the OpenRGB configuration directory.\n");
    }

    $config = sprintf(
        "ENABLED=\"%s\"\nSERVER_PORT=\"%d\"\nEXTRA_ARGS=\"%s\"\nENABLE_I2C=\"%s\"\n",
        $enabled,
        $port,
        addcslashes($extraArgs, "\\\"$`"),
        $i2c
    );
    if (file_put_contents($configFile, $config, LOCK_EX) === false) {
        http_response_code(500);
        exit("Unable to save OpenRGB settings.\n");
    }

    $serviceAction = $enabled === 'yes' ? 'restart' : 'stop';
    passthru(escapeshellarg($control).' '.escapeshellarg($serviceAction).' 2>&1', $status);
    echo "OpenRGB settings saved.\n";
    http_response_code($status === 0 ? 200 : 500);
    exit;
}

passthru(escapeshellarg($control).' '.escapeshellarg($action).' 2>&1', $status);
http_response_code($status === 0 ? 200 : 500);
