# الوثائق الفنية - نظام New Graphic ERP

<div dir="rtl">

## 1. نظرة عامة على البنية المعمارية

### 1.1 البنية العامة

النظام مبني على معمارية Client-Server باستخدام:
- **Backend API**: Laravel 10.x (RESTful API)
- **Frontend SPA**: Vue.js 3
- **Database**: MySQL 8.x
- **Authentication**: Laravel Sanctum / JWT

```
┌─────────────────┐
│   Vue.js SPA    │
│   (Frontend)    │
└────────┬────────┘
         │ HTTP/REST API
         │
┌────────▼────────┐
│  Laravel API    │
│   (Backend)     │
└────────┬────────┘
         │
┌────────▼────────┐
│  MySQL Database │
└─────────────────┘
```

### 1.2 هيكل المجلدات

```
new-graphic-erp/
├── backend/                    # تطبيق Laravel
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/    # Controllers
│   │   │   ├── Middleware/     # Middleware
│   │   │   └── Requests/       # Form Requests
│   │   ├── Models/             # Eloquent Models
│   │   ├── Services/           # Business Logic
│   │   ├── Repositories/       # Data Access Layer
│   │   └── Traits/             # Reusable Traits
│   ├── config/                 # Configuration Files
│   ├── database/
│   │   ├── migrations/         # Database Migrations
│   │   ├── seeders/            # Data Seeders
│   │   └── factories/          # Model Factories
│   ├── routes/
│   │   ├── api.php             # API Routes
│   │   └── web.php             # Web Routes
│   ├── resources/
│   │   └── views/              # Blade Templates (للطباعة)
│   ├── storage/                # Storage
│   └── tests/                  # Tests
│
├── frontend/                   # تطبيق Vue.js
│   ├── src/
│   │   ├── assets/             # Static Assets
│   │   ├── components/         # Vue Components
│   │   │   ├── common/         # مكونات مشتركة
│   │   │   ├── crm/            # مكونات CRM
│   │   │   ├── production/     # مكونات الإنتاج
│   │   │   ├── accounting/     # مكونات المحاسبة
│   │   │   └── inventory/      # مكونات المخزون
│   │   ├── views/              # Page Views
│   │   ├── router/             # Vue Router Config
│   │   ├── store/              # Vuex/Pinia Store
│   │   ├── services/           # API Services
│   │   ├── utils/              # Utility Functions
│   │   ├── composables/        # Vue Composables
│   │   ├── locales/            # i18n Translations
│   │   ├── App.vue             # Root Component
│   │   └── main.js             # Entry Point
│   ├── public/                 # Public Assets
│   └── tests/                  # Tests
│
├── docs/                       # Documentation
└── database/                   # Database Scripts
    ├── schemas/                # Database Schema
    └── seeds/                  # Initial Data
```

## 2. Backend - Laravel Application

### 2.1 Database Design

#### 2.1.1 العلاقات الرئيسية بين الجداول

```
users ──┬─── roles (Many-to-Many)
        └─── permissions (Many-to-Many through roles)

customers ──┬─── quotations (One-to-Many)
            ├─── work_orders (One-to-Many)
            ├─── invoices (One-to-Many)
            └─── payments (One-to-Many)

quotations ──┬─── quotation_items (One-to-Many)
             └─── work_orders (One-to-One)

work_orders ──┬─── work_order_items (One-to-Many)
              ├─── design_files (One-to-Many)
              ├─── work_order_stages (One-to-Many)
              └─── invoices (One-to-Many)

chart_of_accounts ──┬─── journal_entry_details (One-to-Many)
                    └─── parent (Self-referencing)

journal_entries ──── journal_entry_details (One-to-Many)

invoices ──┬─── invoice_items (One-to-Many)
           └─── payments (One-to-Many)

items ──┬─── stock_movement_items (One-to-Many)
        └─── warehouse_stock (One-to-Many)

warehouses ──── warehouse_stock (One-to-Many)
```

