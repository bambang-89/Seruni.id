async function run() {
  const url = "https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1/surat_ajuan?select=*&limit=1&order=created_at.desc";
  const apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg";
  const res = await fetch(url, {
    headers: {
      "apikey": apiKey,
      "Authorization": `Bearer ${apiKey}`
    }
  });
  const data = await res.json();
  console.log("Data surat_ajuan:", JSON.stringify(data, null, 2));
}
run();
