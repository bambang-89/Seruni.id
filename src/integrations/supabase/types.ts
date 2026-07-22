export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      admin_profiles: {
        Row: {
          created_at: string
          id: string
          nama: string
          nik: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id: string
          nama: string
          nik: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          nama?: string
          nik?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "admin_profiles_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      aduan_warga: {
        Row: {
          created_at: string
          ditanggapi_oleh: string | null
          ditanggapi_pada: string | null
          id: string
          isi: string
          judul: string
          kategori: Database["public"]["Enums"]["aduan_kategori"]
          kontak: string
          lampiran_url: string | null
          lokasi: string | null
          nama_pelapor: string
          nomor_tiket: string
          status: Database["public"]["Enums"]["workflow_status"]
          tanggapan: string | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          ditanggapi_oleh?: string | null
          ditanggapi_pada?: string | null
          id?: string
          isi: string
          judul: string
          kategori?: Database["public"]["Enums"]["aduan_kategori"]
          kontak: string
          lampiran_url?: string | null
          lokasi?: string | null
          nama_pelapor: string
          nomor_tiket?: string
          status?: Database["public"]["Enums"]["workflow_status"]
          tanggapan?: string | null
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          ditanggapi_oleh?: string | null
          ditanggapi_pada?: string | null
          id?: string
          isi?: string
          judul?: string
          kategori?: Database["public"]["Enums"]["aduan_kategori"]
          kontak?: string
          lampiran_url?: string | null
          lokasi?: string | null
          nama_pelapor?: string
          nomor_tiket?: string
          status?: Database["public"]["Enums"]["workflow_status"]
          tanggapan?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "aduan_warga_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      agenda: {
        Row: {
          created_at: string
          deskripsi: string
          id: string
          jenis: string
          judul: string
          lokasi: string
          penyelenggara: string
          slug: string
          tanggal: string
          tenant_id: string
          updated_at: string
          waktu: string
        }
        Insert: {
          created_at?: string
          deskripsi?: string
          id?: string
          jenis?: string
          judul: string
          lokasi?: string
          penyelenggara?: string
          slug: string
          tanggal: string
          tenant_id: string
          updated_at?: string
          waktu?: string
        }
        Update: {
          created_at?: string
          deskripsi?: string
          id?: string
          jenis?: string
          judul?: string
          lokasi?: string
          penyelenggara?: string
          slug?: string
          tanggal?: string
          tenant_id?: string
          updated_at?: string
          waktu?: string
        }
        Relationships: [
          {
            foreignKeyName: "agenda_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      analisis_snapshot: {
        Row: {
          created_at: string
          id: string
          judul: string
          kategori: string
          nilai_json: Json
          published: boolean
          ringkasan: string | null
          tahun: number | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          judul: string
          kategori: string
          nilai_json?: Json
          published?: boolean
          ringkasan?: string | null
          tahun?: number | null
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          judul?: string
          kategori?: string
          nilai_json?: Json
          published?: boolean
          ringkasan?: string | null
          tahun?: number | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "analisis_snapshot_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      apbdes: {
        Row: {
          anggaran: number
          created_at: string
          id: string
          jenis: string
          kategori: string
          keterangan: string | null
          realista: number
          sub_kategori: string | null
          sumber_dana: string | null
          tahun: number
          tenant_id: string
          updated_at: string
          uraian: string
          urutan: number | null
        }
        Insert: {
          anggaran?: number
          created_at?: string
          id?: string
          jenis: string
          kategori: string
          keterangan?: string | null
          realista?: number
          sub_kategori?: string | null
          sumber_dana?: string | null
          tahun: number
          tenant_id: string
          updated_at?: string
          uraian: string
          urutan?: number | null
        }
        Update: {
          anggaran?: number
          created_at?: string
          id?: string
          jenis?: string
          kategori?: string
          keterangan?: string | null
          realista?: number
          sub_kategori?: string | null
          sumber_dana?: string | null
          tahun?: number
          tenant_id?: string
          updated_at?: string
          uraian?: string
          urutan?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "apbdes_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      bantuan_sosial: {
        Row: {
          aktif: boolean
          created_at: string
          deskripsi: string | null
          id: string
          kode: string
          kuota: number | null
          nama: string
          periode_mulai: string | null
          periode_selesai: string | null
          sumber: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          deskripsi?: string | null
          id?: string
          kode: string
          kuota?: number | null
          nama: string
          periode_mulai?: string | null
          periode_selesai?: string | null
          sumber: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          deskripsi?: string | null
          id?: string
          kode?: string
          kuota?: number | null
          nama?: string
          periode_mulai?: string | null
          periode_selesai?: string | null
          sumber?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bantuan_sosial_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      bencana_kejadian: {
        Row: {
          created_at: string
          deskripsi: string | null
          dusun: string | null
          id: string
          jenis: string
          kerugian_rp: number | null
          korban_jiwa: number
          korban_luka: number
          lokasi: string
          penanganan: string | null
          pengungsi: number
          severity: Database["public"]["Enums"]["bencana_severity"]
          status: Database["public"]["Enums"]["workflow_status"]
          tanggal: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          deskripsi?: string | null
          dusun?: string | null
          id?: string
          jenis: string
          kerugian_rp?: number | null
          korban_jiwa?: number
          korban_luka?: number
          lokasi: string
          penanganan?: string | null
          pengungsi?: number
          severity?: Database["public"]["Enums"]["bencana_severity"]
          status?: Database["public"]["Enums"]["workflow_status"]
          tanggal?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          deskripsi?: string | null
          dusun?: string | null
          id?: string
          jenis?: string
          kerugian_rp?: number | null
          korban_jiwa?: number
          korban_luka?: number
          lokasi?: string
          penanganan?: string | null
          pengungsi?: number
          severity?: Database["public"]["Enums"]["bencana_severity"]
          status?: Database["public"]["Enums"]["workflow_status"]
          tanggal?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bencana_kejadian_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      berita: {
        Row: {
          cover_url: string | null
          created_at: string
          id: string
          isi: Json
          judul: string
          kategori: string
          penulis: string
          published: boolean
          ringkasan: string
          slug: string
          tanggal: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          cover_url?: string | null
          created_at?: string
          id?: string
          isi?: Json
          judul: string
          kategori?: string
          penulis?: string
          published?: boolean
          ringkasan?: string
          slug: string
          tanggal?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          cover_url?: string | null
          created_at?: string
          id?: string
          isi?: Json
          judul?: string
          kategori?: string
          penulis?: string
          published?: boolean
          ringkasan?: string
          slug?: string
          tanggal?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "berita_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      bidang_tanah: {
        Row: {
          catatan: string | null
          created_at: string
          dusun: string | null
          id: string
          luas_m2: number
          nomor_persil: string
          nomor_sertifikat: string | null
          pemilik_nama: string
          pemilik_nik: string | null
          penggunaan: string | null
          status_hak: string | null
          tanggal_daftar: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          catatan?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          luas_m2: number
          nomor_persil: string
          nomor_sertifikat?: string | null
          pemilik_nama: string
          pemilik_nik?: string | null
          penggunaan?: string | null
          status_hak?: string | null
          tanggal_daftar?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          catatan?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          luas_m2?: number
          nomor_persil?: string
          nomor_sertifikat?: string | null
          pemilik_nama?: string
          pemilik_nik?: string | null
          penggunaan?: string | null
          status_hak?: string | null
          tanggal_daftar?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "bidang_tanah_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      buku_register: {
        Row: {
          catatan: string | null
          created_at: string
          id: string
          jenis_buku: string
          lampiran_url: string | null
          nomor: string | null
          pihak: string | null
          tanggal: string | null
          tenant_id: string
          updated_at: string
          uraian: string | null
        }
        Insert: {
          catatan?: string | null
          created_at?: string
          id?: string
          jenis_buku: string
          lampiran_url?: string | null
          nomor?: string | null
          pihak?: string | null
          tanggal?: string | null
          tenant_id: string
          updated_at?: string
          uraian?: string | null
        }
        Update: {
          catatan?: string | null
          created_at?: string
          id?: string
          jenis_buku?: string
          lampiran_url?: string | null
          nomor?: string | null
          pihak?: string | null
          tanggal?: string | null
          tenant_id?: string
          updated_at?: string
          uraian?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "buku_register_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      desa_pamong: {
        Row: {
          created_at: string
          foto_url: string | null
          id: string
          jabatan: string
          nama: string
          periode: string | null
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          created_at?: string
          foto_url?: string | null
          id?: string
          jabatan: string
          nama: string
          periode?: string | null
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          created_at?: string
          foto_url?: string | null
          id?: string
          jabatan?: string
          nama?: string
          periode?: string | null
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "desa_pamong_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      dpt_pemilih: {
        Row: {
          created_at: string
          dusun: string | null
          id: string
          jenis_kelamin: string | null
          nama: string
          nik: string
          pemilu_kode: string
          rt: string | null
          rw: string | null
          status: string
          tanggal_lahir: string | null
          tenant_id: string
          tempat_lahir: string | null
          tps: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          dusun?: string | null
          id?: string
          jenis_kelamin?: string | null
          nama: string
          nik: string
          pemilu_kode: string
          rt?: string | null
          rw?: string | null
          status?: string
          tanggal_lahir?: string | null
          tenant_id: string
          tempat_lahir?: string | null
          tps?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          dusun?: string | null
          id?: string
          jenis_kelamin?: string | null
          nama?: string
          nik?: string
          pemilu_kode?: string
          rt?: string | null
          rw?: string | null
          status?: string
          tanggal_lahir?: string | null
          tenant_id?: string
          tempat_lahir?: string | null
          tps?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "dpt_pemilih_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      footer_column: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          judul: string
          links: Json
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          judul: string
          links?: Json
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          judul?: string
          links?: Json
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "footer_column_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      galeri: {
        Row: {
          album: string
          created_at: string
          emoji: string
          foto_url: string | null
          id: string
          judul: string
          tanggal: string
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          album?: string
          created_at?: string
          emoji?: string
          foto_url?: string | null
          id?: string
          judul: string
          tanggal?: string
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          album?: string
          created_at?: string
          emoji?: string
          foto_url?: string | null
          id?: string
          judul?: string
          tanggal?: string
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "galeri_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      idm_indikator: {
        Row: {
          created_at: string
          dimensi: string
          id: string
          indikator: string
          keterangan: string | null
          nilai: number | null
          published: boolean
          skor: number | null
          sumber: string | null
          tahun: number
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          dimensi: string
          id?: string
          indikator: string
          keterangan?: string | null
          nilai?: number | null
          published?: boolean
          skor?: number | null
          sumber?: string | null
          tahun: number
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          dimensi?: string
          id?: string
          indikator?: string
          keterangan?: string | null
          nilai?: number | null
          published?: boolean
          skor?: number | null
          sumber?: string | null
          tahun?: number
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "idm_indikator_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      infrastruktur: {
        Row: {
          created_at: string
          dusun: string | null
          id: string
          jenis: string
          keterangan: string | null
          kondisi: string
          nama: string
          sumber_dana: string | null
          tahun_bangun: number | null
          tahun_perbaikan: number | null
          tenant_id: string
          updated_at: string
          volume: string | null
        }
        Insert: {
          created_at?: string
          dusun?: string | null
          id?: string
          jenis: string
          keterangan?: string | null
          kondisi?: string
          nama: string
          sumber_dana?: string | null
          tahun_bangun?: number | null
          tahun_perbaikan?: number | null
          tenant_id: string
          updated_at?: string
          volume?: string | null
        }
        Update: {
          created_at?: string
          dusun?: string | null
          id?: string
          jenis?: string
          keterangan?: string | null
          kondisi?: string
          nama?: string
          sumber_dana?: string | null
          tahun_bangun?: number | null
          tahun_perbaikan?: number | null
          tenant_id?: string
          updated_at?: string
          volume?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "infrastruktur_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      kegiatan_pembangunan: {
        Row: {
          anggaran: number
          bidang: string
          created_at: string
          id: string
          keterangan: string | null
          lokasi: string | null
          nama_kegiatan: string
          realismo: number
          status: Database["public"]["Enums"]["workflow_status"]
          sumber_dana: string | null
          tahun: number
          tanggal_mulai: string | null
          tanggal_selesai: string | null
          tenant_id: string
          updated_at: string
          volume: string | null
        }
        Insert: {
          anggaran?: number
          bidang: string
          created_at?: string
          id?: string
          keterangan?: string | null
          lokasi?: string | null
          nama_kegiatan: string
          realista?: number
          status?: Database["public"]["Enums"]["workflow_status"]
          sumber_dana?: string | null
          tahun: number
          tanggal_mulai?: string | null
          tanggal_selesai?: string | null
          tenant_id: string
          updated_at?: string
          volume?: string | null
        }
        Update: {
          anggaran?: number
          bidang?: string
          created_at?: string
          id?: string
          keterangan?: string | null
          lokasi?: string | null
          nama_kegiatan?: string
          realista?: number
          status?: Database["public"]["Enums"]["workflow_status"]
          sumber_dana?: string | null
          tahun?: number
          tanggal_mulai?: string | null
          tanggal_selesai?: string | null
          tenant_id?: string
          updated_at?: string
          volume?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "kegiatan_pembangunan_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      keluarga: {
        Row: {
          alamat: string | null
          catatan: string | null
          created_at: string
          dusun: string | null
          id: string
          kepala_nama: string | null
          no_kk: string
          rt: string | null
          rw: string | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          alamat?: string | null
          catatan?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          kepala_nama?: string | null
          no_kk: string
          rt?: string | null
          rw?: string | null
          tenant_id: string
          updated_at?: string
        }
        Update: {
          alamat?: string | null
          catatan?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          kepala_nama?: string | null
          no_kk?: string
          rt?: string | null
          rw?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "keluarga_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      langganan_wa: {
        Row: {
          created_at: string
          dusun: string | null
          id: string
          nama: string
          nomor_wa: string
          status: string
          tenant_id: string
          topik: string[]
          updated_at: string
        }
        Insert: {
          created_at?: string
          dusun?: string | null
          id?: string
          nama: string
          nomor_wa: string
          status?: string
          tenant_id: string
          topik?: string[]
          updated_at?: string
        }
        Update: {
          created_at?: string
          dusun?: string | null
          id?: string
          nama?: string
          nomor_wa?: string
          status?: string
          tenant_id?: string
          topik?: string[]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "langganan_wa_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      lembaga_desa: {
        Row: {
          created_at: string
          id: string
          jumlah_anggota: number
          ketua: string
          nama: string
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          created_at?: string
          id?: string
          jumlah_anggota?: number
          ketua: string
          nama: string
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          created_at?: string
          id?: string
          jumlah_anggota?: number
          ketua?: string
          nama?: string
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "lembaga_desa_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      nav_item: {
        Row: {
          aktif: boolean
          created_at: string
          deskripsi: string | null
          href: string
          id: string
          label: string
          parent_id: string | null
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          deskripsi?: string | null
          href: string
          id?: string
          label: string
          parent_id?: string | null
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          aktif?: boolean
          created_at?: string
          deskripsi?: string | null
          href?: string
          id?: string
          label?: string
          parent_id?: string | null
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "nav_item_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "nav_item"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "nav_item_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      notif_otp: {
        Row: {
          created_at: string
          id: string
          kadaluarsa: string
          kanal: string
          kode_hash: string
          konteks: string | null
          percobaan: number
          tenant_id: string
          terpakai: boolean
          tujuan: string
        }
        Insert: {
          created_at?: string
          id?: string
          kadaluarsa: string
          kanal: string
          kode_hash: string
          konteks?: string | null
          percobaan?: number
          tenant_id: string
          terpakai?: boolean
          tujuan: string
        }
        Update: {
          created_at?: string
          id?: string
          kadaluarsa?: string
          kanal?: string
          kode_hash?: string
          konteks?: string | null
          percobaan?: number
          tenant_id?: string
          terpakai?: boolean
          tujuan?: string
        }
        Relationships: [
          {
            foreignKeyName: "notif_otp_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      page_config: {
        Row: {
          deskripsi: string | null
          eyebrow: string
          hero_image_url: string | null
          id: string
          judul: string
          nama: string
          route: string
          section_titles: Json
          tenant_id: string
          updated_at: string
        }
        Insert: {
          deskripsi?: string | null
          eyebrow?: string
          hero_image_url?: string | null
          id?: string
          judul?: string
          nama: string
          route: string
          section_titles?: Json
          tenant_id: string
          updated_at?: string
        }
        Update: {
          deskripsi?: string | null
          eyebrow?: string
          hero_image_url?: string | null
          id?: string
          judul?: string
          nama?: string
          route?: string
          section_titles?: Json
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "page_config_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      pbb_tagihan: {
        Row: {
          alamat_objek: string | null
          created_at: string
          dusun: string | null
          id: string
          jatuh_tempo: string | null
          keterangan: string | null
          luas_bangunan_m2: number | null
          luas_bumi_m2: number | null
          metode_bayar: string | null
          njop_bangunan: number | null
          njop_bumi: number | null
          nop: string
          pbb_terutang: number
          status_bayar: string
          tahun: number
          tanggal_bayar: string | null
          tenant_id: string
          updated_at: string
          wajib_pajak_nama: string
          wajib_pajak_nik: string | null
        }
        Insert: {
          alamat_objek?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          jatuh_tempo?: string | null
          keterangan?: string | null
          luas_bangunan_m2?: number | null
          luas_bumi_m2?: number | null
          metode_bayar?: string | null
          njop_bangunan?: number | null
          njop_bumi?: number | null
          nop: string
          pbb_terutang?: number
          status_bayar?: string
          tahun: number
          tanggal_bayar?: string | null
          tenant_id: string
          updated_at?: string
          wajib_pajak_nama: string
          wajib_pajak_nik?: string | null
        }
        Update: {
          alamat_objek?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          jatuh_tempo?: string | null
          keterangan?: string | null
          luas_bangunan_m2?: number | null
          luas_bumi_m2?: number | null
          metode_bayar?: string | null
          njop_bangunan?: number | null
          njop_bumi?: number | null
          nop?: string
          pbb_terutang?: number
          status_bayar?: string
          tahun?: number
          tanggal_bayar?: string | null
          tenant_id?: string
          updated_at?: string
          wajib_pajak_nama?: string
          wajib_pajak_nik?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pbb_tagihan_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      penduduk: {
        Row: {
          agama: string | null
          alamat: string | null
          bpjs_nomor: string | null
          bpjs_status: string | null
          catatan: string | null
          created_at: string
          created_by: string | null
          dusun: string | null
          foto_url: string | null
          hubungan_kk: string | null
          id: string
          jenis_kelamin: string | null
          keluarga_id: string | null
          nama: string
          nik: string
          nomor_hp: string | null
          pekerjaan: string | null
          pendidikan: string | null
          rt: string | null
          rw: string | null
          status_hidup: string
          status_kawin: string | null
          tanggal_lahir: string | null
          tenant_id: string
          tempat_lahir: string | null
          updated_at: string
          updated_by: string | null
        }
        Insert: {
          agama?: string | null
          alamat?: string | null
          bpjs_nomor?: string | null
          bpjs_status?: string | null
          catatan?: string | null
          created_at?: string
          created_by?: string | null
          dusun?: string | null
          foto_url?: string | null
          hubungan_kk?: string | null
          id?: string
          jenis_kelamin?: string | null
          keluarga_id?: string | null
          nama: string
          nik: string
          nomor_hp?: string | null
          pekerjaan?: string | null
          pendidikan?: string | null
          rt?: string | null
          rw?: string | null
          status_hidup?: string
          status_kawin?: string | null
          tanggal_lahir?: string | null
          tenant_id: string
          tempat_lahir?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Update: {
          agama?: string | null
          alamat?: string | null
          bpjs_nomor?: string | null
          bpjs_status?: string | null
          catatan?: string | null
          created_at?: string
          created_by?: string | null
          dusun?: string | null
          foto_url?: string | null
          hubungan_kk?: string | null
          id?: string
          jenis_kelamin?: string | null
          keluarga_id?: string | null
          nama?: string
          nik?: string
          nomor_hp?: string | null
          pekerjaan?: string | null
          pendidikan?: string | null
          rt?: string | null
          rw?: string | null
          status_hidup?: string
          status_kawin?: string | null
          tanggal_lahir?: string | null
          tenant_id?: string
          tempat_lahir?: string | null
          updated_at?: string
          updated_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "penduduk_keluarga_id_fkey"
            columns: ["keluarga_id"]
            isOneToOne: false
            referencedRelation: "keluarga"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "penduduk_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      penerima_bansos: {
        Row: {
          bansos_id: string
          catatan: string | null
          created_at: string
          dusun: string | null
          id: string
          nama: string
          nik: string
          nominal: number | null
          status: string
          tanggal_salur: string | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          bansos_id: string
          catatan?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          nama: string
          nik: string
          nominal?: number | null
          status?: string
          tanggal_salur?: string | null
          tenant_id: string
          updated_at?: string
        }
        Update: {
          bansos_id?: string
          catatan?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          nama?: string
          nik?: string
          nominal?: number | null
          status?: string
          tanggal_salur?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "penerima_bansos_bansos_id_fkey"
            columns: ["bansos_id"]
            isOneToOne: false
            referencedRelation: "bantuan_sosial"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "penerima_bansos_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      pengumuman: {
        Row: {
          created_at: string
          id: string
          judul: string
          nomor: string
          ringkasan: string
          tanggal: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          judul: string
          nomor: string
          ringkasan?: string
          tanggal?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          judul?: string
          nomor?: string
          ringkasan?: string
          tanggal?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "pengumuman_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      posyandu_agregat: {
        Row: {
          catatan: string | null
          created_at: string
          dusun: string
          gizi_baik: number
          gizi_kurang: number
          hadir: number
          ibu_hamil_dilayani: number
          id: string
          imunisasi_lengkap: number
          jumlah_balita: number
          periode: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          catatan?: string | null
          created_at?: string
          dusun: string
          gizi_baik?: number
          gizi_kurang?: number
          hadir?: number
          ibu_hamil_dilayani?: number
          id?: string
          imunisasi_lengkap?: number
          jumlah_balita?: number
          periode: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          catatan?: string | null
          created_at?: string
          dusun?: string
          gizi_baik?: number
          gizi_kurang?: number
          hadir?: number
          ibu_hamil_dilayani?: number
          id?: string
          imunisasi_lengkap?: number
          jumlah_balita?: number
          periode?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "posyandu_agregat_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      potensi_produk: {
        Row: {
          created_at: string
          deskripsi: string | null
          featured: boolean
          foto_url: string | null
          harga: number | null
          id: string
          kategori: string | null
          nama: string
          penjual_nama: string
          satuan: string | null
          status: string
          stok: number | null
          tenant_id: string
          umkm_id: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          deskripsi?: string | null
          featured?: boolean
          foto_url?: string | null
          harga?: number | null
          id?: string
          kategori?: string | null
          nama: string
          penjual_nama: string
          satuan?: string | null
          status?: string
          stok?: number | null
          tenant_id: string
          umkm_id?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          deskripsi?: string | null
          featured?: boolean
          foto_url?: string | null
          harga?: number | null
          id?: string
          kategori?: string | null
          nama?: string
          penjual_nama?: string
          satuan?: string | null
          status?: string
          stok?: number | null
          tenant_id?: string
          umkm_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "potensi_produk_umkm_id_fkey"
            columns: ["umkm_id"]
            isOneToOne: false
            referencedRelation: "potensi_umkm"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "potensi_produk_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      potensi_umkm: {
        Row: {
          alamat: string | null
          created_at: string
          deskripsi: string | null
          dusun: string | null
          id: string
          kontak: string | null
          nama: string
          pemilik: string | null
          sektor: string | null
          status: string
          tenant_id: string
          tipe: string
          updated_at: string
        }
        Insert: {
          alamat?: string | null
          created_at?: string
          deskripsi?: string | null
          dusun?: string | null
          id?: string
          kontak?: string | null
          nama: string
          pemilik?: string | null
          sektor?: string | null
          status?: string
          tenant_id: string
          tipe?: string
          updated_at?: string
        }
        Update: {
          alamat?: string | null
          created_at?: string
          deskripsi?: string | null
          dusun?: string | null
          id?: string
          kontak?: string | null
          nama?: string
          pemilik?: string | null
          sektor?: string | null
          status?: string
          tenant_id?: string
          tipe?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "potensi_umkm_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      potensi_wisata: {
        Row: {
          created_at: string
          deskripsi: string | null
          dusun: string | null
          fasilitas: string | null
          foto_url: string | null
          id: string
          jenis: string
          latitude: number | null
          longitude: number | null
          nama: string
          status: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          deskripsi?: string | null
          dusun?: string | null
          fasilitas?: string | null
          foto_url?: string | null
          id?: string
          jenis: string
          latitude?: number | null
          longitude?: number | null
          nama: string
          status?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          deskripsi?: string | null
          dusun?: string | null
          fasilitas?: string | null
          foto_url?: string | null
          id?: string
          jenis?: string
          latitude?: number | null
          longitude?: number | null
          nama?: string
          status?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "potensi_wisata_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      profil_desa: {
        Row: {
          id: string
          misi: Json
          sejarah: Json
          singleton: boolean
          tenant_id: string
          updated_at: string
          visi: string
        }
        Insert: {
          id?: string
          misi?: Json
          sejarah?: Json
          singleton?: boolean
          tenant_id: string
          updated_at?: string
          visi?: string
        }
        Update: {
          id?: string
          misi?: Json
          sejarah?: Json
          singleton?: boolean
          tenant_id?: string
          updated_at?: string
          visi?: string
        }
        Relationships: [
          {
            foreignKeyName: "profil_desa_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      rkpdes_kegiatan: {
        Row: {
          anggaran: number
          bidang_id: string | null
          created_at: string
          dusun: string | null
          id: string
          lokasi: string | null
          nama: string
          pelaksana: string | null
          program_id: string | null
          progress_pct: number
          satuan: string | null
          status_realisasi: Database["public"]["Enums"]["realisasi_status"]
          sumber_dana: string | null
          tahun_id: string
          tenant_id: string
          updated_at: string
          urutan: number
          volume: string | null
          waktu: string | null
        }
        Insert: {
          anggaran?: number
          bidang_id?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          lokasi?: string | null
          nama: string
          pelaksana?: string | null
          program_id?: string | null
          progress_pct?: number
          satuan?: string | null
          status_realisasi?: Database["public"]["Enums"]["realisasi_status"]
          sumber_dana?: string | null
          tahun_id: string
          tenant_id: string
          updated_at?: string
          urutan?: number
          volume?: string | null
          waktu?: string | null
        }
        Update: {
          anggaran?: number
          bidang_id?: string | null
          created_at?: string
          dusun?: string | null
          id?: string
          lokasi?: string | null
          nama?: string
          pelaksana?: string | null
          program_id?: string | null
          progress_pct?: number
          satuan?: string | null
          status_realisasi?: Database["public"]["Enums"]["realisasi_status"]
          sumber_dana?: string | null
          tahun_id?: string
          tenant_id?: string
          updated_at?: string
          urutan?: number
          volume?: string | null
          waktu?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "rkpdes_kegiatan_bidang_id_fkey"
            columns: ["bidang_id"]
            isOneToOne: false
            referencedRelation: "rpjmdes_bidang"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "rkpdes_kegiatan_program_id_fkey"
            columns: ["program_id"]
            isOneToOne: false
            referencedRelation: "rpjmdes_program"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "rkpdes_kegiatan_tahun_id_fkey"
            columns: ["tahun_id"]
            isOneToOne: false
            referencedRelation: "rkpdes_tahun"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "rkpdes_kegiatan_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      rkpdes_tahun: {
        Row: {
          catatan: string | null
          created_at: string
          id: string
          periode_id: string | null
          published: boolean
          tahun: number
          tgl_musdes: string | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          catatan?: string | null
          created_at?: string
          id?: string
          periode_id?: string | null
          published?: boolean
          tahun: number
          tgl_musdes?: string | null
          tenant_id: string
          updated_at?: string
        }
        Update: {
          catatan?: string | null
          created_at?: string
          id?: string
          periode_id?: string | null
          published?: boolean
          tahun?: number
          tgl_musdes?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "rkpdes_tahun_periode_id_fkey"
            columns: ["periode_id"]
            isOneToOne: false
            referencedRelation: "rpjmdes_periode"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "rkpdes_tahun_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      rpjmdes_bidang: {
        Row: {
          created_at: string
          deskripsi: string | null
          id: string
          kode: string
          nama: string
          periode_id: string
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          created_at?: string
          deskripsi?: string | null
          id?: string
          kode: string
          nama: string
          periode_id: string
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          created_at?: string
          deskripsi?: string | null
          id?: string
          kode?: string
          nama?: string
          periode_id?: string
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "rpjmdes_bidang_periode_id_fkey"
            columns: ["periode_id"]
            isOneToOne: false
            referencedRelation: "rpjmdes_periode"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "rpjmdes_bidang_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      rpjmdes_periode: {
        Row: {
          created_at: string
          id: string
          misi: Json
          nama: string
          published: boolean
          status: Database["public"]["Enums"]["rpjmdes_status"]
          tahun_mulai: number
          tahun_selesai: number
          tenant_id: string
          updated_at: string
          visi: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          misi?: Json
          nama: string
          published?: boolean
          status?: Database["public"]["Enums"]["rpjmdes_status"]
          tahun_mulai: number
          tahun_selesai: number
          tenant_id: string
          updated_at?: string
          visi?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          misi?: Json
          nama?: string
          published?: boolean
          status?: Database["public"]["Enums"]["rpjmdes_status"]
          tahun_mulai?: number
          tahun_selesai?: number
          tenant_id?: string
          updated_at?: string
          visi?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "rpjmdes_periode_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      rpjmdes_program: {
        Row: {
          anggaran_indikatif: number
          bidang_id: string
          created_at: string
          id: string
          indikator: string | null
          nama: string
          sumber_dana: string | null
          tahun_mulai: number | null
          tahun_selesai: number | null
          target: string | null
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          anggaran_indikatif?: number
          bidang_id: string
          created_at?: string
          id?: string
          indikator?: string | null
          nama: string
          sumber_dana?: string | null
          tahun_mulai?: number | null
          tahun_selesai?: number | null
          target?: string | null
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          anggaran_indikatif?: number
          bidang_id?: string
          created_at?: string
          id?: string
          indikator?: string | null
          nama?: string
          sumber_dana?: string | null
          tahun_mulai?: number | null
          tahun_selesai?: number | null
          target?: string | null
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "rpjmdes_program_bidang_id_fkey"
            columns: ["bidang_id"]
            isOneToOne: false
            referencedRelation: "rpjmdes_bidang"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "rpjmdes_program_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      sinkron_log: {
        Row: {
          arah: string
          created_at: string
          id: string
          jumlah: number | null
          payload: Json | null
          pesan: string | null
          status: string
          target: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          arah?: string
          created_at?: string
          id?: string
          jumlah?: number | null
          payload?: Json | null
          pesan?: string | null
          status: string
          target: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          arah?: string
          created_at?: string
          id?: string
          jumlah?: number | null
          payload?: Json | null
          pesan?: string | null
          status?: string
          target?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "sinkron_log_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      site_draft: {
        Row: {
          action: string
          actor_id: string | null
          catatan: string | null
          created_at: string
          entitas: string
          entitas_id: string | null
          id: string
          payload: Json
          published_at: string | null
          reviewed_at: string | null
          reviewer_id: string | null
          rollback_of: string | null
          status: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          action?: string
          actor_id?: string | null
          catatan?: string | null
          created_at?: string
          entitas: string
          entitas_id?: string | null
          id?: string
          payload?: Json
          published_at?: string | null
          reviewed_at?: string | null
          reviewer_id?: string | null
          rollback_of?: string | null
          status?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          action?: string
          actor_id?: string | null
          catatan?: string | null
          created_at?: string
          entitas?: string
          entitas_id?: string | null
          id?: string
          payload?: Json
          published_at?: string | null
          reviewed_at?: string | null
          reviewer_id?: string | null
          rollback_of?: string | null
          status?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "site_draft_rollback_of_fkey"
            columns: ["rollback_of"]
            isOneToOne: false
            referencedRelation: "site_draft"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "site_draft_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      site_version: {
        Row: {
          actor_id: string | null
          created_at: string
          entitas: string
          entitas_id: string
          id: string
          note: string | null
          snapshot: Json
          tenant_id: string
          versi: number
        }
        Insert: {
          actor_id?: string | null
          created_at?: string
          entitas: string
          entitas_id: string
          id?: string
          note?: string | null
          snapshot: Json
          tenant_id: string
          versi: number
        }
        Update: {
          actor_id?: string | null
          created_at?: string
          entitas?: string
          entitas_id?: string
          id?: string
          note?: string | null
          snapshot?: Json
          tenant_id?: string
          versi?: number
        }
        Relationships: [
          {
            foreignKeyName: "site_version_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      stunting_agregat: {
        Row: {
          balita_diukur: number
          created_at: string
          dusun: string
          id: string
          intervensi: string | null
          periode: string
          stunting: number
          tenant_id: string
          underweight: number
          updated_at: string
          wasting: number
        }
        Insert: {
          balita_diukur?: number
          created_at?: string
          dusun: string
          id?: string
          intervensi?: string | null
          periode: string
          stunting?: number
          tenant_id: string
          underweight?: number
          updated_at?: string
          wasting?: number
        }
        Update: {
          balita_diukur?: number
          created_at?: string
          dusun?: string
          id?: string
          intervensi?: string | null
          periode?: string
          stunting?: number
          tenant_id?: string
          underweight?: number
          updated_at?: string
          wasting?: number
        }
        Relationships: [
          {
            foreignKeyName: "stunting_agregat_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      suplesi_data: {
        Row: {
          created_at: string
          deskripsi: string
          id: string
          jenis: string
          kontak: string | null
          lampiran_url: string | null
          nama: string | null
          nik: string | null
          nomor_tiket: string
          status: string
          tanggapan: string | null
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          deskripsi: string
          id?: string
          jenis: string
          kontak?: string | null
          lampiran_url?: string | null
          nama?: string | null
          nik?: string | null
          nomor_tiket?: string
          status?: string
          tanggapan?: string | null
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          deskripsi?: string
          id?: string
          jenis?: string
          kontak?: string | null
          lampiran_url?: string | null
          nama?: string | null
          nik?: string | null
          nomor_tiket?: string
          status?: string
          tanggapan?: string | null
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "suplesi_data_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      surat_jenis: {
        Row: {
          aktif: boolean
          created_at: string
          dna_field: string | null
          id: string
          kode_klasifikasi: string
          kode_surat: string
          nama: string
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          dna_field?: string | null
          id?: string
          kode_klasifikasi: string
          kode_surat: string
          nama: string
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          aktif?: boolean
          created_at?: string
          dna_field?: string | null
          id?: string
          kode_klasifikasi?: string
          kode_surat?: string
          nama?: string
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "surat_jenis_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      surat_terbit: {
        Row: {
          berlaku_sampai: string | null
          created_at: string
          id: string
          jenis_kode: string
          jenis_nama: string
          keterangan: string | null
          kode_verifikasi: string
          nomor_surat: string
          pemohon_nama: string
          pemohon_nik: string | null
          penandatangan: string | null
          perovsk: string
          status: string
          tanggal_terbit: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          berlaku_sampai?: string | null
          created_at?: string
          id?: string
          jenis_kode: string
          jenis_nama: string
          keterangan?: string | null
          kode_verifikasi: string
          nomor_surat: string
          pemohon_nama: string
          pemohon_nik?: string | null
          penandatangan?: string | null
          perovsk: string
          status?: string
          tanggal_terbit?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          berlaku_sampai?: string | null
          created_at?: string
          id?: string
          jenis_kode?: string
          jenis_nama?: string
          keterangan?: string | null
          kode_verifikasi?: string
          nomor_surat?: string
          pemohon_nama?: string
          pemohon_nik?: string | null
          penandatangan?: string | null
          perovsk?: string
          status?: string
          tanggal_terbit?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "surat_terbit_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          tenant_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          tenant_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          tenant_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_roles_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      usulan_vote: {
        Row: {
          created_at: string
          dusun: string | null
          id: string
          tenant_id: string
          usulan_id: string
          voter_hash: string
        }
        Insert: {
          created_at?: string
          dusun?: string | null
          id?: string
          tenant_id: string
          usulan_id: string
          voter_hash: string
        }
        Update: {
          created_at?: string
          dusun?: string | null
          id?: string
          tenant_id?: string
          usulan_id?: string
          voter_hash?: string
        }
        Relationships: [
          {
            foreignKeyName: "usulan_vote_usulan_id_fkey"
            columns: ["usulan_id"]
            isOneToOne: false
            referencedRelation: "usulan_warga"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "usulan_vote_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      usulan_warga: {
        Row: {
          created_at: string
          deskripsi: string
          dusun: string | null
          foto_url: string | null
          id: string
          judul: string
          kategori: Database["public"]["Enums"]["usulan_kategori"]
          kontak: string | null
          lokasi: string | null
          nama: string
          nomor_tiket: string
          status: Database["public"]["Enums"]["usulan_status"]
          tanggapan: string | null
          target_rkpdes_id: string | null
          tenant_id: string
          updated_at: string
          vote_count: number
        }
        Insert: {
          created_at?: string
          deskripsi: string
          dusun?: string | null
          foto_url?: string | null
          id?: string
          judul: string
          kategori: Database["public"]["Enums"]["usulan_kategori"]
          kontak?: string | null
          lokasi?: string | null
          nama: string
          nomor_tiket: string
          status?: Database["public"]["Enums"]["usulan_status"]
          tanggapan?: string | null
          target_rkpdes_id?: string | null
          tenant_id: string
          updated_at?: string
          vote_count?: number
        }
        Update: {
          created_at?: string
          deskripsi?: string
          dusun?: string | null
          foto_url?: string | null
          id?: string
          judul?: string
          kategori?: Database["public"]["Enums"]["usulan_kategori"]
          kontak?: string | null
          lokasi?: string | null
          nama?: string
          nomor_tiket?: string
          status?: Database["public"]["Enums"]["usulan_status"]
          tanggapan?: string | null
          target_rkpdes_id?: string | null
          tenant_id?: string
          updated_at?: string
          vote_count?: number
        }
        Relationships: [
          {
            foreignKeyName: "usulan_warga_target_rkpdes_id_fkey"
            columns: ["target_rkpdes_id"]
            isOneToOne: false
            referencedRelation: "rkpdes_tahun"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "usulan_warga_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      voting_opsi: {
        Row: {
          created_at: string
          deskripsi: string | null
          id: string
          jumlah_suara: number
          label: string
          tenant_id: string
          topik_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          created_at?: string
          deskripsi?: string | null
          id?: string
          jumlah_suara?: number
          label: string
          tenant_id: string
          topik_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          created_at?: string
          deskripsi?: string | null
          id?: string
          jumlah_suara?: number
          label?: string
          tenant_id?: string
          topik_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "voting_opsi_topik_id_fkey"
            columns: ["topik_id"]
            isOneToOne: false
            referencedRelation: "voting_topik"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "voting_opsi_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      voting_suara: {
        Row: {
          created_at: string
          dusun: string | null
          id: string
          opsi_id: string
          tenant_id: string
          topik_id: string
          voter_hash: string
        }
        Insert: {
          created_at?: string
          dusun?: string | null
          id?: string
          opsi_id: string
          tenant_id: string
          topik_id: string
          voter_hash: string
        }
        Update: {
          created_at?: string
          dusun?: string | null
          id?: string
          opsi_id?: string
          tenant_id?: string
          topik_id?: string
          voter_hash?: string
        }
        Relationships: [
          {
            foreignKeyName: "voting_suara_opsi_id_fkey"
            columns: ["opsi_id"]
            isOneToOne: false
            referencedRelation: "voting_opsi"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "voting_suara_topik_id_fkey"
            columns: ["topik_id"]
            isOneToOne: false
            referencedRelation: "voting_topik"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "voting_suara_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      voting_topik: {
        Row: {
          created_at: string
          deskripsi: string | null
          hasil_dipublikasi: boolean
          hasil_dipublikasi_pada: string | null
          hasil_pemenang_id: string | null
          hasil_ringkasan: string | null
          id: string
          judul: string
          mulai: string | null
          published: boolean
          selesai: string | null
          single_choice: boolean
          status: Database["public"]["Enums"]["voting_status"]
          tenant_id: string
          total_suara: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          deskripsi?: string | null
          hasil_dipublikasi?: boolean
          hasil_dipublikasi_pada?: string | null
          hasil_pemenang_id?: string | null
          hasil_ringkasan?: string | null
          id?: string
          judul: string
          mulai?: string | null
          published?: boolean
          selesai?: string | null
          single_choice?: boolean
          status?: Database["public"]["Enums"]["voting_status"]
          tenant_id: string
          total_suara?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          deskripsi?: string | null
          hasil_dipublikasi?: boolean
          hasil_dipublikasi_pada?: string | null
          hasil_pemenang_id?: string | null
          hasil_ringkasan?: string | null
          id?: string
          judul?: string
          mulai?: string | null
          published?: boolean
          selesai?: string | null
          single_choice?: boolean
          status?: Database["public"]["Enums"]["voting_status"]
          tenant_id?: string
          total_suara?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "voting_topik_hasil_pemenang_id_fkey"
            columns: ["hasil_pemenang_id"]
            isOneToOne: false
            referencedRelation: "voting_opsi"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "voting_topik_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      wa_broadcast: {
        Row: {
          created_at: string
          dibuat_oleh: string | null
          dry_run: boolean
          dusun_filter: string | null
          id: string
          judul: string | null
          pesan: string
          status: string
          tenant_id: string
          topik: string | null
          total_gagal: number
          total_sukes: number
          total_target: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          dibuat_oleh?: string | null
          dry_run?: boolean
          dusun_filter?: string | null
          id?: string
          judul?: string | null
          pesan: string
          status?: string
          tenant_id: string
          topik?: string | null
          total_gagal?: number
          total_sukes?: number
          total_target?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          dibuat_oleh?: string | null
          dry_run?: boolean
          dusun_filter?: string | null
          id?: string
          judul?: string | null
          pesan?: string
          status?: string
          tenant_id?: string
          topik?: string | null
          total_gagal?: number
          total_sukes?: number
          total_target?: number
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "wa_broadcast_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      wa_broadcast_target: {
        Row: {
          attempt: number
          broadcast_id: string
          created_at: string
          dusun: string | null
          error_message: string | null
          id: string
          nama: string | null
          nomor_tujuan: string
          sent_at: string | null
          status: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          attempt?: number
          broadcast_id: string
          created_at?: string
          dusun?: string | null
          error_message?: string | null
          id?: string
          nama?: string | null
          nomor_tujuan: string
          sent_at?: string | null
          status?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          attempt?: number
          broadcast_id?: string
          created_at?: string
          dusun?: string | null
          error_message?: string | null
          id?: string
          nama?: string | null
          nomor_tujuan?: string
          sent_at?: string | null
          status?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "wa_broadcast_target_broadcast_id_fkey"
            columns: ["broadcast_id"]
            isOneToOne: false
            referencedRelation: "wa_broadcast"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "wa_broadcast_target_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      }
      wilayah_dusun: {
        Row: {
          created_at: string
          id: string
          jiwa: number
          kk: number
          latitude: number | null
          longitude: number | null
          luas_ha: number
          nama: string
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          created_at?: string
          id?: string
          jiwa?: number
          kk?: number
          latitude?: number | null
          longitude?: number | null
          luas_ha: number
          nama: string
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          created_at?: string
          id?: string
          jiwa?: number
          kk?: number
          latitude?: number | null
          longitude?: number | null
          luas_ha?: number
          nama?: string
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "wilayah_dusun_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      // === NEW TABLES (2026-07-20) ===

      // Reference Tables
      ref_agama: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          kode: string
          nama: string
          nama_latin: string | null
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode: string
          nama: string
          nama_latin?: string | null
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode?: string
          nama?: string
          nama_latin?: string | null
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },
      ref_pendidikan: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          jenjang: string | null
          kode: string
          nama: string
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          jenjang?: string | null
          kode: string
          nama: string
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          jenjang?: string | null
          kode?: string
          nama?: string
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },
      ref_pekerjaan: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          kategori: string | null
          kode: string
          kelompok_kecil: string | null
          kelompok_utama: string | null
          nama: string
          sub_kelompok: string | null
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          kategori?: string | null
          kode: string
          kelompok_kecil?: string | null
          kelompok_utama?: string | null
          nama: string
          sub_kelompok?: string | null
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          kategori?: string | null
          kode?: string
          kelompok_kecil?: string | null
          kelompok_utama?: string | null
          nama?: string
          sub_kelompok?: string | null
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },
      ref_status_perkawinan: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          kode: string
          nama: string
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode: string
          nama: string
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode?: string
          nama?: string
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },
      ref_hubungan_keluarga: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          kode: string
          nama: string
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode: string
          nama: string
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode?: string
          nama?: string
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },
      ref_golongan_darah: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          kode: string
          nama: string
          rhesus: string | null
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode: string
          nama: string
          rhesus?: string | null
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode?: string
          nama?: string
          rhesus?: string | null
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },
      ref_warga_negara: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          kode: string
          nama: string
          negara_id: string | null
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode: string
          nama: string
          negara_id?: string | null
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          kode?: string
          nama?: string
          negara_id?: string | null
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },
      ref_cacat: {
        Row: {
          aktif: boolean
          created_at: string
          id: string
          kategori: string | null
          kode: string
          nama: string
          urutan: number
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          id?: string
          kategori?: string | null
          kode: string
          nama: string
          urutan?: number
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          id?: string
          kategori?: string | null
          kode?: string
          nama?: string
          urutan?: number
          updated_at?: string
        }
        Relationships: []
      },

      // Multi-tenancy
      tenants: {
        Row: {
          aktif: boolean
          kabupaten: string | null
          created_at: string
          favicon_url: string | null
          id: string
          kode_desa: string | null
          kecamatan: string | null
          logo_url: string | null
          nama_desa: string
          provinsi: string | null
          settings: Json
          subdomain: string | null
          updated_at: string
          warna_aksen: string
          warna_primer: string
        }
        Insert: {
          aktif?: boolean
          kabupaten?: string | null
          created_at?: string
          favicon_url?: string | null
          id?: string
          kode_desa?: string | null
          kecamatan?: string | null
          logo_url?: string | null
          nama_desa: string
          provinsi?: string | null
          settings?: Json
          subdomain?: string | null
          updated_at?: string
          warna_aksen?: string
          warna_primer?: string
        }
        Update: {
          aktif?: boolean
          kabupaten?: string | null
          created_at?: string
          favicon_url?: string | null
          id?: string
          kode_desa?: string | null
          kecamatan?: string | null
          logo_url?: string | null
          nama_desa?: string
          provinsi?: string | null
          settings?: Json
          subdomain?: string | null
          updated_at?: string
          warna_aksen?: string
          warna_primer?: string
        }
        Relationships: []
      },
      site_settings: {
        Row: {
          alamat_kantor: string | null
          created_at: string
          email: string | null
          id: string
          jam_layanan: string | null
          maps_embed_url: string | null
          nama_resmi: string
          nomor_wa_resmi: string | null
          social_media: Json
          tagline: string | null
          telepon: string | null
          tenant_id: string
          updated_at: string
          wa_business_verified: boolean
        }
        Insert: {
          alamat_kantor?: string | null
          created_at?: string
          email?: string | null
          id?: string
          jam_layanan?: string | null
          maps_embed_url?: string | null
          nama_resmi: string
          nomor_wa_resmi?: string | null
          social_media?: Json
          tagline?: string | null
          telepon?: string | null
          tenant_id: string
          updated_at?: string
          wa_business_verified?: boolean
        }
        Update: {
          alamat_kantor?: string | null
          created_at?: string
          email?: string | null
          id?: string
          jam_layanan?: string | null
          maps_embed_url?: string | null
          nama_resmi?: string
          nomor_wa_resmi?: string | null
          social_media?: Json
          tagline?: string | null
          telepon?: string | null
          tenant_id?: string
          updated_at?: string
          wa_business_verified?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "site_settings_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },
      site_navigation: {
        Row: {
          aktif: boolean
          created_at: string
          href: string
          icon: string | null
          id: string
          label: string
          parent_id: string | null
          posisi: Database["public"]["Enums"]["nav_posisi"]
          tenant_id: string
          updated_at: string
          urutan: number
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          href: string
          icon?: string | null
          id?: string
          label: string
          parent_id?: string | null
          posisi: Database["public"]["Enums"]["nav_posisi"]
          tenant_id: string
          updated_at?: string
          urutan?: number
        }
        Update: {
          aktif?: boolean
          created_at?: string
          href?: string
          icon?: string | null
          id?: string
          label?: string
          parent_id?: string | null
          posisi?: Database["public"]["Enums"]["nav_posisi"]
          tenant_id?: string
          updated_at?: string
          urutan?: number
        }
        Relationships: [
          {
            foreignKeyName: "site_navigation_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "site_navigation"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "site_navigation_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },
      feature_flags: {
        Row: {
          aktif: boolean
          created_at: string
          fitur_kode: string
          id: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          fitur_kode: string
          id?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          fitur_kode?: string
          id?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "feature_flags_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      // Event Sourcing
      domain_events: {
        Row: {
          aktor_id: string | null
          created_at: string
          entity_id: string
          entity_type: string
          event_type: string
          id: string
          tenant_id: string | null
          payload: Json
          processed_at: string | null
        }
        Insert: {
          aktor_id?: string | null
          created_at?: string
          entity_id: string
          entity_type: string
          event_type: string
          id?: string
          tenant_id?: string | null
          payload?: Json
          processed_at?: string | null
        }
        Update: {
          aktor_id?: string | null
          created_at?: string
          entity_id?: string
          entity_type?: string
          event_type?: string
          id?: string
          tenant_id?: string | null
          payload?: Json
          processed_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "domain_events_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },
      event_log: {
        Row: {
          actor_id: string | null
          created_at: string
          entitas: string
          entitas_id: string | null
          event_name: Database["public"]["Enums"]["event_type"]
          id: string
          ip_address: string | null
          payload: Json
          tenant_id: string | null
          user_agent: string | null
        }
        Insert: {
          actor_id?: string | null
          created_at?: string
          entitas: string
          entitas_id?: string | null
          event_name: Database["public"]["Enums"]["event_type"]
          id?: string
          ip_address?: string | null
          payload?: Json
          tenant_id?: string | null
          user_agent?: string | null
        }
        Update: {
          actor_id?: string | null
          created_at?: string
          entitas?: string
          entitas_id?: string | null
          event_name?: Database["public"]["Enums"]["event_type"]
          id?: string
          ip_address?: string | null
          payload?: Json
          tenant_id?: string | null
          user_agent?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "event_log_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      // Fakta Turunan (Worker only)
      dashboard_agregat: {
        Row: {
          dihitung_pada: string
          id: string
          kategori: string
          metrik_key: string
          metrik_value: number
          periode: string
          tenant_id: string
          wilayah_id: string | null
        }
        Insert: {
          dihitung_pada?: string
          id?: string
          kategori: string
          metrik_key: string
          metrik_value: number
          periode: string
          tenant_id: string
          wilayah_id?: string | null
        }
        Update: {
          dihitung_pada?: string
          id?: string
          kategori?: string
          metrik_key?: string
          metrik_value?: number
          periode?: string
          tenant_id?: string
          wilayah_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "dashboard_agregat_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },
      idm_status_desa: {
        Row: {
          dimensi_scores: Json
          dimensi_skor_1: number
          dimensi_skor_2: number
          dimensi_skor_3: number
          dimensi_skor_4: number
          dimensi_skor_5: number
          dimensi_skor_6: number
          dihitung_pada: string
          status: string
          tenant_id: string
          total_skor: number
        }
        Insert: {
          dimensi_scores?: Json
          dimensi_skor_1?: number
          dimensi_skor_2?: number
          dimensi_skor_3?: number
          dimensi_skor_4?: number
          dimensi_skor_5?: number
          dimensi_skor_6?: number
          dihitung_pada?: string
          status: string
          tenant_id: string
          total_skor?: number
        }
        Update: {
          dimensi_scores?: Json
          dimensi_skor_1?: number
          dimensi_skor_2?: number
          dimensi_skor_3?: number
          dimensi_skor_4?: number
          dimensi_skor_5?: number
          dimensi_skor_6?: number
          dihitung_pada?: string
          status?: string
          tenant_id?: string
          total_skor?: number
        }
        Relationships: [
          {
            foreignKeyName: "idm_status_desa_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      // IDM Engine Tables
      idm_indicators: {
        Row: {
          created_at: string
          dimensi_nama: string
          dimensi_no: number
          id: string
          indikator_nama: string
          indikator_no: string
          indikator_skor_max: number
          is_active: boolean
          kode_rekening: string | null
          rekomendasi_intervensi: string | null
          sumber_data: string
          subdimensi_kode: string | null
          subdimensi_nama: string | null
          sub_indikator_nama: string | null
          sub_indikator_no: string | null
          sub_skor_max: number | null
          unidade: string | null
        }
        Insert: {
          created_at?: string
          dimensi_nama: string
          dimensi_no: number
          id?: string
          indikator_nama: string
          indikator_no: string
          indikator_skor_max?: number
          is_active?: boolean
          kode_rekening?: string | null
          rekomendasi_intervensi?: string | null
          sumber_data: string
          subdimensi_kode?: string | null
          subdimensi_nama?: string | null
          sub_indikator_nama?: string | null
          sub_indikator_no?: string | null
          sub_skor_max?: number | null
          unidade?: string | null
        }
        Update: {
          created_at?: string
          dimensi_nama?: string
          dimensi_no?: number
          id?: string
          indikator_nama?: string
          indikator_no?: string
          indikator_skor_max?: number
          is_active?: boolean
          kode_rekening?: string | null
          rekomendasi_intervensi?: string | null
          sumber_data?: string
          subdimensi_kode?: string | null
          subdimensi_nama?: string | null
          sub_indikator_nama?: string | null
          sub_indikator_no?: string | null
          sub_skor_max?: number | null
          unidade?: string | null
        }
        Relationships: []
      },

      idm_skor_cache: {
        Row: {
          created_at: string
          dimensi_nama: string
          dimensi_no: number
          id: string
          indikator_id: string
          indikator_kode: string
          nilai_agregat: number
          skor: number
          sumber_data: string
          tenant_id: string
          dihitung_pada: string
        }
        Insert: {
          created_at?: string
          dimensi_nama: string
          dimensi_no: number
          id?: string
          indikator_id: string
          indikator_kode: string
          nilai_agregat?: number
          skor: number
          sumber_data: string
          tenant_id: string
          dihitung_pada?: string
        }
        Update: {
          created_at?: string
          dimensi_nama?: string
          dimensi_no?: number
          id?: string
          indikator_id?: string
          indikator_kode?: string
          nilai_agregat?: number
          skor?: number
          sumber_data?: string
          tenant_id?: string
          dihitung_pada?: string
        }
        Relationships: [
          {
            foreignKeyName: "idm_skor_cache_indikator_id_fkey"
            columns: ["indikator_id"]
            isOneToOne: false
            referencedRelation: "idm_indicators"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "idm_skor_cache_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      idm_scoring_thresholds: {
        Row: {
          created_at: string
          deskripsi_kondisi: string | null
          id: string
          indikator_id: string
          nilai_ambang_atas: number
          nilai_ambang_bawah: number
          skor_level: number
        }
        Insert: {
          created_at?: string
          deskripsi_kondisi?: string | null
          id?: string
          indikator_id: string
          nilai_ambang_atas: number
          nilai_ambang_bawah: number
          skor_level: number
        }
        Update: {
          created_at?: string
          deskripsi_kondisi?: string | null
          id?: string
          indikator_id?: string
          nilai_ambang_atas?: number
          nilai_ambang_bawah?: number
          skor_level?: number
        }
        Relationships: [
          {
            foreignKeyName: "idm_scoring_thresholds_indikator_id_fkey"
            columns: ["indikator_id"]
            isOneToOne: false
            referencedRelation: "idm_indicators"
            referencedColumns: ["id"]
          },
        ]
      },

      idm_log: {
        Row: {
          aktor_id: string | null
          created_at: string
          indikator_kode: string
          keterangan: string | null
          nilai_agregat_baru: number
          nilai_agregat_lama: number | null
          skor_baru: number
          skor_lama: number | null
          sumber_event: string | null
          tenant_id: string
          id: string
        }
        Insert: {
          aktor_id?: string | null
          created_at?: string
          indikator_kode: string
          keterangan?: string | null
          nilai_agregat_baru: number
          nilai_agregat_lama?: number | null
          skor_baru: number
          skor_lama?: number | null
          sumber_event?: string | null
          tenant_id: string
          id?: string
        }
        Update: {
          aktor_id?: string | null
          created_at?: string
          indikator_kode?: string
          keterangan?: string | null
          nilai_agregat_baru?: number
          nilai_agregat_lama?: number | null
          skor_baru?: number
          skor_lama?: number | null
          sumber_event?: string | null
          tenant_id?: string
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "idm_log_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      usulan_kegiatan_draft_otomatis: {
        Row: {
          created_at: string
          deskripsi_saran: string | null
          estimasi_anggaran: number | null
          id: string
          indikator_kode: string | null
          judul_saran: string
          kode_rekening_saran: string | null
          kategori: string
          lokasi_saran: string | null
          reviewer_id: string | null
          reviewed_at: string | null
          sumber_pemicu: string
          sumber_ref_id: string | null
          status: string
          tenant_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          deskripsi_saran?: string | null
          estimasi_anggaran?: number | null
          id?: string
          indikator_kode?: string | null
          judul_saran: string
          kode_rekening_saran?: string | null
          kategori?: string
          lokasi_saran?: string | null
          reviewer_id?: string | null
          reviewed_at?: string | null
          sumber_pemicu: string
          sumber_ref_id?: string | null
          status?: string
          tenant_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          deskripsi_saran?: string | null
          estimasi_anggaran?: number | null
          id?: string
          indikator_kode?: string | null
          judul_saran?: string
          kode_rekening_saran?: string | null
          kategori?: string
          lokasi_saran?: string | null
          reviewer_id?: string | null
          reviewed_at?: string | null
          sumber_pemicu?: string
          sumber_ref_id?: string | null
          status?: string
          tenant_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "usulan_draft_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      pades_pendapatan: {
        Row: {
          created_at: string
          id: string
          jenis_pendapatan: string | null
          keterangan: string | null
          nilai: number
          sumber: string
          sumber_ref_id: string | null
          tenant_id: string
          tahun: number
        }
        Insert: {
          created_at?: string
          id?: string
          jenis_pendapatan?: string | null
          keterangan?: string | null
          nilai: number
          sumber: string
          sumber_ref_id?: string | null
          tenant_id: string
          tahun: number
        }
        Update: {
          created_at?: string
          id?: string
          jenis_pendapatan?: string | null
          keterangan?: string | null
          nilai?: number
          sumber?: string
          sumber_ref_id?: string | null
          tenant_id?: string
          tahun?: number
        }
        Relationships: [
          {
            foreignKeyName: "pades_pendapatan_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      wilayah_batas: {
        Row: {
          boundary_json: Json | null
          created_at: string
          geom: Json | null
          id: string
          jenis: string
          kode: string | null
          luas_m2: number | null
          nama: string
          parent_id: string | null
          tenant_id: string
        }
        Insert: {
          boundary_json?: Json | null
          created_at?: string
          geom?: Json | null
          id?: string
          jenis: string
          kode?: string | null
          luas_m2?: number | null
          nama: string
          parent_id?: string | null
          tenant_id: string
        }
        Update: {
          boundary_json?: Json | null
          created_at?: string
          geom?: Json | null
          id?: string
          jenis?: string
          kode?: string | null
          luas_m2?: number | null
          nama?: string
          parent_id?: string | null
          tenant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "wilayah_batas_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "wilayah_batas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "wilayah_batas_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },

      // Audit Trail Tables
      audit_trail: {
        Row: {
          aksi: string
          actor_id: string | null
          created_at: string
          entitas: string
          entitas_id: string
          perubahan: Json | null
          id: string
          ip_address: string | null
          keterangan: string | null
          payload_baru: Json | null
          payload_lama: Json | null
          tenant_id: string | null
          user_agent: string | null
        }
        Insert: {
          aksi: string
          actor_id?: string | null
          created_at?: string
          entitas: string
          entitas_id: string
          perubahan?: Json | null
          id?: string
          ip_address?: string | null
          keterangan?: string | null
          payload_baru?: Json | null
          payload_lama?: Json | null
          tenant_id?: string | null
          user_agent?: string | null
        }
        Update: {
          aksi?: string
          actor_id?: string | null
          created_at?: string
          entitas?: string
          entitas_id?: string
          perubahan?: Json | null
          id?: string
          ip_address?: string | null
          keterangan?: string | null
          payload_baru?: Json | null
          payload_lama?: Json | null
          tenant_id?: string | null
          user_agent?: string | null
        }
        Relationships: []
      },

      audit_surat_terbit: {
        Row: {
          actor_id: string | null
          aksi: string
          created_at: string
          id: string
          jenis: string | null
          nomor_surat: string | null
          payload: Json | null
          status_baru: string | null
          status_lama: string | null
          surat_id: string
          tenant_id: string | null
        }
        Insert: {
          actor_id?: string | null
          aksi: string
          created_at?: string
          id?: string
          jenis?: string | null
          nomor_surat?: string | null
          payload?: Json | null
          status_baru?: string | null
          status_lama?: string | null
          surat_id: string
          tenant_id?: string | null
        }
        Update: {
          actor_id?: string | null
          aksi?: string
          created_at?: string
          id?: string
          jenis?: string | null
          nomor_surat?: string | null
          payload?: Json | null
          status_baru?: string | null
          status_lama?: string | null
          surat_id?: string
          tenant_id?: string | null
        }
        Relationships: []
      },

      audit_voting: {
        Row: {
          actor_id: string | null
          aksi: string
          created_at: string
          id: string
          jumlah_suara_baru: number | null
          jumlah_suara_lama: number | null
          payload: Json | null
          suara_id: string | null
          tenant_id: string | null
          topik_id: string | null
        }
        Insert: {
          actor_id?: string | null
          aksi: string
          created_at?: string
          id?: string
          jumlah_suara_baru?: number | null
          jumlah_suara_lama?: number | null
          payload?: Json | null
          suara_id?: string | null
          tenant_id?: string | null
          topik_id?: string | null
        }
        Update: {
          actor_id?: string | null
          aksi?: string
          created_at?: string
          id?: string
          jumlah_suara_baru?: number | null
          jumlah_suara_lama?: number | null
          payload?: Json | null
          suara_id?: string | null
          tenant_id?: string | null
          topik_id?: string | null
        }
        Relationships: []
      },

      audit_keuangan: {
        Row: {
          actor_id: string | null
          aksi: string
          anggaran_baru: number | null
          anggaran_lama: number | null
          apbdes_id: string | null
          created_at: string
          id: string
          payload: Json | null
          sumber_dana_baru: string | null
          sumber_dana_lama: string | null
          tahun: number | null
          tenant_id: string | null
        }
        Insert: {
          actor_id?: string | null
          aksi: string
          anggaran_baru?: number | null
          anggaran_lama?: number | null
          apbdes_id?: string | null
          created_at?: string
          id?: string
          payload?: Json | null
          sumber_dana_baru?: string | null
          sumber_dana_lama?: string | null
          tahun?: number | null
          tenant_id?: string | null
        }
        Update: {
          actor_id?: string | null
          aksi?: string
          anggaran_baru?: number | null
          anggaran_lama?: number | null
          apbdes_id?: string | null
          created_at?: string
          id?: string
          payload?: Json | null
          sumber_dana_baru?: string | null
          sumber_dana_lama?: string | null
          tahun?: number | null
          tenant_id?: string | null
        }
        Relationships: []
      },

      // WA Chatbot Tables
      wa_chatbot_session: {
        Row: {
          created_at: string
          expires_at: string
          id: string
          ip_address: string | null
          last_menu: number | null
          nomor_wa: string
          session_id: string
          state: string
          step_data: Json | null
          tenant_id: string | null
          updated_at: string
          user_id: string | null
          user_nik: string | null
        }
        Insert: {
          created_at?: string
          expires_at: string
          id?: string
          ip_address?: string | null
          last_menu?: number | null
          nomor_wa: string
          session_id: string
          state?: string
          step_data?: Json | null
          tenant_id?: string | null
          updated_at?: string
          user_id?: string | null
          user_nik?: string | null
        }
        Update: {
          created_at?: string
          expires_at?: string
          id?: string
          ip_address?: string | null
          last_menu?: number | null
          nomor_wa?: string
          session_id?: string
          state?: string
          step_data?: Json | null
          tenant_id?: string | null
          updated_at?: string
          user_id?: string | null
          user_nik?: string | null
        }
        Relationships: []
      },

      wa_chatbot_conversation: {
        Row: {
          created_at: string
          direction: string
          id: string
          message: string
          nomor_wa: string
          parsed_entities: Json | null
          parsed_intent: string | null
          sent_response: Json | null
          sent_status: string | null
          session_id: string | null
          tenant_id: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string
          direction: string
          id?: string
          message: string
          nomor_wa: string
          parsed_entities?: Json | null
          parsed_intent?: string | null
          sent_response?: Json | null
          sent_status?: string | null
          session_id?: string | null
          tenant_id?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string
          direction?: string
          id?: string
          message?: string
          nomor_wa?: string
          parsed_entities?: Json | null
          parsed_intent?: string | null
          sent_response?: Json | null
          sent_status?: string | null
          session_id?: string | null
          tenant_id?: string | null
          user_id?: string | null
        }
        Relationships: []
      },

      wa_chatbot_menu: {
        Row: {
          action_type: string
          action_value: string | null
          aktif: boolean
          created_at: string
          emoji: string | null
          id: string
          label: string
          menu_key: string
          urutan: number
          parent_key: string | null
          tenant_id: string | null
        }
        Insert: {
          action_type: string
          action_value?: string | null
          aktif?: boolean
          created_at?: string
          emoji?: string | null
          id?: string
          label: string
          menu_key: string
          urutan?: number
          parent_key?: string | null
          tenant_id?: string | null
        }
        Update: {
          action_type?: string
          action_value?: string | null
          aktif?: boolean
          created_at?: string
          emoji?: string | null
          id?: string
          label?: string
          menu_key?: string
          urutan?: number
          parent_key?: string | null
          tenant_id?: string | null
        }
        Relationships: []
      },

      // User Roles Extended
      user_peran: {
        Row: {
          aktif: boolean
          created_at: string
          dusun_id: string | null
          id: string
          peran: Database["public"]["Enums"]["app_peran"]
          tenant_id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          aktif?: boolean
          created_at?: string
          dusun_id?: string | null
          id?: string
          peran: Database["public"]["Enums"]["app_peran"]
          tenant_id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          aktif?: boolean
          created_at?: string
          dusun_id?: string | null
          id?: string
          peran?: Database["public"]["Enums"]["app_peran"]
          tenant_id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_peran_tenant_id_fkey"
            columns: ["tenant_id"]
            isOneToOne: false
            referencedRelation: "tenants"
            referencedColumns: ["id"]
          },
        ]
      },
    }
    Views: {
      penduduk_per_dusun: {
        Row: {
          dusun: string | null
          jumlah: number | null
          laki: number | null
          perempuan: number | null
        }
        Relationships: []
      }
      penduduk_statistik: {
        Row: {
          dusun: number | null
          kk: number | null
          laki: number | null
          perempuan: number | null
          total: number | null
        }
        Relationships: []
      }
    }
    Functions: {
      auto_close_expired_voting: { Args: never; Returns: undefined }
      cek_pbb: {
        Args: { _nik: string; _nop: string; _tahun: number }
        Returns: {
          jatuh_tempo: string
          nop: string
          pbb_terutang: number
          status_bayar: string
          tahun: number
          tanggal_bayar: string
        }[]
      }
      has_peran: {
        Args: {
          _peran: Database["public"]["Enums"]["app_peran"]
          _user_id: string
        }
        Returns: boolean
      }
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      get_tenant_id: { Args: Record<string, never>; Returns: string }
      user_has_tenant_access: { Args: { p_tenant_id: string; p_user_id: string }; Returns: boolean }
      is_feature_enabled: { Args: { p_fitur_kode: string; p_tenant_id: string }; Returns: boolean }
      get_site_navigation: {
        Args: { p_posisi: string; p_tenant_id: string }
        Returns: {
          href: string
          icon: string | null
          id: string
          label: string
          parent_id: string | null
          urutan: number
        }[]
      }
      get_enabled_features: {
        Args: { p_tenant_id: string }
        Returns: { aktif: boolean; fitur_kode: string }[]
      }
      lacak_aduan: {
        Args: { _nomor_tiket: string }
        Returns: {
          created_at: string
          judul: string
          kategori: Database["public"]["Enums"]["aduan_kategori"]
          nomor_tiket: string
          status: Database["public"]["Enums"]["workflow_status"]
          tanggapan: string
          updated_at: string
        }[]
      }
      publish_site_draft: { Args: { _draft_id: string }; Returns: string }
      restore_site_version: {
        Args: { _version_id: string }
        Returns: undefined
      }
      rollback_site_draft: { Args: { _draft_id: string }; Returns: undefined }
      tutup_voting_manual: {
        Args: { _ringkasan: string; _topik_id: string }
        Returns: string
      }
      verifikasi_surat: {
        Args: { _kode: string; _nomor: string }
        Returns: {
          berlaku_sampai: string
          jenis_kode: string
          jenis_nama: string
          nomor_surat: string
          pemohon_nama: string
          penandatangan: string
          perovsk: string
          status: string
          tanggal_terbit: string
        }[]
      }
    }
    Enums: {
      aduan_kategori:
        | "infrastruktur"
        | "pelayanan"
        | "lingkungan"
        | "sosial"
        | "keamanan"
        | "lainnya"
      app_role: "admin"
      app_peran: "admin" | "kades" | "sekdes" | "admin_keuangan" | "admin_kesehatan" | "kader_posyandu" | "dinas_pmd"
      ref_status_kependudukan: "aktif" | "pindah" | "meninggal"
      bencana_severity: "rendah" | "sedang" | "tinggi" | "darurat"
      event_type:
        | "penduduk.dibuat"
        | "penduduk.data.berubah"
        | "penduduk.status.berubah"
        | "penduduk.bpjs.berubah"
        | "surat.diajukan"
        | "surat.diverifikasi"
        | "surat.ditolak"
        | "surat.ditandatangani"
        | "surat.diterbitkan"
        | "surat.dikirim"
        | "usulan.diajukan"
        | "usulan.lolos_verifikasi"
        | "usulan.ditolak"
        | "usulan.ditetapkan_rkpdes"
        | "usulan.vote.bertambah"
        | "voting.ditutup"
        | "pbb.wajib_pajak.didaftarkan"
        | "pbb.objek_pajak.didaftarkan"
        | "pbb.objek_pajak.berubah"
        | "pbb.tagihan.dibayar"
        | "apbdes.realisasi.dicatat"
        | "apbdes.kegiatan.disahkan"
        | "posyandu.kunjungan.dicatat"
        | "posyandu.balita.terindikasi_gizi_buruk"
        | "bidang_tanah.didaftarkan"
        | "bidang_tanah.disahkan"
        | "bidang_tanah.dialihkan"
        | "infrastruktur.dilaporkan"
        | "infrastruktur.diverifikasi"
        | "musdes.usulan.ditetapkan"
        | "musdes.jadwal.ditetapkan"
        | "wa.layanan.selesai"
        | "aset.dibuat"
        | "aset.diverifikasi"
        | "aset.disusutkan"
      nav_posisi: "header" | "footer"
      ref_jenis_kelamin: "L" | "P"
      realista_status:
        | "rencana"
        | "berjalan"
        | "selesai"
        | "tertunda"
        | "batal"
      rpjmdes_status: "draft" | "aktif" | "selesai"
      usulan_kategori:
        | "infrastruktur"
        | "ekonomi"
        | "sosial"
        | "pendidikan"
        | "kesehatan"
        | "lingkungan"
        | "pemerintahan"
        | "lainnya"
      usulan_status:
        | "baru"
        | "diverifikasi"
        | "ditindaklanjuti"
        | "selesai"
        | "ditolak"
      voting_status: "draft" | "aktif" | "ditutup"
      workflow_status:
        | "draft"
        | "diajukan"
        | "diverifikasi"
        | "diproses"
        | "selesai"
        | "ditolak"
        | "dibatalkan"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      aduan_kategori: [
        "infrastruktur",
        "pelayanan",
        "lingkungan",
        "sosial",
        "keamanan",
        "lainnya",
      ],
      app_role: ["admin"],
      app_peran: ["admin", "kades", "sekdes", "admin_keuangan", "admin_kesehatan", "kader_posyandu", "dinas_pmd"],
      ref_status_kependudukan: ["aktif", "pindah", "meninggal"],
      bencana_severity: ["rendah", "sedang", "tinggi", "darurat"],
      ref_jenis_kelamin: ["L", "P"],
      nav_posisi: ["header", "footer"],
      event_type: [
        "penduduk.dibuat",
        "penduduk.data.berubah",
        "penduduk.status.berubah",
        "penduduk.bpjs.berubah",
        "surat.diajukan",
        "surat.diverifikasi",
        "surat.ditolak",
        "surat.ditandatangani",
        "surat.diterbitkan",
        "surat.dikirim",
        "usulan.diajukan",
        "usulan.lolos_verifikasi",
        "usulan.ditolak",
        "usulan.ditetapkan_rkpdes",
        "usulan.vote.bertambah",
        "voting.ditutup",
        "pbb.wajib_pajak.didaftarkan",
        "pbb.objek_pajak.didaftarkan",
        "pbb.objek_pajak.berubah",
        "pbb.tagihan.dibayar",
        "apbdes.realisasi.dicatat",
        "apbdes.kegiatan.disahkan",
        "posyandu.kunjungan.dicatat",
        "posyandu.balita.terindikasi_gizi_buruk",
        "bidang_tanah.didaftarkan",
        "bidang_tanah.disahkan",
        "bidang_tanah.dialihkan",
        "infrastruktur.dilaporkan",
        "infrastruktur.diverifikasi",
        "musdes.usulan.ditetapkan",
        "musdes.jadwal.ditetapkan",
        "wa.layanan.selesai",
        "aset.dibuat",
        "aset.diverifikasi",
        "aset.disusutkan",
      ],
      realismo_status: ["rencana", "berjalan", "selesai", "tertunda", "batal"],
      rpjmdes_status: ["draft", "aktif", "selesai"],
      usulan_kategori: [
        "infrastruktur",
        "ekonomi",
        "sosial",
        "pendidikan",
        "kesehatan",
        "lingkungan",
        "pemerintahan",
        "lainnya",
      ],
      usulan_status: [
        "baru",
        "diverifikasi",
        "ditindaklanjuti",
        "selesai",
        "ditolak",
      ],
      voting_status: ["draft", "aktif", "ditutup"],
      workflow_status: [
        "draft",
        "diajukan",
        "diverifikasi",
        "diproses",
        "selesai",
        "ditolak",
        "dibatalkan",
      ],
    },
  },
} as const
