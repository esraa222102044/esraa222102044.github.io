# API Documentation - New Graphic ERP

<div dir="rtl">

## نظرة عامة

هذا هو توثيق API لنظام New Graphic ERP. جميع نقاط النهاية (endpoints) تستخدم JSON للطلبات والاستجابات.

### Base URL

```
Production: https://newgraphic.me/api
Development: http://localhost:8000/api
```

### Authentication

يستخدم النظام Laravel Sanctum للمصادقة. يجب إرسال token في header:

```
Authorization: Bearer {your-access-token}
```

### Response Format

جميع الاستجابات تتبع الصيغة التالية:

#### Success Response

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "message": "رسالة النجاح" // اختياري
}
```

#### Error Response

```json
{
  "success": false,
  "message": "رسالة الخطأ",
  "errors": {
    "field_name": ["validation error message"]
  }
}
```

### Status Codes

| Code | Description |
|------|-------------|
| 200 | OK - طلب ناجح |
| 201 | Created - تم الإنشاء بنجاح |
| 400 | Bad Request - طلب خاطئ |
| 401 | Unauthorized - غير مصرح |
| 403 | Forbidden - ممنوع |
| 404 | Not Found - غير موجود |
| 422 | Unprocessable Entity - خطأ في التحقق |
| 500 | Internal Server Error - خطأ في الخادم |

---

## Authentication APIs

### Login

تسجيل الدخول للحصول على access token.

**Endpoint:** `POST /auth/login`

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "email": "user@example.com",
      "roles": [
        {
          "id": 1,
          "name": "super_admin",
          "name_ar": "مدير عام"
        }
      ]
    },
    "token": "1|abcdefghijklmnopqrstuvwxyz"
  }
}
```

### Logout

تسجيل الخروج وإلغاء token الحالي.

**Endpoint:** `POST /auth/logout`

**Headers:** `Authorization: Bearer {token}`

**Response:**

```json
{
  "success": true,
  "message": "تم تسجيل الخروج بنجاح"
}
```

### Get Current User

الحصول على معلومات المستخدم الحالي.

**Endpoint:** `GET /auth/user`

**Headers:** `Authorization: Bearer {token}`

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "أحمد محمد",
    "email": "user@example.com",
    "phone": "0123456789",
    "roles": [...],
    "permissions": [...]
  }
}
```

---

## CRM & Sales APIs

### Customers

#### List Customers

**Endpoint:** `GET /crm/customers`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| search | string | بحث في الاسم، الشركة، الهاتف |
| is_active | boolean | تصفية حسب الحالة |
| page | integer | رقم الصفحة |
| per_page | integer | عدد العناصر في الصفحة (default: 25) |

**Example Request:**

```
GET /crm/customers?search=أحمد&is_active=true&page=1&per_page=25
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "أحمد محمد",
      "company_name": "شركة النجاح",
      "email": "ahmed@example.com",
      "phone": "0123456789",
      "phone2": null,
      "tax_number": "123456789",
      "address": "شارع الجامعة، القاهرة",
      "city": "القاهرة",
      "country": "مصر",
      "is_active": true,
      "created_at": "2024-01-01T10:00:00.000000Z",
      "updated_at": "2024-01-01T10:00:00.000000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "per_page": 25,
    "total": 120
  }
}
```

#### Get Customer by ID

**Endpoint:** `GET /crm/customers/{id}`

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "أحمد محمد",
    "company_name": "شركة النجاح",
    // ... all customer fields
    "statistics": {
      "total_quotations": 15,
      "total_work_orders": 12,
      "total_invoices": 10,
      "total_purchases": 150000.00,
      "outstanding_balance": 25000.00
    }
  }
}
```

#### Create Customer

**Endpoint:** `POST /crm/customers`

**Request Body:**

```json
{
  "name": "أحمد محمد",
  "company_name": "شركة النجاح",
  "email": "ahmed@example.com",
  "phone": "0123456789",
  "phone2": "0987654321",
  "tax_number": "123456789",
  "address": "شارع الجامعة، القاهرة",
  "city": "القاهرة",
  "country": "مصر",
  "notes": "عميل مميز",
  "is_active": true
}
```

**Validation Rules:**

