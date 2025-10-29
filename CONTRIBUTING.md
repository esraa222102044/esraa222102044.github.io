# دليل المساهمة في New Graphic ERP

<div dir="rtl">

نرحب بمساهماتكم في تطوير نظام New Graphic ERP! هذا الدليل سيساعدك على فهم كيفية المساهمة في المشروع.

## المحتويات

1. [مدونة السلوك](#مدونة-السلوك)
2. [كيف يمكنني المساهمة](#كيف-يمكنني-المساهمة)
3. [عملية التطوير](#عملية-التطوير)
4. [معايير الكود](#معايير-الكود)
5. [الإبلاغ عن الأخطاء](#الإبلاغ-عن-الأخطاء)
6. [طلب ميزات جديدة](#طلب-ميزات-جديدة)

---

## مدونة السلوك

### تعهدنا

نحن ملتزمون بجعل المشاركة في مشروعنا تجربة خالية من المضايقات للجميع، بغض النظر عن:
- العمر
- حجم الجسم
- الإعاقة
- العرق
- الجنس
- مستوى الخبرة
- الجنسية
- المظهر الشخصي
- العرق أو الأصل العرقي
- الدين
- الهوية والتعبير الجنسي
- التوجه الجنسي

### معاييرنا

أمثلة على السلوك الذي يساهم في خلق بيئة إيجابية:
- استخدام لغة ترحيبية وشاملة
- احترام وجهات النظر والتجارب المختلفة
- قبول النقد البناء بلطف
- التركيز على ما هو أفضل للمجتمع
- إظهار التعاطف تجاه أعضاء المجتمع الآخرين

أمثلة على السلوك غير المقبول:
- استخدام لغة أو صور ذات طابع جنسي
- التعليقات المهينة / المسيئة، أو الهجمات الشخصية / السياسية
- المضايقة العامة أو الخاصة
- نشر معلومات خاصة للآخرين بدون إذن صريح
- سلوك آخر يمكن اعتباره غير مناسب في بيئة مهنية

---

## كيف يمكنني المساهمة

### 1. إبلاغ عن خطأ (Bug Report)

إذا وجدت خطأ برمجي:

1. تأكد أن الخطأ لم يُبلغ عنه من قبل في [Issues](https://github.com/esraa222102044/esraa222102044.github.io/issues)
2. إذا لم تجده، أنشئ Issue جديد
3. استخدم عنواناً واضحاً ووصفياً
4. اشرح كيفية إعادة إنتاج الخطأ
5. قدم أمثلة محددة
6. صِف السلوك الفعلي والسلوك المتوقع
7. أرفق لقطات شاشة إن أمكن
8. حدد البيئة (نظام التشغيل، إصدار PHP، إصدار المتصفح)

**مثال على Bug Report:**

```markdown
## وصف المشكلة
عند محاولة إضافة عميل جديد، تظهر رسالة خطأ 500

## خطوات إعادة الإنتاج
1. الذهاب إلى "العملاء" > "جديد"
2. ملء جميع الحقول المطلوبة
3. الضغط على "حفظ"
4. يظهر خطأ 500

## السلوك المتوقع
يجب حفظ العميل وإظهار رسالة نجاح

## السلوك الفعلي
يظهر خطأ 500 Internal Server Error

## البيئة
- نظام التشغيل: Ubuntu 20.04
- PHP: 8.1
- Laravel: 10.x
- المتصفح: Chrome 120

## لقطات شاشة
[أرفق صورة]
```

### 2. اقتراح ميزة جديدة

لاقتراح ميزة جديدة:

1. تحقق من Issues الموجودة للتأكد أن الميزة لم تُقترح من قبل
2. أنشئ Issue جديد مع وسم "enhancement"
3. اشرح بالتفصيل ما هي الميزة المقترحة
4. اذكر الفائدة من هذه الميزة
5. قدم أمثلة على كيفية استخدامها

**مثال على Feature Request:**

```markdown
## وصف الميزة
إضافة إمكانية تصدير التقارير بصيغة Excel

## الفائدة
سيسمح للمستخدمين بمعالجة البيانات في Excel

## مثال على الاستخدام
عند عرض أي تقرير، يوجد زر "تصدير إلى Excel" يقوم بتحميل ملف .xlsx

## البدائل المتاحة حالياً
يمكن التصدير لـ PDF فقط
```

### 3. المساهمة بالكود

#### خطوات المساهمة

1. **Fork المشروع**
   ```bash
   # اذهب إلى GitHub واضغط Fork
   ```

2. **Clone مشروعك**
   ```bash
   git clone https://github.com/YOUR-USERNAME/esraa222102044.github.io.git
   cd esraa222102044.github.io
   ```

3. **إنشاء فرع جديد**
   ```bash
   git checkout -b feature/your-feature-name
   # أو
   git checkout -b fix/your-bug-fix
   ```

4. **قم بالتعديلات**
   - اتبع [معايير الكود](#معايير-الكود)
   - أضف اختبارات للميزات الجديدة
   - تأكد من أن جميع الاختبارات تعمل

5. **Commit التغييرات**
   ```bash
   git add .
   git commit -m "Add: وصف واضح للتغييرات"
   ```

   استخدم prefixes في رسائل الـ commit:
   - `Add:` لإضافة ميزة جديدة
   - `Fix:` لإصلاح خطأ
   - `Update:` لتحديث موجود
   - `Remove:` لحذف
   - `Refactor:` لإعادة هيكلة الكود
   - `Docs:` لتحديث الوثائق
   - `Test:` لإضافة اختبارات

6. **Push للفرع**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **إنشاء Pull Request**
   - اذهب إلى مشروعك على GitHub
   - اضغط "New Pull Request"
   - املأ قالب الـ PR

---

## عملية التطوير

### إعداد بيئة التطوير

1. **متطلبات النظام**
   - PHP 8.0+
   - Composer
   - MySQL 8.0+
   - Node.js 16+
   - npm

2. **التثبيت**
   ```bash
   # Clone المشروع
   git clone https://github.com/YOUR-USERNAME/esraa222102044.github.io.git
   cd esraa222102044.github.io

   # إعداد Backend
   cd backend
   composer install
   cp .env.example .env
   php artisan key:generate
   php artisan migrate
   php artisan db:seed

   # إعداد Frontend
   cd ../frontend
   npm install
   npm run dev
   ```

### تشغيل الاختبارات

```bash
# Backend Tests
cd backend
php artisan test

# أو اختبارات محددة
php artisan test --filter CustomerTest

# Frontend Tests
cd frontend
npm run test
```

### معايير الجودة

قبل إرسال Pull Request، تأكد من:

- [ ] الكود يتبع معايير PSR-12 (PHP) أو ESLint (JavaScript)
- [ ] جميع الاختبارات تعمل بنجاح
- [ ] لا توجد تحذيرات أو أخطاء في console
- [ ] الكود موثق بشكل جيد
- [ ] الوثائق محدثة (إن لزم الأمر)

---

## معايير الكود

### PHP / Laravel

#### 1. PSR-12 Coding Standard

```php
<?php

namespace App\Services;

use App\Models\Customer;
use Illuminate\Support\Facades\DB;

class CustomerService
{
    /**
     * Get all customers
     *
     * @param array $filters
     * @return \Illuminate\Pagination\LengthAwarePaginator
     */
    public function getAllCustomers(array $filters = [])
    {
        // Implementation
    }
}
```

#### 2. التسمية

- **Classes**: PascalCase - `CustomerService`, `InvoiceController`
- **Methods**: camelCase - `getAllCustomers`, `createInvoice`
- **Variables**: camelCase - `$customerData`, `$totalAmount`
- **Constants**: UPPER_SNAKE_CASE - `MAX_RETRY_ATTEMPTS`

#### 3. التوثيق

```php
/**
 * Create a new customer
 *
 * @param array $data Customer data
 * @return Customer
 * @throws \Exception If customer creation fails
 */
public function createCustomer(array $data): Customer
{
    // Implementation
}
```

### JavaScript / Vue.js

#### 1. ESLint Configuration

نتبع معايير Vue.js الرسمية.

#### 2. التسمية

- **Components**: PascalCase - `CustomerList.vue`, `InvoiceForm.vue`
- **Functions**: camelCase - `fetchCustomers`, `handleSubmit`
- **Variables**: camelCase - `customerData`, `isLoading`
- **Constants**: UPPER_SNAKE_CASE - `API_BASE_URL`

#### 3. Vue Component Structure

```vue
<template>
  <!-- Template -->
</template>

<script setup>
// Imports
import { ref, computed, onMounted } from 'vue'

// Composables
const { can } = usePermissions()

// State
const loading = ref(false)

// Computed
const filteredData = computed(() => {
  // Implementation
})

// Methods
const fetchData = async () => {
  // Implementation
}

// Lifecycle
onMounted(() => {
  fetchData()
})
</script>

<style scoped lang="scss">
// Styles
</style>
```

### Database

#### 1. تسمية الجداول

- جمع، حروف صغيرة، snake_case: `customers`, `work_orders`

#### 2. تسمية الأعمدة

- حروف صغيرة، snake_case: `customer_name`, `created_at`

#### 3. Migrations

```php
public function up()
{
    Schema::create('customers', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->string('email')->nullable();
        $table->timestamps();
        
        $table->index('email');
    });
}
```

---

## الإبلاغ عن الأخطاء

### الأخطاء الأمنية

**⚠️ لا تنشر الأخطاء الأمنية علناً!**

بدلاً من ذلك، راسلنا مباشرة على:
📧 security@newgraphic.me

سنرد عليك في أقرب وقت ممكن.

### الأخطاء العادية

استخدم [GitHub Issues](https://github.com/esraa222102044/esraa222102044.github.io/issues) للإبلاغ عن الأخطاء.

---

## طلب ميزات جديدة

نرحب بالأفكار الجديدة! لاقتراح ميزة:

1. افتح [Issue جديد](https://github.com/esraa222102044/esraa222102044.github.io/issues/new)
2. استخدم وسم `enhancement`
3. اشرح الميزة بالتفصيل
4. اذكر حالات الاستخدام
5. أرفق mockups أو sketches إن أمكن

---

## قالب Pull Request

عند إنشاء Pull Request، استخدم القالب التالي:

```markdown
## الوصف
وصف مختصر للتغييرات

## نوع التغيير
- [ ] إصلاح خطأ (Bug fix)
- [ ] ميزة جديدة (New feature)
- [ ] تغيير كبير (Breaking change)
- [ ] تحديث الوثائق (Documentation update)

## كيف تم الاختبار؟
صِف الاختبارات التي أجريتها

## Checklist
- [ ] الكود يتبع معايير المشروع
- [ ] قمت بمراجعة الكود الخاص بي
- [ ] قمت بالتعليق على الكود، خاصة في المناطق المعقدة
- [ ] قمت بإجراء التغييرات المقابلة على الوثائق
- [ ] تغييراتي لا تولد تحذيرات جديدة
- [ ] أضفت اختبارات تثبت أن الإصلاح فعال أو أن الميزة تعمل
- [ ] الاختبارات الجديدة والموجودة تمر محلياً بتغييراتي

## لقطات الشاشة (إن وجدت)
أضف لقطات شاشة لشرح التغييرات
```

---

## الأسئلة الشائعة

### هل أحتاج لخبرة كبيرة للمساهمة؟

لا! نرحب بجميع مستويات الخبرة. يمكنك البدء بـ:
- تحسين الوثائق
- إصلاح أخطاء بسيطة
- ترجمة
- الإبلاغ عن الأخطاء

### كم يستغرق مراجعة Pull Request؟

نحاول مراجعة PRs في غضون 2-3 أيام عمل.

### ماذا لو رُفض PR الخاص بي؟

لا تقلق! سنشرح السبب ونقترح تحسينات. يمكنك إجراء التعديلات وإعادة الطلب.

### كيف أحصل على المساعدة؟

- راجع [الوثائق](https://esraa222102044.github.io/)
- افتح [Issue](https://github.com/esraa222102044/esraa222102044.github.io/issues) مع وسم `question`
- راسلنا على support@newgraphic.me

---

## الترخيص

بالمساهمة في هذا المشروع، فإنك توافق على أن مساهماتك ستكون مرخصة بموجب [MIT License](LICENSE).

---

## الاعتراف

نشكر جميع [المساهمين](https://github.com/esraa222102044/esraa222102044.github.io/graphs/contributors) الذين ساعدوا في جعل هذا المشروع أفضل!

---

**شكراً لمساهمتك في New Graphic ERP! 🎉**

</div>
