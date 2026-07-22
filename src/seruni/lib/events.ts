// ============================================================
// EVENT TYPES - Domain Events System
// Prinsip: "Satu Input, Banyak Dampak"
// ============================================================

// Event types (sesuai enum di database)
export const EVENT_TYPES = {
  // Core Registry - Penduduk
  PENDUDUK_DIBUAT: 'penduduk.dibuat',
  PENDUDUK_DATA_BERUBAH: 'penduduk.data.berubah',
  PENDUDUK_STATUS_BERUBAH: 'penduduk.status.berubah',
  PENDUDUK_BPJS_BERUBAH: 'penduduk.bpjs.berubah',

  // Surat
  SURAT_DIAJUKAN: 'surat.diajukan',
  SURAT_DIVERIFIKASI: 'surat.diverifikasi',
  SURAT_DITOLAK: 'surat.ditolak',
  SURAT_DITANDATANGANI: 'surat.ditandatangani',
  SURAT_DITERBITKAN: 'surat.diterbitkan',
  SURAT_DIKIRIM: 'surat.dikirim',

  // Usulan & Voting
  USULAN_DIAJUKAN: 'usulan.diajukan',
  USULAN_LOLOS_VERIFIKASI: 'usulan.lolos_verifikasi',
  USULAN_DITOLAK: 'usulan.ditolak',
  USULAN_DITETAPKAN_RKPDES: 'usulan.ditetapkan_rkpdes',
  USULAN_VOTE_BERTAAMBAH: 'usulan.vote.bertambah',
  VOTING_DITUTUP: 'voting.ditutup',

  // PBB
  PBB_WAJIB_PAJAK_DAFTARKAN: 'pbb.wajib_pajak.didaftarkan',
  PBB_OBJEK_PAJAK_DAFTARKAN: 'pbb.objek_pajak.didaftarkan',
  PBB_OBJEK_PAJAK_BERUBAH: 'pbb.objek_pajak.berubah',
  PBB_TAGIHAN_DIBAYAR: 'pbb.tagihan.dibayar',

  // Keuangan
  APBDES_REALISASI_DICATAT: 'apbdes.realisasi.dicatat',
  APBDES_KEGIATAN_DISAHKAN: 'apbdes.kegiatan.disahkan',

  // Posyandu
  POSYANDU_KUNJUNGAN_DICATAT: 'posyandu.kunjungan.dicatat',
  POSYANDU_BALITA_TERINDIKASI_GIZI_BURUK: 'posyandu.balita.terindikasi_gizi_buruk',

  // Pertanahan
  BIDANG_TANAH_DAFTARKAN: 'bidang_tanah.didaftarkan',
  BIDANG_TANAH_DISAHKAN: 'bidang_tanah.disahkan',
  BIDANG_TANAH_DIALIHKAN: 'bidang_tanah.dialihkan',

  // Pemetaan
  INFRASTRUKTUR_DILAPORKAN: 'infrastruktur.dilaporkan',
  INFRASTRUKTUR_DIVERIFIKASI: 'infrastruktur.diverifikasi',

  // Musdes
  MUSDES_USULAN_DITETAPKAN: 'musdes.usulan.ditetapkan',
  MUSDES_JADWAL_DITETAPKAN: 'musdes.jadwal.ditetapkan',

  // WA
  WA_LAYANAN_SELESAI: 'wa.layanan.selesai',

  // Aset
  ASET_DIBUAT: 'aset.dibuat',
  ASET_DIVERIFIKASI: 'aset.diverifikasi',
  ASET_DISUSUTKAN: 'aset.disusutkan',
} as const;

export type EventType = typeof EVENT_TYPES[keyof typeof EVENT_TYPES];

// Event payload types
export interface BaseEventPayload {
  timestamp?: string;
  actor_id?: string;
  [key: string]: unknown;
}

export interface PendudukDibuatPayload extends BaseEventPayload {
  nik: string;
  nama: string;
  dusun?: string;
  rt?: string;
  rw?: string;
  jenis_kelamin?: 'L' | 'P';
  tanggal_lahir?: string;
}

