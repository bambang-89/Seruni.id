async function run() {
  const url = "https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1/surat_jenis?select=*&limit=1";
  const apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg";
  const res = await fetch(url, {
    headers: {
      "apikey": apiKey,
      "Authorization": `Bearer ${apiKey}`
    }
  });
  const data = await res.json();
  if (data.length > 0) {
    console.log("Columns in surat_jenis:", Object.keys(data[0]));
    console.log("Sample row:", JSON.stringify(data[0], null, 2));
  } else {
    console.log("No rows found:", data);
  }
}
run();
