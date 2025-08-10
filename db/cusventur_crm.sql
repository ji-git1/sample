-- CusVentur Real Estate CRM Database Schema (Fixed & Optimized)
-- Removes duplications, fixes inconsistencies, and improves structure

-- Create database
CREATE DATABASE IF NOT EXISTS cusventur_crm;
USE cusventur_crm;

-- =========================
-- 1. USERS TABLE
-- =========================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('admin', 'agent', 'client') DEFAULT 'client',
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_users_email (email),
    INDEX idx_users_role (role),
    INDEX idx_users_active (is_active)
);

-- =========================
-- 2. PROPERTIES TABLE (UNIFIED)
-- =========================
CREATE TABLE properties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    property_type ENUM('house', 'condo', 'townhouse', 'apartment', 'commercial', 'villa', 'lot') NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    bedrooms INT,
    bathrooms DECIMAL(3,1),
    square_feet INT,
    lot_size VARCHAR(50),
    year_built YEAR,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    status ENUM('available', 'sold', 'pending', 'under_contract', 'reserved') DEFAULT 'available',
    agent_id INT,
    listed_date DATE DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_properties_status (status),
    INDEX idx_properties_type (property_type),
    INDEX idx_properties_price (price),
    INDEX idx_properties_city (city),
    INDEX idx_properties_agent (agent_id),
    INDEX idx_properties_listed_date (listed_date)
);

-- =========================
-- 3. CONTACTS TABLE
-- =========================
CREATE TABLE contacts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    title VARCHAR(100),
    address TEXT,
    website VARCHAR(200),
    type ENUM('client', 'prospect', 'lead', 'buyer', 'seller', 'investor', 'partner') DEFAULT 'prospect',
    source ENUM('facebook', 'website', 'referral', 'walk-in', 'social_media', 'cold_call', 'advertisement', 'other') DEFAULT 'other',
    tags TEXT,
    notes TEXT,
    assigned_to INT,
    starred BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_contacts_email (email),
    INDEX idx_contacts_type (type),
    INDEX idx_contacts_source (source),
    INDEX idx_contacts_assigned (assigned_to),
    INDEX idx_contacts_starred (starred)
);

-- =========================
-- 4. LEADS TABLE (UNIFIED)
-- =========================
CREATE TABLE leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    property_type VARCHAR(50),
    budget_range VARCHAR(50),
    stage ENUM('new', 'contacted', 'qualified', 'interested', 'proposal', 'negotiation', 'converted', 'lost') DEFAULT 'new',
    source ENUM('facebook', 'website', 'referral', 'walk-in', 'social_media', 'cold_call', 'advertisement', 'other') DEFAULT 'other',
    notes TEXT,
    assigned_to INT,
    contact_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
    INDEX idx_leads_stage (stage),
    INDEX idx_leads_source (source),
    INDEX idx_leads_assigned (assigned_to),
    INDEX idx_leads_email (email)
);

-- =========================
-- 5. PIPELINE TABLE
-- =========================
CREATE TABLE pipeline (
    id INT PRIMARY KEY AUTO_INCREMENT,
    lead_id INT NOT NULL,
    stage ENUM('prospecting', 'qualification', 'negotiation', 'contract', 'closing') NOT NULL,
    expected_value DECIMAL(12,2),
    expected_close_date DATE,
    notes TEXT,
    probability INT DEFAULT 0 CHECK (probability >= 0 AND probability <= 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE,
    INDEX idx_pipeline_stage (stage),
    INDEX idx_pipeline_expected_close (expected_close_date),
    INDEX idx_pipeline_probability (probability)
);

-- =========================
-- 6. DEALS TABLE
-- =========================
CREATE TABLE deals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    deal_name VARCHAR(200) NOT NULL,
    company VARCHAR(100),
    value DECIMAL(12,2) NOT NULL,
    deal_size DECIMAL(12,2) NOT NULL,
    stage ENUM('discovery', 'proposal', 'negotiation', 'closed_won', 'closed_lost') DEFAULT 'discovery',
    probability INT DEFAULT 0 CHECK (probability >= 0 AND probability <= 100),
    expected_close DATE,
    actual_close DATE,
    notes TEXT,
    contact_id INT,
    property_id INT,
    lead_id INT,
    assigned_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE SET NULL,
    FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_deals_stage (stage),
    INDEX idx_deals_value (value),
    INDEX idx_deals_expected_close (expected_close),
    INDEX idx_deals_assigned (assigned_to)
);

