const apikey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg';
(async () => {
  const res = await fetch('https://smngqdpbmgcdbmkiuviq.supabase.co/rest/v1/surat_jenis?select=*&limit=5', {
    headers: {
      apikey,
      Authorization: `Bearer ${apikey}`,
    }
  });
  console.log('Status:', res.status);
  console.log(await res.text());
})();
