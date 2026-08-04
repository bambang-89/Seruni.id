-- Add missing columns from previous steps
ALTER TABLE site_settings ADD COLUMN IF NOT EXISTS singkatan_desa TEXT;
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS fonnte_token TEXT;

-- Create ref_dusun table
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
    nama TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create ref_rt table
CREATE TABLE IF NOT EXISTS ref_rt (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    dusun_id UUID REFERENCES ref_dusun(id) ON DELETE CASCADE,
    nomor TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create ref_rw table (opsional jika dibutuhkan, biasanya digabung dengan RT atau level di atas RT)
CREATE TABLE IF NOT EXISTS ref_rw (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    dusun_id UUID REFERENCES ref_dusun(id) ON DELETE CASCADE,
    nomor TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add RLS Policies
ALTER TABLE ref_dusun ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_rt ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_rw ENABLE ROW LEVEL SECURITY;

-- Allow public read access (or authenticated)
CREATE POLICY "Enable read access for all users" ON ref_dusun FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON ref_dusun FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for authenticated users" ON ref_dusun FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for authenticated users" ON ref_dusun FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable read access for all users" ON ref_rt FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON ref_rt FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for authenticated users" ON ref_rt FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for authenticated users" ON ref_rt FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable read access for all users" ON ref_rw FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON ref_rw FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for authenticated users" ON ref_rw FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for authenticated users" ON ref_rw FOR DELETE USING (auth.role() = 'authenticated');

-- Modify penduduk to reference the ref tables or we can keep it as TEXT for now to not break existing data.
-- But the plan says "Mengganti input manual teks <input> pada RT dan RW menjadi <RefSelect> atau dropdown".
-- It means we just use the ref_dusun/rt/rw names to populate the dropdowns, so the `penduduk` table doesn't necessarily need schema changes. It can still store the text values, but they are selected from the dropdown!

NOTIFY pgrst, 'reload schema';
