<?php
session_start();
$_SESSION['time'] = $_SESSION['time'] ?? time();
echo "Session started at: " . date('c', $_SESSION['time']);
?>
