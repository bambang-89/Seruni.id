// ============================================================
// WA CHATBOT — Supabase Edge Function
// Rule-based chatbot untuk layanan warga via WhatsApp
//
// Fitur:
// - Menu interaktif (menu numerik)
// - Cek status surat
// - Cek tagihan PBB
// - Cek voting aktif
// - Cek bantuan sosial
// - Cek data diri (NIK)
// - AI fallback (optional)
//
// Webhook Fonnte → POST /functions/v1/wa-chatbot
// ============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders } from "npm:@supabase/supabase-js@2/cors";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

// ============================================================
// TYPES
// ============================================================

interface ChatContext {
  session_id: string;
  nomor_wa: string;
  tenant_id: string;
  user_id?: string;
  user_nik?: string;
  last_menu?: number;
  state: string;
  step_data?: Record<string, string>;
  created_at: string;
  expires_at: string;
}

interface ChatMessage {
  from: string;
  text: string;
  id?: string;
  timestamp?: string;
}

interface ReplyPayload {
  to: string;
  message: string;
}

// ============================================================
// MENU DEFINITIONS
// ============================================================

const MAIN_MENU = `
🏘️ *PORTAL DESA SERUNI MUMBUL*

Selamat datang di layanan chatbot resmi Desa Seruni Mumbul!

Silakan pilih menu:

*1.* 📋 Cek Status Surat
*2.* 💰 Cek Tagihan PBB
*3.* 🗳️ Voting Aktif
*4.* 🎁 Bantuan Sosial
*5.* 👤 Cek Data Diri (NIK)
*6.* ℹ️ Info Desa
*7.* 📞 Hubungi Admin
*0.* 🏠 Menu Utama

Ketik nomor pilihan Anda.
`.trim();

const MENU_SURAT = `
📋 *LAYANAN SURAT*

Silakan pilih sub-menu:

*1.* 🔍 Lacak Surat
*2.* 📝 Jenis Surat
*3.* 📋 Syarat Surat
*0.* 🔙 Kembali
`.trim();

const MENU_PBB = `
💰 *LAYANAN PBB*

Silakan pilih sub-menu:

*1.* 🔍 Cek Tagihan
*2.* 📅 Jadwal Pembayaran
*3.* 📞 Hubungi Petugas
*0.* 🔙 Kembali
`.trim();

const MENU_VOTING = `
🗳️ *VOTING & PARTISIPASI*

Silakan pilih sub-menu:

*1.* 🗳️ Voting Aktif
*2.* 📊 Hasil Voting
*3.* 💡 Ajukan Usulan
*0.* 🔙 Kembali
`.trim();

const MENU_BANSOS = `
🎁 *BANTUAN SOSIAL*

Silakan pilih sub-menu:

*1.* 🔍 Cek Penerima
*2.* 📋 Program Aktif
*3.* 📝 Syarat Bantuan
*0.* 🔙 Kembali
`.trim();

const MENU_INFO = `
ℹ️ *INFO DESA*

*Kantor Desa Seruni Mumbul*
Kec. Pringgabaya
Kab. Lombok Timur, NTB

🕐 Jam Layanan:
Senin - Jumat: 08:00 - 15:00 WITA

📞 Kontak:
WhatsApp: 087763170088

🌐 Website:
https://seruni.id
`.trim();

// ============================================================
// SESSION MANAGEMENT
// ============================================================

const SESSION_TIMEOUT_MINUTES = 30;

