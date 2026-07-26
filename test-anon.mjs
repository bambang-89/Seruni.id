import { createClient } from '@supabase/supabase-js';

const anonClient = createClient(
  'https://smngqdpbmgcdbmkiuviq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg'
);

(async () => {
  const { data, error } = await anonClient.from("penduduk").select("*").eq("nik", "5203083004880003").maybeSingle();
  console.log("Anon fetch:", { data, error });
})();
