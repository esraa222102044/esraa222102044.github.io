# دليل التطوير - نظام New Graphic ERP

<div dir="rtl">

## 1. إعداد بيئة التطوير

### 1.1 المتطلبات الأساسية

قبل البدء، تأكد من تثبيت:

- **PHP >= 8.0** مع الإضافات:
  - OpenSSL
  - PDO
  - Mbstring
  - Tokenizer
  - XML
  - Ctype
  - JSON
  - BCMath
- **Composer** (لإدارة حزم PHP)
- **MySQL 8.0+** أو **PostgreSQL 15.0+**
- **Node.js >= 16.x** و **npm**
- **Git**
- محرر نصوص (VS Code موصى به)

### 1.2 استنساخ المشروع

```bash
git clone https://github.com/esraa222102044/esraa222102044.github.io.git
cd esraa222102044.github.io
```

### 1.3 إعداد Backend (Laravel)

```bash
cd backend

# تثبيت الحزم
composer install

# نسخ ملف البيئة
cp .env.example .env

# توليد مفتاح التطبيق
php artisan key:generate

# إعداد قاعدة البيانات في .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=new_graphic_erp_dev
# DB_USERNAME=root
# DB_PASSWORD=

# تشغيل Migrations
php artisan migrate

# تشغيل Seeders
php artisan db:seed

# ربط التخزين
php artisan storage:link

# تشغيل الخادم
php artisan serve
# سيعمل على http://localhost:8000
```

### 1.4 إعداد Frontend (Vue.js)

```bash
cd ../frontend

# تثبيت الحزم
npm install

# نسخ ملف البيئة
cp .env.example .env

# تعديل .env
# VITE_API_URL=http://localhost:8000/api

# تشغيل خادم التطوير
npm run dev
# سيعمل على http://localhost:5173
```

## 2. بنية المشروع

### 2.1 Backend Structure

```
backend/
├── app/
│   ├── Console/           # Artisan Commands
│   ├── Exceptions/        # Exception Handlers
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── API/       # API Controllers
│   │   ├── Middleware/    # HTTP Middleware
│   │   └── Requests/      # Form Request Validation
│   ├── Models/            # Eloquent Models
│   ├── Observers/         # Model Observers
│   ├── Policies/          # Authorization Policies
│   ├── Providers/         # Service Providers
│   ├── Repositories/      # Repository Pattern
│   ├── Services/          # Business Logic Layer
│   └── Traits/            # Reusable Traits
├── bootstrap/
├── config/                # Configuration Files
├── database/
│   ├── factories/         # Model Factories
│   ├── migrations/        # Database Migrations
│   └── seeders/           # Database Seeders
├── public/                # Public Assets
├── resources/
│   ├── lang/              # Translations
│   └── views/             # Blade Templates
├── routes/
│   ├── api.php            # API Routes
│   └── web.php            # Web Routes
├── storage/
│   ├── app/               # Application Storage
│   ├── framework/         # Framework Files
│   └── logs/              # Log Files
├── tests/
│   ├── Feature/           # Feature Tests
│   └── Unit/              # Unit Tests
├── .env.example           # Environment Example
├── artisan                # Artisan CLI
├── composer.json          # PHP Dependencies
└── phpunit.xml            # PHPUnit Configuration
```

### 2.2 Frontend Structure