-- =========================
-- 7. SALES TABLE
-- =========================
CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    agent_id INT NOT NULL,
    deal_id INT,
    sale_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    commission_rate DECIMAL(5,2) DEFAULT 0.00,
    commission_amount DECIMAL(12,2) DEFAULT 0.00,
    status ENUM('closed', 'pending', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE,
    FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (deal_id) REFERENCES deals(id) ON DELETE SET NULL,
    INDEX idx_sales_date (sale_date),
    INDEX idx_sales_agent (agent_id),
    INDEX idx_sales_status (status),
    INDEX idx_sales_amount (amount)
);

-- =========================
-- 8. QUOTES TABLE
-- =========================
CREATE TABLE quotes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quote_number VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    property_id INT,
    property_type VARCHAR(100),
    budget_range VARCHAR(100),
    location VARCHAR(255),
    bedrooms INT,
    requirements TEXT,
    quote_amount DECIMAL(12,2),
    status ENUM('draft', 'sent', 'accepted', 'rejected', 'expired', 'pending', 'reviewed', 'responded', 'closed') DEFAULT 'draft',
    valid_until DATE,
    notes TEXT,
    response TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_quotes_status (status),
    INDEX idx_quotes_customer_email (customer_email),
    INDEX idx_quotes_valid_until (valid_until)
);

-- =========================
-- 9. TICKETS TABLE
-- =========================
CREATE TABLE tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('new', 'open', 'in_progress', 'resolved', 'closed') DEFAULT 'new',
    category VARCHAR(50),
    assigned_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_tickets_status (status),
    INDEX idx_tickets_priority (priority),
    INDEX idx_tickets_assigned (assigned_to),
    INDEX idx_tickets_customer_email (customer_email)
);

-- =========================
-- 10. ACTIVITIES TABLE
-- =========================
CREATE TABLE activities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type ENUM('email', 'phone', 'meeting', 'note', 'showing', 'follow_up', 'task') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    contact_id INT,
    property_id INT,
    deal_id INT,
    lead_id INT,
    created_by INT,
    activity_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE SET NULL,
    FOREIGN KEY (deal_id) REFERENCES deals(id) ON DELETE SET NULL,
    FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_activities_type (type),
    INDEX idx_activities_date (activity_date),
    INDEX idx_activities_due (due_date),
    INDEX idx_activities_contact (contact_id),
    INDEX idx_activities_property (property_id),
    INDEX idx_activities_deal (deal_id),
    INDEX idx_activities_completed (completed)
);

-- =========================
-- 11. REPORTS TABLE
-- =========================
CREATE TABLE reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT,
    parameters JSON,
    schedule_frequency ENUM('daily', 'weekly', 'monthly', 'quarterly', 'yearly'),
    next_run_date DATETIME,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_reports_type (type),
    INDEX idx_reports_next_run (next_run_date)
);

-- =========================
-- 12. SCHEDULED REPORTS TABLE
-- =========================
CREATE TABLE scheduled_reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    report_name VARCHAR(255) NOT NULL,
    report_type ENUM('sales_performance','deal_closing','customer_retention','revenue_forecast','lead_source') NOT NULL,
    frequency ENUM('daily','weekly','monthly','quarterly') NOT NULL,
    recipients TEXT NOT NULL,
    next_run_date DATETIME NOT NULL,
    last_run_date DATETIME NULL,
    parameters JSON NULL,
    status ENUM('active','paused','completed','error') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_scheduled_reports_user (user_id),
    INDEX idx_scheduled_reports_status (status),
    INDEX idx_scheduled_reports_next_run (next_run_date),
    INDEX idx_scheduled_reports_composite (status, next_run_date)
);

-- =========================
-- 13. REPORT EXECUTIONS TABLE
-- =========================
CREATE TABLE report_executions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    scheduled_report_id INT NOT NULL,
    execution_date DATETIME NOT NULL,
    status ENUM('pending','running','completed','failed') DEFAULT 'pending',
    file_path VARCHAR(500) NULL,
    file_size INT NULL,
    execution_time_seconds DECIMAL(8,3) NULL,
    error_message TEXT NULL,
    recipients_sent TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (scheduled_report_id) REFERENCES scheduled_reports(id) ON DELETE CASCADE,
    INDEX idx_report_executions_scheduled (scheduled_report_id),
    INDEX idx_report_executions_date (execution_date),
    INDEX idx_report_executions_status (status),
    INDEX idx_report_executions_composite (scheduled_report_id, execution_date)
);

