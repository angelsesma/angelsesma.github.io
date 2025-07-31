<?php
// Configure SQLite database
$dbPath = 'device-data.sqlite';
$tableName = 'devices';

// Create table if not exists
$db = new SQLite3($dbPath) or die("Could not open database");
$db->exec("CREATE TABLE IF NOT EXISTS $tableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deviceId TEXT UNIQUE,
    visits INTEGER DEFAULT 1,
    firstVisit TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lastVisit TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)");

// Handle POST requests (device registration)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $data = json_decode(file_get_contents('php://input'), true);
  $deviceId = $data['deviceId'];

  // Check if device exists
  $stmt = $db->prepare("INSERT OR IGNORE INTO $tableName (deviceId) VALUES (?)");
  $stmt->bindParam(1, $deviceId);
  $stmt->execute();

  // Update visits and last visit time
  $updateStmt = $db->prepare("UPDATE $tableName 
    SET visits = visits + 1, lastVisit = CURRENT_TIMESTAMP 
    WHERE deviceId = ?");
  $updateStmt->bindParam(1, $deviceId);
  $updateStmt->execute();

  echo json_encode(["status" => "success", "message" => "Device tracked"]);
}

// Handle GET requests (demo - not secure for production)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
  $deviceId = $_GET['deviceId'] ?? '';
  $stmt = $db->prepare("SELECT * FROM $tableName WHERE deviceId = ?");
  $stmt->bindParam(1, $deviceId);
  $result = $stmt->execute()->fetchArray(SQLITE3_ASSOC);

  if ($result) {
    echo json_encode($result);
  } else {
    echo json_encode(["error" => "Device not found"]);
  }
}
?>