export interface PendudukStatusBerubahPayload extends BaseEventPayload {
  field: 'status_hidup';
  lama: string;
  baru: string;
  nik: string;
}

export interface PendudukBpjsBerubahPayload extends BaseEventPayload {
  bpjs_status_lama?: string;
  bpjs_status_baru?: string;
  bpjs_nomor_baru?: string;
  nik: string;
}

export interface SuratDiterbitkanPayload extends BaseEventPayload {
  surat_id: string;
  jenis_surat: string;
  nomor_surat: string;
  pemohon_nik: string;
}

export interface PbbTagihanDibayarPayload extends BaseEventPayload {
  tagihan_id: string;
  objek_pajak_id: string;
  tahun_pajak: number;
  jumlah_bayar: number;
  wajib_pajak_id: string;
}

export interface PosyanduKunjunganDicatatPayload extends BaseEventPayload {
  kunjungan_id: string;
  balita_id: string;
  dusun: string;
  status_gizi?: string;
}

// Domain Event type
export interface DomainEvent<T = BaseEventPayload> {
  id: string;
  tenant_id: string | null;
  event_type: EventType;
  entity_type: string;
  entity_id: string;
  payload: T;
  aktor_id: string | null;
  created_at: string;
  processed_at: string | null;
}

// Event Publisher Function
export interface PublishEventOptions {
  eventType: EventType;
  entityType: string;
  entityId: string;
  payload?: Record<string, unknown>;
  actorId?: string;
}

// ============================================================
// HELPER: Format tanggal Indonesia
// ============================================================

export function formatTanggalIndonesia(date: string | Date): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}

// ============================================================
// HELPER: Cek eligibility berdasarkan status kependudukan
// ============================================================

export const STATUS_KEPENDUDUKAN = {
  AKTIF: 'aktif',
  PINDAH: 'pindah',
  MENINGGAL: 'meninggal',
} as const;

export type StatusKependudukan = typeof STATUS_KEPENDUDUKAN[keyof typeof STATUS_KEPENDUDUKAN];

export function isEligibleForVoting(status: StatusKependudukan): boolean {
  return status === STATUS_KEPENDUDUKAN.AKTIF;
}

export function isEligibleForSurat(status: StatusKependudukan): boolean {
  return status === STATUS_KEPENDUDUKAN.AKTIF;
}

export function isEligibleForPbb(status: StatusKependudukan | null): boolean {
  // Luar desa bisa punya objek pajak meskipun status bukan aktif
  return true; // Cek lebih spesifik di level aplikasi
}

// ============================================================
// HELPER: Mapping entity type ke event type
// ============================================================

export function getEventTypeForAction(entityType: string, action: string): EventType {
  const mapping: Record<string, Record<string, EventType>> = {
    penduduk: {
      create: EVENT_TYPES.PENDUDUK_DIBUAT,
      update: EVENT_TYPES.PENDUDUK_DATA_BERUBAH,
      status: EVENT_TYPES.PENDUDUK_STATUS_BERUBAH,
      bpjs: EVENT_TYPES.PENDUDUK_BPJS_BERUBAH,
    },
    surat: {
      submit: EVENT_TYPES.SURAT_DIAJUKAN,
      verify: EVENT_TYPES.SURAT_DIVERIFIKASI,
      reject: EVENT_TYPES.SURAT_DITOLAK,
      sign: EVENT_TYPES.SURAT_DITANDATANGANI,
      publish: EVENT_TYPES.SURAT_DITERBITKAN,
      send: EVENT_TYPES.SURAT_DIKIRIM,
    },
    pbb_tagihan: {
      pay: EVENT_TYPES.PBB_TAGIHAN_DIBAYAR,
    },
    posyandu_kunjungan: {
      create: EVENT_TYPES.POSYANDU_KUNJUNGAN_DICATAT,
    },
  };

  return mapping[entityType]?.[action] ?? EVENT_TYPES.PENDUDUK_DATA_BERUBAH;
}
