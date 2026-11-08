# UTS Pemrograman Mobile — KaryaSetara

Platform Kerja Inklusif & Portofolio Keterampilan (Smart Matching & Secure Escrow)

## Identitas Pengembang
- **Nama:** I Kadek Santa Buana Gotama
- **NIM:** 2415051019
- **Mata Kuliah:** Pemrograman Mobile (Semester 5)
- **Dosen Pengampu:** Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom
- **Teaching Assistant:** Made Yuda Sadewa, S.Pd.

## Deskripsi Singkat Project
KaryaSetara adalah aplikasi mobile berbasis Flutter yang dirancang dengan prinsip inklusivitas penuh dan aksesibilitas utama (*accessibility-first*). Aplikasi ini menghubungkan pencari kerja mandiri (*Worker*) dengan pemberi kerja (*Employer*) yang didukung oleh sistem pencocokan cerdas (*Smart Matching*) dan perlindungan status pembayaran (*Secure Payment Escrow*).

## Arsitektur & Teknologi
- **Framework:** Flutter (Dart 3)
- **State Management:** Provider + ChangeNotifier
- **Arsitektur:** Model-View-ViewModel / Layered Architecture (`models/`, `services/`, `repositories/`, `providers/`, `screens/`, `widgets/`)
- **Backend & Database:** Supabase (PostgreSQL)
- **REST API:** Public REST API Integration (Operasi GET)
- **Responsive Layout:** `LayoutBuilder` & `MediaQuery` (Compact < 600dp vs Expanded >= 600dp)
