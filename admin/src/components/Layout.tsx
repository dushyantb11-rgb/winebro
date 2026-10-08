import React, { useState } from "react";
import { NavLink, useLocation } from "react-router-dom";
import { Icon, useTheme } from "./ui";
import { signOutUser } from "../lib/auth";
import { useMe } from "../App";

const NAV: { group: string; items: { to: string; label: string; icon: string }[] }[] = [
  { group: "Overview", items: [{ to: "/", label: "Dashboard", icon: "dashboard" }, { to: "/access", label: "Access", icon: "admin_panel_settings" }] },
  {
    group: "Catalogue",
    items: [
      { to: "/c/products", label: "Drinks", icon: "wine_bar" },
      { to: "/c/dishes", label: "Dishes", icon: "restaurant" },
      { to: "/c/pilot_candidates", label: "Pilot candidates", icon: "science" },
    ],
  },
  { group: "Rules", items: [{ to: "/rules", label: "Rules and lists", icon: "tune" }] },
  { group: "Publishing", items: [{ to: "/releases", label: "Releases", icon: "rocket_launch" }] },
  {
    group: "People",
    items: [
      { to: "/users", label: "Users", icon: "group" },
      { to: "/c/community_signals", label: "Community signals", icon: "groups" },
      { to: "/c/pairing_feedback", label: "Pairing feedback", icon: "thumb_up" },
      { to: "/c/pairing_aggregates", label: "Pairing votes", icon: "how_to_vote" },
      { to: "/c/phone_index", label: "Phone index", icon: "contact_phone" },
    ],
  },
];

const MOBILE = [
  { to: "/", label: "Home", icon: "dashboard" },
  { to: "/c/products", label: "Drinks", icon: "wine_bar" },
  { to: "/c/dishes", label: "Dishes", icon: "restaurant" },
  { to: "/rules", label: "Rules", icon: "tune" },
  { to: "/users", label: "Users", icon: "group" },
];

export function Layout({ title, crumbs, actions, children }: {
  title: string; crumbs?: string; actions?: React.ReactNode; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const { theme, setTheme } = useTheme();
  const me = useMe();
  const loc = useLocation();
  const isActive = (to: string) => (to === "/" ? loc.pathname === "/" : loc.pathname.startsWith(to));
  return (
    <div className="shell">
      {open && <div className="scrim" onClick={() => setOpen(false)} />}
      <aside className={`sidebar ${open ? "open" : ""}`}>
        <div className="brand">
          <div className="logo"><Icon name="wine_bar" fill /></div>
          <div><b>WineBro</b><span>Console</span></div>
        </div>
        {NAV.map((g) => (
          <React.Fragment key={g.group}>
            <div className="nav-group">{g.group}</div>
            {g.items.map((i) => (
              <NavLink key={i.to} to={i.to} className={`nav-item ${isActive(i.to) ? "active" : ""}`} onClick={() => setOpen(false)}>
                <Icon name={i.icon} fill={isActive(i.to)} /><span>{i.label}</span>
              </NavLink>
            ))}
          </React.Fragment>
        ))}
        <div className="nav-foot">
          <div className="seg" style={{ borderColor: "rgba(255,255,255,0.2)" }}>
            {(["auto", "light", "dark"] as const).map((t) => (
              <button key={t} className={theme === t ? "active" : ""} style={{ color: "inherit" }} onClick={() => setTheme(t)}>
                <Icon name={t === "auto" ? "contrast" : t === "light" ? "light_mode" : "dark_mode"} className="sm" />
              </button>
            ))}
          </div>
          <div style={{ marginTop: 10, display: "flex", alignItems: "center", gap: 8, color: "rgba(255,255,255,0.75)" }}>
            <Icon name="account_circle" className="sm" />
            <span style={{ flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }} title={me.email}>{me.name || me.email}</span>
            <button className="btn ghost icon" style={{ color: "inherit", width: 32, height: 32 }} onClick={() => void signOutUser()} aria-label="Sign out" title="Sign out"><Icon name="logout" className="sm" /></button>
          </div>
        </div>
      </aside>
      <div className="main">
        <header className="topbar">
          <button className="btn ghost icon menu-btn" onClick={() => setOpen(true)} aria-label="Menu"><Icon name="menu" /></button>
          <div className="title">
            {crumbs && <div className="crumbs">{crumbs}</div>}
            <h1>{title}</h1>
          </div>
          <div className="row actions" style={{ flexWrap: "nowrap" }}>{actions}</div>
        </header>
        <main className="content">{children}</main>
      </div>
      <nav className="mobile-nav">
        {MOBILE.map((i) => (
          <NavLink key={i.to} to={i.to} className={isActive(i.to) ? "active" : ""}>
            <Icon name={i.icon} fill={isActive(i.to)} /><span>{i.label}</span>
          </NavLink>
        ))}
      </nav>
    </div>
  );
}