```
frontend/
├── public/                # Static Assets
│   ├── index.html
│   └── favicon.ico
├── src/
│   ├── assets/            # Images, Fonts, Styles
│   │   ├── images/
│   │   ├── fonts/
│   │   └── styles/
│   │       ├── main.css
│   │       └── rtl.css
│   ├── components/        # Vue Components
│   │   ├── common/        # Shared Components
│   │   │   ├── DataTable.vue
│   │   │   ├── Modal.vue
│   │   │   ├── FormInput.vue
│   │   │   └── Pagination.vue
│   │   ├── crm/           # CRM Module Components
│   │   ├── production/    # Production Components
│   │   ├── accounting/    # Accounting Components
│   │   └── inventory/     # Inventory Components
│   ├── views/             # Page Views
│   │   ├── Dashboard.vue
│   │   ├── auth/
│   │   │   └── Login.vue
│   │   ├── crm/
│   │   │   ├── Customers.vue
│   │   │   └── Quotations.vue
│   │   ├── production/
│   │   │   └── WorkOrders.vue
│   │   ├── accounting/
│   │   │   └── Invoices.vue
│   │   └── inventory/
│   │       └── Items.vue
│   ├── layouts/           # Layout Components
│   │   ├── MainLayout.vue
│   │   ├── AuthLayout.vue
│   │   └── components/
│   │       ├── Navbar.vue
│   │       ├── Sidebar.vue
│   │       └── Footer.vue
│   ├── router/            # Vue Router
│   │   └── index.js
│   ├── store/             # Pinia Store
│   │   ├── index.js
│   │   └── modules/
│   │       ├── auth.js
│   │       ├── customers.js
│   │       └── ...
│   ├── services/          # API Services
│   │   ├── api.js         # Axios Instance
│   │   ├── auth.service.js
│   │   ├── customer.service.js
│   │   └── ...
│   ├── composables/       # Vue Composables
│   │   ├── useAuth.js
│   │   ├── usePermissions.js
│   │   └── useNotification.js
│   ├── utils/             # Utility Functions
│   │   ├── helpers.js
│   │   ├── validators.js
│   │   └── formatters.js
│   ├── locales/           # i18n Translations
│   │   ├── ar.json
│   │   └── en.json
│   ├── App.vue            # Root Component
│   └── main.js            # Entry Point
├── .env.example           # Environment Example
├── package.json           # Node Dependencies
├── vite.config.js         # Vite Configuration
└── index.html             # HTML Entry Point
```

## 3. معايير الكود

### 3.1 PHP Coding Standards (PSR)

نتبع معايير PSR-12:

```php
<?php

namespace App\Services;

use App\Models\Customer;
use App\Repositories\CustomerRepository;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CustomerService
{
    /**
     * Customer repository instance
     *
     * @var CustomerRepository
     */
    protected $customerRepository;

    /**
     * Create a new service instance
     *
     * @param CustomerRepository $customerRepository
     */
    public function __construct(CustomerRepository $customerRepository)
    {
        $this->customerRepository = $customerRepository;
    }

    /**
     * Get all customers with filters
     *
     * @param array $filters
     * @return \Illuminate\Pagination\LengthAwarePaginator
     */
    public function getAllCustomers(array $filters = [])
    {
        return $this->customerRepository->getAll($filters);
    }

    /**
     * Create a new customer
     *
     * @param array $data
     * @return Customer
     * @throws \Exception
     */
    public function createCustomer(array $data): Customer
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
            Log::error('Error creating customer: ' . $e->getMessage());
            throw $e;
        }
    }
}
```

### 3.2 JavaScript/Vue Coding Standards

```javascript
// services/customer.service.js

import api from './api'

/**
 * Customer Service
 * Handles all customer-related API calls
 */
export const customerService = {
  /**
   * Get all customers
   * @param {Object} params - Query parameters
   * @returns {Promise<Object>}
   */
  async getAllCustomers(params = {}) {
    try {
      const response = await api.get('/crm/customers', { params })
      return response.data
    } catch (error) {
      console.error('Error fetching customers:', error)
      throw error
    }
  },

  /**
   * Get customer by ID
   * @param {number} id - Customer ID
   * @returns {Promise<Object>}
   */
  async getCustomerById(id) {
    try {
      const response = await api.get(`/crm/customers/${id}`)
      return response.data
    } catch (error) {
      console.error(`Error fetching customer ${id}:`, error)
      throw error
    }
  },

  /**
   * Create new customer
   * @param {Object} data - Customer data
   * @returns {Promise<Object>}
   */
  async createCustomer(data) {
    try {
      const response = await api.post('/crm/customers', data)
      return response.data
    } catch (error) {
      console.error('Error creating customer:', error)
      throw error
    }
  },

  /**
   * Update customer
   * @param {number} id - Customer ID
   * @param {Object} data - Updated data
   * @returns {Promise<Object>}
   */
  async updateCustomer(id, data) {
    try {
      const response = await api.put(`/crm/customers/${id}`, data)
      return response.data
    } catch (error) {
      console.error(`Error updating customer ${id}:`, error)
      throw error
    }
  },

  /**
   * Delete customer
   * @param {number} id - Customer ID
   * @returns {Promise<Object>}
   */
  async deleteCustomer(id) {
    try {
      const response = await api.delete(`/crm/customers/${id}`)
      return response.data
    } catch (error) {
      console.error(`Error deleting customer ${id}:`, error)
      throw error
    }
  }
}
```

