#!/usr/bin/env node
// Script: apply-migration.mjs

import { readFileSync } from 'fs';

const SUPABASE_URL = 'https://smngqdpbmgcdbmkiuviq.supabase.co';
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';


// Statements to execute in order
const statements = [
  // 1. Fix kontak nullable
  `ALTER TABLE public.surat_ajuan ALTER COLUMN kontak DROP NOT NULL`,
  
  // 2. Ensure data_identitas column exists
  `DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'surat_ajuan_data' AND column_name = 'data_identitas'
    ) THEN
      ALTER TABLE public.surat_ajuan_data ADD COLUMN data_identitas JSONB NOT NULL DEFAULT '{}'::jsonb;
      RAISE NOTICE 'Column data_identitas added';
    ELSE
      RAISE NOTICE 'Column data_identitas already exists';
    END IF;
  END $$`,
  
  // 3. Enable RLS on surat_ajuan
  `ALTER TABLE public.surat_ajuan ENABLE ROW LEVEL SECURITY`,
  
  // 4. Policy: authenticated can read all surat_ajuan
  `DO $$
  BEGIN
    DROP POLICY IF EXISTS "surat_ajuan_admin_read" ON public.surat_ajuan;
    CREATE POLICY "surat_ajuan_admin_read"
      ON public.surat_ajuan FOR SELECT TO authenticated
      USING (true);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating read policy: %', SQLERRM;
  END $$`,
  
  // 5. Policy: authenticated can write surat_ajuan
  `DO $$
  BEGIN
    DROP POLICY IF EXISTS "surat_ajuan_admin_write" ON public.surat_ajuan;
    CREATE POLICY "surat_ajuan_admin_write"
      ON public.surat_ajuan FOR ALL TO authenticated
      USING (true) WITH CHECK (true);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating write policy: %', SQLERRM;
  END $$`,
  
  // 6. Grant
  `GRANT SELECT, UPDATE, DELETE ON public.surat_ajuan TO authenticated`,
  
  // 7. Enable RLS on surat_ajuan_data
  `ALTER TABLE public.surat_ajuan_data ENABLE ROW LEVEL SECURITY`,
  
  // 8. Policy: authenticated can read surat_ajuan_data
  `DO $$
  BEGIN
    DROP POLICY IF EXISTS "surat_ajuan_data_admin_read" ON public.surat_ajuan_data;
    CREATE POLICY "surat_ajuan_data_admin_read"
      ON public.surat_ajuan_data FOR SELECT TO authenticated
      USING (true);
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error creating data read policy: %', SQLERRM;
  END $$`,
  
  // 9. Grant surat_ajuan_data
  `GRANT SELECT ON public.surat_ajuan_data TO authenticated`,
  
  // 10. Update submit_surat_ajuan RPC
  `CREATE OR REPLACE FUNCTION public.submit_surat_ajuan(
    p_tenant_id UUID,
    p_nomor_tiket TEXT,
    p_nik TEXT,
    p_nama TEXT,
    p_kontak TEXT,
    p_jenis_surat_id UUID,
    p_keperluan TEXT,
    p_lampiran JSONB,
    p_data_dna JSONB,
    p_data_identitas JSONB
  )
  RETURNS JSONB
  LANGUAGE plpgsql
  SECURITY DEFINER
  AS $$
  DECLARE
    v_surat_id UUID;
  BEGIN
    INSERT INTO public.surat_ajuan (
      tenant_id, nomor_tiket, nik, nama, kontak,
      jenis_surat_id, keperluan, lampiran, status, created_at
    ) VALUES (
      p_tenant_id, p_nomor_tiket, p_nik, p_nama,
      NULLIF(TRIM(COALESCE(p_kontak, '')), ''),
      p_jenis_surat_id, p_keperluan,
      COALESCE(p_lampiran, '[]'::JSONB),
      'menunggu', NOW()
    ) RETURNING id INTO v_surat_id;

    IF p_data_dna IS NOT NULL OR p_data_identitas IS NOT NULL THEN
      INSERT INTO public.surat_ajuan_data (
        tenant_id, surat_ajuan_id, data_dna, data_identitas
      ) VALUES (
        p_tenant_id, v_surat_id,
        COALESCE(p_data_dna, '{}'::JSONB),
        COALESCE(p_data_identitas, '{}'::JSONB)
      )
      ON CONFLICT (surat_ajuan_id) DO UPDATE
        SET data_dna = EXCLUDED.data_dna,
            data_identitas = EXCLUDED.data_identitas,
            updated_at = NOW();
    END IF;

    BEGIN
      INSERT INTO public.event_log (event_name, entitas, entitas_id, payload)
      VALUES ('surat.diajukan', 'surat_ajuan', v_surat_id,
        jsonb_build_object('nik', p_nik, 'nomor_tiket', p_nomor_tiket));
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    RETURN jsonb_build_object('id', v_surat_id, 'nomor_tiket', p_nomor_tiket);
  END;
  $$`,
  
  `GRANT EXECUTE ON FUNCTION public.submit_surat_ajuan(UUID, TEXT, TEXT, TEXT, TEXT, UUID, TEXT, JSONB, JSONB, JSONB) TO anon, authenticated`,
];

async function applyStatements() {
  let success = 0;
  let failed = 0;
  
  for (let i = 0; i < statements.length; i++) {
    const stmt = statements[i].trim();
    console.log(`\n[${i + 1}/${statements.length}] Executing...`);
    console.log(stmt.substring(0, 80) + (stmt.length > 80 ? '...' : ''));
    
    try {
      // Use the rpc endpoint with a dummy function or try direct
      const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/exec_sql`, {
        method: 'POST',
        headers: {
          apikey: SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ sql: stmt })
      });
      
      const text = await res.text();
      
      if (res.status === 404 && text.includes('not found')) {
        console.log('  exec_sql RPC not available, skipping...');
        failed++;
      } else if (res.ok) {
        console.log('  ✓ Success');
        success++;
      } else {
        console.log('  ✗ Error:', text.substring(0, 200));
        failed++;
      }
    } catch (err) {
      console.log('  ✗ Exception:', err.message);
      failed++;
    }
  }
  
  console.log(`\n=== Results: ${success} success, ${failed} failed ===`);
  console.log('\nNote: If all failed with "exec_sql not found", please run the SQL manually in Supabase Dashboard:');
  console.log('https://supabase.com/dashboard/project/smngqdpbmgcdbmkiuviq/sql');
}

applyStatements().catch(console.error);
