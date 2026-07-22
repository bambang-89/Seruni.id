// ============================================================
// DRIZZLE SCHEMA — Generated from existing Supabase types
// Migration Target: Next.js + Drizzle + PostgreSQL
//
// This schema mirrors the existing Supabase schema for incremental migration.
// Run: npx drizzle-kit generate
// Run: npx drizzle-kit push
// ============================================================

import {
  pgTable,
  uuid,
  text,
  varchar,
  timestamp,
  boolean,
  integer,
  bigint,
  jsonb,
  numeric,
  date,
  inet,
  pgEnum,
  unique,
  index,
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";

// ============================================================
// ENUMS
// ============================================================

export const roleEnum = pgEnum("app_role", ["admin"]);
export const peranEnum = pgEnum("app_peran", [
  "admin",
  "kades",
  "sekdes",
  "admin_keuangan",
  "admin_kesehatan",
  "kader_posyandu",
  "dinas_pmd",
]);
export const eventTypeEnum = pgEnum("event_type", [
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
]);
export const workflowStatusEnum = pgEnum("workflow_status", [
  "draft",
  "diajukan",
  "terverifikasi",
  "ditolak",
  "ditandatangani",
  "diterbitkan",
  "dikirim",
  "ditutup",
]);
export const votingStatusEnum = pgEnum("voting_status", ["aktif", "ditutup"]);
export const AduanKategoriEnum = pgEnum("aduan_kategori", [
  "infrastruktur",
  "pelayanan",
  "lingkungan",
  "sosial",
  "keamanan",
  "lainnya",
]);
export const NavPosisiEnum = pgEnum("nav_posisi", ["header", "footer"]);
export const RefJenisKelaminEnum = pgEnum("ref_jenis_kelamin", ["L", "P"]);
export const BencanaSeverityEnum = pgEnum("bencana_severity", [
  "rendah",
  "sedang",
  "tinggi",
  "darurat",
]);

// ============================================================
// TENANTS (Multi-tenancy)
// ============================================================

export const tenants = pgTable(
  "tenants",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    slug: varchar("slug", { length: 100 }).notNull().unique(),
    namaResmi: text("nama_resmi").notNull(),
    tagline: text("tagline"),
    logoUrl: text("logo_url"),
    warnaPrimer: varchar("warna_primer", { length: 7 }),
    warnaAksen: varchar("warna_aksen", { length: 7 }),
    kontak: jsonb("kontak"),
    alamat: jsonb("alamat"),
    jamLayanan: jsonb("jam_layanan"),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    slugIdx: index("tenants_slug_idx").on(table.slug),
  }),
);

export const tenantsRelations = relations(tenants, ({ many }) => ({
  penduduk: many(penduduk),
  keluarga: many(keluarga),
  suratTerbit: many(suratTerbit),
  votingTopik: many(votingTopik),
  domainEvents: many(domainEvents),
}));

// ============================================================
// CORE DOMAIN: PENDUDUK (Single Source of Truth)
// ============================================================

export const keluarga = pgTable(
  "keluarga",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    noKk: text("no_kk").notNull().unique(),
    kepalaNama: text("kepala_nama"),
    alamat: text("alamat"),
    dusun: text("dusun"),
    rt: varchar("rt", { length: 3 }),
    rw: varchar("rw", { length: 3 }),
    statusKk: text("status_kk").default("aktif"),
    catatan: text("catatan"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    tenantIdx: index("keluarga_tenant_idx").on(table.tenantId),
    noKkIdx: unique("keluarga_no_kk_unique").on(table.noKk),
  }),
);

export const penduduk = pgTable(
  "penduduk",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    keluargaId: uuid("keluarga_id").references(() => keluarga.id),
    nik: text("nik").notNull().unique(),
    nama: text("nama").notNull(),
    jenisKelamin: text("jenis_kelamin"),
    tempatLahir: text("tempat_lahir"),
    tanggalLahir: date("tanggal_lahir"),
    agama: text("agama"),
    pendidikan: text("pendidikan"),
    pekerjaan: text("pekerjaan"),
    statusKawin: text("status_kawin"),
    hubunganKk: text("hubungan_kk"),
    dusun: text("dusun"),
    alamat: text("alamat"),
    fotoUrl: text("foto_url"),
    statusHidup: text("status_hidup").default("aktif"),
    bpjsStatus: text("bpjs_status"),
    bpjsNomor: text("bpjs_nomor"),
    rt: varchar("rt", { length: 3 }),
    rw: varchar("rw", { length: 3 }),
    nomorHp: text("nomor_hp"),
    createdBy: uuid("created_by"),
    updatedBy: uuid("updated_by"),
    catatan: text("catatan"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    tenantIdx: index("penduduk_tenant_idx").on(table.tenantId),
    nikIdx: unique("penduduk_nik_unique").on(table.nik),
    dusunIdx: index("penduduk_dusun_idx").on(table.dusun),
    keluargaIdx: index("penduduk_keluarga_idx").on(table.keluargaId),
    statusHidupIdx: index("penduduk_status_idx").on(table.statusHidup),
  }),
);