### 3.3 Vue Component Structure

```vue
<template>
  <div class="customer-list">
    <!-- Header -->
    <div class="page-header">
      <h1>{{ $t('customers.title') }}</h1>
      <button 
        v-if="can('customers.create')"
        class="btn btn-primary"
        @click="openCreateModal"
      >
        <i class="bi bi-plus"></i>
        {{ $t('customers.add_new') }}
      </button>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <input
        v-model="filters.search"
        type="text"
        class="form-control"
        :placeholder="$t('common.search')"
        @input="debouncedSearch"
      />
    </div>

    <!-- Data Table -->
    <DataTable
      :columns="columns"
      :data="customers"
      :loading="loading"
      @edit="editCustomer"
      @delete="deleteCustomer"
    />

    <!-- Pagination -->
    <Pagination
      :current-page="currentPage"
      :total-pages="totalPages"
      @page-changed="handlePageChange"
    />

    <!-- Create/Edit Modal -->
    <CustomerModal
      v-if="showModal"
      :customer="selectedCustomer"
      @close="closeModal"
      @saved="handleCustomerSaved"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useCustomerStore } from '@/store/modules/customers'
import { usePermissions } from '@/composables/usePermissions'
import { debounce } from '@/utils/helpers'
import DataTable from '@/components/common/DataTable.vue'
import Pagination from '@/components/common/Pagination.vue'
import CustomerModal from './CustomerModal.vue'

// Stores
const customerStore = useCustomerStore()

// Permissions
const { can } = usePermissions()

// State
const loading = ref(false)
const showModal = ref(false)
const selectedCustomer = ref(null)
const filters = ref({
  search: '',
  page: 1,
  per_page: 25
})

// Computed
const customers = computed(() => customerStore.customers)
const currentPage = computed(() => customerStore.pagination.current_page)
const totalPages = computed(() => customerStore.pagination.total_pages)

const columns = computed(() => [
  { key: 'id', label: '#' },
  { key: 'name', label: 'الاسم' },
  { key: 'company_name', label: 'الشركة' },
  { key: 'phone', label: 'الهاتف' },
  { key: 'email', label: 'البريد الإلكتروني' },
  { key: 'actions', label: 'الإجراءات' }
])

// Methods
const fetchCustomers = async () => {
  loading.value = true
  try {
    await customerStore.fetchCustomers(filters.value)
  } catch (error) {
    console.error('Error fetching customers:', error)
  } finally {
    loading.value = false
  }
}

const debouncedSearch = debounce(() => {
  filters.value.page = 1
  fetchCustomers()
}, 500)

const handlePageChange = (page) => {
  filters.value.page = page
  fetchCustomers()
}

const openCreateModal = () => {
  selectedCustomer.value = null
  showModal.value = true
}

const editCustomer = (customer) => {
  selectedCustomer.value = customer
  showModal.value = true
}

const deleteCustomer = async (customer) => {
  if (!confirm('هل أنت متأكد من حذف هذا العميل؟')) return
  
  try {
    await customerStore.deleteCustomer(customer.id)
    await fetchCustomers()
  } catch (error) {
    console.error('Error deleting customer:', error)
  }
}

const closeModal = () => {
  showModal.value = false
  selectedCustomer.value = null
}

const handleCustomerSaved = async () => {
  closeModal()
  await fetchCustomers()
}

// Lifecycle
onMounted(() => {
  fetchCustomers()
})
</script>

<style scoped lang="scss">
.customer-list {
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;

    h1 {
      font-size: 1.75rem;
      font-weight: 600;
      margin: 0;
    }
  }

  .filters-section {
    margin-bottom: 1.5rem;
  }
}
</style>
```

## 4. إضافة ميزة جديدة

### 4.1 Backend (Laravel)

#### خطوة 1: إنشاء Migration

```bash
php artisan make:migration create_products_table
```

```php
// database/migrations/xxxx_create_products_table.php

public function up()
{
    Schema::create('products', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->text('description')->nullable();
        $table->decimal('price', 10, 2);
        $table->boolean('is_active')->default(true);
        $table->timestamps();
    });
}
```

```bash
php artisan migrate
```

#### خطوة 2: إنشاء Model

```bash
php artisan make:model Product
```

```php
// app/Models/Product.php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'name',
        'description',
        'price',
        'is_active'
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'is_active' => 'boolean'
    ];
}
```

#### خطوة 3: إنشاء Request Validation

