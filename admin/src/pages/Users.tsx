import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useNavigate, useParams } from "react-router-dom";
import { api, Doc } from "../lib/api";
import { CollectionSpec } from "../lib/schema";
import { fmtDate } from "../lib/format";
import { downloadCsv, downloadXlsx } from "../lib/xlsx";
import { Layout } from "../components/Layout";
import { Confirm, Empty, Icon, Skeleton, Tabs, useToast } from "../components/ui";

const usersSpec: CollectionSpec = {
  id: "users", title: "Users", singular: "user", icon: "group", editable: false, deletable: true, description: "",
  fields: [
    { key: "id", label: "User ID", type: "readonly", table: true },
    { key: "displayName", label: "Name", type: "readonly", table: true },
    { key: "email", label: "Email", type: "readonly", table: true },
    { key: "phoneNumber", label: "Phone", type: "readonly", table: true },
    { key: "hasCompletedQuiz", label: "Quiz done", type: "readonly", table: true },
    { key: "isAgeVerified", label: "Age verified", type: "readonly", table: true },
    { key: "createdAt", label: "Joined", type: "readonly", table: true },
    { key: "lastActiveDate", label: "Last active", type: "readonly", table: true },
  ],
};

const SUBS: { id: string; label: string; icon: string; cols: string[] }[] = [
  { id: "journal", label: "BroCards", icon: "menu_book", cols: ["productName", "category", "rating", "foodPaired", "occasion", "isFavorite", "buyAgain", "notes", "createdAt"] },
  { id: "gamification", label: "XP and badges", icon: "military_tech", cols: ["xp", "level", "streak", "totalScans", "totalJournalEntries", "totalPairings", "earnedBadgeIds", "lastActiveDate"] },
  { id: "wishlist", label: "Wishlist", icon: "favorite", cols: ["productName", "productId", "addedAt"] },
  { id: "friends", label: "Friends", icon: "group", cols: ["id", "displayName", "visibility", "followedAt"] },
  { id: "fcm_token", label: "Push tokens", icon: "notifications", cols: ["id", "token", "updatedAt"] },
  { id: "pre_quiz_seed", label: "Quiz seed", icon: "quiz", cols: ["id"] },
  { id: "cross_category", label: "Cross-category", icon: "swap_horiz", cols: ["id"] },
  { id: "aroma_calibration", label: "Aroma calibration", icon: "air", cols: ["id", "aroma", "category", "familiarity", "userAssociation"] },
];