- `name`: required, string, max:255
- `company_name`: nullable, string, max:255
- `email`: nullable, email, unique
- `phone`: required, string, max:20
- `phone2`: nullable, string, max:20
- `tax_number`: nullable, string, max:50
- `address`: nullable, string
- `city`: nullable, string, max:100
- `country`: nullable, string, max:100
- `notes`: nullable, string
- `is_active`: boolean

**Response:**

```json
{
  "success": true,
  "message": "تم إضافة العميل بنجاح",
  "data": {
    "id": 1,
    // ... customer data
  }
}
```

#### Update Customer

**Endpoint:** `PUT /crm/customers/{id}`

**Request Body:** Same as Create Customer

**Response:**

```json
{
  "success": true,
  "message": "تم تحديث بيانات العميل بنجاح",
  "data": {
    // ... updated customer data
  }
}
```

#### Delete Customer

**Endpoint:** `DELETE /crm/customers/{id}`

**Response:**

```json
{
  "success": true,
  "message": "تم حذف العميل بنجاح"
}
```

### Quotations

#### List Quotations

**Endpoint:** `GET /crm/quotations`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| customer_id | integer | تصفية حسب العميل |
| status | string | draft, sent, approved, rejected, cancelled |
| from_date | date | من تاريخ |
| to_date | date | إلى تاريخ |
| page | integer | رقم الصفحة |
| per_page | integer | عدد العناصر |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "quotation_number": "QT-2024-001",
      "customer": {
        "id": 1,
        "name": "أحمد محمد"
      },
      "quotation_date": "2024-01-15",
      "valid_until": "2024-02-15",
      "status": "sent",
      "subtotal": 10000.00,
      "tax_rate": 14.00,
      "tax_amount": 1400.00,
      "total": 11400.00,
      "created_at": "2024-01-15T10:00:00.000000Z"
    }
  ],
  "meta": { ... }
}
```

#### Get Quotation by ID

**Endpoint:** `GET /crm/quotations/{id}`

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "quotation_number": "QT-2024-001",
    "customer": {
      "id": 1,
      "name": "أحمد محمد",
      "company_name": "شركة النجاح"
    },
    "quotation_date": "2024-01-15",
    "valid_until": "2024-02-15",
    "status": "sent",
    "subtotal": 10000.00,
    "tax_rate": 14.00,
    "tax_amount": 1400.00,
    "discount_type": "percentage",
    "discount_value": 5.00,
    "total": 11400.00,
    "notes": "ملاحظات",
    "terms_conditions": "الشروط والأحكام",
    "items": [
      {
        "id": 1,
        "item_number": 1,
        "description": "لافتة خارجية 3×2 متر",
        "design_cost": 500.00,
        "material_type": "فينيل",
        "material_specs": "فينيل لامع 5 ميل",
        "width": 3.00,
        "height": 2.00,
        "unit": "متر مربع",
        "quantity": 1.00,
        "print_type": "ديجيتال",
        "finishing": "قص وتركيب",
        "installation_cost": 1000.00,
        "transport_cost": 200.00,
        "unit_price": 5000.00,
        "total_price": 5000.00
      }
    ]
  }
}
```

#### Create Quotation

**Endpoint:** `POST /crm/quotations`

**Request Body:**

```json
{
  "customer_id": 1,
  "quotation_date": "2024-01-15",
  "valid_until": "2024-02-15",
  "tax_rate": 14.00,
  "discount_type": "percentage",
  "discount_value": 5.00,
  "notes": "ملاحظات",
  "terms_conditions": "الشروط والأحكام",
  "items": [
    {
      "item_number": 1,
      "description": "لافتة خارجية 3×2 متر",
      "design_cost": 500.00,
      "material_type": "فينيل",
      "material_specs": "فينيل لامع 5 ميل",
      "width": 3.00,
      "height": 2.00,
      "unit": "متر مربع",
      "quantity": 1.00,
      "print_type": "ديجيتال",
      "finishing": "قص وتركيب",
      "installation_cost": 1000.00,
      "transport_cost": 200.00,
      "unit_price": 5000.00,
      "total_price": 5000.00
    }
  ]
}
```

**Response:**

```json
{
  "success": true,
  "message": "تم إنشاء عرض السعر بنجاح",
  "data": { ... }
}
```

#### Approve Quotation

**Endpoint:** `POST /crm/quotations/{id}/approve`

