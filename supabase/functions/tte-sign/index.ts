/**
 * TTE Sign Edge Function
 * Handles electronic signature (Tanda Tangan Elektronik) for surat
 *
 * Supports:
 * - Simple signature (development mode)
 * - BSRE eSign integration (production mode)
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, json } from "../_shared/cors.ts";

interface TTESignRequest {
  surat_id: string;
  document_hash: string;
  signer_name: string;
  signer_nip?: string;
  signer_role: string;
  signature_image_url?: string;
}

interface TTESignature {
  id: string;
  surat_id: string;
  tipe: 'sederhana' | 'bsre' | 'esign';
  status: 'pending' | 'signed' | 'verified' | 'expired' | 'rejected';
  signed_by: string;
  signed_at: string;
  signature_hash: string;
  certificate_id?: string;
  ttd_image_url?: string;
  qr_code_url?: string;
}

// BSRE API configuration (production)
const BSRE_API_URL = "https://api-esign.bsre.id";
const BSRE_API_KEY = Deno.env.get("BSRE_API_KEY") || "";
const TTE_MODE = Deno.env.get("TTE_MODE") || "sederhana"; // 'sederhana' | 'bsre'

/**
 * Generate verification QR code URL
 */
function generateVerificationQRUrl(signatureId: string): string {
  const baseUrl = Deno.env.get("PUBLIC_URL") || Deno.env.get("PUBLIC_DOMAIN") ? `https://${Deno.env.get("PUBLIC_DOMAIN") || "serunimumbul.id"}` : "https://serunimumbul.id";
  const qrData = `${baseUrl}/verify/${signatureId}`;
  return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(qrData)}`;
}

/**
 * Sign document with BSRE eSign (production mode)
 */
async function signWithBSRE(pdfBlob: ArrayBuffer, signerNIK: string): Promise<{
  signedDocumentUrl: string;
  signatureId: string;
  certificateId: string;
}> {
  if (!BSRE_API_KEY) {
    throw new Error("BSRE API key not configured");
  }

  // Step 1: Upload document
  const formData = new FormData();
  formData.append("file", new File([pdfBlob], "document.pdf", { type: "application/pdf" }));
  formData.append("nik", signerNIK);
  formData.append("tanggal", new Date().toISOString().split("T")[0]);
  formData.append("keterangan", "Dokumen ditandatangani secara elektronik oleh Pemerintah Desa Seruni Mumbul");

  const uploadResponse = await fetch(`${BSRE_API_URL}/v2.0/sign-doc/upload`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${BSRE_API_KEY}` },
    body: formData,
  });

  if (!uploadResponse.ok) {
    const error = await uploadResponse.text();
    throw new Error(`BSRE upload failed: ${error}`);
  }

  const uploadResult = await uploadResponse.json();
  const documentId = uploadResult.data?.document_id;

  if (!documentId) {
    throw new Error("Failed to get document ID from BSRE");
  }

  // Step 2: Request signature
  const signResponse = await fetch(`${BSRE_API_URL}/v2.0/sign-doc/request`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${BSRE_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      document_id: documentId,
      nik: signerNIK,
      ttd: "gambar",
      image抗日: true,
      halaman: "last",
      koordinat_x: 140,
      koordinat_y: 240,
      lebar: 30,
      tinggi: 15,
    }),
  });

  if (!signResponse.ok) {
    const error = await signResponse.text();
    throw new Error(`BSRE sign request failed: ${error}`);
  }

  const signResult = await signResponse.json();
  const signatureId = signResult.data?.signature_id;

  if (!signatureId) {
    throw new Error("Failed to get signature ID from BSRE");
  }

  // Step 3: Download signed document
  const downloadResponse = await fetch(`${BSRE_API_URL}/v2.0/sign-doc/download/${signatureId}`, {
    method: "GET",
    headers: { "Authorization": `Bearer ${BSRE_API_KEY}` },
  });

  if (!downloadResponse.ok) {
    throw new Error("Failed to download signed document from BSRE");
  }

  // Upload signed document to Supabase storage
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const signedPdfBlob = await downloadResponse.arrayBuffer();
  const timestamp = Date.now();
  const signedPath = `signed-surat/${signatureId}_${timestamp}.pdf`;

  const { data: uploadData, error: uploadError } = await supabase.storage
    .from("seruni-media")
    .upload(signedPath, signedPdfBlob, {
      contentType: "application/pdf",
      upsert: true,
    });

  if (uploadError) {
    throw new Error(`Failed to upload signed document: ${uploadError.message}`);
  }

  const { data: urlData } = supabase.storage
    .from("seruni-media")
    .getPublicUrl(uploadData.path);

  return {
    signedDocumentUrl: urlData.publicUrl,
    signatureId,
    certificateId: documentId,
  };
}

