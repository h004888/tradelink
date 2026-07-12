# Home API Specification — TradeLink

> **Version:** 1.0.0  
> **Base URL:** `{{BASE_URL}}` (cấu hình trong `AppConfig`)  
> **Content-Type:** `application/json`  
> **Ngày cập nhật:** 2026-07-12

---

## Mục lục

1. [Tổng quan](#tổng-quan)
2. [GET /home](#1-get-home)
3. [GET /transactions](#2-get-transactions)
4. [GET /categories](#3-get-categories)
5. [Error Response chung](#error-response-chung)
6. [Luồng dữ liệu Response → Widget](#luồng-dữ-liệu-response--widget)

---

## Tổng quan

Trang Home (`HomeView`) gọi **3 API endpoint** thông qua 2 ViewModel:

| # | Method | Endpoint | Gọi từ | Auth | Mục đích |
|---|---|---|---|---|---|
| 1 | `GET` | `/home` | `HomeViewModel` | Không | HomeData (featured, newest, popular, categories, topSellers) |
| 2 | `GET` | `/transactions` | `HomeViewModel` | Có | Danh sách giao dịch → ActiveTransactionCard |
| 3 | `GET` | `/categories` | `HomeCategoryViewModel` | Không | Danh sách danh mục → CategoryHorizontalList |

```
HomeView
  ├── HomeViewModel.load()
  │   ├── GET /home          ──► ProductSection ×3 (Nổi bật, Mới đăng, Phổ biến)
  │   └── GET /transactions  ──► ActiveTransactionCard
  │
  └── CategoryHorizontalList
      └── HomeCategoryViewModel.load()
          └── GET /categories ──► CategoryHorizontalList
```

---

## 1. GET /home

### Request

```
GET {{BASE_URL}}/home
```

| Header | Value | Bắt buộc |
|--------|-------|----------|
| `Content-Type` | `application/json` | Có |

**Query Parameters:** Không

**Request Body:** Không

**Authentication:** Không bắt buộc

---

### Response

#### Success — 200 OK

```json
{
  "data": {
    "featured": [
      {
        "_id": "60f1a2b3c4d5e6f7a8b9c0d1",
        "title": "iPhone 15 Pro Max 256GB — Chính hãng VN/A, fullbox",
        "description": "Máy mới 99%, mua tháng 1/2026, còn bảo hành Apple đến 1/2027...",
        "price": 28990000,
        "imageUrls": [
          "https://cdn.example.com/images/iphone15_1.jpg",
          "https://cdn.example.com/images/iphone15_2.jpg",
          "https://cdn.example.com/images/iphone15_3.jpg"
        ],
        "category": "Điện thoại",
        "categoryId": "cat-phone",
        "condition": "likeNew",
        "type": "sale",
        "status": "active",
        "sellerId": "60f1a2b3c4d5e6f7a8b9c0e1",
        "sellerName": "Minh Trần",
        "views": 1523,
        "interests": 89,
        "saves": 45,
        "createdAt": "2026-07-07T08:30:00.000Z",
        "boostExpiry": "2026-07-14T08:30:00.000Z"
      }
    ],
    "newest": [ /* Listing[] — cùng cấu trúc featured */ ],
    "popular": [ /* Listing[] — cùng cấu trúc featured */ ],
    "categories": [
      "Điện thoại",
      "Laptop",
      "Xe cộ",
      "Thời trang",
      "Điện tử",
      "Phụ kiện",
      "Đồ gia dụng",
      "Thể thao",
      "Sách",
      "Khác"
    ],
    "topSellers": [
      {
        "_id": "60f1a2b3c4d5e6f7a8b9c0e1",
        "sellerName": "Hoàng Mobile",
        "totalListings": 145,
        "totalViews": 98200
      }
    ]
  }
}
```

#### Field Reference — `Listing`

| JSON Field | Type | Required | Dart Model | Ghi chú |
|---|---|---|---|---|
| `_id` | `string` | Có | `Listing.id` | Unique identifier |
| `title` | `string` | Có | `Listing.title` | Hiển thị max 2 dòng trên card |
| `description` | `string` | Không | `Listing.description` | Mô tả chi tiết sản phẩm |
| `price` | `number\|null` | Không | `Listing.price` | Đơn vị: VNĐ. `null` nếu trade-only |
| `imageUrls` | `string[]` | Không | `Listing.imageUrls` | URL ảnh, phần tử đầu dùng cho thumbnail |
| `category` | `string` | Có | `Listing.category` | Tên danh mục (VD: "Điện thoại") |
| `categoryId` | `string\|null` | Không | `Listing.categoryId` | ID danh mục |
| `condition` | `enum` | Không | `Listing.condition` | `"new"` / `"likeNew"` / `"used"` |
| `type` | `enum` | Không | `Listing.type` | `"sale"` / `"trade"` / `"both"` |
| `status` | `enum` | Không | `Listing.status` | `"active"` / `"sold"` / `"hidden"` / `"draft"` |
| `sellerId` | `string` | Có | `Listing.sellerId` | ID người bán |
| `sellerName` | `string` | Có | `Listing.sellerName` | Tên hiển thị người bán |
| `views` | `number` | Không | `Listing.views` | Số lượt xem |
| `interests` | `number` | Không | `Listing.interests` | Số lượt quan tâm |
| `saves` | `number` | Không | `Listing.saves` | Số lượt lưu |
| `createdAt` | `string` (ISO 8601) | Có | `Listing.createdAt` | Thời điểm đăng |
| `boostExpiry` | `string\|null` (ISO 8601) | Không | `Listing.boostExpiry` | Thời điểm hết hạn boost. `null` = không boost |

#### Field Reference — `TopSellerInfo`

| JSON Field | Type | Required | Dart Model | Ghi chú |
|---|---|---|---|---|
| `_id` | `string` | Có | `TopSellerInfo.sellerId` | ID người bán |
| `sellerName` | `string` | Có | `TopSellerInfo.sellerName` | Tên hiển thị |
| `totalListings` | `number` | Không | `TopSellerInfo.totalListings` | Tổng số tin đăng |
| `totalViews` | `number` | Không | `TopSellerInfo.totalViews` | Tổng lượt xem |

#### Enum Value Reference

**`condition`**

| JSON Value | Dart Enum | Giao diện |
|---|---|---|
| `"new"` | `ItemCondition.new_` | Mới |
| `"likeNew"` | `ItemCondition.likeNew` | Như mới |
| `"used"` | `ItemCondition.used` | Đã qua sử dụng |

**`type`**

| JSON Value | Dart Enum | Giao diện (màu giá) |
|---|---|---|
| `"sale"` | `ListingType.sale` | Giá hiển thị bằng số, màu `#2563EB` (saleBlue) |
| `"trade"` | `ListingType.trade` | Hiển thị text "Trao đổi", màu `#14B8A6` (tradeTeal) |
| `"both"` | `ListingType.both` | Giá + "Trao đổi" |

**`status`**

| JSON Value | Dart Enum | Ghi chú |
|---|---|---|
| `"active"` | `ListingStatus.active` | Đang hiển thị |
| `"sold"` | `ListingStatus.sold` | Đã bán |
| `"hidden"` | `ListingStatus.hidden` | Bị ẩn |
| `"draft"` | `ListingStatus.draft` | Nháp |

---

### Mapping Response → Widget

```
GET /home Response
│
├── data.featured[N]   ──► ProductSection("Nổi bật")
│   └── Mỗi Listing ──► ProductCard (vertical)
│       ├── imageUrls[0]   → CachedNetworkImage (ảnh 1:1)
│       ├── title          → Text (max 2 dòng, f12w600)
│       ├── price+type     → Text (max 1 dòng, f15w700, saleBlue/tradeTeal)
│       └── boostExpiry    → (chưa hiển thị trực tiếp, chỉ dùng để sort)
│
├── data.newest[N]     ──► ProductSection("Mới đăng")
│   └── Cấu trúc giống featured, sắp xếp theo createdAt DESC
│
├── data.popular[N]    ──► ProductSection("Phổ biến")
│   └── Cấu trúc giống featured, sắp xếp theo saves+views DESC
│
├── data.categories[]  ──► HomeData.categories (List<String>)
│   └── Hiện tại chỉ lưu, CategoryHorizontalList dùng API riêng
│
└── data.topSellers[]  ──► HomeData.topSellers (List<TopSellerInfo>)
    └── Hiện chưa có widget riêng trên Home
```

#### Phân biệt 3 Section

| Section | Key Response | Cách sort phía server | Client nhận |
|---|---|---|---|
| **Nổi bật** | `data.featured` | Boosted + views DESC | Hiển thị nguyên thứ tự |
| **Mới đăng** | `data.newest` | createdAt DESC | Hiển thị nguyên thứ tự |
| **Phổ biến** | `data.popular` | saves + views DESC | Hiển thị nguyên thứ tự |

> **Lưu ý:** Mỗi section lấy tối đa **8 items** (client-side limit trong `ProductSection._buildSuccessState`).

---

## 2. GET /transactions

### Request

```
GET {{BASE_URL}}/transactions
```

| Header | Value | Bắt buộc |
|--------|-------|----------|
| `Content-Type` | `application/json` | Có |
| `Authorization` | `Bearer {{token}}` | Có |

**Query Parameters:**

| Param | Type | Required | Mô tả |
|-------|------|----------|-------|
| `role` | `string` | Không | Lọc theo vai trò: `"buyer"` / `"seller"`. Từ Home không truyền → lấy tất cả |

**Request Body:** Không

**Authentication:** Có (Bearer token). Nếu chưa login → không gọi API này.

---

### Response

#### Success — 200 OK

```json
{
  "data": [
    {
      "_id": "60f2b3c4d5e6f7a8b9c0d1e2",
      "type": "sale",
      "listingId": "60f1a2b3c4d5e6f7a8b9c0d1",
      "listingTitle": "iPhone 15 Pro Max 256GB — Chính hãng VN/A",
      "buyerId": "60f3c4d5e6f7a8b9c0d1e2f3",
      "buyerName": "Nguyễn Văn A",
      "sellerId": "60f1a2b3c4d5e6f7a8b9c0e1",
      "sellerName": "Minh Trần",
      "amount": 28990000,
      "escrowStep": "shipping",
      "partyASent": true,
      "partyAReceived": false,
      "partyBSent": false,
      "partyBReceived": false,
      "createdAt": "2026-07-10T14:00:00.000Z"
    }
  ]
}
```

#### Field Reference — `Transaction`

| JSON Field | Type | Required | Dart Model | Ghi chú |
|---|---|---|---|---|
| `_id` | `string` | Có | `Transaction.id` | Unique identifier |
| `type` | `enum` | Có | `Transaction.type` | `"sale"` / `"trade"` |
| `listingId` | `string` | Có | `Transaction.listingId` | ID sản phẩm |
| `listingTitle` | `string` | Có | `Transaction.listingTitle` | Tên sản phẩm (hiển thị trên card) |
| `buyerId` | `string` | Có | `Transaction.buyerId` | ID người mua |
| `buyerName` | `string` | Có | `Transaction.buyerName` | Tên người mua |
| `sellerId` | `string` | Có | `Transaction.sellerId` | ID người bán |
| `sellerName` | `string` | Có | `Transaction.sellerName` | Tên người bán |
| `amount` | `number\|null` | Không | `Transaction.amount` | Số tiền giao dịch (VNĐ) |
| `escrowStep` | `enum\|null` | Không | `Transaction.escrowStep` | Bước hiện tại trong escrow |
| `partyASent` | `boolean\|null` | Không | `Transaction.partyASent` | Trade: bên A đã gửi hàng |
| `partyAReceived` | `boolean\|null` | Không | `Transaction.partyAReceived` | Trade: bên A đã nhận hàng |
| `partyBSent` | `boolean\|null` | Không | `Transaction.partyBSent` | Trade: bên B đã gửi hàng |
| `partyBReceived` | `boolean\|null` | Không | `Transaction.partyBReceived` | Trade: bên B đã nhận hàng |
| `createdAt` | `string` (ISO 8601) | Có | `Transaction.createdAt` | Thời điểm tạo giao dịch |

#### Enum Value Reference — `escrowStep`

| JSON Value | Dart Enum | Label (VN) | Description |
|---|---|---|---|
| `"paymentPending"` | `EscrowStep.paymentPending` | TT (Chờ thanh toán) | Người mua đang tiến hành thanh toán vào hệ thống trung gian |
| `"paymentConfirmed"` | `EscrowStep.paymentConfirmed` | Giữ tiền (Đã thanh toán) | Tiền đã được giữ an toàn. Người bán vui lòng giao hàng |
| `"shipping"` | `EscrowStep.shipping` | Gửi hàng (Đang giao) | Người bán đã gửi hàng. Vui lòng chờ nhận hàng |
| `"delivered"` | `EscrowStep.delivered` | Nhận hàng (Đã nhận) | Bạn đã nhận được hàng? Xác nhận để giải ngân |
| `"reviewPeriod"` | `EscrowStep.reviewPeriod` | ĐG (Thời gian đánh giá) | Đang chờ đánh giá từ hai bên |
| `"released"` | `EscrowStep.released` | HT (Hoàn tất) | Giao dịch hoàn tất! Tiền đã được chuyển cho người bán |

---

### Mapping Response → Widget

```
GET /transactions Response
│
├── data[0..N]  ──► HomeViewModel.activeTransactions (List<Transaction>)
│
└── ActiveTransactionCard hiển thị:
    │
    ├── Lọc: tx đầu tiên có escrowStep != null && escrowStep != "released"
    │
    ├── Header Row:
    │   ├── Icon shield_rounded (#0F766E, bg 10%)
    │   ├── listingTitle (f15w600, max 1 dòng)
    │   ├── escrowStep label + description (f12, textSecondary)
    │   └── amount (formatVnd, f16w700, primary)
    │
    ├── _EscrowProgressBar:
    │   ├── 6 dots nối bằng đường kẻ
    │   ├── Dot completed:  trustTeal (#14B8A6)
    │   ├── Dot current:    primary  (#2563EB)
    │   ├── Dot pending:    neutral  (#CBD5E1)
    │   └── Label dưới: TT · Giữ tiền · Gửi hàng · Nhận hàng · ĐG · HT
    │
    └── CTA (chỉ hiện khi escrowStep == "delivered"):
        └── Button "Xác nhận đã nhận hàng" (full width, primary)
```

#### Card States

| Điều kiện | Giao diện |
|---|---|
| `isLoading == true` | Skeleton shimmer (hình chữ nhật placeholder) |
| `transaction == null` hoặc `escrowStep == "released"` | `SizedBox.shrink()` — card ẩn hoàn toàn |
| `escrowStep == "delivered"` | Card đầy đủ + CTA button "Xác nhận đã nhận hàng" |
| Các escrowStep khác | Card đầy đủ (không CTA) |

---

## 3. GET /categories

### Request

```
GET {{BASE_URL}}/categories
```

| Header | Value | Bắt buộc |
|--------|-------|----------|
| `Content-Type` | `application/json` | Có |

**Query Parameters:** Không

**Request Body:** Không

**Authentication:** Không bắt buộc

---

### Response

#### Success — 200 OK

```json
{
  "data": [
    {
      "_id": "cat-phone",
      "name": "Điện thoại",
      "slug": "dien-thoai",
      "icon": "phone_android",
      "order": 1
    },
    {
      "_id": "cat-laptop",
      "name": "Laptop",
      "slug": "laptop",
      "icon": "laptop",
      "order": 2
    },
    {
      "_id": "cat-vehicle",
      "name": "Xe cộ",
      "slug": "xe-co",
      "icon": "directions_car",
      "order": 3
    },
    {
      "_id": "cat-fashion",
      "name": "Thời trang",
      "slug": "thoi-trang",
      "icon": "checkroom",
      "order": 4
    },
    {
      "_id": "cat-electronics",
      "name": "Điện tử",
      "slug": "dien-tu",
      "icon": "headphones",
      "order": 5
    },
    {
      "_id": "cat-accessories",
      "name": "Phụ kiện",
      "slug": "phu-kien",
      "icon": "watch",
      "order": 6
    },
    {
      "_id": "cat-home",
      "name": "Đồ gia dụng",
      "slug": "do-gia-dung",
      "icon": "kitchen",
      "order": 7
    },
    {
      "_id": "cat-sports",
      "name": "Thể thao",
      "slug": "the-thao",
      "icon": "fitness_center",
      "order": 8
    },
    {
      "_id": "cat-books",
      "name": "Sách",
      "slug": "sach",
      "icon": "menu_book",
      "order": 9
    },
    {
      "_id": "cat-other",
      "name": "Khác",
      "slug": "khac",
      "icon": "grid_view_rounded",
      "order": 10
    }
  ]
}
```

#### Field Reference — `CategoryItem`

| JSON Field | Type | Required | Dart Model | Ghi chú |
|---|---|---|---|---|
| `_id` | `string` | Có | `CategoryItem.id` | Unique identifier. Fallback: dùng `id` nếu `_id` null |
| `name` | `string` | Có | `CategoryItem.name` | Tên hiển thị (max 2 dòng, f10w500) |
| `slug` | `string` | Không | `CategoryItem.slug` | URL-friendly slug |
| `icon` | `string` | Không | `CategoryItem.icon` | Tên icon, map sang Material Icon |
| `order` | `number` | Không | `CategoryItem.order` | Thứ tự sắp xếp |

#### Icon Mapping

| `icon` value | Material Icon | Fallback (từ `name`) |
|---|---|---|
| `"phone_android"` / `"phone_android_outlined"` | `Icons.phone_android_outlined` | "Điện thoại" |
| `"laptop"` / `"laptop_outlined"` | `Icons.laptop_outlined` | "Laptop" |
| `"directions_car"` / `"directions_car_outlined"` | `Icons.directions_car_outlined` | "Xe cộ" |
| `"checkroom"` / `"checkroom_outlined"` | `Icons.checkroom_outlined` | "Thời trang" |
| `"camera_alt"` / `"camera_alt_outlined"` | `Icons.camera_alt_outlined` | "Máy ảnh" |
| `"headphones"` / `"headphones_outlined"` | `Icons.headphones_outlined` | "Điện tử" |
| `"watch"` / `"watch_outlined"` | `Icons.watch_outlined` | "Phụ kiện" |
| `"kitchen"` / `"kitchen_outlined"` | `Icons.kitchen_outlined` | "Đồ gia dụng" |
| `"home"` / `"home_outlined"` | `Icons.home_outlined` | "Nhà cửa" |
| `"fitness_center"` / `"fitness_center_outlined"` | `Icons.fitness_center_outlined` | "Thể thao" |
| `"menu_book"` / `"menu_book_outlined"` | `Icons.menu_book_outlined` | "Sách" |
| `"grid_view_rounded"` | `Icons.grid_view_rounded` | "Khác" / default |

---

### Mapping Response → Widget

```
GET /categories Response
│
├── data[0..N]  ──► HomeCategoryViewModel.state (List<CategoryItem>)
│
└── CategoryHorizontalList:
    │
    └── Mỗi CategoryItem ──► _CategoryItemWidget:
        ├── Container (w=68px)
        │   ├── Icon tròn (w=h=44px, r=12, bg=surfaceContainerLow)
        │   │   └── icon → Material IconData (size=20, opacity=70%)
        │   └── Text name (max 2 dòng, f10w500, center)
        │
        └── Tap → navigate /home/category/{id}
```

#### States

| Điều kiện | Giao diện |
|---|---|
| `Loading` | 5 skeleton items (icon tròn + bar placeholder) |
| `Success` | Danh sách category items scroll ngang |
| `Error` / Empty | Fallback MockData.categories (10 danh mục) |

---

## Error Response chung

Tất cả API đều trả về error theo format thống nhất từ `ApiClient` và `Failure` model.

### Error Response Body

```json
{
  "message": "Mô tả lỗi",
  "code": "ERROR_CODE",
  "statusCode": 400
}
```

### Error Types

| HTTP Status | Dart Failure Type | Xử lý trên Home |
|---|---|---|
| `400` Bad Request | `ValidationFailure` | Hiển thị message, fallback MockData |
| `401` Unauthorized | `AuthFailure` | Token hết hạn → không gọi `/transactions` |
| `403` Forbidden | `AuthFailure` | Không gọi `/transactions` |
| `404` Not Found | `ServerFailure` | Hiển thị message, fallback MockData |
| `500` Internal Server | `ServerFailure` | Hiển thị message, fallback MockData |
| Không có mạng | `NetworkFailure` | Hiển thị message, fallback MockData |
| Parse error | `UnknownFailure` | Hiển thị message, fallback MockData |

### Cách xử lý fallback trên Home

```
┌────────────────────────────────────────────────────────┐
│               HOME DATA FLOW                           │
├────────────────────────────────────────────────────────┤
│                                                        │
│  GET /home  ──► Success? ──Yes──► Success(r.data)     │
│                    │                                   │
│                    No                                  │
│                    │                                   │
│                    ▼                                   │
│              Success(MockData.homeData)                │
│              (không hiển thị error)                    │
│                                                        │
│  GET /transactions ──► Success? ──Yes──► Success(r.data)│
│                          │                             │
│                          No                            │
│                          │                             │
│                          ▼                             │
│                  Success([MockData.activeTransaction]) │
│                                                        │
│  GET /categories ──► Success? ──Yes──► Success(list)  │
│                        │                               │
│                        No                              │
│                        │                               │
│                        ▼                               │
│               Success(MockData.categories)             │
│                                                        │
└────────────────────────────────────────────────────────┘
```

> **Quan trọng:** MockData được dùng làm **silent fallback** — người dùng không thấy error message, thay vào đó thấy dữ liệu mẫu. Khi API hoạt động bình thường, dữ liệu thật luôn được ưu tiên.

---

## Luồng dữ liệu Response → Widget

```
┌────────────────────────────────────────────────────────────────────┐
│                        RESPONSE → WIDGET                           │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  GET /home                                                         │
│  │                                                                 │
│  ├── data.featured[0..N]                                           │
│  │   └── Listing ──► ProductCard ──► ProductSection("Nổi bật")    │
│  │       ├── imageUrls[0]   → _ProductImage (CachedNetworkImage)   │
│  │       ├── title          → Text (SizedBox h=32, maxLines=2)     │
│  │       ├── price          → formatVnd(price) hoặc "Trao đổi"    │
│  │       └── type           → saleBlue / tradeTeal                 │
│  │                                                                 │
│  ├── data.newest[0..N]                                             │
│  │   └── Listing ──► ProductCard ──► ProductSection("Mới đăng")   │
│  │                                                                 │
│  ├── data.popular[0..N]                                            │
│  │   └── Listing ──► ProductCard ──► ProductSection("Phổ biến")   │
│  │                                                                 │
│  ├── data.categories[]   → HomeData.categories (String list)       │
│  └── data.topSellers[]   → HomeData.topSellers (TopSellerInfo list)│
│                                                                    │
│  ─────────────────────────────────────────────────────────────     │
│                                                                    │
│  GET /transactions                                                 │
│  │                                                                 │
│  └── data[0..N]                                                    │
│      └── Transaction ──► ActiveTransactionCard                     │
│          ├── listingTitle    → Text (f15w600)                      │
│          ├── amount          → formatVnd(amount) (f16w700)          │
│          ├── escrowStep      → _EscrowProgressBar (6 dots)         │
│          │   ├── 0: paymentPending                                  │
│          │   ├── 1: paymentConfirmed                                │
│          │   ├── 2: shipping                                        │
│          │   ├── 3: delivered                                       │
│          │   ├── 4: reviewPeriod                                    │
│          │   └── 5: released                                        │
│          └── escrowStep=="delivered" → CTA Button                   │
│                                                                    │
│  ─────────────────────────────────────────────────────────────     │
│                                                                    │
│  GET /categories                                                   │
│  │                                                                 │
│  └── data[0..N]                                                    │
│      └── CategoryItem ──► _CategoryItemWidget                      │
│          ├── icon → Material IconData (circle 44px)                │
│          └── name → Text (max 2 dòng, f10w500)                     │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## Tóm tắt

| # | Endpoint | Method | Auth | Dữ liệu trả về | Widget sử dụng |
|---|---|---|---|---|---|
| 1 | `/home` | `GET` | ✗ | `{data: {featured, newest, popular, categories, topSellers}}` | ProductSection ×3 |
| 2 | `/transactions` | `GET` | ✓ | `{data: [Transaction]}` | ActiveTransactionCard |
| 3 | `/categories` | `GET` | ✗ | `{data: [CategoryItem]}` | CategoryHorizontalList |

- **SafeTransactionBanner** — Static widget, không cần API
- **HomeSearchBar** — Static widget, tap → navigate `/search`, không cần API
- **Header** (logo + notification icon) — Static widget, không cần API
