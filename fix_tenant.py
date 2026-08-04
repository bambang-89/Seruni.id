#!/usr/bin/env python3
"""Fix tenant_id filters in queries.ts using exact byte-level matching"""
import re

with open('src/seruni/lib/queries.ts', 'rb') as f:
    raw = f.read()

# We need to work with the file as bytes since it has CRLF and Unicode
data = raw.decode('utf-8')

changes = []

# Extract the exact status filter string from the file itself
idx = data.find('useUsulanPublik')
snippet = data[idx:idx+500]
arr_start = snippet.find('["diverifikasi')
arr_end = snippet.find('],"selesai"])', arr_start)
if arr_end < 0:
    arr_end = snippet.find('],\n      "selesai")', arr_start)
arr_end += len('],"selesai"])')
STATUS_ARRAY = snippet[arr_start:arr_end]
STATUS_FILTER = '.in("status", ' + STATUS_ARRAY

# Helper: extract function content
def get_func(name):
    pattern = f'export function {name}'
    idx = data.find(pattern)
    if idx < 0:
        return None
    # Find next export or section marker
    rest = data[idx:]
    candidates = [
        rest.find('\n\nexport function'),
        rest.find('\n\nexport type'),
        rest.find('\n\nexport const'),
        rest.find('\n// ===================='),
    ]
    candidates = [x+1 for x in candidates if x >= 0]
    end = min(candidates) if candidates else len(data)
    return data[idx:idx+end]

# Fix 1: useUsulanPublik
func = get_func('useUsulanPublik')
if func:
    new_func = func
    # Add tenantId decl
    if 'const tenantId = useTenantId' not in new_func:
        new_func = new_func.replace(
            'export function useUsulanPublik(reloadKey = 0) {\n  const [rows, setRows]',
            'export function useUsulanPublik(reloadKey = 0) {\n  const tenantId = useTenantId();\n  const [rows, setRows]'
        )
        changes.append('useUsulanPublik: added tenantId')
    # Restructure query chain
    # Pattern: .in("status", <arr>)\n      .order(...).limit(200)\n      .then(
    old_chain = STATUS_FILTER + '\n      .order("vote_count", { ascending: false }).limit(200)\n      .then(({ data }) => {'
    new_chain = STATUS_FILTER + ';\n    if (tenantId) q = q.eq("tenant_id", tenantId);\n    q.then(({ data }) => {'
    if old_chain in new_func:
        new_func = new_func.replace(old_chain, new_chain)
        changes.append('useUsulanPublik: restructured query chain')
    # Add let q = before supabase.from
    if 'let q = supabase' not in new_func:
        new_func = new_func.replace(
            '    setLoading(true);\n    supabase.from("usulan_warga").select("*")',
            '    setLoading(true);\n    let q = supabase.from("usulan_warga").select("*")'
        )
        changes.append('useUsulanPublik: added let q')
    # Fix deps
    if '}, [reloadKey]);' in new_func and 'tenantId]' not in new_func:
        new_func = new_func.replace('}, [reloadKey]);', '}, [reloadKey, tenantId]);')
        changes.append('useUsulanPublik: fixed deps')
    if new_func != func:
        data = data.replace(func, new_func, 1)

# Fix 2: useVotingTopikList
func = get_func('useVotingTopikList')
if func:
    new_func = func
    if 'const tenantId = useTenantId' not in new_func:
        new_func = new_func.replace(
            'export function useVotingTopikList(reloadKey = 0) {\n  const [rows, setRows]',
            'export function useVotingTopikList(reloadKey = 0) {\n  const tenantId = useTenantId();\n  const [rows, setRows]'
        )
        changes.append('useVotingTopikList: added tenantId')
    if 'let q = supabase' not in new_func:
        new_func = new_func.replace(
            '    supabase.from("voting_topik").select("*").eq("published", true)\n      .order("created_at", { ascending: false })\n      .then',
            '    let q = supabase.from("voting_topik").select("*").eq("published", true)\n      .order("created_at", { ascending: false });\n    if (tenantId) q = q.eq("tenant_id", tenantId);\n    q.then'
        )
        changes.append('useVotingTopikList: restructured query')
    if '}, [reloadKey]);' in new_func and 'tenantId]' not in new_func:
        new_func = new_func.replace('}, [reloadKey]);', '}, [reloadKey, tenantId]);')
        changes.append('useVotingTopikList: fixed deps')
    if new_func != func:
        data = data.replace(func, new_func, 1)

