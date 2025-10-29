-- ============================================
-- New Graphic ERP Database Schema
-- نظام New Graphic ERP - مخطط قاعدة البيانات
-- Version: 1.0
-- Database: MySQL 8.0+
-- ============================================

-- ============================================
-- 1. Users and Authentication Tables
-- جداول المستخدمين والمصادقة
-- ============================================

CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL COMMENT 'اسم المستخدم',
  `email` VARCHAR(255) UNIQUE NOT NULL COMMENT 'البريد الإلكتروني',
  `password` VARCHAR(255) NOT NULL COMMENT 'كلمة المرور المشفرة',
  `phone` VARCHAR(20) COMMENT 'رقم الهاتف',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'حالة النشاط',
  `last_login_at` TIMESTAMP NULL COMMENT 'آخر تسجيل دخول',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_email` (`email`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول المستخدمين';

CREATE TABLE IF NOT EXISTS `roles` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) UNIQUE NOT NULL COMMENT 'اسم الدور',
  `name_ar` VARCHAR(100) NOT NULL COMMENT 'الاسم بالعربية',
  `description` TEXT COMMENT 'الوصف',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول الأدوار';

CREATE TABLE IF NOT EXISTS `permissions` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) UNIQUE NOT NULL COMMENT 'اسم الصلاحية',
  `name_ar` VARCHAR(100) NOT NULL COMMENT 'الاسم بالعربية',
  `module` VARCHAR(50) NOT NULL COMMENT 'الوحدة',
  `description` TEXT COMMENT 'الوصف',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول الصلاحيات';

CREATE TABLE IF NOT EXISTS `role_user` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `role_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_user_role` (`user_id`, `role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='علاقة المستخدمين بالأدوار';

