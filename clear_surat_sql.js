const url = 'https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

async function executeSql(query) {
  const res = await fetch(`${url}/rpc/exec`, {
    method: 'POST',
    headers: {
      'apikey': serviceKey,
      'Authorization': `Bearer ${serviceKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ query })
  });
  
  if (!res.ok) {
    console.error(`Failed to execute SQL:`, await res.text());
  } else {
    console.log(`Executed SQL successfully`, await res.text());
  }
}

async function run() {
  console.log('Disabling triggers and clearing surat data...');
  
  const sql = `
    ALTER TABLE audit_surat_terbit DISABLE TRIGGER ALL;
    ALTER TABLE tte_signatures DISABLE TRIGGER ALL;
    ALTER TABLE surat_terbit_data DISABLE TRIGGER ALL;
    ALTER TABLE surat_terbit DISABLE TRIGGER ALL;
    ALTER TABLE surat_ajuan_data DISABLE TRIGGER ALL;
    ALTER TABLE surat_ajuan DISABLE TRIGGER ALL;

    DELETE FROM audit_surat_terbit;
    DELETE FROM tte_signatures;
    DELETE FROM surat_terbit_data;
    DELETE FROM surat_terbit;
    DELETE FROM surat_ajuan_data;
    DELETE FROM surat_ajuan;

    ALTER TABLE audit_surat_terbit ENABLE TRIGGER ALL;
    ALTER TABLE tte_signatures ENABLE TRIGGER ALL;
    ALTER TABLE surat_terbit_data ENABLE TRIGGER ALL;
    ALTER TABLE surat_terbit ENABLE TRIGGER ALL;
    ALTER TABLE surat_ajuan_data ENABLE TRIGGER ALL;
    ALTER TABLE surat_ajuan ENABLE TRIGGER ALL;
  `;
  
  await executeSql(sql);
  
  console.log('Done!');
}

run().catch(console.error);
