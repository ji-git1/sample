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

// Get posts with user info and like counts
$stmt = $pdo->prepare("
    SELECT p.*, u.username, u.full_name, u.profile_image,
           COUNT(l.id) as like_count,
           EXISTS(SELECT 1 FROM likes WHERE user_id = ? AND post_id = p.id) as user_liked
    FROM posts p 
    JOIN users u ON p.user_id = u.id 
    LEFT JOIN likes l ON p.id = l.post_id
    GROUP BY p.id 
    ORDER BY p.created_at DESC
");
$stmt->execute([$_SESSION['user_id']]);
$posts = $stmt->fetchAll();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tuyu - Home</title>
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
                        <a href="settings.php" class="settings-btn" title="Settings">
                            <span class="settings-icon">⚙️</span>
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
            <!-- Post Form -->
            <div class="post-form-container">
                <form id="postForm" action="php/posts.php" method="POST">
                    <div class="post-form">
                        <textarea name="content" placeholder="What's happening?" maxlength="280" required></textarea>
                        <div class="post-actions">
                            <span class="char-count">280</span>
                            <button type="submit" class="btn-primary">Tweet</button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Posts Feed -->
            <div class="posts-container">
                <?php foreach ($posts as $post): ?>
                <div class="post">
                    <div class="post-header">
                        <div class="user-avatar">
                            <img src="images/<?php echo htmlspecialchars($post['profile_image']); ?>" alt="Avatar">
                        </div>
                        <div class="post-info">
                            <h4><?php echo htmlspecialchars($post['full_name']); ?></h4>
                            <span class="username">@<?php echo htmlspecialchars($post['username']); ?></span>
                            <span class="post-time"><?php echo date('M j, Y g:i A', strtotime($post['created_at'])); ?></span>
                        </div>
                    </div>
                    
                    <div class="post-content">
                        <p><?php echo nl2br(htmlspecialchars($post['content'])); ?></p>
                    </div>
                    
                    <div class="post-actions">
                        <button class="like-btn <?php echo $post['user_liked'] ? 'liked' : ''; ?>" 
                                onclick="toggleLike(<?php echo $post['id']; ?>, this)">
                            <span class="heart">🥚</span>
                            <span class="like-count"><?php echo $post['like_count']; ?></span>
                        </button>
                        
                        <?php if ($post['user_id'] == $_SESSION['user_id']): ?>
                        <button class="delete-btn" onclick="deletePost(<?php echo $post['id']; ?>, this)">
                            <span class="trash">🗑️</span>
                            <span>Delete</span>
                        </button>
                        <?php endif; ?>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        </main>
    </div>

    <script src="js/script.js"></script>
</body>
</html>