# Fix 3: useVotingTopikById
func = get_func('useVotingTopikById')
if func:
    new_func = func
    if 'const tenantId = useTenantId' not in new_func:
        new_func = new_func.replace(
            'export function useVotingTopikById(id?: string) {\n  const [data, setData]',
            'export function useVotingTopikById(id?: string) {\n  const tenantId = useTenantId();\n  const [data, setData]'
        )
        changes.append('useVotingTopikById: added tenantId')
    if 'let q = supabase' not in new_func:
        new_func = new_func.replace(
            '    supabase.from("voting_topik").select("*").eq("id", id).maybeSingle()\n      .then',
            '    let q = supabase.from("voting_topik").select("*").eq("id", id).maybeSingle();\n    if (tenantId) q = q.eq("tenant_id", tenantId);\n    q.then'
        )
        changes.append('useVotingTopikById: restructured query')
    if '}, [id]);' in new_func and 'tenantId]' not in new_func:
        new_func = new_func.replace('}, [id]);', '}, [id, tenantId]);')
        changes.append('useVotingTopikById: fixed deps')
    if new_func != func:
        data = data.replace(func, new_func, 1)

# Fix 4: useUsulanWargaById
func = get_func('useUsulanWargaById')
if func:
    new_func = func
    if 'const tenantId = useTenantId' not in new_func:
        new_func = new_func.replace(
            'export function useUsulanWargaById(id?: string) {\n  const [data, setData]',
            'export function useUsulanWargaById(id?: string) {\n  const tenantId = useTenantId();\n  const [data, setData]'
        )
        changes.append('useUsulanWargaById: added tenantId')
    if 'let q = supabase' not in new_func:
        new_func = new_func.replace(
            '    supabase.from("usulan_warga").select("*").eq("id", id).maybeSingle()\n      .then',
            '    let q = supabase.from("usulan_warga").select("*").eq("id", id).maybeSingle();\n    if (tenantId) q = q.eq("tenant_id", tenantId);\n    q.then'
        )
        changes.append('useUsulanWargaById: restructured query')
    if '}, [id]);' in new_func and 'tenantId]' not in new_func:
        new_func = new_func.replace('}, [id]);', '}, [id, tenantId]);')
        changes.append('useUsulanWargaById: fixed deps')
    if new_func != func:
        data = data.replace(func, new_func, 1)

# Fix 5: useUsulanStats
func = get_func('useUsulanStats')
if func:
    new_func = func
    if 'const tenantId = useTenantId' not in new_func:
        new_func = new_func.replace(
            'export function useUsulanStats() {\n  const [data, setData]',
            'export function useUsulanStats() {\n  const tenantId = useTenantId();\n  const [data, setData]'
        )
        changes.append('useUsulanStats: added tenantId')
    # Restructure Promise.all
    old_pa = f'''    Promise.all([
      supabase.from("usulan_warga").select("id, judul, vote_count").in("status", {STATUS_ARRAY}),
      supabase.from("usulan_vote").select("id"),
    ])'''
    new_pa = f'''    let qUsulan = supabase.from("usulan_warga").select("id, judul, vote_count").in("status", {STATUS_ARRAY});
    if (tenantId) qUsulan = qUsulan.eq("tenant_id", tenantId);
    let qVote = supabase.from("usulan_vote").select("id");
    if (tenantId) qVote = qVote.eq("tenant_id", tenantId);
    Promise.all([qUsulan, qVote])'''
    if old_pa in new_func:
        new_func = new_func.replace(old_pa, new_pa)
        changes.append('useUsulanStats: restructured Promise.all')
    if '}, []);' in new_func and 'tenantId]' not in new_func:
        new_func = new_func.replace('}, []);', '}, [tenantId]);')
        changes.append('useUsulanStats: fixed deps')
    if new_func != func:
        data = data.replace(func, new_func, 1)

for c in changes:
    print(f'  {c}')

with open('src/seruni/lib/queries.ts', 'w', encoding='utf-8') as f:
    f.write(data)
print(f'Total: {len(changes)} changes')