**Response:**

```json
{
  "success": true,
  "message": "تمت الموافقة على عرض السعر",
  "data": { ... }
}
```

#### Convert Quotation to Work Order

**Endpoint:** `POST /crm/quotations/{id}/convert`

**Response:**

```json
{
  "success": true,
  "message": "تم تحويل عرض السعر إلى أمر شغل",
  "data": {
    "work_order": { ... }
  }
}
```

---

## Production APIs

### Work Orders

#### List Work Orders

**Endpoint:** `GET /production/work-orders`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| customer_id | integer | تصفية حسب العميل |
| status | string | received, design, printing, finishing, installation, delivered |
| priority | string | low, normal, high, urgent |
| from_date | date | من تاريخ |
| to_date | date | إلى تاريخ |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "order_number": "WO-2024-001",
      "customer": {
        "id": 1,
        "name": "أحمد محمد"
      },
      "order_date": "2024-01-15",
      "delivery_date": "2024-01-20",
      "status": "printing",
      "priority": "high",
      "total_amount": 11400.00,
      "estimated_cost": 7000.00,
      "actual_cost": 6500.00,
      "profit": 4900.00,
      "assigned_to": {
        "id": 2,
        "name": "محمد علي"
      }
    }
  ]
}
```

#### Get Work Order by ID

**Endpoint:** `GET /production/work-orders/{id}`

#### Create Work Order

**Endpoint:** `POST /production/work-orders`

#### Update Work Order Stage

**Endpoint:** `POST /production/work-orders/{id}/update-stage`

**Request Body:**

```json
{
  "status": "printing",
  "notes": "بدأت مرحلة الطباعة"
}
```

#### Upload Design File

**Endpoint:** `POST /production/work-orders/{id}/design-files`

**Request:** Multipart form data

```
file: [file]
description: "التصميم النهائي"
version: 1
is_final: true
```

---

## Accounting APIs

### Chart of Accounts

#### List Accounts

**Endpoint:** `GET /accounting/chart-of-accounts`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| account_type | string | asset, liability, equity, revenue, expense |
| parent_id | integer | للحصول على الحسابات الفرعية |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "account_code": "1000",
      "account_name": "الأصول",
      "account_type": "asset",
      "parent_id": null,
      "level": 1,
      "is_main_account": true,
      "current_balance": 500000.00,
      "children": [
        {
          "id": 2,
          "account_code": "1100",
          "account_name": "أصول متداولة",
          "level": 2,
          // ...
        }
      ]
    }
  ]
}
```

### Journal Entries

#### List Journal Entries

**Endpoint:** `GET /accounting/journal-entries`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| entry_type | string | manual, auto_invoice, auto_payment, etc |
| from_date | date | من تاريخ |
| to_date | date | إلى تاريخ |

#### Create Journal Entry

**Endpoint:** `POST /accounting/journal-entries`

**Request Body:**

```json
{
  "entry_date": "2024-01-15",
  "description": "قيد يومية لـ...",
  "details": [
    {
      "account_id": 10,
      "debit": 5000.00,
      "credit": 0,
      "description": "من حـ/ النقدية"
    },
    {
      "account_id": 20,
      "debit": 0,
      "credit": 5000.00,
      "description": "إلى حـ/ المبيعات"
    }
  ]
}
```

### Invoices

#### List Invoices

**Endpoint:** `GET /accounting/invoices`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| customer_id | integer | تصفية حسب العميل |
| status | string | draft, sent, partial, paid, overdue, cancelled |
| from_date | date | من تاريخ |
| to_date | date | إلى تاريخ |

#### Create Invoice

**Endpoint:** `POST /accounting/invoices`

**Request Body:**

```json
{
  "customer_id": 1,
  "work_order_id": 1,
  "invoice_date": "2024-01-15",
  "due_date": "2024-02-15",
  "tax_rate": 14.00,
  "discount_type": "fixed",
  "discount_value": 500.00,
  "notes": "ملاحظات",
  "items": [
    {
      "item_number": 1,
      "description": "لافتة خارجية",
      "quantity": 1,
      "unit": "قطعة",
      "unit_price": 5000.00,
      "total_price": 5000.00
    }
  ]
}
```

### Payments

#### Create Payment

