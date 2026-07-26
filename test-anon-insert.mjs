import { createClient } from '@supabase/supabase-js';

const anonClient = createClient(
  'https://smngqdpbmgcdbmkiuviq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg'
);

(async () => {
  const { data, error } = await anonClient.from("surat_ajuan").insert({
    nik: "5203083004880003",
    nama: "Warga Ujicoba",
    kontak: "087763170088",
    keperluan: "Test insert from frontend",
    tenant_id: "d532ae95-0ad9-42bb-a6e8-5c840447c90e",
    nomor_tiket: "SRT-TESTING"
  });
  console.log("Anon insert:", { data, error });
})();