```bash
php artisan make:request ProductRequest
```

```php
// app/Http/Requests/ProductRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        $productId = $this->route('product');
        
        return [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'is_active' => 'boolean'
        ];
    }

    public function messages()
    {
        return [
            'name.required' => 'اسم المنتج مطلوب',
            'price.required' => 'السعر مطلوب',
            'price.numeric' => 'السعر يجب أن يكون رقم',
        ];
    }
}
```

#### خطوة 4: إنشاء Repository

```bash
mkdir -p app/Repositories
```

```php
// app/Repositories/ProductRepository.php

namespace App\Repositories;

use App\Models\Product;

class ProductRepository
{
    protected $model;

    public function __construct(Product $model)
    {
        $this->model = $model;
    }

    public function getAll(array $filters = [])
    {
        $query = $this->model->query();

        if (isset($filters['search'])) {
            $query->where('name', 'like', '%' . $filters['search'] . '%');
        }

        if (isset($filters['is_active'])) {
            $query->where('is_active', $filters['is_active']);
        }

        return $query->paginate($filters['per_page'] ?? 25);
    }

    public function findOrFail($id)
    {
        return $this->model->findOrFail($id);
    }

    public function create(array $data)
    {
        return $this->model->create($data);
    }

    public function update($id, array $data)
    {
        $product = $this->findOrFail($id);
        $product->update($data);
        return $product;
    }

    public function delete($id)
    {
        $product = $this->findOrFail($id);
        return $product->delete();
    }
}
```

#### خطوة 5: إنشاء Service

```php
// app/Services/ProductService.php

namespace App\Services;

use App\Repositories\ProductRepository;
use Illuminate\Support\Facades\DB;

class ProductService
{
    protected $productRepository;

    public function __construct(ProductRepository $productRepository)
    {
        $this->productRepository = $productRepository;
    }

    public function getAllProducts(array $filters = [])
    {
        return $this->productRepository->getAll($filters);
    }

    public function getProductById($id)
    {
        return $this->productRepository->findOrFail($id);
    }

    public function createProduct(array $data)
    {
        DB::beginTransaction();
        try {
            $product = $this->productRepository->create($data);
            
            activity()
                ->performedOn($product)
                ->causedBy(auth()->user())
                ->log('تم إضافة منتج جديد');

            DB::commit();
            return $product;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function updateProduct($id, array $data)
    {
        DB::beginTransaction();
        try {
            $product = $this->productRepository->update($id, $data);
            
            activity()
                ->performedOn($product)
                ->causedBy(auth()->user())
                ->log('تم تحديث المنتج');

            DB::commit();
            return $product;
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function deleteProduct($id)
    {
        DB::beginTransaction();
        try {
            $product = $this->productRepository->findOrFail($id);
            $this->productRepository->delete($id);
            
            activity()
                ->performedOn($product)
                ->causedBy(auth()->user())
                ->log('تم حذف المنتج');

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
}
```

#### خطوة 6: إنشاء Controller

```bash
php artisan make:controller API/ProductController --api
```

```php
// app/Http/Controllers/API/ProductController.php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProductRequest;
use App\Services\ProductService;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    protected $productService;

    public function __construct(ProductService $productService)
    {
        $this->productService = $productService;
    }

    public function index(Request $request)
    {
        $products = $this->productService->getAllProducts(
            $request->all()
        );

        return response()->json([
            'success' => true,
            'data' => $products
        ]);
    }

    public function show($id)
    {
        $product = $this->productService->getProductById($id);

        return response()->json([
            'success' => true,
            'data' => $product
        ]);
    }

    public function store(ProductRequest $request)
    {
        $product = $this->productService->createProduct(
            $request->validated()
        );

        return response()->json([
            'success' => true,
            'message' => 'تم إضافة المنتج بنجاح',
            'data' => $product
        ], 201);
    }

    public function update(ProductRequest $request, $id)
    {
        $product = $this->productService->updateProduct(
            $id,
            $request->validated()
        );

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث المنتج بنجاح',
            'data' => $product
        ]);
    }

    public function destroy($id)
    {
        $this->productService->deleteProduct($id);

        return response()->json([
            'success' => true,
            'message' => 'تم حذف المنتج بنجاح'
        ]);
    }
}
```

#### خطوة 7: إضافة Routes

```php
// routes/api.php

Route::middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('products', API\ProductController::class);
});
```

