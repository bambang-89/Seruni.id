import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://smngqdpbmgcdbmkiuviq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ'
);

(async () => {
  const { data, error } = await supabase.rpc('execute_sql', { sql: `
    SELECT polname, polcmd, polroles, polqual
    FROM pg_policy
    WHERE polrelid = 'penduduk'::regclass;
  `});
  if (error) {
    console.error("RPC Error:", error);
  } else {
    console.log("Policies:", data);
  }
})();