/**
 * Create simple signature (development mode)
 */
async function createSimpleSignature(
  supabase: ReturnType<typeof createClient>,
  request: TTESignRequest
): Promise<TTESignature> {
  const signatureId = crypto.randomUUID();
  const now = new Date().toISOString();
  const qrUrl = generateVerificationQRUrl(signatureId);

  // Create TTE signature record
  const { data, error } = await supabase
    .from("tte_signatures")
    .insert({
      id: signatureId,
      surat_id: request.surat_id,
      tipe: "sederhana",
      status: "signed",
      signed_by: request.signer_name,
      signed_at: now,
      signature_hash: request.document_hash,
      ttd_image_url: request.signature_image_url,
      qr_code_url: qrUrl,
      metadata: {
        signer_role: request.signer_role,
        signer_nip: request.signer_nip,
      },
    })
    .select()
    .single();

  if (error) {
    // If tte_signatures table doesn't exist, return a mock response
    if (error.code === "42P01") {
      console.warn("tte_signatures table not found, returning mock signature");
      return {
        id: signatureId,
        surat_id: request.surat_id,
        tipe: "sederhana",
        status: "signed",
        signed_by: request.signer_name,
        signed_at: now,
        signature_hash: request.document_hash,
        ttd_image_url: request.signature_image_url,
        qr_code_url: qrUrl,
      };
    }
    throw error;
  }

  return data;
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response(null, { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405, origin);

  const body = await req.json().catch(() => null) as TTESignRequest | null;

  if (!body) {
    return json({ error: "Invalid request body" }, 400, origin);
  }

  const { surat_id, document_hash, signer_name, signer_role } = body;

  if (!surat_id) return json({ error: "surat_id is required" }, 400, origin);
  if (!signer_name) return json({ error: "signer_name is required" }, 400, origin);
  if (!signer_role) return json({ error: "signer_role is required" }, 400, origin);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  try {
    let signature: TTESignature;

    if (TTE_MODE === "bsre" && body.signer_nip) {
      // BSRE mode: requires NIK from signer
      // First, get the PDF from surat_terbit
      const { data: surat } = await supabase
        .from("surat_terbit")
        .select("pdf_url:preview_url")
        .eq("id", surat_id)
        .single();

      if (!surat?.pdf_url) {
        return json({ error: "Surat PDF not found. Generate PDF first." }, 404, origin);
      }

      // Fetch PDF
      const pdfResponse = await fetch(surat.pdf_url);
      if (!pdfResponse.ok) {
        return json({ error: "Failed to fetch PDF" }, 500, origin);
      }
      const pdfBlob = await pdfResponse.arrayBuffer();

      // Sign with BSRE
      const bsreResult = await signWithBSRE(pdfBlob, body.signer_nip);

      // Create signature record
      const signatureId = crypto.randomUUID();
      const qrUrl = generateVerificationQRUrl(signatureId);

      const { data: sigData, error: sigError } = await supabase
        .from("tte_signatures")
        .insert({
          id: signatureId,
          surat_id,
          tipe: "bsre",
          status: "signed",
          signed_by: signer_name,
          signed_at: new Date().toISOString(),
          signature_hash: document_hash,
          certificate_id: bsreResult.certificateId,
          signed_pdf_url: bsreResult.signedDocumentUrl,
          qr_code_url: qrUrl,
          metadata: {
            signer_role,
            signer_nip: body.signer_nip,
            bsre_signature_id: bsreResult.signatureId,
          },
        })
        .select()
        .single();

      if (sigError && sigError.code !== "42P01") {
        throw sigError;
      }

      signature = sigData || {
        id: signatureId,
        surat_id,
        tipe: "bsre" as const,
        status: "signed" as const,
        signed_by: signer_name,
        signed_at: new Date().toISOString(),
        signature_hash: document_hash,
        certificate_id: bsreResult.certificateId,
        signed_pdf_url: bsreResult.signedDocumentUrl,
        qr_code_url: qrUrl,
      };

      // Update surat_terbit with signed PDF URL
      await supabase
        .from("surat_terbit")
        .update({
          tte_signature_id: signature.id,
          signed_pdf_url: bsreResult.signedDocumentUrl,
          status_preview: "signed",
          signed_at: new Date().toISOString(),
        })
        .eq("id", surat_id);
    } else {
      // Simple signature mode (development)
      signature = await createSimpleSignature(supabase, body);

      // Update surat_terbit
      await supabase
        .from("surat_terbit")
        .update({
          tte_signature_id: signature.id,
          qr_code_url: signature.qr_code_url,
          status_preview: "signed",
          signed_at: signature.signed_at,
        })
        .eq("id", surat_id);
    }

    // Log event
    await supabase.from("event_log").insert({
      event_name: "surat.ttd_signed",
      entitas: "surat_terbit",
      entitas_id: surat_id,
      payload: {
        signature_id: signature.id,
        signer_name,
        signer_role,
        tipe: signature.tipe,
      },
    });

    // Send WA notification to pemohon
    const fonnteToken = Deno.env.get("FONNTE_TOKEN");
    if (fonnteToken) {
      const { data: terbit } = await supabase
        .from("surat_terbit")
        .select("surat_ajuan_id")
        .eq("id", surat_id)
        .single();

      if (terbit?.surat_ajuan_id) {
        const { data: ajuan } = await supabase
          .from("surat_ajuan")
          .select("nama, kontak")
          .eq("id", terbit.surat_ajuan_id)
          .single();

        if (ajuan?.kontak) {
          const pesan = [
            `Yth. *${ajuan.nama}*,\n`,
            ``,
            `Surat Anda telah *DITANDATANGANI SECARA ELEKTRONIK*.\n`,
            `Silakan unduh di halaman Service Center:\n`,
            `https://${Deno.env.get("PUBLIC_DOMAIN") || "serunimumbul.id"}/service-center\n`,
            ``,
            `_Pesan otomatis dari Kantor Desa Seruni Mumbul_`,
          ].join("");

          // Fire-and-forget WA notification
          const norm = ajuan.kontak.replace(/\D/g, "");
          const target = norm.startsWith("0") ? "62" + norm.slice(1) : norm.startsWith("62") ? norm : "62" + norm;
          fetch("https://api.fonnte.com/send", {
            method: "POST",
            headers: { Authorization: fonnteToken, "Content-Type": "application/json" },
            body: JSON.stringify({ target, message: pesan }),
          }).catch(() => { /* non-fatal */ });
        }
      }
    }

    return json({
      ok: true,
      signature_id: signature.id,
      signed_pdf_url: (signature as unknown as Record<string, unknown>).signed_pdf_url,
      qr_code_url: signature.qr_code_url,
      status: signature.status,
      signed_at: signature.signed_at,
      message: `Surat berhasil ditandatangani secara elektronik sebagai ${signature.tipe}`,
    });
  } catch (err: unknown) {
    console.error("TTE signing error:", err);
    return json({ error: (err as Error).message || "TTE signing failed" }, 500, origin);
  }
});
