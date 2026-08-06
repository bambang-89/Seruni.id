async function run() {
  // Check all surat_jenis to see what dna_template contains
  const url = "https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1/surat_jenis?select=id,nama,dna_field,dna_template&limit=10";
  const apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg";
  const res = await fetch(url, {
    headers: { "apikey": apiKey, "Authorization": `Bearer ${apiKey}` }
  });
  const data = await res.json();
  console.log("surat_jenis rows:");
  data.forEach(row => {
    console.log(`\n- ${row.nama}`);
    console.log(`  dna_field: ${JSON.stringify(row.dna_field)?.substring(0,100)}`);
    console.log(`  dna_template: ${JSON.stringify(row.dna_template)?.substring(0,100)}`);
  });

  // Also check surat_template table
  const url2 = "https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1/surat_template?select=*&limit=3";
  const res2 = await fetch(url2, {
    headers: { "apikey": apiKey, "Authorization": `Bearer ${apiKey}` }
  });
  const data2 = await res2.json();
  console.log("\n\nsurat_template rows:", data2.length ? Object.keys(data2[0]) : "empty or no access");
  data2.forEach(row => {
    console.log("\nTemplate:", JSON.stringify(row).substring(0,300));
  });

  // Check surat_ajuan_data structure  
  const url3 = "https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1/surat_ajuan_data?select=*&limit=1";
  const res3 = await fetch(url3, {
    headers: { "apikey": apiKey, "Authorization": `Bearer ${apiKey}` }
  });
  const data3 = await res3.json();
  console.log("\n\nsurat_ajuan_data sample:", JSON.stringify(data3, null, 2));
}
run();
