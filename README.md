
# 📘 HƯỚNG DẪN LÀM VIỆC NHÓM TRÊN GITHUB & ANDROID STUDIO  
### Dự án Flutter – Cấu trúc 3 nhánh `main` – `develop` – `feature`

---

## 👥 Thành viên nhóm
| Vai trò | Tên | Nhiệm vụ |
|----------|------|-----------|
| 👨‍💼 Trưởng nhóm | Người A | Quản lý repo, merge code, code 1 module (ví dụ: trang admin/dashboard) |
| 👩‍💻 Thành viên 1 | Người B | Trang chủ |
| 👨‍💻 Thành viên 2 | Người C | Chi tiết sản phẩm |
| 👩‍💻 Thành viên 3 | Người D | Giỏ hàng |
| 👨‍💻 Thành viên 4 | Người E | Đăng nhập / Đăng ký |
| 👩‍💻 Thành viên 5 | Người F | Hồ sơ người dùng |
| 👨‍💻 Thành viên 6 | Người G | Thanh toán / Đơn hàng |

---

## 🧭 I. Cấu trúc nhánh Git

| Nhánh | Mục đích | Ai được push trực tiếp |
|-------|-----------|--------------------------|
| **main** | Code ổn định (đã kiểm tra, sẵn sàng release) | ✅ Chỉ trưởng nhóm |
| **develop** | Code đang phát triển, tích hợp các nhánh feature | ✅ Chỉ trưởng nhóm |
| **feature/...** | Code của từng thành viên (bao gồm trưởng nhóm) | ✅ Thành viên phụ trách |

---

## ⚙️ II. Khởi tạo dự án (Trưởng nhóm)

### 1️⃣ Tạo dự án Flutter
```bash
flutter create ecmobile
cd ecmobile
```

### 2️⃣ Khởi tạo Git cục bộ và commit lần đầu
```bash
git init
git add .
git commit -m "Initial commit - Flutter project with checkout"
```

### 3️⃣ Tạo repo trên GitHub
Repo: [ecmobile](https://github.com/Thangnguyen252/ecmobile)

### 4️⃣ Kết nối và đẩy code lên GitHub
```bash
git remote add origin https://github.com/Thangnguyen252/ecmobile.git
git branch -M main
git push -u origin main
```

### 5️⃣ Tạo nhánh `develop`
```bash
git checkout -b develop
git push -u origin develop
```

---

## 💻 III. Các thao tác chung cho tất cả thành viên (coi từ đây)

### 1️⃣ Clone dự án về máy
```bash
git clone https://github.com/Thangnguyen252/ecmobile.git
cd ecmobile
```

Hoặc trong Android Studio: (nên dùng cách này) 
> File → New → Project from Version Control → Git → Paste URL

---

### 2️⃣ Chuyển sang nhánh `develop`
```bash
git checkout develop
git pull origin develop
```

---

### 3️⃣ Tạo nhánh `feature` cho mỗi người

| Thành viên | Nhánh feature |
|-------------|----------------|
| Trưởng nhóm | `feature/admin_dashboard` |
| B | `feature/home` |
| C | `feature/product_detail` |
| D | `feature/cart` |
| E | `feature/auth` |
| F | `feature/profile` |
| G | `feature/order` |

Câu lệnh:
```bash
git checkout -b feature/admin_dashboard
git push -u origin feature/admin_dashboard
```
(Mỗi người thay tên nhánh theo module mình phụ trách)

---

### 4️⃣ Làm việc, commit và push code của mình
```bash
git add .
git commit -m "Hoàn thiện giao diện trang Admin"
git push
```

---

### 5️⃣ Cập nhật code mới nhất từ nhóm (mỗi khi bắt đầu làm)
```bash
git checkout develop
git pull origin develop
git checkout feature/admin_dashboard
git merge develop
```

→ Đảm bảo code của bạn luôn cập nhật với những thay đổi mới nhất của nhóm.

---

## 🧠 IV. Quy trình khi hoàn thành tính năng

### 1️⃣ Thành viên (kể cả trưởng nhóm) tạo **Pull Request (PR)**  
Trên GitHub:
- Vào repo → **Pull Requests → New Pull Request**
- Chọn:
  - Base branch: `develop`
  - Compare: `feature/...` của bạn
- Viết mô tả, gắn nhãn người review (thường là trưởng nhóm)
- Nhấn **Create Pull Request**

---

### 2️⃣ Trưởng nhóm review và merge vào `develop`
- Kiểm tra code, giao diện, logic.  
- Nếu ổn → **Merge pull request**  
- Nếu lỗi → comment để thành viên fix rồi gửi lại PR.

---

### 3️⃣ Khi toàn bộ tính năng hoàn thiện
Trưởng nhóm hợp nhất từ `develop` → `main`:
```bash
git checkout main
git pull origin main
git merge develop
git push origin main
```





## 🧩 VI. Tóm tắt quy trình thao tác Git

| Vai trò | Công việc | Lệnh chính |
|----------|------------|-------------|
| **Trưởng nhóm** | Tạo repo, tạo nhánh chính | `git init`, `git push origin main/develop` |
| **Tất cả thành viên** | Clone repo | `git clone` |
| **Tất cả thành viên** | Tạo nhánh riêng | `git checkout -b feature/...` |
| **Thành viên** | Commit code | `git add .`, `git commit -m "..."`, `git push` |
| **Thành viên** | Tạo Pull Request → develop | Thực hiện trên GitHub |
| **Trưởng nhóm** | Review & merge | Merge trên GitHub hoặc CLI |
| **Trưởng nhóm** | Merge final vào main | `git checkout main`, `git merge develop` |
| **Trưởng nhóm** | Tag version & release | `git tag -a v1.0`, `git push origin v1.0` |

---

## ⚠️ VII. Lưu ý quan trọng

1. ❌ Không push trực tiếp vào `main` hoặc `develop` (chỉ trưởng nhóm được phép).  
2. ✅ Mỗi commit phải rõ ràng, mô tả đúng nội dung thay đổi.  
3. 🔄 Trước khi push code, luôn `pull origin develop` để tránh xung đột.  
4. ⚙️ Nếu có conflict khi merge → dùng Android Studio hoặc `git mergetool` để xử lý.  
5. 🧹 Luôn test tính năng trước khi gửi Pull Request.  

---



## ✅ Kết quả mong đợi

- `main` → Bản hoàn chỉnh, chạy ổn định.  
- `develop` → Bản đang phát triển, luôn được cập nhật.  
- `feature/*` → Nơi từng thành viên làm việc độc lập, không chồng code.  

---

📄 **Tài liệu này nên được lưu trong repo với tên:**
```
HDSD_LamViecNhom_GitHub.md
```
