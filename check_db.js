import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://smngqdpbmgcdbmkiuviq.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0ODQ5OTIsImV4cCI6MjEwMDA2MDk5Mn0.zBzW539UwmYIxBNAmAmVt0wHA9NmIWsihd3oWf_MAMg'
);

async function run() {
  const { data, error } = await supabase.from('tenants').select('settings').limit(1);
  if (error) console.error("Error:", error);
  else {
    console.log("Settings value:", data[0]?.settings);
    console.log("Type:", typeof data[0]?.settings);
  }
}

run();
