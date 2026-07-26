import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://smngqdpbmgcdbmkiuviq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ'
);

(async () => {
  const { data, error } = await supabase.from('penduduk').upsert({
    nik: '5203083004880003',
    nama: 'Warga Ujicoba',
    nomor_hp: '087763170088',
    jenis_kelamin: 'L',
    agama: 'Islam',
    pekerjaan: 'Karyawan',
    status_hidup: 'hidup',
    tenant_id: 'd532ae95-0ad9-42bb-a6e8-5c840447c90e'
  }, { onConflict: 'nik' });
  console.log('Result:', { data, error });
})();
