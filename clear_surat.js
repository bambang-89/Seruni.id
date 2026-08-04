const url = 'https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

async function clearTable(table) {
  const res = await fetch(`${url}/${table}?id=not.eq.00000000-0000-0000-0000-000000000000`, {
    method: 'DELETE',
    headers: {
      'apikey': serviceKey,
      'Authorization': `Bearer ${serviceKey}`,
      'Prefer': 'return=minimal'
    }
  });
  if (!res.ok) {
    console.error(`Failed to clear ${table}:`, await res.text());
  } else {
    console.log(`Cleared ${table}`);
  }
}

async function run() {
  console.log('Clearing surat data...');
  
  await clearTable('audit_surat_terbit');
  await clearTable('tte_signatures');
  await clearTable('surat_terbit_data');
  await clearTable('surat_terbit');
  await clearTable('surat_ajuan_data');
  await clearTable('surat_ajuan');
  
  console.log('Done!');
}

run().catch(console.error);