-- =========================
-- 14. ANALYTICS DATA TABLE
-- =========================
CREATE TABLE analytics_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,2) NOT NULL,
    metric_date DATE NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_analytics_metric (metric_name),
    INDEX idx_analytics_date (metric_date),
    INDEX idx_analytics_category (category)
);

-- =========================
-- 15. LEAD SOURCES ANALYTICS TABLE
-- =========================
CREATE TABLE lead_sources (
    id INT PRIMARY KEY AUTO_INCREMENT,
    source_name VARCHAR(50) UNIQUE NOT NULL,
    total_leads INT DEFAULT 0,
    converted_leads INT DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0.00,
    total_value DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_lead_sources_conversion (conversion_rate),
    INDEX idx_lead_sources_value (total_value)
);

-- =========================
-- 16. PROPERTY TYPE PERFORMANCE TABLE
-- =========================
CREATE TABLE property_type_performance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_type ENUM('house', 'condo', 'townhouse', 'apartment', 'commercial', 'villa', 'lot') NOT NULL,
    total_sales INT DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0.00,
    average_sale_price DECIMAL(12,2) DEFAULT 0.00,
    average_days_on_market INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_property_performance_type (property_type),
    INDEX idx_property_performance_revenue (total_revenue)
);

-- =========================
-- SAMPLE DATA INSERTION
-- =========================

-- Insert default users
INSERT INTO users (username, email, password, first_name, last_name, role, phone) VALUES 
('admin', 'admin@cusventur.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin', 'User', 'admin', '(555) 000-0001'),
('agent_demo', 'agent@cusventur.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Demo', 'Agent', 'agent', '(555) 000-0002'),
('client_demo', 'client@cusventur.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Demo', 'Client', 'client', '(555) 000-0003');

-- Insert sample properties
INSERT INTO properties (title, description, property_type, price, bedrooms, bathrooms, square_feet, address, city, state, zip_code, status, agent_id, listed_date) VALUES
('Luxury Family Estate', 'Magnificent 5-bedroom estate featuring modern luxury amenities, chef\'s kitchen, and resort-style backyard with pool and spa', 'house', 1250000.00, 5, 4.5, 4200, '123 Prestige Boulevard', 'Beverly Hills', 'CA', '90210', 'available', 2, '2024-01-15'),
('Downtown Penthouse Suite', 'Stunning penthouse with floor-to-ceiling windows, panoramic city views, and premium finishes throughout', 'condo', 890000.00, 3, 3.0, 2100, '456 Metropolitan Tower', 'Manhattan', 'NY', '10001', 'available', 2, '2024-02-01'),
('Waterfront Villa Paradise', 'Breathtaking oceanfront villa with private beach access, infinity pool, and world-class entertaining spaces', 'villa', 2100000.00, 6, 5.0, 5800, '789 Ocean Drive', 'Malibu', 'CA', '90265', 'available', 2, '2024-01-20'),
('Modern Townhouse Retreat', 'Contemporary townhouse with sustainable features, private garden, and smart home technology', 'townhouse', 675000.00, 4, 3.5, 2800, '321 Garden Lane', 'Portland', 'OR', '97201', 'sold', 2, '2024-01-10'),
('Historic Brownstone', 'Meticulously restored Victorian brownstone blending historic charm with modern luxury amenities', 'house', 1450000.00, 4, 3.0, 3200, '654 Heritage Street', 'Boston', 'MA', '02101', 'under_contract', 2, '2024-02-05'),
('Mountain View Sanctuary', 'Stunning mountain retreat with panoramic views, ski-in access, and luxurious spa-like amenities', 'house', 925000.00, 3, 2.5, 2400, '987 Alpine Ridge', 'Aspen', 'CO', '81611', 'available', 2, '2024-01-25');

-- Insert sample contacts
INSERT INTO contacts (name, email, phone, company, type, source, assigned_to) VALUES
('Sarah Johnson', 'sarah.johnson@email.com', '(555) 123-4567', 'Johnson Enterprises', 'client', 'website', 2),
('Michael Chen', 'michael.chen@email.com', '(555) 234-5678', 'Chen Holdings', 'prospect', 'referral', 2),
('Emily Rodriguez', 'emily.rodriguez@email.com', '(555) 345-6789', 'Rodriguez Investments', 'investor', 'social_media', 2),
('David Thompson', 'david.thompson@email.com', '(555) 456-7890', 'Thompson Group', 'buyer', 'website', 2),
('Lisa Wang', 'lisa.wang@email.com', '(555) 567-8901', 'Wang Properties', 'seller', 'cold_call', 2);

