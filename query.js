import 'dotenv/config';

async function main() {
  const res = await fetch(`${process.env.VITE_SUPABASE_URL}/rest/v1/tenants?select=*`, {
    headers: {
      "apikey": process.env.VITE_SUPABASE_PUBLISHABLE_KEY,
      "Authorization": `Bearer ${process.env.VITE_SUPABASE_PUBLISHABLE_KEY}`
    }
  });
  const data = await res.json();
  console.log("Tenants:", data);
}

main();