async function getOrCreateSession(
  sb: ReturnType<typeof createClient>,
  nomorWa: string,
  tenantId: string,
): Promise<ChatContext> {
  // Try to find existing session
  const { data: existing } = await sb
    .from("wa_chatbot_session")
    .select("*")
    .eq("nomor_wa", nomorWa)
    .eq("tenant_id", tenantId)
    .eq("state", "!=", "expired")
    .single();

  if (existing) {
    const expiresAt = new Date(existing.expires_at);
    if (expiresAt > new Date()) {
      // Return existing session
      return existing as unknown as ChatContext;
    } else {
      // Mark as expired
      await sb
        .from("wa_chatbot_session")
        .update({ state: "expired" })
        .eq("id", existing.id);
    }
  }

  // Create new session
  const now = new Date();
  const expires = new Date(now.getTime() + SESSION_TIMEOUT_MINUTES * 60 * 1000);

  const { data: newSession, error } = await sb
    .from("wa_chatbot_session")
    .insert({
      session_id: `session-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      nomor_wa: nomorWa,
      tenant_id: tenantId,
      state: "main_menu",
      expires_at: expires.toISOString(),
    })
    .select()
    .single();

  if (error || !newSession) {
    throw new Error("Gagal membuat sesi chat");
  }

  return newSession as unknown as ChatContext;
}

async function updateSession(
  sb: ReturnType<typeof createClient>,
  sessionId: string,
  updates: Partial<ChatContext>,
) {
  const expires = new Date(Date.now() + SESSION_TIMEOUT_MINUTES * 60 * 1000);
  await sb
    .from("wa_chatbot_session")
    .update({
      ...updates,
      expires_at: expires.toISOString(),
    })
    .eq("session_id", sessionId);
}

// ============================================================
// LOGIC HANDLERS
// ============================================================

async function handleCekSurat(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<string> {
  if (input === "1") {
    // Lacak Surat
    await updateSession(sb, session.session_id, {
      state: "lacak_surat",
      last_menu: 1,
    });
    return `📮 *Lacak Surat*

Masukkan *Nomor Surat* atau *NIK pemohon*:

Contoh: SRN-202601-0001
       atau: 5201011234560001
`;
  }

  if (input === "2") {
    // Jenis Surat
    const { data: jenis } = await sb
      .from("surat_jenis")
      .select("kode:kode_surat, nama, deskripsi")
      .eq("aktif", true)
      .limit(10);

    if (!jenis?.length) {
      return "Maaf, belum ada jenis surat yang tersedia.";
    }

    let reply = `📝 *JENIS SURAT TERSEDIA*\n\n`;
    jenis.forEach((j: any, i: number) => {
      reply += `${i + 1}. ${j.nama}\n   Kode: ${j.kode}\n`;
    });
    reply += `\n\nHubungi admin untuk informasi lengkap.`;
    return reply;
  }

  return "Pilihan tidak valid. Ketik *1*, *2*, atau *0*.";
}

async function handleLacakSurat(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<{ reply: string; done: boolean }> {
  // Simple search by nomor_surat or NIK
  const searchTerm = input.trim();

  const { data: surat } = await sb
    .from("surat_terbit")
    .select(`
      id, nomor_surat, jenis, status, tanggal_terbit,
      penduduk:penduduk_id (nama, nik)
    `)
    .or(`nomor_surat.ilike.%${searchTerm}%,penduduk.nik.ilike.%${searchTerm}%`)
    .eq("tenant_id", session.tenant_id)
    .order("created_at", { ascending: false })
    .limit(1)
    .single();

  if (!surat) {
    return {
      reply: `❌ Surat tidak ditemukan.\n\nCoba lagi dengan nomor surat atau NIK yang benar.\n\nKetik *0* untuk kembali.`,
      done: false,
    };
  }

  const statusEmoji: Record<string, string> = {
    diajukan: "📝",
    diverifikasi: "✅",
    ditandatangani: "✍️",
    diterbitkan: "📜",
    dikirim: "📬",
    ditolak: "❌",
  };

  const emoji = statusEmoji[surat.status] || "📋";
  const date = surat.tanggal_terbit
    ? new Date(surat.tanggal_terbit).toLocaleDateString("id-ID")
    : "-";

  return {
    reply: `${emoji} *STATUS SURAT*

📄 Nomor: ${surat.nomor_surat}
📋 Jenis: ${surat.jenis}
📊 Status: ${surat.status.toUpperCase()}
📅 Tanggal: ${date}

Ketik *0* untuk menu utama.`,
    done: true,
  };
}

async function handleCekPBB(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<string> {
  if (input === "1") {
    // Cek Tagihan
    await updateSession(sb, session.session_id, {
      state: "lacak_pbb",
      last_menu: 2,
    });
    return `🏠 *Cek Tagihan PBB*

Masukkan *NOP* (Nomor Objek Pajak) atau *NIK WP*:

Contoh: 52.02.010.001.001-0000.0
       atau: 5201011234560001
`;
  }

  if (input === "2") {
    return `📅 *JADWAL PEMBAYARAN PBB*

💰 Jatuh Tempo: 31 Mei setiap tahun
📍 Tempat: Kantor Desa / Bank NTT

⚠️ Denda 2% per bulan jika telat.

Ketik *0* untuk kembali.`;
  }

  return "Pilihan tidak valid. Ketik *1*, *2*, atau *0*.";
}

async function handleLacakPBB(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<{ reply: string; done: boolean }> {
  const searchTerm = input.trim();

  const { data: tagihan } = await sb
    .from("pbb_tagihan")
    .select(`
      id, nop, tahun, tagihan:pbb_terutang, jatuh_tempo, status_pembayaran:status_bayar
    `)
    .or(`nop.ilike.%${searchTerm}%,wajib_pajak_nik.ilike.%${searchTerm}%`)
    .eq("tenant_id", session.tenant_id)
    .order("tahun", { ascending: false })
    .limit(1)
    .single();

  if (!tagihan) {
    return {
      reply: `❌ Tagihan tidak ditemukan.\n\nCoba lagi dengan NOP atau NIK yang benar.\n\nKetik *0* untuk kembali.`,
      done: false,
    };
  }

  const isLunas = tagihan.status_pembayaran === "lunas";
  const emoji = isLunas ? "✅" : "⏳";

  return {
    reply: `${emoji} *TAGIHAN PBB*

🏠 NOP: ${tagihan.nop}
📍 Lokasi: ${tagihan.alamat_objek || "-"}
📅 Tahun: ${tagihan.tahun}
💵 Tagihan: Rp ${(tagihan.tagihan ?? 0).toLocaleString("id-ID")}
📊 Status: ${isLunas ? "LUNAS ✅" : "BELUM LUNAS ⏳"}

Ketik *0* untuk menu utama.`,
    done: true,
  };
}

async function handleVoting(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<string> {
  if (input === "1") {
    // Voting Aktif
    const { data: voting } = await sb
      .from("voting_topik")
      .select(`
        id, judul, deskripsi, status, mulai, selesai,
        voting_opsi (id, opsi, jumlah_suara)
      `)
      .eq("tenant_id", session.tenant_id)
      .eq("status", "aktif")
      .order("mulai", { ascending: false })
      .limit(5);

    if (!voting?.length) {
      return `🗳️ *TIDAK ADA VOTING AKTIF*

Saat ini tidak ada voting atau survei yang sedang berlangsung.

Silakan pantau terus informasi desa kami!

Ketik *0* untuk kembali.`;
    }

    let reply = `🗳️ *VOTING AKTIF*\n\n`;
    voting.forEach((v: any, i: number) => {
      reply += `*${i + 1}.* ${v.judul}\n`;
      reply += `   ${v.deskripsi?.slice(0, 50) || ""}...\n`;
      reply += `   📊 Suara: ${v.voting_opsi?.reduce((s: number, o: any) => s + (o.jumlah_suara ?? 0), 0) || 0}\n\n`;
    });
    reply += `Kunjungi website kami untuk voting!`;
    return reply;
  }

  if (input === "2") {
    // Hasil Voting
    const { data: voting } = await sb
      .from("voting_topik")
      .select(`
        id, judul, status, hasil_ringkasan, hasil_pemenang_id,
        voting_opsi (id, opsi, jumlah_suara)
      `)
      .eq("tenant_id", session.tenant_id)
      .eq("status", "ditutup")
      .order("hasil_dipublikasi_pada", { ascending: false })
      .limit(5);

    if (!voting?.length) {
      return "Belum ada hasil voting yang dipublikasikan.";
    }

    let reply = `📊 *HASIL VOTING*\n\n`;
    voting.forEach((v: any, i: number) => {
      const totalSuara = v.voting_opsi?.reduce((s: number, o: any) => s + (o.jumlah_suara ?? 0), 0) || 0;
      reply += `*${v.judul}*\n`;
      reply += `   Total Suara: ${totalSuara}\n`;
      if (v.hasil_ringkasan) {
        reply += `   📝 ${v.hasil_ringkasan}\n`;
      }
      reply += "\n";
    });
    return reply;
  }

  return "Pilihan tidak valid. Ketik *1*, *2*, atau *0*.";
}

async function handleBansos(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<string> {
  if (input === "1") {
    // Cek Penerima
    await updateSession(sb, session.session_id, {
      state: "lacak_bansos",
      last_menu: 4,
    });
    return `🎁 *Cek Penerima Bantuan*

Masukkan *NIK* untuk cek status penerima:

Contoh: 5201011234560001
`;
  }

  if (input === "2") {
    // Program Aktif
    const { data: program } = await sb
      .from("bantuan_sosial")
      .select("nama_program:nama, jenis_bantuan:sumber, periode_mulai, status:aktif")
      .eq("tenant_id", session.tenant_id)
      .eq("aktif", true)
      .order("periode_mulai", { ascending: false })
      .limit(5);

    if (!program?.length) {
      return "Belum ada program bantuan sosial aktif.";
    }

    let reply = `📋 *PROGRAM BANTUAN AKTIF*\n\n`;
    program.forEach((p: Record<string, unknown>, i: number) => {
      const tahun = p.periode_mulai ? new Date(p.periode_mulai as string).getFullYear() : "-";
      reply += `*${i + 1}.* ${p.nama_program as string}\n`;
      reply += `   Jenis: ${p.jenis_bantuan as string}\n`;
      reply += `   Tahun: ${tahun}\n\n`;
    });
    return reply;
  }

  return "Pilihan tidak valid. Ketik *1*, *2*, atau *0*.";
}

async function handleLacakBansos(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<{ reply: string; done: boolean }> {
  const nik = input.trim();

  const { data: penerima } = await sb
    .from("penerima_bansos")
    .select(`
      id, status, keluarga_id,
      bantuan_sosial:bantuan_id (nama_program, jenis_bantuan),
      keluarga:keluarga_id (no_kk)
    `)
    .eq("tenant_id", session.tenant_id)
    .single();

  // Also try by NIK lookup via penduduk
  if (!penerima) {
    const { data: pend } = await sb
      .from("penduduk")
      .select("id, keluarga_id")
      .eq("nik", nik)
      .single();

    if (pend?.keluarga_id) {
      const { data: byKeluarga } = await sb
        .from("penerima_bansos")
        .select(`
          id, status,
          bantuan_sosial:bantuan_id (nama_program, jenis_bantuan)
        `)
        .eq("tenant_id", session.tenant_id)
        .eq("keluarga_id", pend.keluarga_id)
        .single();

      if (byKeluarga) {
        return {
          reply: `🎁 *STATUS BANTUAN SOSIAL*

📋 Program: ${byKeluarga.bantuan_sosial?.nama_program || "-"}
📊 Status: ${byKeluarga.status || "-"}

*Catatan:*
Penerima bantuan ditentukan berdasarkan DTKS dan verifikasi RT/RW.

Hubungi Kantor Desa untuk informasi lebih lanjut.

Ketik *0* untuk menu utama.`,
          done: true,
        };
      }
    }
  }

  return {
    reply: `❌ Data tidak ditemukan.

NIK yang Anda masukkan belum terdaftar sebagai penerima bantuan.

Hubungi Kantor Desa untuk info lebih lanjut.

Ketik *0* untuk menu utama.`,
    done: true,
  };
}

async function handleCekDataDiri(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<string> {
  if (!input) {
    await updateSession(sb, session.session_id, {
      state: "cek_data_nik",
    });
    return `👤 *CEK DATA DIRI*

Masukkan *NIK* Anda (16 digit):

Contoh: 5201011234560001
`;
  }

  // Lookup by NIK
  const { data: pend } = await sb
    .from("penduduk")
    .select(`
      id, nik, nama, tempat_lahir, tanggal_lahir,
      jenis_kelamin, alamat, dusun, rt, rw
    `)
    .eq("nik", input.trim())
    .single();

  if (!pend) {
    return `❌ *DATA TIDAK DITEMUKAN*

NIK yang Anda masukkan tidak ditemukan dalam database kami.

Pastikan NIK yang dimasukkan benar (16 digit).

Hubungi Kantor Desa jika ada kesalahan data.

Ketik *0* untuk menu utama.`;
  }

  return `👤 *DATA PENDUDUK (VERIFIKASI)*

📛 Nama: ${pend.nama}
📍 Status Kependudukan: ${pend.status_hidup === "hidup" ? "✅ Aktif" : pend.status_hidup === "meninggal" ? "⚰️ Meninggal" : "📦 Pindah"}
📍 Wilayah: ${pend.dusun || "-"} RT ${pend.rt || "-"} RW ${pend.rw || "-"}

⚠️ *Data lengkap hanya bisa dilihat di Kantor Desa Seruni Mumbul.*

Hubungi kami di WA: 087763170088

Ketik *0* untuk menu utama.`;
}

// ============================================================
// MAIN ROUTER
// ============================================================

async function handleMessage(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  text: string,
): Promise<string> {
  const input = text.trim().toLowerCase();
  const state = session.state;

  // Reset to main menu
  if (input === "menu" || input === "0") {
    await updateSession(sb, session.session_id, { state: "main_menu", last_menu: undefined });
    return MAIN_MENU;
  }

  // Back to parent menu
  if (input === "00" || input === "kembali") {
    const parentState: Record<string, string> = {
      lacak_surat: "surat",
      lacak_pbb: "pbb",
      lacak_bansos: "bansos",
      cek_data_nik: "main_menu",
    };
    const newState = parentState[state] || "main_menu";
    await updateSession(sb, session.session_id, { state: newState });
    return getMenuForState(newState);
  }

  // Route based on state
  switch (state) {
    case "main_menu":
    case "":
    case undefined:
      return await handleMainMenu(sb, session, input);

    case "surat":
      return handleCekSurat(sb, session, input);

    case "lacak_surat": {
      const result = await handleLacakSurat(sb, session, input);
      if (result.done) {
        await updateSession(sb, session.session_id, { state: "main_menu" });
      }
      return result.reply;
    }

    case "pbb":
      return handleCekPBB(sb, session, input);

    case "lacak_pbb": {
      const result = await handleLacakPBB(sb, session, input);
      if (result.done) {
        await updateSession(sb, session.session_id, { state: "main_menu" });
      }
      return result.reply;
    }

    case "voting":
      return handleVoting(sb, session, input);

    case "bansos":
      return handleBansos(sb, session, input);

    case "lacak_bansos": {
      const result = await handleLacakBansos(sb, session, input);
      if (result.done) {
        await updateSession(sb, session.session_id, { state: "main_menu" });
      }
      return result.reply;
    }

    case "cek_data_nik":
      return handleCekDataDiri(sb, session, input);

    case "info":
      return MENU_INFO;

    default:
      await updateSession(sb, session.session_id, { state: "main_menu" });
      return MAIN_MENU;
  }
}

async function handleMainMenu(
  sb: ReturnType<typeof createClient>,
  session: ChatContext,
  input: string,
): Promise<string> {
  switch (input) {
    case "1":
      await updateSession(sb, session.session_id, { state: "surat" });
      return MENU_SURAT;
    case "2":
      await updateSession(sb, session.session_id, { state: "pbb" });
      return MENU_PBB;
    case "3":
      await updateSession(sb, session.session_id, { state: "voting" });
      return MENU_VOTING;
    case "4":
      await updateSession(sb, session.session_id, { state: "bansos" });
      return MENU_BANSOS;
    case "5":
      // Cek Data Diri — langsung minta NIK
      return handleCekDataDiri(sb, session, "");
    case "6":
      await updateSession(sb, session.session_id, { state: "info" });
      return MENU_INFO;
    case "7":
      return `📞 *KONTAK ADMIN*

Hubungi kami:

📱 WhatsApp: 087763170088
📧 Email: admin@seruni.id
🏠 Kantor: Jl. Desa Seruni, Lombok Timur
`;
    default:
      return `Maaf, saya tidak memahami pilihan Anda.\n\n${MAIN_MENU}`;
  }
}

function getMenuForState(state: string): string {
  const menus: Record<string, string> = {
    main_menu: MAIN_MENU,
    surat: MENU_SURAT,
    pbb: MENU_PBB,
    voting: MENU_VOTING,
    bansos: MENU_BANSOS,
    info: MENU_INFO,
  };
  return menus[state] || MAIN_MENU;
}

// ============================================================
// FONNTE WEBHOOK HANDLER
// ============================================================

async function handleFonnteWebhook(
  req: Request,
  sb: ReturnType<typeof createClient>,
  fonnteToken: string,
): Promise<Response> {
  const body = await req.json();

  // Fonnte webhook format
  const message: ChatMessage = {
    from: body.from || body.phone || "",
    text: body.text || body.message || "",
    id: body.id,
    timestamp: body.timestamp,
  };

  if (!message.from || !message.text) {
    return json({ error: "Invalid webhook payload" }, 400);
  }

  // Normalize phone number
  const nomorWa = normalizeNomor(message.from);

  // Get tenant (first tenant for now, multi-tenant will use domain mapping)
  const { data: tenant } = await sb
    .from("tenants")
    .select("id")
    .limit(1)
    .single();

  if (!tenant) {
    return json({ error: "Tenant not found" }, 404);
  }

  // Get or create session
  const session = await getOrCreateSession(sb, nomorWa, tenant.id);

  // Handle message
  const replyText = await handleMessage(sb, session, message.text);

  // Save conversation
  await sb.from("wa_chatbot_conversation").insert({
    session_id: session.session_id,
    nomor_wa: nomorWa,
    tenant_id: tenant.id,
    direction: "incoming",
    message: message.text,
    user_id: session.user_id,
  });

  // Send reply via Fonnte
  if (!fonnteToken) {
    // Log only in dry-run mode
    await sb.from("wa_chatbot_conversation").insert({
      session_id: session.session_id,
      nomor_wa: nomorWa,
      tenant_id: tenant.id,
      direction: "outgoing",
      message: replyText,
    });
    return json({ success: true, reply: replyText, dry_run: true });
  }

  // Send actual reply
  const sent = await sendFonnte(fonnteToken, nomorWa, replyText);

  await sb.from("wa_chatbot_conversation").insert({
    session_id: session.session_id,
    nomor_wa: nomorWa,
    tenant_id: tenant.id,
    direction: "outgoing",
    message: replyText,
    sent_status: sent.ok ? "sukses" : "gagal",
    sent_response: sent.response,
  });

  return json({ success: true, reply: replyText, sent: sent.ok });
}

async function sendFonnte(token: string, nomor: string, message: string) {
  try {
    const res = await fetch("https://api.fonnte.com/send", {
      method: "POST",
      headers: {
        Authorization: token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ target: nomor, message }),
    });
    const data = await res.json().catch(() => ({}));
    return { ok: res.ok && (data?.status === true), response: data };
  } catch (e: unknown) {
    return { ok: false, response: { error: (e as Error)?.message } };
  }
}

function normalizeNomor(v: string): string {
  return String(v).replace(/[^0-9]/g, "").replace(/^0/, "62");
}

// ============================================================
// MAIN HANDLER
// ============================================================

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const sb = createClient(supabaseUrl, serviceKey);
  const fonnteToken = Deno.env.get("FONNTE_TOKEN");

  // Handle Fonnte webhook
  if (req.method === "POST") {
    return handleFonnteWebhook(req, sb, fonnteToken || "");
  }

  // Handle test / health check
  if (req.method === "GET") {
    return json({
      status: "ok",
      chatbot: "active",
      features: [
        "Cek Status Surat",
        "Cek Tagihan PBB",
        "Voting Aktif",
        "Cek Bantuan Sosial",
        "Cek Data Diri",
        "Info Desa",
      ],
    });
  }

  return json({ error: "Method not allowed" }, 405);
});
