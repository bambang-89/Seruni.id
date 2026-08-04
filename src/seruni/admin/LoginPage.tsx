import { useState } from "react";
import { Link, Navigate, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../lib/auth";
import { Seo } from "../lib/seo";
import { useSiteSettings } from "../lib/zeroHardcode";
import { StandaloneLayout } from "../ui";

export default function LoginPage() {
  const { user, isAdmin, loading, signInWithNik } = useAuth();
  const { data: settings } = useSiteSettings();
  const siteName = settings?.nama_resmi ?? "Desa Seruni";
  const nav = useNavigate();
  const loc = useLocation() as { state?: { from?: string } };
  const [nik, setNik] = useState("");
  const [password, setPassword] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  
  const [showPassword, setShowPassword] = useState(false);

  if (!loading && user && isAdmin) {
    return <Navigate to={loc.state?.from || "/admin"} replace />;
  }

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErr(null);
    if (!/^\d{6,20}$/.test(nik.trim())) {
      setErr("NIK harus 6-20 digit angka.");
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
    <StandaloneLayout>
      <Seo title="Login Admin" description="Masuk ke portal administrasi desa" />
      <div className="w-full max-w-md mx-auto flex-1 flex flex-col justify-center">
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
            <div className="relative">
              <input
                type={showPassword ? "text" : "password"}
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary pr-10"
                placeholder="Password admin"
                required
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute inset-y-0 right-0 px-3 flex items-center text-muted-foreground hover:text-foreground"
              >
                {showPassword ? (
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M10.79 12.912l-1.614-1.615a3.5 3.5 0 0 1-4.474-4.474l-2.06-2.06C.938 6.278 0 8 0 8s3 5.5 8 5.5a7.029 7.029 0 0 0 2.79-.588zM5.21 3.088A7.028 7.028 0 0 1 8 2.5c5 0 8 5.5 8 5.5s-.939 1.721-2.641 3.238l-2.062-2.062a3.5 3.5 0 0 0-4.474-4.474L5.21 3.089z"/><path d="M5.525 7.646a2.5 2.5 0 0 0 2.829 2.829l-2.83-2.829zm4.95.708-2.829-2.83a2.5 2.5 0 0 1 2.829 2.829zm3.171 6-12-12 .708-.708 12 12-.708.708z"/></svg>
                ) : (
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16"><path d="M10.5 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z"/><path d="M0 8s3-5.5 8-5.5S16 8 16 8s-3 5.5-8 5.5S0 8 0 8zm8 3.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z"/></svg>
                )}
              </button>
            </div>
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
            {busy ? "Memproses..." : "Masuk"}
          </button>
          <div className="pt-2 border-t border-border text-center text-xs text-muted-foreground">
            Belum ada admin?{" "}
            <Link to="/admin/init" className="text-primary font-medium hover:underline">
              Buat admin pertama
            </Link>
          </div>
        </form>
        <div className="mt-4 text-center">
          <Link to="/" className="text-xs text-muted-foreground hover:text-primary inline-flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path fillRule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"/></svg>
            Kembali ke portal
          </Link>
        </div>
      </div>
    </StandaloneLayout>
  );
}