### 2.2 Models and Relationships

#### مثال: Customer Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Customer extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'name', 'company_name', 'email', 'phone', 'phone2',
        'tax_number', 'address', 'city', 'country', 'notes',
        'is_active', 'created_by'
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Relationships
    public function quotations()
    {
        return $this->hasMany(Quotation::class);
    }

    public function workOrders()
    {
        return $this->hasMany(WorkOrder::class);
    }

    public function invoices()
    {
        return $this->hasMany(Invoice::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    // Accessors
    public function getFullNameAttribute()
    {
        return $this->company_name ?? $this->name;
    }

    // Business Methods
    public function getTotalPurchases()
    {
        return $this->invoices()
            ->where('status', 'paid')
            ->sum('total');
    }

    public function getOutstandingBalance()
    {
        return $this->invoices()
            ->whereIn('status', ['sent', 'partial', 'overdue'])
            ->sum('remaining_amount');
    }
}
```

### 2.3 Controllers Structure

#### مثال: CustomerController

```php
<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\CustomerRequest;
use App\Services\CustomerService;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    protected $customerService;

    public function __construct(CustomerService $customerService)
    {
        $this->customerService = $customerService;
        
        // Permissions
        $this->middleware('permission:customers.view')->only(['index', 'show']);
        $this->middleware('permission:customers.create')->only(['store']);
        $this->middleware('permission:customers.edit')->only(['update']);
        $this->middleware('permission:customers.delete')->only(['destroy']);
    }

    public function index(Request $request)
    {
        $customers = $this->customerService->getAllCustomers(
            $request->all()
        );

        return response()->json([
            'success' => true,
            'data' => $customers
        ]);
    }

    public function show($id)
    {
        $customer = $this->customerService->getCustomerById($id);

        return response()->json([
            'success' => true,
            'data' => $customer
        ]);
    }

    public function store(CustomerRequest $request)
    {
        $customer = $this->customerService->createCustomer(
            $request->validated()
        );

        return response()->json([
            'success' => true,
            'message' => 'تم إضافة العميل بنجاح',
            'data' => $customer
        ], 201);
    }

    public function update(CustomerRequest $request, $id)
    {
        $customer = $this->customerService->updateCustomer(
            $id, 
            $request->validated()
        );

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث بيانات العميل بنجاح',
            'data' => $customer
        ]);
    }

    public function destroy($id)
    {
        $this->customerService->deleteCustomer($id);

        return response()->json([
            'success' => true,
            'message' => 'تم حذف العميل بنجاح'
        ]);
    }
}
```

### 2.4 Services Layer

Services تحتوي على Business Logic:

```php
<?php

namespace App\Services;

use App\Models\Customer;
use App\Repositories\CustomerRepository;
use Illuminate\Support\Facades\DB;

class CustomerService
{
    protected $customerRepository;

    public function __construct(CustomerRepository $customerRepository)
    {
        $this->customerRepository = $customerRepository;
    }

    public function getAllCustomers(array $filters = [])
    {
        return $this->customerRepository->getAll($filters);
    }

    public function getCustomerById($id)
    {
        return $this->customerRepository->findOrFail($id);
    }