### 4.2 Frontend (Vue.js)

#### خطوة 1: إنشاء Service

```javascript
// src/services/product.service.js

import api from './api'

export const productService = {
  async getAllProducts(params = {}) {
    const response = await api.get('/products', { params })
    return response.data
  },

  async getProductById(id) {
    const response = await api.get(`/products/${id}`)
    return response.data
  },

  async createProduct(data) {
    const response = await api.post('/products', data)
    return response.data
  },

  async updateProduct(id, data) {
    const response = await api.put(`/products/${id}`, data)
    return response.data
  },

  async deleteProduct(id) {
    const response = await api.delete(`/products/${id}`)
    return response.data
  }
}
```

#### خطوة 2: إنشاء Store Module

```javascript
// src/store/modules/products.js

import { defineStore } from 'pinia'
import { productService } from '@/services/product.service'

export const useProductStore = defineStore('products', {
  state: () => ({
    products: [],
    currentProduct: null,
    pagination: {
      current_page: 1,
      total_pages: 1,
      per_page: 25,
      total: 0
    },
    loading: false,
    error: null
  }),

  actions: {
    async fetchProducts(params = {}) {
      this.loading = true
      this.error = null
      
      try {
        const response = await productService.getAllProducts(params)
        this.products = response.data
        this.pagination = response.meta || response.pagination
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchProduct(id) {
      this.loading = true
      this.error = null
      
      try {
        const response = await productService.getProductById(id)
        this.currentProduct = response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async createProduct(data) {
      this.loading = true
      this.error = null
      
      try {
        const response = await productService.createProduct(data)
        this.products.unshift(response.data)
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateProduct(id, data) {
      this.loading = true
      this.error = null
      
      try {
        const response = await productService.updateProduct(id, data)
        const index = this.products.findIndex(p => p.id === id)
        if (index !== -1) {
          this.products[index] = response.data
        }
        return response.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteProduct(id) {
      this.loading = true
      this.error = null
      
      try {
        await productService.deleteProduct(id)
        this.products = this.products.filter(p => p.id !== id)
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})
```

#### خطوة 3: إنشاء Component

```vue
<!-- src/views/products/Products.vue -->

<template>
  <div class="products-page">
    <div class="page-header">
      <h1>المنتجات</h1>
      <button class="btn btn-primary" @click="openCreateModal">
        <i class="bi bi-plus"></i>
        إضافة منتج
      </button>
    </div>

    <div class="products-list">
      <div v-if="loading" class="loading">
        جاري التحميل...
      </div>

      <div v-else-if="error" class="error">
        {{ error }}
      </div>

      <div v-else>
        <table class="table">
          <thead>
            <tr>
              <th>#</th>
              <th>الاسم</th>
              <th>السعر</th>
              <th>الحالة</th>
              <th>الإجراءات</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="product in products" :key="product.id">
              <td>{{ product.id }}</td>
              <td>{{ product.name }}</td>
              <td>{{ formatCurrency(product.price) }}</td>
              <td>
                <span :class="['badge', product.is_active ? 'bg-success' : 'bg-secondary']">
                  {{ product.is_active ? 'نشط' : 'غير نشط' }}
                </span>
              </td>
              <td>
                <button class="btn btn-sm btn-info" @click="editProduct(product)">
                  <i class="bi bi-pencil"></i>
                </button>
                <button class="btn btn-sm btn-danger" @click="deleteProduct(product)">
                  <i class="bi bi-trash"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal -->
    <ProductModal
      v-if="showModal"
      :product="selectedProduct"
      @close="closeModal"
      @saved="handleSaved"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useProductStore } from '@/store/modules/products'
import { formatCurrency } from '@/utils/formatters'
import ProductModal from './ProductModal.vue'

const productStore = useProductStore()

const showModal = ref(false)
const selectedProduct = ref(null)

const products = computed(() => productStore.products)
const loading = computed(() => productStore.loading)
const error = computed(() => productStore.error)

const openCreateModal = () => {
  selectedProduct.value = null
  showModal.value = true
}

const editProduct = (product) => {
  selectedProduct.value = product
  showModal.value = true
}

const deleteProduct = async (product) => {
  if (!confirm('هل أنت متأكد من حذف هذا المنتج؟')) return
  
  try {
    await productStore.deleteProduct(product.id)
  } catch (error) {
    alert('حدث خطأ أثناء الحذف')
  }
}

const closeModal = () => {
  showModal.value = false
  selectedProduct.value = null
}

const handleSaved = () => {
  closeModal()
  productStore.fetchProducts()
}

onMounted(() => {
  productStore.fetchProducts()
})
</script>

<style scoped lang="scss">
.products-page {
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
  }
}
</style>
```