**Endpoint:** `POST /accounting/payments`

**Request Body:**

```json
{
  "invoice_id": 1,
  "customer_id": 1,
  "payment_date": "2024-01-15",
  "amount": 5000.00,
  "payment_method": "bank_transfer",
  "bank_account_id": 1,
  "reference_number": "TRF123456",
  "notes": "دفعة جزئية"
}
```

### Reports

#### Income Statement

**Endpoint:** `GET /accounting/reports/income-statement`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| from_date | date | من تاريخ (required) |
| to_date | date | إلى تاريخ (required) |

**Response:**

```json
{
  "success": true,
  "data": {
    "period": {
      "from": "2024-01-01",
      "to": "2024-01-31"
    },
    "revenue": {
      "sales_revenue": 150000.00,
      "other_revenue": 5000.00,
      "total_revenue": 155000.00
    },
    "expenses": {
      "cost_of_sales": 80000.00,
      "operating_expenses": 30000.00,
      "administrative_expenses": 15000.00,
      "total_expenses": 125000.00
    },
    "net_income": 30000.00
  }
}
```

#### Balance Sheet

**Endpoint:** `GET /accounting/reports/balance-sheet`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| date | date | التاريخ (required) |

#### Trial Balance

**Endpoint:** `GET /accounting/reports/trial-balance`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| from_date | date | من تاريخ |
| to_date | date | إلى تاريخ |
| type | string | totals (بالمجاميع) أو balances (بالأرصدة) |

#### Aging Report

**Endpoint:** `GET /accounting/reports/aging-report`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| type | string | customers أو suppliers |
| date | date | التاريخ |

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "customer": {
        "id": 1,
        "name": "أحمد محمد"
      },
      "current": 5000.00,
      "1_30_days": 3000.00,
      "31_60_days": 2000.00,
      "61_90_days": 1000.00,
      "over_90_days": 500.00,
      "total": 11500.00
    }
  ]
}
```

---

## Inventory APIs

### Items

#### List Items

**Endpoint:** `GET /inventory/items`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| category_id | integer | تصفية حسب الفئة |
| search | string | بحث في الاسم أو الكود |
| is_active | boolean | تصفية حسب الحالة |

#### Create Item

**Endpoint:** `POST /inventory/items`

**Request Body:**

```json
{
  "item_code": "ITM-001",
  "item_name": "ورق بانر 440 جرام",
  "category_id": 1,
  "description": "ورق بانر عالي الجودة",
  "unit": "متر مربع",
  "cost_price": 50.00,
  "selling_price": 75.00,
  "min_stock_level": 100.00,
  "reorder_level": 150.00,
  "is_active": true
}
```

### Stock Movements

#### Create Stock Movement (In)

**Endpoint:** `POST /inventory/stock-movements`

**Request Body:**

```json
{
  "movement_type": "in",
  "movement_date": "2024-01-15",
  "warehouse_id": 1,
  "reference_type": "purchase_invoice",
  "reference_id": 5,
  "notes": "استلام بضاعة",
  "items": [
    {
      "item_id": 1,
      "quantity": 100.00,
      "unit_cost": 50.00,
      "total_cost": 5000.00
    }
  ]
}
```

#### Get Stock Alerts

**Endpoint:** `GET /inventory/stock-alerts`

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "item": {
        "id": 1,
        "item_code": "ITM-001",
        "item_name": "ورق بانر 440 جرام"
      },
      "current_stock": 80.00,
      "min_stock_level": 100.00,
      "reorder_level": 150.00,
      "alert_type": "below_minimum",
      "needed_quantity": 70.00
    }
  ]
}
```

---

## User Management APIs

### Users

#### List Users

**Endpoint:** `GET /admin/users`

#### Create User

**Endpoint:** `POST /admin/users`

**Request Body:**

```json
{
  "name": "محمد علي",
  "email": "mohamed@example.com",
  "phone": "0123456789",
  "password": "password123",
  "password_confirmation": "password123",
  "role_ids": [2, 3],
  "is_active": true
}
```

### Roles & Permissions

#### List Roles

**Endpoint:** `GET /admin/roles`

#### Create Role

**Endpoint:** `POST /admin/roles`

**Request Body:**