CREATE TABLE IF NOT EXISTS `permission_role` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `role_id` BIGINT UNSIGNED NOT NULL,
  `permission_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_role_permission` (`role_id`, `permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='علاقة الأدوار بالصلاحيات';

CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NULL,
  `action` VARCHAR(50) NOT NULL COMMENT 'نوع العملية',
  `module` VARCHAR(50) NOT NULL COMMENT 'الوحدة',
  `record_id` BIGINT UNSIGNED NULL COMMENT 'معرف السجل',
  `old_values` JSON NULL COMMENT 'القيم القديمة',
  `new_values` JSON NULL COMMENT 'القيم الجديدة',
  `ip_address` VARCHAR(45) NULL COMMENT 'عنوان IP',
  `user_agent` TEXT NULL COMMENT 'متصفح المستخدم',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_module` (`module`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='سجل الأنشطة';

-- ============================================
-- 2. CRM and Sales Tables
-- جداول إدارة العملاء والمبيعات
-- ============================================

CREATE TABLE IF NOT EXISTS `customers` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL COMMENT 'اسم العميل',
  `company_name` VARCHAR(255) NULL COMMENT 'اسم الشركة',
  `email` VARCHAR(255) NULL COMMENT 'البريد الإلكتروني',
  `phone` VARCHAR(20) NOT NULL COMMENT 'رقم الهاتف',
  `phone2` VARCHAR(20) NULL COMMENT 'رقم هاتف إضافي',
  `tax_number` VARCHAR(50) NULL COMMENT 'الرقم الضريبي',
  `address` TEXT NULL COMMENT 'العنوان',
  `city` VARCHAR(100) NULL COMMENT 'المدينة',
  `country` VARCHAR(100) DEFAULT 'مصر' COMMENT 'الدولة',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'حالة النشاط',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_name` (`name`),
  INDEX `idx_company_name` (`company_name`),
  INDEX `idx_phone` (`phone`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول العملاء';

CREATE TABLE IF NOT EXISTS `quotations` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `quotation_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم عرض السعر',
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `quotation_date` DATE NOT NULL COMMENT 'تاريخ العرض',
  `valid_until` DATE NULL COMMENT 'صالح حتى',
  `status` ENUM('draft', 'sent', 'approved', 'rejected', 'cancelled') DEFAULT 'draft' COMMENT 'الحالة',
  `subtotal` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'المجموع قبل الضريبة',
  `tax_rate` DECIMAL(5,2) DEFAULT 14.00 COMMENT 'نسبة الضريبة',
  `tax_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'قيمة الضريبة',
  `total` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'الإجمالي',
  `discount_type` ENUM('percentage', 'fixed') NULL COMMENT 'نوع الخصم',
  `discount_value` DECIMAL(10,2) DEFAULT 0 COMMENT 'قيمة الخصم',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `terms_conditions` TEXT NULL COMMENT 'الشروط والأحكام',
  `created_by` BIGINT UNSIGNED NULL,
  `approved_at` TIMESTAMP NULL COMMENT 'تاريخ الموافقة',
  `rejected_at` TIMESTAMP NULL COMMENT 'تاريخ الرفض',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_quotation_number` (`quotation_number`),
  INDEX `idx_customer_id` (`customer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_quotation_date` (`quotation_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول عروض الأسعار';

CREATE TABLE IF NOT EXISTS `quotation_items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `quotation_id` BIGINT UNSIGNED NOT NULL,
  `item_number` INT NOT NULL COMMENT 'رقم البند',
  `description` TEXT NOT NULL COMMENT 'الوصف',
  `design_cost` DECIMAL(10,2) DEFAULT 0 COMMENT 'تكلفة التصميم',
  `material_type` VARCHAR(100) NULL COMMENT 'نوع المادة',
  `material_specs` VARCHAR(255) NULL COMMENT 'مواصفات المادة',
  `width` DECIMAL(10,2) NULL COMMENT 'العرض',
  `height` DECIMAL(10,2) NULL COMMENT 'الارتفاع',
  `unit` VARCHAR(20) DEFAULT 'متر مربع' COMMENT 'الوحدة',
  `quantity` DECIMAL(10,2) NOT NULL DEFAULT 1 COMMENT 'الكمية',
  `print_type` VARCHAR(50) NULL COMMENT 'نوع الطباعة',
  `finishing` TEXT NULL COMMENT 'التشطيبات',
  `installation_cost` DECIMAL(10,2) DEFAULT 0 COMMENT 'تكلفة التركيب',
  `transport_cost` DECIMAL(10,2) DEFAULT 0 COMMENT 'تكلفة النقل',
  `unit_price` DECIMAL(10,2) NOT NULL COMMENT 'سعر الوحدة',
  `total_price` DECIMAL(15,2) NOT NULL COMMENT 'السعر الإجمالي',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`quotation_id`) REFERENCES `quotations`(`id`) ON DELETE CASCADE,
  INDEX `idx_quotation_id` (`quotation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='بنود عروض الأسعار';

-- ============================================
-- 3. Production and Projects Tables
-- جداول الإنتاج والمشاريع
-- ============================================

CREATE TABLE IF NOT EXISTS `work_orders` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `order_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم أمر الشغل',
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `quotation_id` BIGINT UNSIGNED NULL COMMENT 'عرض السعر المرتبط',
  `order_date` DATE NOT NULL COMMENT 'تاريخ الأمر',
  `delivery_date` DATE NULL COMMENT 'تاريخ التسليم المتوقع',
  `actual_delivery_date` DATE NULL COMMENT 'تاريخ التسليم الفعلي',
  `status` ENUM('received', 'design', 'printing', 'finishing', 'installation', 'delivered', 'cancelled') DEFAULT 'received' COMMENT 'المرحلة',
  `priority` ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal' COMMENT 'الأولوية',
  `total_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'القيمة الإجمالية',
  `estimated_cost` DECIMAL(15,2) DEFAULT 0 COMMENT 'التكلفة التقديرية',
  `actual_cost` DECIMAL(15,2) DEFAULT 0 COMMENT 'التكلفة الفعلية',
  `profit` DECIMAL(15,2) DEFAULT 0 COMMENT 'الربح',
  `assigned_to` BIGINT UNSIGNED NULL COMMENT 'المسؤول',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`quotation_id`) REFERENCES `quotations`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_order_number` (`order_number`),
  INDEX `idx_customer_id` (`customer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_order_date` (`order_date`),
  INDEX `idx_delivery_date` (`delivery_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول أوامر الشغل';

CREATE TABLE IF NOT EXISTS `work_order_items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `work_order_id` BIGINT UNSIGNED NOT NULL,
  `item_number` INT NOT NULL COMMENT 'رقم البند',
  `description` TEXT NOT NULL COMMENT 'الوصف',
  `quantity` DECIMAL(10,2) NOT NULL DEFAULT 1 COMMENT 'الكمية',
  `unit` VARCHAR(20) DEFAULT 'متر مربع' COMMENT 'الوحدة',
  `unit_price` DECIMAL(10,2) NOT NULL COMMENT 'سعر الوحدة',
  `total_price` DECIMAL(15,2) NOT NULL COMMENT 'السعر الإجمالي',
  `status` ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending' COMMENT 'الحالة',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`work_order_id`) REFERENCES `work_orders`(`id`) ON DELETE CASCADE,
  INDEX `idx_work_order_id` (`work_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='بنود أوامر الشغل';

CREATE TABLE IF NOT EXISTS `design_files` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `work_order_id` BIGINT UNSIGNED NOT NULL,
  `file_name` VARCHAR(255) NOT NULL COMMENT 'اسم الملف',
  `file_path` VARCHAR(500) NOT NULL COMMENT 'مسار الملف',
  `file_type` VARCHAR(50) NOT NULL COMMENT 'نوع الملف',
  `file_size` INT NOT NULL COMMENT 'حجم الملف بالبايت',
  `description` TEXT NULL COMMENT 'الوصف',
  `version` INT DEFAULT 1 COMMENT 'الإصدار',
  `is_final` BOOLEAN DEFAULT FALSE COMMENT 'نهائي؟',
  `uploaded_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`work_order_id`) REFERENCES `work_orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_work_order_id` (`work_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول ملفات التصميم';

CREATE TABLE IF NOT EXISTS `work_order_stages` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `work_order_id` BIGINT UNSIGNED NOT NULL,
  `stage` VARCHAR(50) NOT NULL COMMENT 'المرحلة',
  `assigned_to` BIGINT UNSIGNED NULL COMMENT 'المسؤول',
  `started_at` TIMESTAMP NULL COMMENT 'تاريخ البدء',
  `completed_at` TIMESTAMP NULL COMMENT 'تاريخ الإنجاز',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`work_order_id`) REFERENCES `work_orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_work_order_id` (`work_order_id`),
  INDEX `idx_stage` (`stage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='مراحل أوامر الشغل';

-- ============================================
-- 4. Accounting Tables
-- جداول المحاسبة
-- ============================================

CREATE TABLE IF NOT EXISTS `chart_of_accounts` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `account_code` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رمز الحساب',
  `account_name` VARCHAR(255) NOT NULL COMMENT 'اسم الحساب',
  `account_name_en` VARCHAR(255) NULL COMMENT 'اسم الحساب بالإنجليزية',
  `account_type` ENUM('asset', 'liability', 'equity', 'revenue', 'expense') NOT NULL COMMENT 'نوع الحساب',
  `parent_id` BIGINT UNSIGNED NULL COMMENT 'الحساب الأب',
  `level` INT NOT NULL DEFAULT 1 COMMENT 'المستوى',
  `is_main_account` BOOLEAN DEFAULT FALSE COMMENT 'حساب رئيسي؟',
  `opening_balance` DECIMAL(15,2) DEFAULT 0 COMMENT 'الرصيد الافتتاحي',
  `current_balance` DECIMAL(15,2) DEFAULT 0 COMMENT 'الرصيد الحالي',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'نشط؟',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`parent_id`) REFERENCES `chart_of_accounts`(`id`) ON DELETE RESTRICT,
  INDEX `idx_account_code` (`account_code`),
  INDEX `idx_account_type` (`account_type`),
  INDEX `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='دليل الحسابات';

CREATE TABLE IF NOT EXISTS `journal_entries` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `entry_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم القيد',
  `entry_date` DATE NOT NULL COMMENT 'تاريخ القيد',
  `entry_type` ENUM('manual', 'auto_invoice', 'auto_payment', 'auto_expense', 'auto_purchase') DEFAULT 'manual' COMMENT 'نوع القيد',
  `reference_type` VARCHAR(50) NULL COMMENT 'نوع المرجع',
  `reference_id` BIGINT UNSIGNED NULL COMMENT 'معرف المرجع',
  `description` TEXT NOT NULL COMMENT 'البيان',
  `total_debit` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'إجمالي المدين',
  `total_credit` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'إجمالي الدائن',
  `is_posted` BOOLEAN DEFAULT TRUE COMMENT 'مرحّل؟',
  `posted_at` TIMESTAMP NULL COMMENT 'تاريخ الترحيل',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_entry_number` (`entry_number`),
  INDEX `idx_entry_date` (`entry_date`),
  INDEX `idx_entry_type` (`entry_type`),
  INDEX `idx_reference` (`reference_type`, `reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='قيود اليومية';

CREATE TABLE IF NOT EXISTS `journal_entry_details` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `journal_entry_id` BIGINT UNSIGNED NOT NULL,
  `account_id` BIGINT UNSIGNED NOT NULL,
  `debit` DECIMAL(15,2) DEFAULT 0 COMMENT 'مدين',
  `credit` DECIMAL(15,2) DEFAULT 0 COMMENT 'دائن',
  `description` TEXT NULL COMMENT 'البيان',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`journal_entry_id`) REFERENCES `journal_entries`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts`(`id`) ON DELETE RESTRICT,
  INDEX `idx_journal_entry_id` (`journal_entry_id`),
  INDEX `idx_account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='تفاصيل قيود اليومية';

CREATE TABLE IF NOT EXISTS `invoices` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `invoice_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم الفاتورة',
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `work_order_id` BIGINT UNSIGNED NULL COMMENT 'أمر الشغل المرتبط',
  `invoice_date` DATE NOT NULL COMMENT 'تاريخ الفاتورة',
  `due_date` DATE NULL COMMENT 'تاريخ الاستحقاق',
  `subtotal` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'المجموع قبل الضريبة',
  `tax_rate` DECIMAL(5,2) DEFAULT 14.00 COMMENT 'نسبة الضريبة',
  `tax_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'قيمة الضريبة',
  `total` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'الإجمالي',
  `discount_type` ENUM('percentage', 'fixed') NULL COMMENT 'نوع الخصم',
  `discount_value` DECIMAL(10,2) DEFAULT 0 COMMENT 'قيمة الخصم',
  `paid_amount` DECIMAL(15,2) DEFAULT 0 COMMENT 'المبلغ المدفوع',
  `remaining_amount` DECIMAL(15,2) DEFAULT 0 COMMENT 'المبلغ المتبقي',
  `status` ENUM('draft', 'sent', 'partial', 'paid', 'overdue', 'cancelled') DEFAULT 'draft' COMMENT 'الحالة',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`work_order_id`) REFERENCES `work_orders`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_invoice_number` (`invoice_number`),
  INDEX `idx_customer_id` (`customer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_invoice_date` (`invoice_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='فواتير المبيعات';

CREATE TABLE IF NOT EXISTS `invoice_items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `invoice_id` BIGINT UNSIGNED NOT NULL,
  `item_number` INT NOT NULL COMMENT 'رقم البند',
  `description` TEXT NOT NULL COMMENT 'الوصف',
  `quantity` DECIMAL(10,2) NOT NULL DEFAULT 1 COMMENT 'الكمية',
  `unit` VARCHAR(20) DEFAULT 'متر مربع' COMMENT 'الوحدة',
  `unit_price` DECIMAL(10,2) NOT NULL COMMENT 'سعر الوحدة',
  `total_price` DECIMAL(15,2) NOT NULL COMMENT 'السعر الإجمالي',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`) ON DELETE CASCADE,
  INDEX `idx_invoice_id` (`invoice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='بنود الفواتير';

CREATE TABLE IF NOT EXISTS `payments` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `payment_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم الإيصال',
  `invoice_id` BIGINT UNSIGNED NULL,
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `payment_date` DATE NOT NULL COMMENT 'تاريخ الدفع',
  `amount` DECIMAL(15,2) NOT NULL COMMENT 'المبلغ',
  `payment_method` ENUM('cash', 'bank_transfer', 'check', 'credit_card', 'other') NOT NULL COMMENT 'طريقة الدفع',
  `bank_account_id` BIGINT UNSIGNED NULL COMMENT 'الحساب البنكي',
  `reference_number` VARCHAR(100) NULL COMMENT 'رقم المرجع',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_payment_number` (`payment_number`),
  INDEX `idx_invoice_id` (`invoice_id`),
  INDEX `idx_customer_id` (`customer_id`),
  INDEX `idx_payment_date` (`payment_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول الدفعات';

-- ============================================
-- 5. Suppliers and Purchases Tables
-- جداول الموردين والمشتريات
-- ============================================

CREATE TABLE IF NOT EXISTS `suppliers` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL COMMENT 'اسم المورد',
  `company_name` VARCHAR(255) NULL COMMENT 'اسم الشركة',
  `email` VARCHAR(255) NULL COMMENT 'البريد الإلكتروني',
  `phone` VARCHAR(20) NOT NULL COMMENT 'رقم الهاتف',
  `phone2` VARCHAR(20) NULL COMMENT 'رقم هاتف إضافي',
  `tax_number` VARCHAR(50) NULL COMMENT 'الرقم الضريبي',
  `address` TEXT NULL COMMENT 'العنوان',
  `city` VARCHAR(100) NULL COMMENT 'المدينة',
  `country` VARCHAR(100) DEFAULT 'مصر' COMMENT 'الدولة',
  `category` VARCHAR(100) NULL COMMENT 'الفئة',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'حالة النشاط',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول الموردين';

CREATE TABLE IF NOT EXISTS `purchase_invoices` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `invoice_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم الفاتورة',
  `supplier_id` BIGINT UNSIGNED NOT NULL,
  `invoice_date` DATE NOT NULL COMMENT 'تاريخ الفاتورة',
  `due_date` DATE NULL COMMENT 'تاريخ الاستحقاق',
  `subtotal` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'المجموع قبل الضريبة',
  `tax_rate` DECIMAL(5,2) DEFAULT 14.00 COMMENT 'نسبة الضريبة',
  `tax_amount` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'قيمة الضريبة',
  `total` DECIMAL(15,2) NOT NULL DEFAULT 0 COMMENT 'الإجمالي',
  `paid_amount` DECIMAL(15,2) DEFAULT 0 COMMENT 'المبلغ المدفوع',
  `remaining_amount` DECIMAL(15,2) DEFAULT 0 COMMENT 'المبلغ المتبقي',
  `status` ENUM('draft', 'received', 'partial', 'paid', 'overdue', 'cancelled') DEFAULT 'draft' COMMENT 'الحالة',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`supplier_id`) REFERENCES `suppliers`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_invoice_number` (`invoice_number`),
  INDEX `idx_supplier_id` (`supplier_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_invoice_date` (`invoice_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='فواتير المشتريات';

CREATE TABLE IF NOT EXISTS `purchase_invoice_items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `purchase_invoice_id` BIGINT UNSIGNED NOT NULL,
  `item_id` BIGINT UNSIGNED NULL COMMENT 'الصنف',
  `description` TEXT NOT NULL COMMENT 'الوصف',
  `quantity` DECIMAL(10,2) NOT NULL DEFAULT 1 COMMENT 'الكمية',
  `unit` VARCHAR(20) COMMENT 'الوحدة',
  `unit_price` DECIMAL(10,2) NOT NULL COMMENT 'سعر الوحدة',
  `total_price` DECIMAL(15,2) NOT NULL COMMENT 'السعر الإجمالي',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`purchase_invoice_id`) REFERENCES `purchase_invoices`(`id`) ON DELETE CASCADE,
  INDEX `idx_purchase_invoice_id` (`purchase_invoice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='بنود فواتير المشتريات';

CREATE TABLE IF NOT EXISTS `supplier_payments` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `payment_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم الدفع',
  `purchase_invoice_id` BIGINT UNSIGNED NULL,
  `supplier_id` BIGINT UNSIGNED NOT NULL,
  `payment_date` DATE NOT NULL COMMENT 'تاريخ الدفع',
  `amount` DECIMAL(15,2) NOT NULL COMMENT 'المبلغ',
  `payment_method` ENUM('cash', 'bank_transfer', 'check', 'credit_card', 'other') NOT NULL COMMENT 'طريقة الدفع',
  `bank_account_id` BIGINT UNSIGNED NULL COMMENT 'الحساب البنكي',
  `reference_number` VARCHAR(100) NULL COMMENT 'رقم المرجع',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`purchase_invoice_id`) REFERENCES `purchase_invoices`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`supplier_id`) REFERENCES `suppliers`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_payment_number` (`payment_number`),
  INDEX `idx_supplier_id` (`supplier_id`),
  INDEX `idx_payment_date` (`payment_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='دفعات الموردين';

-- ============================================
-- 6. Expenses Tables
-- جداول المصروفات
-- ============================================

CREATE TABLE IF NOT EXISTS `expense_categories` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT 'اسم الفئة',
  `account_id` BIGINT UNSIGNED NULL COMMENT 'الحساب المرتبط',
  `description` TEXT NULL COMMENT 'الوصف',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'نشط؟',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts`(`id`) ON DELETE SET NULL,
  INDEX `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='فئات المصروفات';

CREATE TABLE IF NOT EXISTS `expenses` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `expense_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم المصروف',
  `expense_date` DATE NOT NULL COMMENT 'تاريخ المصروف',
  `category_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL COMMENT 'المبلغ',
  `payment_method` ENUM('cash', 'bank_transfer', 'check', 'credit_card', 'other') NOT NULL COMMENT 'طريقة الدفع',
  `bank_account_id` BIGINT UNSIGNED NULL COMMENT 'الحساب البنكي',
  `reference_number` VARCHAR(100) NULL COMMENT 'رقم المرجع',
  `description` TEXT NOT NULL COMMENT 'الوصف',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `attachments` JSON NULL COMMENT 'المرفقات',
  `is_recurring` BOOLEAN DEFAULT FALSE COMMENT 'متكرر؟',
  `recurring_frequency` ENUM('daily', 'weekly', 'monthly', 'yearly') NULL COMMENT 'تكرار',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`category_id`) REFERENCES `expense_categories`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_expense_number` (`expense_number`),
  INDEX `idx_expense_date` (`expense_date`),
  INDEX `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول المصروفات';

-- ============================================
-- 7. Bank Accounts and Cash Tables
-- جداول البنوك والخزينة
-- ============================================

CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `account_name` VARCHAR(255) NOT NULL COMMENT 'اسم الحساب',
  `bank_name` VARCHAR(255) NOT NULL COMMENT 'اسم البنك',
  `account_number` VARCHAR(50) NOT NULL COMMENT 'رقم الحساب',
  `iban` VARCHAR(50) NULL COMMENT 'الآيبان',
  `swift_code` VARCHAR(20) NULL COMMENT 'سويفت كود',
  `branch` VARCHAR(100) NULL COMMENT 'الفرع',
  `currency` VARCHAR(10) DEFAULT 'EGP' COMMENT 'العملة',
  `opening_balance` DECIMAL(15,2) DEFAULT 0 COMMENT 'الرصيد الافتتاحي',
  `current_balance` DECIMAL(15,2) DEFAULT 0 COMMENT 'الرصيد الحالي',
  `account_id` BIGINT UNSIGNED NULL COMMENT 'الحساب في دليل الحسابات',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'نشط؟',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts`(`id`) ON DELETE SET NULL,
  INDEX `idx_account_number` (`account_number`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الحسابات البنكية';

-- ============================================
-- 8. Inventory Tables
-- جداول المخزون
-- ============================================

CREATE TABLE IF NOT EXISTS `item_categories` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT 'اسم الفئة',
  `parent_id` BIGINT UNSIGNED NULL COMMENT 'الفئة الأب',
  `description` TEXT NULL COMMENT 'الوصف',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'نشط؟',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`parent_id`) REFERENCES `item_categories`(`id`) ON DELETE SET NULL,
  INDEX `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='فئات الأصناف';

CREATE TABLE IF NOT EXISTS `items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `item_code` VARCHAR(50) UNIQUE NOT NULL COMMENT 'كود الصنف',
  `item_name` VARCHAR(255) NOT NULL COMMENT 'اسم الصنف',
  `category_id` BIGINT UNSIGNED NULL,
  `description` TEXT NULL COMMENT 'الوصف',
  `unit` VARCHAR(20) NOT NULL COMMENT 'الوحدة',
  `cost_price` DECIMAL(10,2) DEFAULT 0 COMMENT 'سعر التكلفة',
  `selling_price` DECIMAL(10,2) DEFAULT 0 COMMENT 'سعر البيع',
  `min_stock_level` DECIMAL(10,2) DEFAULT 0 COMMENT 'الحد الأدنى للمخزون',
  `reorder_level` DECIMAL(10,2) DEFAULT 0 COMMENT 'نقطة إعادة الطلب',
  `current_stock` DECIMAL(10,2) DEFAULT 0 COMMENT 'المخزون الحالي',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'نشط؟',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`category_id`) REFERENCES `item_categories`(`id`) ON DELETE SET NULL,
  INDEX `idx_item_code` (`item_code`),
  INDEX `idx_item_name` (`item_name`),
  INDEX `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='جدول الأصناف';

CREATE TABLE IF NOT EXISTS `warehouses` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL COMMENT 'اسم المخزن',
  `code` VARCHAR(50) UNIQUE NOT NULL COMMENT 'كود المخزن',
  `location` TEXT NULL COMMENT 'الموقع',
  `manager_id` BIGINT UNSIGNED NULL COMMENT 'المسؤول',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'نشط؟',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`manager_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='المخازن';

CREATE TABLE IF NOT EXISTS `stock_movements` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `movement_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'رقم الحركة',
  `movement_date` DATE NOT NULL COMMENT 'تاريخ الحركة',
  `movement_type` ENUM('in', 'out', 'transfer', 'adjustment') NOT NULL COMMENT 'نوع الحركة',
  `warehouse_id` BIGINT UNSIGNED NOT NULL,
  `reference_type` VARCHAR(50) NULL COMMENT 'نوع المرجع',
  `reference_id` BIGINT UNSIGNED NULL COMMENT 'معرف المرجع',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX `idx_movement_number` (`movement_number`),
  INDEX `idx_movement_date` (`movement_date`),
  INDEX `idx_movement_type` (`movement_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='حركات المخزون';

CREATE TABLE IF NOT EXISTS `stock_movement_items` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stock_movement_id` BIGINT UNSIGNED NOT NULL,
  `item_id` BIGINT UNSIGNED NOT NULL,
  `quantity` DECIMAL(10,2) NOT NULL COMMENT 'الكمية',
  `unit_cost` DECIMAL(10,2) DEFAULT 0 COMMENT 'تكلفة الوحدة',
  `total_cost` DECIMAL(15,2) DEFAULT 0 COMMENT 'التكلفة الإجمالية',
  `notes` TEXT NULL COMMENT 'ملاحظات',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`stock_movement_id`) REFERENCES `stock_movements`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE RESTRICT,
  INDEX `idx_stock_movement_id` (`stock_movement_id`),
  INDEX `idx_item_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='بنود حركات المخزون';

CREATE TABLE IF NOT EXISTS `warehouse_stock` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `warehouse_id` BIGINT UNSIGNED NOT NULL,
  `item_id` BIGINT UNSIGNED NOT NULL,
  `quantity` DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT 'الكمية',
  `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`item_id`) REFERENCES `items`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_warehouse_item` (`warehouse_id`, `item_id`),
  INDEX `idx_warehouse_id` (`warehouse_id`),
  INDEX `idx_item_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='مخزون المستودعات';

-- ============================================
-- 9. Settings and Configuration Tables
-- جداول الإعدادات
-- ============================================

CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `setting_key` VARCHAR(100) UNIQUE NOT NULL COMMENT 'مفتاح الإعداد',
  `setting_value` TEXT NULL COMMENT 'قيمة الإعداد',
  `setting_type` VARCHAR(50) DEFAULT 'string' COMMENT 'نوع الإعداد',
  `description` TEXT NULL COMMENT 'الوصف',
  `is_public` BOOLEAN DEFAULT FALSE COMMENT 'عام؟',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='إعدادات النظام';

CREATE TABLE IF NOT EXISTS `company_info` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `company_name` VARCHAR(255) NOT NULL COMMENT 'اسم الشركة',
  `company_name_en` VARCHAR(255) NULL COMMENT 'اسم الشركة بالإنجليزية',
  `tax_number` VARCHAR(50) NULL COMMENT 'الرقم الضريبي',
  `commercial_register` VARCHAR(50) NULL COMMENT 'السجل التجاري',
  `address` TEXT NULL COMMENT 'العنوان',
  `city` VARCHAR(100) NULL COMMENT 'المدينة',
  `country` VARCHAR(100) DEFAULT 'مصر' COMMENT 'الدولة',
  `phone` VARCHAR(20) NULL COMMENT 'الهاتف',
  `phone2` VARCHAR(20) NULL COMMENT 'هاتف إضافي',
  `email` VARCHAR(255) NULL COMMENT 'البريد الإلكتروني',
  `website` VARCHAR(255) NULL COMMENT 'الموقع الإلكتروني',
  `logo_path` VARCHAR(500) NULL COMMENT 'مسار الشعار',
  `currency` VARCHAR(10) DEFAULT 'EGP' COMMENT 'العملة',
  `tax_rate` DECIMAL(5,2) DEFAULT 14.00 COMMENT 'نسبة الضريبة الافتراضية',
  `fiscal_year_start` DATE NULL COMMENT 'بداية السنة المالية',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='معلومات الشركة';

-- ============================================
-- 10. Notifications Tables
-- جداول الإشعارات
-- ============================================

CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(255) NOT NULL COMMENT 'العنوان',
  `message` TEXT NOT NULL COMMENT 'الرسالة',
  `type` VARCHAR(50) NOT NULL COMMENT 'النوع',
  `reference_type` VARCHAR(50) NULL COMMENT 'نوع المرجع',
  `reference_id` BIGINT UNSIGNED NULL COMMENT 'معرف المرجع',
  `is_read` BOOLEAN DEFAULT FALSE COMMENT 'مقروء؟',
  `read_at` TIMESTAMP NULL COMMENT 'تاريخ القراءة',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الإشعارات';

-- ============================================
-- Initial Data Seeding
-- البيانات الأولية
-- ============================================

-- Insert default company info
INSERT INTO `company_info` (
  `company_name`, 
  `company_name_en`, 
  `phone`, 
  `email`, 
  `currency`, 
  `tax_rate`, 
  `country`
) VALUES (
  'New Graphic', 
  'New Graphic', 
  '', 
  'info@newgraphic.me', 
  'EGP', 
  14.00, 
  'مصر'
);

-- Insert default roles
INSERT INTO `roles` (`name`, `name_ar`, `description`) VALUES
('super_admin', 'مدير عام', 'صلاحيات كاملة على النظام'),
('accountant', 'محاسب', 'إدارة الحسابات والتقارير المالية'),
('sales_manager', 'مسؤول مبيعات', 'إدارة العملاء وعروض الأسعار والفواتير'),
('production_manager', 'مدير إنتاج', 'إدارة أوامر الشغل والمشاريع'),
('warehouse_manager', 'مسؤول مخزن', 'إدارة المخزون والمستودعات'),
('employee', 'موظف', 'صلاحيات محدودة');

-- Insert default system settings
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_public`) VALUES
('app_name', 'New Graphic ERP', 'string', 'اسم التطبيق', TRUE),
('app_language', 'ar', 'string', 'اللغة الافتراضية', TRUE),
('app_timezone', 'Africa/Cairo', 'string', 'المنطقة الزمنية', FALSE),
('date_format', 'Y-m-d', 'string', 'صيغة التاريخ', FALSE),
('pagination_per_page', '25', 'integer', 'عدد السجلات في الصفحة', FALSE),
('default_tax_rate', '14.00', 'decimal', 'نسبة الضريبة الافتراضية', FALSE);

-- ============================================
-- End of Schema
-- ============================================