    public function createCustomer(array $data)
    {
        DB::beginTransaction();
        try {
            $data['created_by'] = auth()->id();
            $customer = $this->customerRepository->create($data);

            // Log activity
            activity()
                ->performedOn($customer)
                ->causedBy(auth()->user())
                ->log('تم إضافة عميل جديد');

            DB::commit();
            return $customer;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function updateCustomer($id, array $data)
    {
        DB::beginTransaction();
        try {
            $customer = $this->customerRepository->findOrFail($id);
            $customer = $this->customerRepository->update($id, $data);

            // Log activity
            activity()
                ->performedOn($customer)
                ->causedBy(auth()->user())
                ->log('تم تحديث بيانات العميل');

            DB::commit();
            return $customer;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function deleteCustomer($id)
    {
        DB::beginTransaction();
        try {
            $customer = $this->customerRepository->findOrFail($id);
            
            // Check if customer has related records
            if ($customer->invoices()->exists()) {
                throw new \Exception('لا يمكن حذف العميل لوجود فواتير مرتبطة به');
            }

            $this->customerRepository->delete($id);

            // Log activity
            activity()
                ->performedOn($customer)
                ->causedBy(auth()->user())
                ->log('تم حذف العميل');

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
```

### 2.5 API Routes

```php
// routes/api.php

use App\Http\Controllers\API;

Route::middleware(['auth:sanctum'])->group(function () {
    
    // CRM & Sales
    Route::prefix('crm')->group(function () {
        Route::apiResource('customers', API\CustomerController::class);
        Route::apiResource('quotations', API\QuotationController::class);
        Route::post('quotations/{id}/approve', [API\QuotationController::class, 'approve']);
        Route::post('quotations/{id}/convert', [API\QuotationController::class, 'convertToWorkOrder']);
    });

    // Production
    Route::prefix('production')->group(function () {
        Route::apiResource('work-orders', API\WorkOrderController::class);
        Route::post('work-orders/{id}/update-stage', [API\WorkOrderController::class, 'updateStage']);
        Route::post('work-orders/{id}/design-files', [API\WorkOrderController::class, 'uploadDesignFile']);
    });

    // Accounting
    Route::prefix('accounting')->group(function () {
        Route::apiResource('chart-of-accounts', API\ChartOfAccountsController::class);
        Route::apiResource('journal-entries', API\JournalEntryController::class);
        Route::apiResource('invoices', API\InvoiceController::class);
        Route::apiResource('payments', API\PaymentController::class);
        Route::apiResource('suppliers', API\SupplierController::class);
        Route::apiResource('expenses', API\ExpenseController::class);
        
        // Reports
        Route::get('reports/income-statement', [API\ReportController::class, 'incomeStatement']);
        Route::get('reports/balance-sheet', [API\ReportController::class, 'balanceSheet']);
        Route::get('reports/trial-balance', [API\ReportController::class, 'trialBalance']);
        Route::get('reports/aging-report', [API\ReportController::class, 'agingReport']);
    });

    // Inventory
    Route::prefix('inventory')->group(function () {
        Route::apiResource('items', API\ItemController::class);
        Route::apiResource('warehouses', API\WarehouseController::class);
        Route::apiResource('stock-movements', API\StockMovementController::class);
        Route::get('stock-alerts', [API\InventoryController::class, 'stockAlerts']);
    });

    // Users & Permissions
    Route::prefix('admin')->group(function () {
        Route::apiResource('users', API\UserController::class);
        Route::apiResource('roles', API\RoleController::class);
        Route::apiResource('permissions', API\PermissionController::class);
        Route::get('audit-logs', [API\AuditLogController::class, 'index']);
    });

    // Dashboard
    Route::get('dashboard/stats', [API\DashboardController::class, 'stats']);
    Route::get('dashboard/charts', [API\DashboardController::class, 'charts']);
    Route::get('dashboard/notifications', [API\DashboardController::class, 'notifications']);
});
```

### 2.6 Authentication & Authorization

#### Authentication (Laravel Sanctum)

```php
// Login
Route::post('login', function (Request $request) {
    $request->validate([
        'email' => 'required|email',
        'password' => 'required'
    ]);

    $user = User::where('email', $request->email)->first();

    if (!$user || !Hash::check($request->password, $user->password)) {
        throw ValidationException::withMessages([
            'email' => ['البيانات المدخلة غير صحيحة'],
        ]);
    }

    $token = $user->createToken('auth-token')->plainTextToken;

    return response()->json([
        'success' => true,
        'user' => $user->load('roles.permissions'),
        'token' => $token
    ]);
});

// Logout
Route::post('logout', function (Request $request) {
    $request->user()->currentAccessToken()->delete();
    
    return response()->json([
        'success' => true,
        'message' => 'تم تسجيل الخروج بنجاح'
    ]);
})->middleware('auth:sanctum');
```

#### Authorization (Permissions)

```php
// app/Providers/AuthServiceProvider.php

use Illuminate\Support\Facades\Gate;

public function boot()
{
    $this->registerPolicies();

    // Super Admin bypass
    Gate::before(function ($user, $ability) {
        if ($user->hasRole('super_admin')) {
            return true;
        }
    });

    // Dynamic permissions
    Permission::all()->each(function ($permission) {
        Gate::define($permission->name, function ($user) use ($permission) {
            return $user->hasPermission($permission->name);
        });
    });
}
```

### 2.7 Middleware

#### Permission Middleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckPermission
{
    public function handle(Request $request, Closure $next, $permission)
    {
        if (!$request->user()->can($permission)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية للوصول إلى هذا المورد'
            ], 403);
        }

        return $next($request);
    }
}
```

## 3. Frontend - Vue.js Application

### 3.1 Project Structure

```
frontend/src/
├── main.js                    # Entry point
├── App.vue                    # Root component
├── router/
│   └── index.js              # Router configuration
├── store/
│   ├── index.js              # Vuex/Pinia store
│   └── modules/              # Store modules
│       ├── auth.js
│       ├── customers.js
│       ├── quotations.js
│       └── ...
├── views/                    # Page components
│   ├── Dashboard.vue
│   ├── crm/
│   │   ├── Customers.vue
│   │   ├── CustomerForm.vue
│   │   └── Quotations.vue
│   ├── production/
│   │   └── WorkOrders.vue
│   ├── accounting/
│   │   ├── ChartOfAccounts.vue
│   │   └── Invoices.vue
│   └── inventory/
│       └── Items.vue
├── components/               # Reusable components
│   ├── common/
│   │   ├── DataTable.vue
│   │   ├── Modal.vue
│   │   ├── FormInput.vue
│   │   └── DatePicker.vue
│   └── layout/
│       ├── Navbar.vue
│       ├── Sidebar.vue
│       └── Footer.vue
├── services/                 # API services
│   ├── api.js               # Axios instance
│   ├── auth.service.js
│   ├── customer.service.js
│   └── ...
├── composables/              # Vue composables
│   ├── useAuth.js
│   ├── usePermissions.js
│   └── useNotification.js
├── utils/                    # Utilities
│   ├── helpers.js
│   ├── validators.js
│   └── formatters.js
└── locales/                  # i18n translations
    ├── ar.json
    └── en.json
```

### 3.2 Router Configuration

```javascript
// router/index.js

import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/store/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/Login.vue'),
    meta: { guest: true }
  },
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue')
      },
      {
        path: 'customers',
        name: 'Customers',
        component: () => import('@/views/crm/Customers.vue'),
        meta: { permission: 'customers.view' }
      },
      {
        path: 'quotations',
        name: 'Quotations',
        component: () => import('@/views/crm/Quotations.vue'),
        meta: { permission: 'quotations.view' }
      },
      // ... more routes
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guards
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'Login' })
  } else if (to.meta.guest && authStore.isAuthenticated) {
    next({ name: 'Dashboard' })
  } else if (to.meta.permission && !authStore.hasPermission(to.meta.permission)) {
    next({ name: 'Dashboard' })
  } else {
    next()
  }
})

export default router
```

### 3.3 State Management (Pinia)

```javascript
// store/auth.js

import { defineStore } from 'pinia'
import { authService } from '@/services/auth.service'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token') || null,
    permissions: []
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    userName: (state) => state.user?.name || '',
    userRoles: (state) => state.user?.roles || []
  },

  actions: {
    async login(credentials) {
      try {
        const response = await authService.login(credentials)
        this.user = response.user
        this.token = response.token
        this.permissions = this.extractPermissions(response.user.roles)
        
        localStorage.setItem('token', response.token)
        return true
      } catch (error) {
        throw error
      }
    },

    async logout() {
      try {
        await authService.logout()
      } finally {
        this.user = null
        this.token = null
        this.permissions = []
        localStorage.removeItem('token')
      }
    },

    hasPermission(permission) {
      return this.permissions.includes(permission) || 
             this.userRoles.some(role => role.name === 'super_admin')
    },

    extractPermissions(roles) {
      const permissions = []
      roles.forEach(role => {
        role.permissions.forEach(permission => {
          if (!permissions.includes(permission.name)) {
            permissions.push(permission.name)
          }
        })
      })
      return permissions
    }
  }
})
```

### 3.4 API Service

```javascript
// services/api.js

import axios from 'axios'
import { useAuthStore } from '@/store/auth'
import router from '@/router'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000/api',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  }
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      const authStore = useAuthStore()
      authStore.logout()
      router.push({ name: 'Login' })
    }
    return Promise.reject(error)
  }
)

export default api
```

### 3.5 RTL Support

```javascript
// main.js

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { createPinia } from 'pinia'
import i18n from './i18n'

// Bootstrap RTL
import 'bootstrap/dist/css/bootstrap.rtl.min.css'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'

// Custom RTL styles
import '@/assets/styles/rtl.css'

const app = createApp(App)

// Set HTML dir attribute
document.documentElement.dir = 'rtl'
document.documentElement.lang = 'ar'

app.use(createPinia())
app.use(router)
app.use(i18n)

app.mount('#app')
```

```css
/* assets/styles/rtl.css */

body {
  direction: rtl;
  text-align: right;
  font-family: 'Cairo', 'Tajawal', sans-serif;
}

.form-label {
  text-align: right;
}

.table {
  direction: rtl;
  text-align: right;
}

/* Override Bootstrap defaults for RTL */
.dropdown-menu {
  right: 0;
  left: auto;
}

/* Custom RTL utilities */
.me-auto {
  margin-right: auto !important;
  margin-left: 0 !important;
}

.ms-auto {
  margin-left: auto !important;
  margin-right: 0 !important;
}
```

## 4. Security Implementation

### 4.1 Password Hashing

```php
// Using bcrypt (Laravel default)
$hashedPassword = Hash::make($password);

// Verification
if (Hash::check($plainPassword, $hashedPassword)) {
    // Password matches
}
```

### 4.2 CSRF Protection

```php
// Automatically enabled in Laravel
// frontend should send CSRF token with requests

// api.php routes are exempt by default
// For web routes, include @csrf in forms
```

### 4.3 XSS Protection

```php
// Input sanitization
$cleanInput = strip_tags($request->input('field'));

// Output escaping (automatic in Blade)
{{ $variable }} // Escaped
{!! $variable !!} // Unescaped (use with caution)
```

### 4.4 SQL Injection Protection

```php
// Use Eloquent ORM or Query Builder
// Parameterized queries by default

// Safe
User::where('email', $email)->first();

// Safe with raw queries
DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// UNSAFE - Never do this
DB::select("SELECT * FROM users WHERE email = '$email'");
```

### 4.5 Rate Limiting

```php
// routes/api.php

Route::middleware(['throttle:60,1'])->group(function () {
    // 60 requests per minute
});

Route::post('login')->middleware('throttle:5,1');
// 5 login attempts per minute
```

## 5. Performance Optimization

### 5.1 Database Optimization

```php
// Eager Loading
$customers = Customer::with(['quotations', 'invoices'])->get();

// Lazy Eager Loading
$customers = Customer::all();
$customers->load('quotations');

// Pagination
$customers = Customer::paginate(25);

// Indexing
Schema::table('customers', function (Blueprint $table) {
    $table->index('email');
    $table->index('phone');
});

// Query optimization
$invoices = Invoice::select('id', 'invoice_number', 'total')
    ->where('status', 'paid')
    ->orderBy('created_at', 'desc')
    ->limit(100)
    ->get();
```

### 5.2 Caching

```php
// Cache frequently accessed data
$settings = Cache::remember('system_settings', 3600, function () {
    return SystemSetting::all();
});

// Cache tags
Cache::tags(['customers'])->put('customer-' . $id, $customer, 3600);
Cache::tags(['customers'])->flush();

// Redis for session and cache
// config/database.php
'redis' => [
    'client' => 'predis',
    'default' => [
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', 6379),
        'database' => 0,
    ],
]
```

### 5.3 Queue Jobs

```php
// For long-running tasks
// jobs/GenerateInvoicePDF.php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class GenerateInvoicePDF implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $invoice;

    public function __construct($invoice)
    {
        $this->invoice = $invoice;
    }

    public function handle()
    {
        // Generate PDF logic
    }
}

// Dispatch job
GenerateInvoicePDF::dispatch($invoice);
```

## 6. Testing

### 6.1 Unit Tests

```php
// tests/Unit/CustomerTest.php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\Customer;

class CustomerTest extends TestCase
{
    public function test_customer_can_be_created()
    {
        $customer = Customer::factory()->create([
            'name' => 'أحمد محمد',
            'phone' => '0123456789'
        ]);

        $this->assertDatabaseHas('customers', [
            'name' => 'أحمد محمد',
            'phone' => '0123456789'
        ]);
    }
}
```

### 6.2 Feature Tests

```php
// tests/Feature/CustomerAPITest.php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Customer;

class CustomerAPITest extends TestCase
{
    public function test_authenticated_user_can_list_customers()
    {
        $user = User::factory()->create();
        
        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/crm/customers');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['id', 'name', 'phone', 'email']
                ]
            ]);
    }
}
```

## 7. Deployment

### 7.1 Server Requirements

- PHP >= 8.0
- MySQL >= 8.0 or PostgreSQL >= 15.0
- Composer
- Node.js >= 16.x
- Nginx or Apache
- SSL Certificate (للإنتاج)

### 7.2 Deployment Steps

```bash
# 1. Clone repository
git clone https://github.com/your-repo/new-graphic-erp.git
cd new-graphic-erp

# 2. Install backend dependencies
cd backend
composer install --optimize-autoloader --no-dev

# 3. Setup environment
cp .env.example .env
php artisan key:generate

# 4. Configure database in .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=new_graphic_erp
# DB_USERNAME=root
# DB_PASSWORD=

# 5. Run migrations
php artisan migrate --force

# 6. Seed initial data
php artisan db:seed

# 7. Link storage
php artisan storage:link

# 8. Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 9. Install frontend dependencies
cd ../frontend
npm install

# 10. Build frontend
npm run build

# 11. Configure web server (Nginx example)
# See nginx.conf example below
```

### 7.3 Nginx Configuration

```nginx
server {
    listen 80;
    server_name newgraphic.me www.newgraphic.me;
    root /var/www/new-graphic-erp/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # Frontend SPA
    location / {
        try_files $uri $uri/ /index.html;
        root /var/www/new-graphic-erp/frontend/dist;
    }

    # API Backend
    location /api {
        try_files $uri $uri/ /index.php?$query_string;
        root /var/www/new-graphic-erp/backend/public;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

## 8. Backup and Maintenance

### 8.1 Database Backup

```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/database"
DB_NAME="new_graphic_erp"

mysqldump -u root -p $DB_NAME > $BACKUP_DIR/backup_$DATE.sql
gzip $BACKUP_DIR/backup_$DATE.sql

# Delete backups older than 30 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
```

### 8.2 Application Maintenance

```php
// Enable maintenance mode
php artisan down --message="نظام قيد الصيانة" --retry=60

// Run updates
composer update
php artisan migrate
php artisan cache:clear
php artisan config:cache

// Disable maintenance mode
php artisan up
```

</div>
