import { useState } from "react";
import { Link, Navigate, useNavigate } from "react-router-dom";
import { useAuth } from "../lib/auth";
import { siteSettings as seedSettings } from "../data";
import { useSiteSettings } from "../lib/zeroHardcode";

export default function InitAdminPage() {
  const { user, isAdmin, signUpFirstAdmin } = useAuth();
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
  const nav = useNavigate();
  const [nik, setNik] = useState("");
  const [nama, setNama] = useState("");
  const [password, setPassword] = useState("");
  const [password2, setPassword2] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  if (user && isAdmin) return <Navigate to="/admin" replace />;

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr(null);
    if (!/^\d{6,20}$/.test(nik.trim())) return setErr("NIK harus 6–20 digit angka.");
    if (nama.trim().length < 2) return setErr("Nama minimal 2 karakter.");
    if (password.length < 8) return setErr("Password minimal 8 karakter.");
    if (password !== password2) return setErr("Konfirmasi password tidak cocok.");
    setBusy(true);
    const { error } = await signUpFirstAdmin(nik.trim(), nama.trim(), password);
    setBusy(false);
    if (error) return setErr(error);
    nav("/admin", { replace: true });
  };

  return (
    <div className="min-h-screen grid place-items-center bg-secondary p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-6">
          <h1 className="font-display text-2xl font-bold text-foreground">Bootstrap Admin Pertama</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Hanya berlaku jika belum ada admin di sistem — {siteName}
          </p>
        </div>
        <form onSubmit={submit} className="rounded-xl bg-card border border-border p-6 space-y-4 shadow-sm">
          <div>
            <label className="block text-sm font-medium mb-1">NIK</label>
            <input value={nik} onChange={(e) => setNik(e.target.value.replace(/\D/g, ""))} maxLength={20} inputMode="numeric" required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Nama Lengkap</label>
            <input value={nama} onChange={(e) => setNama(e.target.value)} maxLength={100} required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Password (min 8)</label>
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Ulangi Password</label>
            <input type="password" value={password2} onChange={(e) => setPassword2(e.target.value)} required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
          </div>
          {err && <div className="rounded-md bg-destructive/10 border border-destructive/30 text-destructive text-sm px-3 py-2">{err}</div>}
          <button type="submit" disabled={busy} className="w-full rounded-md bg-primary text-primary-foreground font-medium py-2.5 text-sm hover:bg-primary/90 disabled:opacity-60">
            {busy ? "Memproses…" : "Buat Admin"}
          </button>
          <div className="text-center text-xs text-muted-foreground">
            <Link to="/admin/login" className="hover:text-primary">Sudah punya akun? Login</Link>
          </div>
        </form>
      </div>
    </div>
  );
}