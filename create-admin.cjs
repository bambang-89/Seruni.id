const https = require('https');

const AUTH_IPS = ['104.18.38.10', '172.64.149.246', '104.18.39.10'];
let currentIP = 0;

const PROJECT_REF = 'smmngqdpbmgcdbmkiuviq';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNtbmdxZHBibWdjZGJta2l1dmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ4NDk5MiwiZXhwIjoyMTAwMDYwOTkyfQ.ax7wYmOe1F9Aenr27yZQIJ1YeBXf2JbjCJDUqYJUfyQ';

console.log('='.repeat(50));
console.log('Setup Admin Seruni.id');
console.log('='.repeat(50));
console.log('NIK: 5203083004880003');
console.log('Nama: Bambang Nurdiansyah');
console.log('Password: Seruni88');
console.log('');

function request(ip, method, path, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const options = {
      hostname: ip,
      port: 443,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Host': `${PROJECT_REF}.supabase.co`,
        'Content-Length': data ? Buffer.byteLength(data) : 0
      }
    };

    const req = https.request(options, (res) => {
      let response = '';
      res.on('data', c => response += c);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(response) });
        } catch {
          resolve({ status: res.statusCode, data: response });
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

async function tryIP(ip) {
  console.log(`Trying IP: ${ip}...`);
  const result = await request(ip, 'POST', '/auth/v1/admin/users', {
    email: 'nik-5203083004880003@admin.seruni.local',
    password: 'Seruni88',
    email_confirm: true,
    user_metadata: {
      nik: '5203083004880003',
      nama: 'Bambang Nurdiansyah'
    }
  });
  return result;
}

async function main() {
  // Try each IP
  for (let i = 0; i < AUTH_IPS.length; i++) {
    try {
      const result = await tryIP(AUTH_IPS[i]);
      
      if (result.status === 200 || result.status === 201) {
        console.log('\n✓ SUCCESS! Admin user created!');
        console.log('User ID:', result.data.id);
        console.log('');
        console.log('='.repeat(50));
        console.log('AKUN SIAP DIGUNAKAN!');
        console.log('='.repeat(50));
        console.log('Login: http://localhost:8080/admin/login');
        console.log('NIK: 5203083004880003');
        console.log('Password: Seruni88');
        return;
      } else if (typeof result.data === 'string' && result.data.includes('already been registered')) {
        console.log('User already exists, getting ID...');
        // Get existing user
        const listResult = await request(AUTH_IPS[i], 'GET', '/auth/v1/admin/users');
        const user = listResult.data.users?.find(u => 
          u.email === 'nik-5203083004880003@admin.seruni.local'
        );
        if (user) {
          console.log('\n✓ User exists!');
          console.log('User ID:', user.id);
          console.log('');
          console.log('='.repeat(50));
          console.log('AKUN SIAP DIGUNAKAN!');
          console.log('='.repeat(50));
          console.log('Login: http://localhost:8080/admin/login');
          console.log('NIK: 5203083004880003');
          console.log('Password: Seruni88');
          return;
        }
      } else {
        console.log(`Status: ${result.status}, Error:`, result.data);
      }
    } catch (e) {
      console.log(`Failed: ${e.message}`);
    }
  }
  
  console.log('\n✗ All IPs failed.');
  console.log('Silakan buat user manual via Supabase Dashboard.');
}

main();