export function UsersList() {
  const nav = useNavigate();
  const q = useQuery({ queryKey: ["collection", "users"], queryFn: () => api.list("users") });
  const [query, setQuery] = useState("");
  const rows = useMemo(() => (q.data ?? []).filter((u) => JSON.stringify(u).toLowerCase().includes(query.toLowerCase())), [q.data, query]);
  return (
    <Layout title="Users" crumbs="People" actions={<>
      <button className="btn" onClick={() => downloadCsv(usersSpec, rows)}><Icon name="download" className="sm" />CSV</button>
      <button className="btn" onClick={() => downloadXlsx(usersSpec, rows)}><Icon name="download" className="sm" />Excel</button>
    </>}>
      <div className="small muted">People who signed in to the app. Their BroCards, wishlist and badges are theirs; you can view, export and delete, not edit.</div>
      <div className="toolbar"><div className="search"><Icon name="search" /><input className="input" placeholder="Search name, email, phone…" value={query} onChange={(e) => setQuery(e.target.value)} /></div></div>
      {q.isLoading ? <Skeleton /> : rows.length === 0 ? <Empty icon="person_off" title="No users" /> : (
        <div className="card table-wrap">
          <table className="tbl">
            <thead><tr><th>Name</th><th>Email</th><th>Phone</th><th>Quiz</th><th>Age</th><th>Joined</th><th>Last active</th></tr></thead>
            <tbody>
              {rows.map((u) => (
                <tr key={u.id} className="click" onClick={() => nav(`/users/${encodeURIComponent(u.id)}`)}>
                  <td><b>{String(u.displayName ?? "—")}</b><div className="small muted mono">{u.id}</div></td>
                  <td>{String(u.email ?? "—")}</td>
                  <td>{String(u.phoneNumber ?? "—")}</td>
                  <td>{u.hasCompletedQuiz ? <span className="chip ok">Done</span> : <span className="chip">Not yet</span>}</td>
                  <td>{u.isAgeVerified ? <span className="chip ok">Yes</span> : <span className="chip warn">No</span>}</td>
                  <td>{fmtDate(u.createdAt)}</td>
                  <td>{fmtDate(u.lastActiveDate)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Layout>
  );
}

export function UserDetail() {
  const { uid = "" } = useParams();
  const nav = useNavigate();
  const qc = useQueryClient();
  const toast = useToast();
  const user = useQuery({ queryKey: ["doc", "users", uid], queryFn: () => api.get("users", uid) });
  const [tab, setTab] = useState(SUBS[0].id);
  const sub = useQuery({ queryKey: ["usersub", uid, tab], queryFn: () => api.userSub(uid, tab) });
  const [confirm, setConfirm] = useState(false);
  const del = useMutation({
    mutationFn: () => api.remove("users", uid),
    onSuccess: () => { toast("User and all their data deleted"); void qc.invalidateQueries({ queryKey: ["collection", "users"] }); nav("/users"); },
    onError: (e) => toast(e instanceof Error ? e.message : "Delete failed", "err"),
  });
  const current = SUBS.find((s) => s.id === tab)!;
  const rows = sub.data ?? [];
  const cols = rows.length ? Array.from(new Set([...current.cols.filter((c) => rows.some((r) => r[c] !== undefined)), ...Object.keys(rows[0]).filter((k) => !current.cols.includes(k))])).slice(0, 12) : current.cols;
  const spec: CollectionSpec = { id: tab, title: `${user.data?.displayName ?? uid} ${current.label}`, singular: "row", icon: current.icon, editable: false, deletable: false, description: "", fields: cols.map((c) => ({ key: c, label: c, type: "readonly" })) };

  return (
    <Layout title={String(user.data?.displayName ?? uid)} crumbs="Users" actions={<>
      <button className="btn" onClick={() => downloadXlsx(spec, rows)} disabled={!rows.length}><Icon name="download" className="sm" />Export {current.label}</button>
      <button className="btn danger" onClick={() => setConfirm(true)}><Icon name="person_remove" className="sm" />Delete user</button>
    </>}>
      {user.isLoading ? <Skeleton rows={3} /> : (
        <div className="card card-pad">
          <dl className="kv" style={{ margin: 0 }}>
            <dt>User ID</dt><dd className="mono">{uid}</dd>
            <dt>Email</dt><dd>{String(user.data?.email ?? "—")}</dd>
            <dt>Phone</dt><dd>{String(user.data?.phoneNumber ?? "—")}</dd>
            <dt>Quiz</dt><dd>{user.data?.hasCompletedQuiz ? "Completed" : "Not yet"}</dd>
            <dt>Age verified</dt><dd>{user.data?.isAgeVerified ? "Yes" : "No"}</dd>
            <dt>Joined</dt><dd>{fmtDate(user.data?.createdAt)}</dd>
            <dt>Last active</dt><dd>{fmtDate(user.data?.lastActiveDate)}</dd>
          </dl>
        </div>
      )}
      <Tabs value={tab} onChange={setTab} tabs={SUBS.map((s) => ({ id: s.id, label: s.label }))} />
      {sub.isLoading ? <Skeleton /> : rows.length === 0 ? <Empty icon={current.icon} title={`No ${current.label.toLowerCase()} yet`} /> : (
        <div className="card table-wrap">
          <table className="tbl">
            <thead><tr>{cols.map((c) => <th key={c}>{c}</th>)}</tr></thead>
            <tbody>{rows.map((r: Doc) => <tr key={r.id}>{cols.map((c) => <td key={c}>{text(r[c])}</td>)}</tr>)}</tbody>
          </table>
        </div>
      )}
      {confirm && <Confirm title="Delete this user?" text="Their profile, BroCards, wishlist, friends, badges and push tokens will be removed. This cannot be undone." onClose={() => setConfirm(false)} onConfirm={() => del.mutate()} busy={del.isPending} />}
    </Layout>
  );
}

function text(v: unknown): string {
  if (v === undefined || v === null) return "—";
  if (typeof v === "boolean") return v ? "Yes" : "No";
  if (typeof v === "string" && /^\d{4}-\d{2}-\d{2}T/.test(v)) return fmtDate(v);
  if (Array.isArray(v)) return v.join(", ");
  if (typeof v === "object") return JSON.stringify(v);
  return String(v);
}