// ============================================================
// EVENT SOURCING
// ============================================================

export const domainEvents = pgTable(
  "domain_events",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    eventType: varchar("event_type", { length: 100 }).notNull(),
    entityType: varchar("entity_type", { length: 50 }).notNull(),
    entityId: uuid("entity_id").notNull(),
    payload: jsonb("payload").default({}),
    aktorId: uuid("aktor_id"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    processedAt: timestamp("processed_at", { withTimezone: true }),
  },
  (table) => ({
    unprocessedIdx: index("idx_domain_events_unprocessed")
      .on(table.createdAt)
      .where(table.processedAt.isNull()),
    entityIdx: index("idx_domain_events_entity").on(
      table.entityType,
      table.entityId,
      table.createdAt,
    ),
    typeIdx: index("idx_domain_events_type").on(
      table.eventType,
      table.createdAt,
    ),
  }),
);

// ============================================================
// SURAT
// ============================================================

export const suratTerbit = pgTable(
  "surat_terbit",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    jenis: text("jenis").notNull(),
    nomorSurat: text("nomor_surat"),
    pendudukId: uuid("penduduk_id").references(() => penduduk.id),
    status: text("status").default("diajukan"),
    tanggalTerbit: timestamp("tanggal_terbit", { withTimezone: true }),
    createBy: uuid("created_by"),
    updatedBy: uuid("updated_by"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    tenantIdx: index("surat_terbit_tenant_idx").on(table.tenantId),
  }),
);

// ============================================================
// VOTING & PARTISIPASI
// ============================================================

export const votingTopik = pgTable(
  "voting_topik",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    judul: text("judul").notNull(),
    deskripsi: text("deskripsi"),
    status: text("status").default("aktif"),
    mulai: timestamp("mulai", { withTimezone: true }),
    selesai: timestamp("selesai", { withTimezone: true }),
    createBy: uuid("created_by"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    tenantIdx: index("voting_topik_tenant_idx").on(table.tenantId),
    statusIdx: index("voting_topik_status_idx").on(table.status),
  }),
);

export const votingSuara = pgTable(
  "voting_suara",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    topikId: uuid("topik_id").references(() => votingTopik.id),
    opsiId: uuid("opsi_id").references(() => votingOpsi.id),
    pendudukId: uuid("penduduk_id").references(() => penduduk.id),
    votingToken: text("voting_token"),
    createBy: uuid("created_by"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    topikIdx: index("voting_suara_topik_idx").on(table.topikId),
    pendudukIdx: index("voting_suara_penduduk_idx").on(table.pendudukId),
  }),
);

export const votingOpsi = pgTable(
  "voting_opsi",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    topikId: uuid("topik_id").references(() => votingTopik.id),
    opsi: text("opsi").notNull(),
    jumlahSuara: integer("jumlah_suara").default(0),
    urutan: integer("urutan").default(0),
  },
  (table) => ({
    topikIdx: index("voting_opsi_topik_idx").on(table.topikId),
  }),
);

// ============================================================
// IDM
// ============================================================

export const idmIndicators = pgTable(
  "idm_indicators",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    dimensiNo: integer("dimensi_no").notNull(),
    dimensiNama: varchar("dimensi_nama", { length: 100 }).notNull(),
    subdimensiKode: varchar("subdimensi_kode", { length: 20 }),
    subdimensiNama: varchar("subdimensi_nama", { length: 100 }),
    indikatorNo: varchar("indikator_no", { length: 20 }).notNull(),
    indikatorNama: text("indikator_nama").notNull(),
    indikatorSkorMax: integer("indikator_skor_max").default(5),
    subIndikatorNo: varchar("sub_indikator_no", { length: 20 }),
    subIndikatorNama: text("sub_indikator_nama"),
    subSkorMax: integer("sub_skor_max"),
    sumberData: varchar("sumber_data", { length: 30 }).notNull(),
    kodeRekening: varchar("kode_rekening", { length: 50 }),
    rekomendasiIntervensi: text("rekomendasi_intervensi"),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    dimensiIdx: index("idm_indicators_dimensi_idx").on(
      table.dimensiNo,
      table.dimensiNama,
    ),
  }),
);

