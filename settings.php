<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.html');
    exit();
}

require_once 'config/database.php';

// Get user info
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$_SESSION['user_id']]);
$user = $stmt->fetch();

// Check for success/error messages
$success_message = isset($_SESSION['success_message']) ? $_SESSION['success_message'] : '';
$error_message = isset($_SESSION['error_message']) ? $_SESSION['error_message'] : '';

// Clear messages after displaying
unset($_SESSION['success_message']);
unset($_SESSION['error_message']);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Settings - Tuyu </title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    
    <div class="container">
        <!-- Header -->
        <header class="header">
            <div class="header-content">
                 <h1><img src="images/logo2.png" width="50px" height="50px">Tuyu</h1>
                <div class="user-info">
                    <div class="user-profile">
                        <div class="user-avatar-small">
                            <img src="images/<?php echo htmlspecialchars($user['profile_image']); ?>" alt="Your Avatar">
                        </div>
                        <span class="user-name"><?php echo htmlspecialchars($user['full_name']); ?></span>
                    </div>
                    <div class="header-actions">
                        <a href="index.php" class="back-btn" title="Back to Home">
                            <span class="back-icon">🏠</span>
                        </a>
                        <a href="php/auth.php?action=logout" class="logout-btn" title="Logout">
                            <span class="logout-icon">🚪</span>
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <div class="settings-container">
                <h2>Account Settings</h2>
                
                <?php if ($success_message): ?>
                <div class="alert alert-success">
                    <?php echo htmlspecialchars($success_message); ?>
                </div>
                <?php endif; ?>
                
                <?php if ($error_message): ?>
                <div class="alert alert-error">
                    <?php echo htmlspecialchars($error_message); ?>
                </div>
                <?php endif; ?>
                
                <!-- Profile Picture Section -->
                <div class="settings-section">
                    <h3>Profile Picture</h3>
                    <div class="profile-picture-container">
                        <div class="current-picture">
                            <img id="profile-preview" src="images/<?php echo htmlspecialchars($user['profile_image']); ?>" alt="Profile Picture">
                        </div>
                        <form action="php/update_profile.php" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="update_picture">
                            <div class="file-input-container">
                                <input type="file" name="profile_image" id="profile_image" accept="image/*" onchange="previewImage(this)">
                                <label for="profile_image" class="file-input-label">Choose new picture</label>
                            </div>
                            <button type="submit" class="btn-primary">Update Picture</button>
                        </form>
                    </div>
                </div>
                
                <!-- Profile Information Section -->
                <div class="settings-section">
                    <h3>Profile Information</h3>
                    <form action="php/update_profile.php" method="POST">
                        <input type="hidden" name="action" value="update_info">
                        
                        <div class="form-group">
                            <label for="full_name">Full Name</label>
                            <input type="text" id="full_name" name="full_name" value="<?php echo htmlspecialchars($user['full_name']); ?>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="username">Username</label>
                            <input type="text" id="username" name="username" value="<?php echo htmlspecialchars($user['username']); ?>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" value="<?php echo htmlspecialchars($user['email']); ?>" required>
                        </div>
                        
                        <button type="submit" class="btn-primary">Save Changes</button>
                    </form>
                </div>
                
                <!-- Change Password Section -->
                <div class="settings-section">
                    <h3>Change Password</h3>
                    <form action="php/update_profile.php" method="POST" id="password-form">
                        <input type="hidden" name="action" value="change_password">
                        
                        <div class="form-group">
                            <label for="current_password">Current Password</label>
                            <input type="password" id="current_password" name="current_password" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="new_password">New Password</label>
                            <input type="password" id="new_password" name="new_password" required minlength="6">
                        </div>
                        
                        <div class="form-group">
                            <label for="confirm_password">Confirm New Password</label>
                            <input type="password" id="confirm_password" name="confirm_password" required minlength="6">
                            <span id="password-match-error" class="error-text" style="display: none;">Passwords do not match</span>
                        </div>
                        
                        <button type="submit" class="btn-primary">Change Password</button>
                    </form>
                </div>
                
                <!-- Delete Account Section -->
                <div class="settings-section danger-zone">
                    <h3>Danger Zone</h3>
                    <p>Once you delete your account, there is no going back. Please be certain.</p>
                    <button type="button" class="btn-danger" onclick="confirmDeleteAccount()">Delete Account</button>
                </div>
            </div>
        </main>
    </div>

    <script src="js/script.js"></script>
</body>
</html>
