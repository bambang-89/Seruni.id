import { useState } from "react";
import { Link, Navigate, useNavigate } from "react-router-dom";
import { useAuth } from "../lib/auth";

import { useSiteSettings } from "../lib/zeroHardcode";
import { StandaloneLayout } from "../ui";

export default function InitAdminPage() {
  const { user, isAdmin, signUpFirstAdmin } = useAuth();
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? "Desa Seruni";
  const nav = useNavigate();
  const [nik, setNik] = useState("");
  const [nama, setNama] = useState("");
  const [password, setPassword] = useState("");
  const [password2, setPassword2] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  if (user && isAdmin) return <Navigate to="/admin" replace />;

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr(null);
    if (!/^\d{6,20}$/.test(nik.trim())) return setErr("NIK harus 6-20 digit angka.");
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
    <StandaloneLayout>
      <div className="w-full max-w-md mx-auto flex-1 flex flex-col justify-center">
        <div className="text-center mb-6">
          <h1 className="font-display text-2xl font-bold text-foreground">Bootstrap Admin Pertama</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Hanya berlaku jika belum ada admin di sistem - {siteName}
          </p>
        </div>
        <form onSubmit={submit} className="rounded-xl bg-card border border-border p-6 space-y-4 shadow-sm">
          <div>
            <label className="block text-sm font-medium mb-1">NIK</label>
            <input value={nik} onChange={(e) => setNik(e.target.value.replace(/\D/g, ""))} maxLength={20} inputMode="numeric" required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary" autoComplete="off" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Nama Lengkap</label>
            <input value={nama} onChange={(e) => setNama(e.target.value)} maxLength={100} required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary" autoComplete="off" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Password (min 8)</label>
            <div className="relative">
              <input type={showPassword ? "text" : "password"} value={password} onChange={(e) => setPassword(e.target.value)} required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary pr-10" autoComplete="new-password" />
              <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute inset-y-0 right-0 px-3 flex items-center text-muted-foreground hover:text-foreground">
                {showPassword ? (
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M10.79 12.912l-1.614-1.615a3.5 3.5 0 0 1-4.474-4.474l-2.06-2.06C.938 6.278 0 8 0 8s3 5.5 8 5.5a7.029 7.029 0 0 0 2.79-.588zM5.21 3.088A7.028 7.028 0 0 1 8 2.5c5 0 8 5.5 8 5.5s-.939 1.721-2.641 3.238l-2.062-2.062a3.5 3.5 0 0 0-4.474-4.474L5.21 3.089z"/><path d="M5.525 7.646a2.5 2.5 0 0 0 2.829 2.829l-2.83-2.829zm4.95.708-2.829-2.83a2.5 2.5 0 0 1 2.829 2.829zm3.171 6-12-12 .708-.708 12 12-.708.708z"/></svg>
                ) : (
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z"/><path d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8zm8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z"/></svg>
                )}
              </button>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Ulangi Password</label>
            <div className="relative">
              <input type={showPassword ? "text" : "password"} value={password2} onChange={(e) => setPassword2(e.target.value)} required className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary pr-10" autoComplete="new-password" />
            </div>
          </div>
          {err && <div className="rounded-md bg-destructive/10 border border-destructive/30 text-destructive text-sm px-3 py-2">{err}</div>}
          <button type="submit" disabled={busy} className="w-full rounded-md bg-primary text-primary-foreground font-medium py-2.5 text-sm hover:bg-primary/90 disabled:opacity-60">
            {busy ? "Memproses..." : "Buat Admin"}
          </button>
          <div className="text-center text-xs text-muted-foreground">
            <Link to="/admin/login" className="hover:text-primary">Sudah punya akun? Login</Link>
          </div>
        </form>
      </div>
    </StandaloneLayout>
  );
}