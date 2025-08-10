<?php
header('Content-Type: application/json');
session_start();

require_once __DIR__ . '/../config/database.php';

function jsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode($data);
    exit;
}

try {
    // Monthly revenue (current month, closed sales)
    $monthlyRevenueStmt = $pdo->prepare("SELECT COALESCE(SUM(amount), 0) AS monthly_revenue
        FROM sales
        WHERE status = 'closed'
          AND sale_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
          AND sale_date < DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01')");
    $monthlyRevenueStmt->execute();
    $monthlyRevenue = (float) ($monthlyRevenueStmt->fetch()['monthly_revenue'] ?? 0);

    // Close rate: percentage of deals that are closed_won over all deals
    $totalDeals = (int) ($pdo->query("SELECT COUNT(*) AS c FROM deals")->fetch()['c'] ?? 0);
    $closedWonDeals = (int) ($pdo->query("SELECT COUNT(*) AS c FROM deals WHERE stage = 'closed_won'")->fetch()['c'] ?? 0);
    $closeRate = $totalDeals > 0 ? round(($closedWonDeals / $totalDeals) * 100, 2) : 0.0;

    // Average deal size for closed deals
    $avgDealSizeStmt = $pdo->query("SELECT AVG(deal_size) AS avg_deal_size FROM deals WHERE stage = 'closed_won'");
    $avgDealSize = (float) ($avgDealSizeStmt->fetch()['avg_deal_size'] ?? 0);

    jsonResponse([
        'success' => true,
        'data' => [
            'monthly_revenue' => $monthlyRevenue,
            'close_rate' => $closeRate,
            'avg_deal_size' => $avgDealSize,
        ],
    ]);
} catch (Throwable $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}