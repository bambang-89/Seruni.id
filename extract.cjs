const fs = require('fs');
const content = fs.readFileSync('supabase/migrations/20260720000003_008_append_only_audit_trail.sql', 'utf8');

const regex = /CREATE OR REPLACE FUNCTION public\.(enforce_append_only_surat|log_surat_insert|enforce_append_only_voting_suara|enforce_append_only_voting_topik|enforce_append_only_usulan_vote|enforce_append_only_apbdes|enforce_append_only_bidang_tanah)[\s\S]*?END;\s*\$\$;/g;

let matches;
let out = '';
while ((matches = regex.exec(content)) !== null) {
  out += matches[0] + '\n\n';
}

out = out.replace(/\(SELECT tenant_id FROM tenants LIMIT 1\)/g, '(SELECT id FROM tenants LIMIT 1)');

fs.writeFileSync('supabase/migrations/20260731000002_fix_audit_triggers.sql', out);
console.log('done');
