import { useState } from "react";
import { signInWithGoogle, signOutUser } from "../lib/auth";
import { Icon } from "../components/ui";

export function Login() {
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const go = async () => {
    setBusy(true);
    setErr(null);
    try {
      await signInWithGoogle();
    } catch (e) {
      const code = (e as { code?: string }).code ?? "";
      setErr(code === "auth/popup-closed-by-user" ? "Sign-in window was closed." : code === "auth/popup-blocked" ? "Your browser blocked the sign-in window. Allow pop-ups for this site and try again." : (e instanceof Error ? e.message : "Sign-in failed"));
    } finally {
      setBusy(false);
    }
  };
  return (
    <Gate>
      <h1 style={{ marginTop: 14 }}>WineBro Console</h1>
      <p className="muted" style={{ margin: "6px 0 22px" }}>Catalogue, rules and people for the WineBro app. Sign in with the Google account that is on the admin list.</p>
      <button className="btn primary" style={{ width: "100%", padding: "12px 16px", fontSize: 14 }} onClick={go} disabled={busy}>
        <GoogleMark />{busy ? "Opening Google…" : "Sign in with Google"}
      </button>
      {err && <p className="small" style={{ color: "var(--error)", marginTop: 12 }}>{err}</p>}
      <p className="small muted" style={{ marginTop: 22 }}>Access is limited to named admins. Nothing here is public.</p>
    </Gate>
  );
}

export function Denied({ email }: { email: string }) {
  return (
    <Gate>
      <Icon name="lock" className="" />
      <h1 style={{ marginTop: 10 }}>Not on the admin list</h1>
      <p className="muted" style={{ margin: "6px 0 18px" }}>
        You signed in as <b>{email}</b>, but this account is not allowed to use the console. Ask an existing admin to add you under <i>Access</i>.
      </p>
      <button className="btn" onClick={() => void signOutUser()}><Icon name="logout" className="sm" />Sign out and try another account</button>
    </Gate>
  );
}

export function Checking() {
  return (
    <Gate>
      <div className="skeleton" style={{ width: "60%", height: 22, margin: "16px auto 10px" }} />
      <div className="skeleton" style={{ width: "80%", height: 14, margin: "0 auto" }} />
    </Gate>
  );
}

function Gate({ children }: { children: React.ReactNode }) {
  return (
    <div style={{ minHeight: "100%", display: "grid", placeItems: "center", padding: 16, background: "linear-gradient(160deg, var(--bg) 0%, var(--bg-deep) 100%)" }}>
      <div className="card" style={{ width: "min(420px, 100%)", padding: "32px 28px", textAlign: "center" }}>
        <div className="brand" style={{ justifyContent: "center", padding: 0 }}>
          <div className="logo" style={{ width: 52, height: 52, borderRadius: 14 }}><Icon name="wine_bar" fill /></div>
        </div>
        {children}
      </div>
    </div>
  );
}

function GoogleMark() {
  return (
    <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden>
      <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3l5.7-5.7C34 6.1 29.3 4 24 4 13 4 4 13 4 24s9 20 20 20 20-9 20-20c0-1.2-.1-2.4-.4-3.5z" />
      <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 7.9 3l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z" />
      <path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-8l-6.5 5C9.5 39.6 16.2 44 24 44z" />
      <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.3-2.3 4.3-4.1 5.6l6.2 5.2C40.9 35.6 44 30.2 44 24c0-1.2-.1-2.4-.4-3.5z" />
    </svg>
  );
}