export const idmSkorCache = pgTable(
  "idm_skor_cache",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id")
      .references(() => tenants.id)
      .notNull(),
    indikatorId: uuid("indikator_id").references(() => idmIndicators.id),
    indikatorKode: varchar("indikator_kode", { length: 50 }).notNull(),
    dimensiNo: integer("dimensi_no").notNull(),
    dimensiNama: varchar("dimensi_nama", { length: 100 }).notNull(),
    skor: numeric("skor", { precision: 3, scale: 2 }).notNull(),
    nilaiAgregat: numeric("nilai_agregat").default(0),
    sumberData: varchar("sumber_data", { length: 30 }).notNull(),
    dihitungPada: timestamp("dihitung_pada", { withTimezone: true }).defaultNow(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    tenantIndikatorIdx: unique("idm_skor_cache_unique").on(
      table.tenantId,
      table.indikatorKode,
    ),
  }),
);

export const idmStatusDesa = pgTable(
  "idm_status_desa",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    tenantId: uuid("tenant_id")
      .references(() => tenants.id)
      .unique()
      .notNull(),
    totalSkor: numeric("total_skor", { precision: 5, scale: 4 }),
    status: text("status"),
    dimensiScores: jsonb("dimensi_scores").default({}),
    dimensiSkor1: numeric("dimensi_skor_1", { precision: 5, scale: 4 }),
    dimensiSkor2: numeric("dimensi_skor_2", { precision: 5, scale: 4 }),
    dimensiSkor3: numeric("dimensi_skor_3", { precision: 5, scale: 4 }),
    dimensiSkor4: numeric("dimensi_skor_4", { precision: 5, scale: 4 }),
    dimensiSkor5: numeric("dimensi_skor_5", { precision: 5, scale: 4 }),
    dimensiSkor6: numeric("dimensi_skor_6", { precision: 5, scale: 4 }),
    dihitungPada: timestamp("dihitung_pada", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    tenantIdx: unique("idm_status_desa_tenant_idx").on(table.tenantId),
  }),
);

// ============================================================
// ADMIN & AUTH
// ============================================================

export const adminProfiles = pgTable(
  "admin_profiles",
  {
    id: uuid("id").primaryKey(),
    nik: text("nik").notNull().unique(),
    nama: text("nama").notNull(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    nikIdx: unique("admin_profiles_nik_unique").on(table.nik),
  }),
);

export const userRoles = pgTable(
  "user_roles",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").notNull(),
    tenantId: uuid("tenant_id").references(() => tenants.id),
    peran: text("peran").notNull(),
    aktif: boolean("aktif").default(true),
    dusunId: uuid("dusun_id"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
  },
  (table) => ({
    userIdx: index("user_roles_user_idx").on(table.userId),
    tenantIdx: index("user_roles_tenant_idx").on(table.tenantId),
  }),
);

// ============================================================
// RELATIONS
// ============================================================

export const keluargaRelations = relations(keluarga, ({ one, many }) => ({
  tenant: one(tenants, {
    fields: [keluarga.tenantId],
    references: [tenants.id],
  }),
  anggota: many(penduduk),
}));

export const pendudukRelations = relations(penduduk, ({ one }) => ({
  tenant: one(tenants, {
    fields: [penduduk.tenantId],
    references: [tenants.id],
  }),
  keluarga: one(keluarga, {
    fields: [penduduk.keluargaId],
    references: [keluarga.id],
  }),
}));

export const votingTopikRelations = relations(votingTopik, ({ one, many }) => ({
  tenant: one(tenants, {
    fields: [votingTopik.tenantId],
    references: [tenants.id],
  }),
  opsi: many(votingOpsi),
  suara: many(votingSuara),
}));

export const votingOpsiRelations = relations(votingOpsi, ({ one, many }) => ({
  topik: one(votingTopik, {
    fields: [votingOpsi.topikId],
    references: [votingTopik.id],
  }),
  suara: many(votingSuara),
}));

export const votingSuaraRelations = relations(votingSuara, ({ one }) => ({
  tenant: one(tenants, {
    fields: [votingSuara.tenantId],
    references: [tenants.id],
  }),
  topik: one(votingTopik, {
    fields: [votingSuara.topikId],
    references: [votingTopik.id],
  }),
  opsi: one(votingOpsi, {
    fields: [votingSuara.opsiId],
    references: [votingOpsi.id],
  }),
  penduduk: one(penduduk, {
    fields: [votingSuara.pendudukId],
    references: [penduduk.id],
  }),
}));
