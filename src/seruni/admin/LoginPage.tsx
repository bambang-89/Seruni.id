import { useState } from "react";
import { Link, Navigate, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../lib/auth";
import { siteSettings as seedSettings } from "../data";
import { useSiteSettings } from "../lib/zeroHardcode";

export default function LoginPage() {
  const { user, isAdmin, loading, signInWithNik } = useAuth();
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? seedSettings.nama_resmi;
  const nav = useNavigate();
  const loc = useLocation() as { state?: { from?: string } };
  const [nik, setNik] = useState("");
  const [password, setPassword] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  if (!loading && user && isAdmin) {
    return <Navigate to={loc.state?.from || "/admin"} replace />;
  }

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr(null);
    if (!/^\d{6,20}$/.test(nik.trim())) {
      setErr("NIK harus 6–20 digit angka.");
      return;
    }
    if (password.length < 8) {
      setErr("Password minimal 8 karakter.");
      return;
    }
    setBusy(true);
    const { error } = await signInWithNik(nik, password);
    setBusy(false);
    if (error) setErr(error);
    else nav(loc.state?.from || "/admin", { replace: true });
  };

  return (
    <div className="min-h-screen grid place-items-center bg-secondary p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-6">
          <div className="mx-auto grid h-14 w-14 place-items-center rounded-full bg-accent text-primary font-display font-bold stempel-badge">
            <span>SM</span>
          </div>
          <h1 className="mt-4 font-display text-2xl font-bold text-foreground">Login Admin Desa</h1>
          <p className="text-sm text-muted-foreground mt-1">{siteName}</p>
        </div>
        <form onSubmit={submit} className="rounded-xl bg-card border border-border p-6 space-y-4 shadow-sm">
          <div>
            <label className="block text-sm font-medium text-foreground mb-1">NIK</label>
            <input
              type="text"
              inputMode="numeric"
              autoComplete="username"
              value={nik}
              onChange={(e) => setNik(e.target.value.replace(/\D/g, ""))}
              className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="16 digit NIK"
              maxLength={20}
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-foreground mb-1">Password</label>
            <input
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="Password admin"
              required
            />
          </div>
          {err && (
            <div role="alert" className="rounded-md bg-destructive/10 border border-destructive/30 text-destructive text-sm px-3 py-2">
              {err}
            </div>
          )}
          <button
            type="submit"
            disabled={busy}
            className="w-full rounded-md bg-primary text-primary-foreground font-medium py-2.5 text-sm hover:bg-primary/90 disabled:opacity-60"
          >
            {busy ? "Memproses…" : "Masuk"}
          </button>
          <div className="pt-2 border-t border-border text-center text-xs text-muted-foreground">
            Belum ada admin?{" "}
            <Link to="/admin/init" className="text-primary font-medium hover:underline">
              Buat admin pertama
            </Link>
          </div>
        </form>
        <div className="mt-4 text-center">
          <Link to="/" className="text-xs text-muted-foreground hover:text-primary">
            ← Kembali ke portal
          </Link>
        </div>
      </div>
    </div>
  );
}