-- Insert sample leads
INSERT INTO leads (name, email, phone, property_type, budget_range, stage, source, assigned_to, contact_id) VALUES
('John Smith', 'john.smith@email.com', '(555) 111-2222', 'house', '$500K - $750K', 'new', 'website', 2, 1),
('Maria Garcia', 'maria.garcia@email.com', '(555) 222-3333', 'condo', '$300K - $500K', 'contacted', 'referral', 2, 2),
('Robert Brown', 'robert.brown@email.com', '(555) 333-4444', 'townhouse', '$400K - $600K', 'qualified', 'social_media', 2, 3),
('Jennifer Davis', 'jennifer.davis@email.com', '(555) 444-5555', 'villa', '$1M+', 'proposal', 'website', 2, 4),
('William Wilson', 'william.wilson@email.com', '(555) 555-6666', 'apartment', '$200K - $400K', 'negotiation', 'advertisement', 2, 5);

-- Insert sample pipeline data
INSERT INTO pipeline (lead_id, stage, expected_value, expected_close_date, probability) VALUES
(1, 'qualification', 625000.00, '2024-03-15', 40),
(2, 'negotiation', 400000.00, '2024-03-22', 75),
(3, 'contract', 500000.00, '2024-03-08', 85),
(4, 'closing', 1500000.00, '2024-04-01', 90),
(5, 'prospecting', 300000.00, '2024-03-18', 25);

-- Insert sample deals
INSERT INTO deals (deal_name, company, value, deal_size, stage, probability, expected_close, contact_id, property_id, lead_id, assigned_to) VALUES
('Downtown Condo Sale', 'Johnson Enterprises', 890000.00, 890000.00, 'negotiation', 75, '2024-03-15', 1, 2, 1, 2),
('Townhouse Purchase', 'Chen Holdings', 675000.00, 675000.00, 'closed_won', 100, '2024-02-28', 2, 4, 2, 2),
('Villa Investment', 'Rodriguez Investments', 2100000.00, 2100000.00, 'proposal', 60, '2024-04-15', 3, 3, 4, 2),
('Luxury Home Sale', 'Thompson Group', 1450000.00, 1450000.00, 'negotiation', 80, '2024-04-01', 4, 5, 3, 2),
('Investment Property', 'Wang Properties', 925000.00, 925000.00, 'proposal', 65, '2024-03-18', 5, 6, 5, 2);

-- Insert sample sales
INSERT INTO sales (property_id, agent_id, deal_id, sale_date, amount, commission_rate, commission_amount, status) VALUES
(4, 2, 2, '2024-02-28', 675000.00, 3.00, 20250.00, 'closed');

-- Insert sample analytics data
INSERT INTO analytics_data (metric_name, metric_value, metric_date, category) VALUES
('total_properties', 347, CURDATE(), 'inventory'),
('properties_sold', 298, CURDATE(), 'sales'),
('happy_clients', 742, CURDATE(), 'satisfaction'),
('monthly_revenue', 85000, CURDATE(), 'financial'),
('active_leads', 89, CURDATE(), 'leads'),
('conversion_rate', 72, CURDATE(), 'performance');

-- Insert sample lead sources
INSERT INTO lead_sources (source_name, total_leads, converted_leads, conversion_rate, total_value) VALUES
('website', 45, 15, 33.33, 2450000.00),
('referral', 32, 18, 56.25, 1890000.00),
('social_media', 28, 8, 28.57, 1200000.00),
('cold_call', 15, 3, 20.00, 450000.00),
('advertisement', 20, 6, 30.00, 980000.00);

-- Insert sample property performance data
INSERT INTO property_type_performance (property_type, total_sales, total_revenue, average_sale_price, average_days_on_market) VALUES
('house', 85, 42500000.00, 500000.00, 45),
('condo', 92, 36800000.00, 400000.00, 35),
('townhouse', 34, 20400000.00, 600000.00, 42),
('villa', 12, 18000000.00, 1500000.00, 65),
('apartment', 65, 19500000.00, 300000.00, 28),
('commercial', 8, 12000000.00, 1500000.00, 85),
('lot', 25, 3750000.00, 150000.00, 90);