```json
{
  "name": "sales_manager",
  "name_ar": "مسؤول مبيعات",
  "description": "مسؤول عن إدارة المبيعات",
  "permission_ids": [1, 2, 3, 4, 5]
}
```

### Audit Logs

#### List Audit Logs

**Endpoint:** `GET /admin/audit-logs`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| user_id | integer | تصفية حسب المستخدم |
| action | string | create, update, delete |
| module | string | الوحدة |
| from_date | date | من تاريخ |
| to_date | date | إلى تاريخ |

---

## Dashboard APIs

### Dashboard Statistics

**Endpoint:** `GET /dashboard/stats`

**Response:**

```json
{
  "success": true,
  "data": {
    "total_sales": 500000.00,
    "pending_sales": 50000.00,
    "total_customers": 150,
    "active_work_orders": 25,
    "overdue_invoices": 5,
    "low_stock_items": 8,
    "today_sales": 15000.00,
    "this_month_sales": 125000.00
  }
}
```

### Dashboard Charts

**Endpoint:** `GET /dashboard/charts`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| period | string | today, week, month, year |

**Response:**

```json
{
  "success": true,
  "data": {
    "revenue_expenses": {
      "labels": ["01-01", "01-02", "01-03", ...],
      "revenue": [5000, 7000, 6000, ...],
      "expenses": [3000, 4000, 3500, ...]
    },
    "work_orders_by_status": {
      "received": 5,
      "design": 3,
      "printing": 8,
      "finishing": 4,
      "installation": 2,
      "delivered": 15
    }
  }
}
```

---

## Error Handling

### Validation Errors

**Status Code:** 422

```json
{
  "success": false,
  "message": "خطأ في البيانات المدخلة",
  "errors": {
    "email": ["البريد الإلكتروني مستخدم بالفعل"],
    "phone": ["رقم الهاتف مطلوب"]
  }
}
```

### Authentication Errors

**Status Code:** 401

```json
{
  "success": false,
  "message": "غير مصرح - يرجى تسجيل الدخول"
}
```

### Authorization Errors

**Status Code:** 403

```json
{
  "success": false,
  "message": "ليس لديك صلاحية للوصول إلى هذا المورد"
}
```

### Not Found Errors

**Status Code:** 404

```json
{
  "success": false,
  "message": "المورد غير موجود"
}
```

---

## Rate Limiting

- **General Endpoints:** 60 requests per minute
- **Login Endpoint:** 5 requests per minute

عند تجاوز الحد:

**Status Code:** 429

```json
{
  "success": false,
  "message": "عدد كبير من الطلبات. يرجى المحاولة لاحقاً"
}
```

---

## Pagination

جميع endpoints التي تُرجع قوائم تدعم الترقيم (pagination):

**Query Parameters:**

- `page`: رقم الصفحة (default: 1)
- `per_page`: عدد العناصر في الصفحة (default: 25, max: 100)

**Response Meta:**

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "per_page": 25,
    "total": 250,
    "from": 1,
    "to": 25
  },
  "links": {
    "first": "http://api.example.com/customers?page=1",
    "last": "http://api.example.com/customers?page=10",
    "prev": null,
    "next": "http://api.example.com/customers?page=2"
  }
}
```

---

## File Upload

لرفع الملفات، استخدم `multipart/form-data`:

**Headers:**

```
Content-Type: multipart/form-data
Authorization: Bearer {token}
```

**Example (Design File Upload):**

```javascript
const formData = new FormData()
formData.append('file', file)
formData.append('description', 'التصميم النهائي')
formData.append('version', 1)
formData.append('is_final', true)

fetch('/production/work-orders/1/design-files', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token
  },
  body: formData
})
```

---

## Testing the API

### Using Postman

1. استيراد Collection من: `docs/postman/new-graphic-erp.postman_collection.json`
2. تعيين Environment Variables:
   - `base_url`: http://localhost:8000/api
   - `token`: [your access token]

### Using cURL

**Login:**

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password"
  }'
```

**Get Customers (with token):**

```bash
curl -X GET http://localhost:8000/api/crm/customers \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## Support

للاستفسارات حول الـ API:

📧 **Email:** developers@newgraphic.me

📚 **Documentation:** https://api.newgraphic.me/docs

🐛 **Report Issues:** https://github.com/esraa222102044/esraa222102044.github.io/issues

</div>