#### خطوة 4: إضافة Route

```javascript
// src/router/index.js

{
  path: '/products',
  name: 'Products',
  component: () => import('@/views/products/Products.vue'),
  meta: { 
    requiresAuth: true,
    permission: 'products.view'
  }
}
```

## 5. الاختبارات

### 5.1 Unit Tests (PHPUnit)

```php
// tests/Unit/ProductTest.php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    public function test_product_can_be_created()
    {
        $product = Product::factory()->create([
            'name' => 'Test Product',
            'price' => 99.99
        ]);

        $this->assertDatabaseHas('products', [
            'name' => 'Test Product',
            'price' => 99.99
        ]);
    }

    public function test_product_price_is_cast_to_decimal()
    {
        $product = Product::factory()->create(['price' => 100]);
        
        $this->assertIsFloat($product->price);
        $this->assertEquals(100.00, $product->price);
    }
}
```

### 5.2 Feature Tests

```php
// tests/Feature/ProductAPITest.php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ProductAPITest extends TestCase
{
    use RefreshDatabase;

    protected $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }

    public function test_authenticated_user_can_list_products()
    {
        Product::factory()->count(5)->create();

        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/products');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['id', 'name', 'price']
                ]
            ]);
    }

    public function test_authenticated_user_can_create_product()
    {
        $data = [
            'name' => 'New Product',
            'description' => 'Test description',
            'price' => 150.00,
            'is_active' => true
        ];

        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/products', $data);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'تم إضافة المنتج بنجاح'
            ]);

        $this->assertDatabaseHas('products', [
            'name' => 'New Product',
            'price' => 150.00
        ]);
    }

    public function test_unauthenticated_user_cannot_access_products()
    {
        $response = $this->getJson('/api/products');
        $response->assertStatus(401);
    }
}
```

### 5.3 تشغيل الاختبارات

```bash
# تشغيل جميع الاختبارات
php artisan test

# تشغيل اختبارات محددة
php artisan test --filter ProductTest

# تشغيل مع تقرير التغطية
php artisan test --coverage
```

## 6. نشر التطبيق

### 6.1 إعداد الإنتاج

```bash
# Backend
cd backend
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Frontend
cd frontend
npm run build
```

### 6.2 Deployment Checklist

- [ ] تحديث ملف `.env` بإعدادات الإنتاج
- [ ] تعيين `APP_ENV=production`
- [ ] تعيين `APP_DEBUG=false`
- [ ] إنشاء قاعدة بيانات الإنتاج
- [ ] تشغيل migrations
- [ ] إعداد SSL Certificate
- [ ] إعداد CORS
- [ ] إعداد خادم الويب (Nginx/Apache)
- [ ] إعداد Supervisor للـ queues
- [ ] إعداد Cron jobs
- [ ] اختبار النظام في بيئة الإنتاج

## 7. الصيانة

### 7.1 Logging

```php
// استخدام Laravel Logging
use Illuminate\Support\Facades\Log;

Log::info('User logged in', ['user_id' => $user->id]);
Log::error('Payment failed', ['order_id' => $order->id, 'error' => $e->getMessage()]);
```

### 7.2 Monitoring

- استخدام Laravel Telescope للتطوير
- استخدام Laravel Horizon لمراقبة Queues
- استخدام خدمات مثل Sentry لمراقبة الأخطاء في الإنتاج

### 7.3 Backup

```bash
# إنشاء backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p new_graphic_erp > backup_$DATE.sql
tar -czf backup_$DATE.tar.gz backup_$DATE.sql storage/
```

## 8. موارد إضافية

### 8.1 Documentation

- [Laravel Documentation](https://laravel.com/docs)
- [Vue.js Documentation](https://vuejs.org/guide)
- [Pinia Documentation](https://pinia.vuejs.org)
- [Bootstrap Documentation](https://getbootstrap.com/docs)

### 8.2 Tools

- **IDE**: VS Code, PHPStorm
- **API Testing**: Postman, Insomnia
- **Database Management**: PHPMyAdmin, TablePlus
- **Version Control**: Git, GitHub

</div>
