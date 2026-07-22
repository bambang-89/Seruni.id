import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import type { Session, User } from "@supabase/supabase-js";
import { supabase } from "@/integrations/supabase/client";

type AuthState = {
  session: Session | null;
  user: User | null;
  isAdmin: boolean;
  loading: boolean;
  signInWithNik: (nik: string, password: string) => Promise<{ error?: string }>;
  signUpFirstAdmin: (nik: string, nama: string, password: string) => Promise<{ error?: string }>;
  signOut: () => Promise<void>;
};

const AuthCtx = createContext<AuthState | null>(null);

// NIK → email sintetis untuk Supabase Auth (email tidak dipakai user).
export const nikToEmail = (nik: string) => `nik-${nik.trim()}@admin.seruni.local`;

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const { data: sub } = supabase.auth.onAuthStateChange((_evt, s) => {
      setSession(s);
      setUser(s?.user ?? null);
      if (s?.user) {
        // defer role fetch
        setTimeout(async () => {
          const { data } = await supabase
            .from("user_roles")
            .select("role")
            .eq("user_id", s.user!.id)
            .eq("role", "admin")
            .maybeSingle();
          setIsAdmin(!!data);
        }, 0);
      } else {
        setIsAdmin(false);
      }
    });
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setUser(data.session?.user ?? null);
      setLoading(false);
    });
    return () => sub.subscription.unsubscribe();
  }, []);

  const signInWithNik: AuthState["signInWithNik"] = async (nik, password) => {
    const { error } = await supabase.auth.signInWithPassword({
      email: nikToEmail(nik),
      password,
    });
    return error ? { error: "NIK atau password salah." } : {};
  };

  const signUpFirstAdmin: AuthState["signUpFirstAdmin"] = async (nik, nama, password) => {
    const { error } = await supabase.auth.signUp({
      email: nikToEmail(nik),
      password,
      options: {
        emailRedirectTo: `${window.location.origin}/admin`,
        data: { nik, nama },
      },
    });
    if (error) return { error: error.message };
    return {};
  };

  const signOut = async () => {
    await supabase.auth.signOut();
  };

  return (
    <AuthCtx.Provider value={{ session, user, isAdmin, loading, signInWithNik, signUpFirstAdmin, signOut }}>
      {children}
    </AuthCtx.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthCtx);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}