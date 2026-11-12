# KaryaSetara — Platform Micro-Job Inklusif & Smart Matching Berbasis Escrow

Proyek Ujian Tengah Semester (UTS) — Pemrograman Mobile (Semester 5)  
Program Studi Pendidikan Teknik Informatika / Ilmu Komputer

---

## Identitas Pengembang
- **Nama Mahasiswa:** I Kadek Santa Buana Gotama
- **NIM:** 2415051019
- **Mata Kuliah:** Pemrograman Mobile
- **Dosen Pengampu:** Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom
- **Teaching Assistant:** Made Yuda Sadewa, S.Pd.
- **Repository GitHub:** [https://github.com/SantaGotama/karyasetara](https://github.com/SantaGotama/karyasetara)

---

## Deskripsi Aplikasi & Unique Selling Point (USP)
**KaryaSetara** adalah aplikasi mobile berbasis Flutter yang dirancang dengan prinsip inklusivitas penuh (*accessibility-first*). Aplikasi ini mempertemukan pekerja mandiri—khususnya penyandang disabilitas—dengan pemberi kerja (*Employer*) melalui 3 pilar utama:
1. **Smart Matching Algorithm:** Rekomendasi pekerjaan berbasis bobot multi-faktor (50% kecocokan skill, 30% kedekatan radius lokasi, dan 20% akomodasi aksesibilitas teks mandiri).
2. **Escrow Payment Guard:** Sistem transparansi dan jaminan upah aman di mana dana employer dikunci di sistem sebelum tugas dimulai dan otomatis dicairkan setelah tugas selesai diverifikasi.
3. **WCAG AAA Compliance:** Aksesibilitas tingkat tinggi dengan Mode Kontras Tinggi rasio 7:1, pembaca layar (*Semantics screen reader* untuk TalkBack), dan dynamic text scaler global tanpa layout overflow.

---

## Struktur Arsitektur (7-Layer Clean Architecture)
Aplikasi menerapkan pemisahan tanggung jawab (*Separation of Concerns*) dengan alur data satu arah:
$$\text{UI Layer (Screens \& Widgets)} \longrightarrow \text{State Layer (Providers)} \longrightarrow \text{Repository Layer} \longrightarrow \text{Service Layer} \longrightarrow \text{Cloud DB \& REST API}$$

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart          # Konfigurasi endpoint REST API
│   │   ├── app_colors.dart             # Palet warna standard & High Contrast
│   │   ├── app_constants.dart          # Breakpoint responsif & konstanta app
│   │   └── supabase_constants.dart     # Kredensial URL, key & tabel Supabase
│   └── theme/
│       └── app_theme.dart              # ThemeData standar M3 & High Contrast WCAG AAA
├── models/
│   ├── job_model.dart                  # Model lowongan dengan serialisasi JSON & copyWith
│   ├── worker_model.dart               # Model profil pekerja & saldo
│   └── smart_match_model.dart          # Model algoritma evaluasi kecocokan AI
├── services/
│   ├── api_service.dart                # HTTP Client GET dengan exception handling
│   └── supabase_service.dart           # Database Service CRUD & resilient offline cache
├── repositories/
│   └── job_repository.dart             # Mediasi data REST API & Supabase Database
├── providers/
│   ├── job_provider.dart               # State lowongan, CRUD, search, filter, sorting
│   ├── user_provider.dart              # State profil worker, skill CRUD, saldo escrow
│   └── accessibility_provider.dart     # State tema kontras tinggi & TextScaler global
├── screens/
│   ├── dashboard_screen.dart           # Screen 1: Beranda & ringkasan aktivitas
│   ├── job_catalog_screen.dart         # Screen 2: Katalog lowongan, search, filter, dismissible
│   ├── job_detail_screen.dart          # Screen 3: Detail tugas, smart match, aksi terima & hapus
│   ├── create_job_screen.dart          # Screen 4: Formulir tambah lowongan (Database CREATE)
│   ├── edit_job_screen.dart            # Screen 5: Formulir edit lowongan (Database UPDATE)
│   ├── active_job_screen.dart          # Screen 6: Lembar kerja aktif & timeline alur escrow
│   └── profile_screen.dart             # Screen 7: Manajemen skill, radius & aksesibilitas
├── widgets/
│   ├── responsive_scaffold.dart        # Adaptif NavigationBar (mobile) vs NavigationRail (desktop)
│   ├── job_card.dart                   # Komponen kartu lowongan modular
│   ├── smart_match_badge.dart          # Komponen badge & kartu breakdown match score
│   ├── escrow_status_card.dart         # Komponen transparansi proteksi dana escrow
│   ├── stat_metric_card.dart           # Komponen metrik numerik berikon
│   ├── loading_state_widget.dart       # State loading dengan spinner interaktif
│   ├── error_state_widget.dart         # State error dengan tombol retry
│   └── empty_state_widget.dart         # State empty dengan tombol reset filter
└── main.dart                           # Root widget dengan MultiProvider & MediaQuery scaler
```

---

## Matriks Pemenuhan Spesifikasi Rubrik UTS

| No | Komponen Rubrik | Spesifikasi Wajib | Implementasi pada KaryaSetara | Status |
|:---:|:---|:---|:---|:---:|
| 1 | **Screen Fungsional** | Minimal 6 screen | **7 Screen Lengkap**: Dashboard, Catalog, Detail, Create, Edit, Active/Escrow, dan Profile | ✅ Terpenuhi |
| 2 | **Navigasi Utama** | NavigationBar / NavigationRail | **ResponsiveScaffold**: NavigationBar pada layar `< 600dp` dan NavigationRail pada layar `≥ 600dp` | ✅ Terpenuhi |
| 3 | **Passing Data** | List $\rightarrow$ Detail $\rightarrow$ Edit | Navigasi Catalog $\rightarrow$ Detail membawa `JobModel`, Detail $\rightarrow$ Edit meneruskan model untuk pre-populasi form | ✅ Terpenuhi |
| 4 | **Responsive Layout** | Minimal 2 kondisi layout | Compact (`< 600dp`) ListView 1-kolom vs Expanded (`≥ 600dp`) GridView 2-kolom & split screen | ✅ Terpenuhi |
| 5 | **Reusable Widgets** | Minimal 3 custom widgets | **7 Custom Widgets**: `JobCard`, `SmartMatchBadge`, `EscrowStatusCard`, `StatMetricCard`, `LoadingStateWidget`, `ErrorStateWidget`, `EmptyStateWidget` | ✅ Terpenuhi |
| 6 | **State Management** | Provider + ChangeNotifier | `JobProvider`, `UserProvider`, `AccessibilityProvider` terdaftar di `MultiProvider` root | ✅ Terpenuhi |
| 7 | **REST API (GET)** | Minimal 1 GET API + parsing JSON | Integrasi `jsonplaceholder.typicode.com/posts` via `ApiService` & `JobRepository` | ✅ Terpenuhi |
| 8 | **State Handling** | Loading, Error, Empty states | Widget terpisah: `LoadingStateWidget`, `ErrorStateWidget` (dengan tombol Retry), dan `EmptyStateWidget` | ✅ Terpenuhi |
| 9 | **Backend Database** | Minimal 1 cloud DB (Supabase) | Supabase PostgreSQL client dengan tabel `jobs` (13 field data) + offline fallback | ✅ Terpenuhi |
| 10 | **Database CRUD** | Create, Read, Update, Delete | **Create** (CreateJobScreen), **Read** (JobCatalogScreen), **Update** (EditJobScreen), **Delete** (Confirmation Dialog) | ✅ Terpenuhi |
| 11 | **Delete Confirmation** | Wajib konfirmasi dialog | `AlertDialog` konfirmasi sebelum delete permanen pada `JobDetailScreen` & `Dismissible` swipe | ✅ Terpenuhi |
| 12 | **User Interactions** | Minimal 4 bentuk interaksi | 1) Search & ChoiceChips, 2) Swipe-to-delete Dismissible, 3) Modal BottomSheet Filter, 4) Bookmark SnackBar dengan UNDO action | ✅ Terpenuhi |
| 13 | **Form & Validasi** | Minimal 1 form validasi | Form CreateJobScreen & EditJobScreen dengan validasi judul, upah minimal Rp 10.000, kategori & deskripsi | ✅ Terpenuhi |
| 14 | **Aksesibilitas** | Kepatuhan tema kontras & font | Mode Kontras Tinggi WCAG AAA (rasio 7:1), `Semantics` screen reader, dan global TextScaler 1.2x | ✅ Terpenuhi |
| 15 | **Git Progression** | Minimal 16 commits bermakna | **16 Commits Bertahap** mencakup seluruh lifecycle pengembangan | ✅ Terpenuhi |

---

## Riwayat 16 Milestone Git Commit

| Commit | Hash / Milestone | Deskripsi Perubahan |
|:---:|:---|:---|
| **1** | `Project Initialization` | Inisialisasi proyek Flutter, konfigurasi `.gitignore`, dan README awal. |
| **2** | `Architecture & Constants` | Setup struktur 7 folder, dependensi package (`provider`, `supabase_flutter`, `http`, `intl`), palet warna, dan tema. |
| **3** | `Responsive Scaffold & Nav` | Pembuatan widget adaptif `ResponsiveScaffold` (`NavigationBar` vs `NavigationRail`) dan 6 kerangka screen. |
| **4** | `Data Models & Serialization` | Pembuatan model Dart `JobModel`, `WorkerModel`, dan `SmartMatchModel` dengan deserialisasi JSON dan `copyWith`. |
| **5** | `State Management (Provider)` | Implementasi `JobProvider`, `UserProvider`, dan `AccessibilityProvider` terhubung ke `MultiProvider` di `main.dart`. |
| **6** | `Modular Reusable Widgets` | Pembuatan custom widgets `JobCard`, `SmartMatchBadge`, `EscrowStatusCard`, dan `StatMetricCard`. |
| **7** | `REST API Service & Repo` | Integrasi `ApiService` dan `JobRepository` untuk pengambilan data eksternal via HTTP GET. |
| **8** | `UI State Handling` | Penanganan antarmuka reaktif untuk `LoadingStateWidget`, `ErrorStateWidget` (Retry), dan `EmptyStateWidget`. |
| **9** | `Supabase Client Setup` | Konfigurasi `SupabaseConstants`, inisialisasi client database asinkron, dan arsitektur resilient offline cache. |
| **10** | `Database CREATE Operation` | Implementasi form posting lowongan baru ke tabel cloud database Supabase dengan validasi input. |
| **11** | `Database READ Operation` | Pengambilan records lowongan dari Supabase, kategorisasi sumber data (`Supabase Cloud` vs `REST API`), dan filter chips. |
| **12** | `Database UPDATE & EditScreen` | Pembuatan `EditJobScreen` untuk memperbarui data lowongan secara asinkron dengan passing data antar-screen. |
| **13** | `Database DELETE Operation` | Implementasi operasi hapus record dari database dengan perlindungan `AlertDialog` konfirmasi dan gesture swipe. |
| **14** | `User Interaction & Feedback` | Penambahan modal bottom sheet filter & pengurutan, `SnackBarAction` ("URUNGKAN"), dan edukasi Escrow sheet. |
| **15** | `Accessibility & WCAG AAA` | Pemolesan tema kontras tinggi rasio 7:1, pembungkus `Semantics` untuk pembaca layar, dan dynamic font scaling 1.2x. |
| **16** | `Final Polish & Docs` | Dokumentasi komprehensif README.md, final static analysis (0 issue), dan verifikasi kesiapan rilis. |

---

## Cara Menjalankan Aplikasi

### 1. Prasyarat Sistem
- Flutter SDK `^3.13` atau lebih tinggi
- Dart SDK `^3.1` atau lebih tinggi
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Emulator Android (API 34+) atau perangkat fisik dengan USB Debugging aktif

### 2. Langkah Instalasi & Menjalankan Proyek
```bash
# 1. Masuk ke direktori proyek
cd PROJECT

# 2. Unduh seluruh dependensi package
flutter pub get

# 3. Jalankan static analysis untuk verifikasi kode bersih
flutter analyze

# 4. Jalankan aplikasi pada emulator atau desktop
flutter run -d emulator-5554
# atau untuk platform Windows desktop:
flutter run -d windows
```

### 3. Konfigurasi Database Supabase (Opsional)
Untuk menghubungkan aplikasi ke project Supabase pribadi Anda:
1. Buka [supabase.com](https://supabase.com) dan buat project baru.
2. Jalankan query SQL pembuatan tabel yang terdapat pada dokumentasi di menu **SQL Editor**.
3. Salin URL dan Anon Key ke [`lib/core/constants/supabase_constants.dart`](lib/core/constants/supabase_constants.dart).
*(Aplikasi otomatis berjalan dalam mode mock cache aman jika kredensial tidak diatur).*

---

## Lisensi & Kepatuhan Akademik
Proyek ini dikembangkan secara mandiri oleh **I Kadek Santa Buana Gotama (NIM: 2415051019)** sebagai pemenuhan Ujian Tengah Semester mata kuliah Pemrograman Mobile semester ganjil tahun akademik berjalan, berlandaskan prinsip kejujuran akademik.
