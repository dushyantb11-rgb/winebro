import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { api } from "../lib/api";
import { fmtDate } from "../lib/format";
import { Layout } from "../components/Layout";
import { Confirm, Icon, Skeleton, TextInput, useToast } from "../components/ui";

export default function Access({ me }: { me: string }) {
  const qc = useQueryClient();
  const toast = useToast();
  const q = useQuery({ queryKey: ["access"], queryFn: api.access });
  const [draft, setDraft] = useState("");
  const [removing, setRemoving] = useState<string | null>(null);
  const save = useMutation({
    mutationFn: (emails: string[]) => api.saveAccess(emails),
    onSuccess: (a) => { qc.setQueryData(["access"], a); toast("Admin list saved"); setDraft(""); setRemoving(null); },
    onError: (e) => toast(e instanceof Error ? e.message : "Could not save", "err"),
  });
  const emails = q.data?.emails ?? [];
  const add = () => {
    const e = draft.trim().toLowerCase();
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(e)) return toast("Enter a full email address", "err");
    if (emails.includes(e)) return toast("Already on the list");
    save.mutate([...emails, e]);
  };
  return (
    <Layout title="Access" crumbs="Who can use the console">
      <div className="small muted">Only these Google accounts can open the console or call its API. Changes apply at once. You cannot remove yourself.</div>
      {q.isLoading ? <Skeleton rows={3} /> : (
        <div className="card">
          <div className="card-head"><h3>Admins</h3><span className="small muted">{q.data?.updatedAt ? `Changed ${fmtDate(q.data.updatedAt)} by ${q.data.updatedBy}` : ""}</span></div>
          <div className="table-wrap">
            <table className="tbl">
              <tbody>
                {emails.map((e) => (
                  <tr key={e}>
                    <td><Icon name="account_circle" className="sm" /> {e}{e === me && <span className="chip accent" style={{ marginLeft: 8 }}>you</span>}</td>
                    <td className="row end">
                      <button className="btn sm danger" disabled={e === me || save.isPending} onClick={() => setRemoving(e)}><Icon name="person_remove" className="sm" />Remove</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="card-pad row">
            <TextInput placeholder="name@gmail.com" value={draft} onChange={(e) => setDraft(e.target.value)} onKeyDown={(e) => e.key === "Enter" && add()} style={{ flex: "1 1 240px" }} />
            <button className="btn primary" onClick={add} disabled={save.isPending}><Icon name="person_add" className="sm" />Add admin</button>
          </div>
        </div>
      )}
      {removing && <Confirm title={`Remove ${removing}?`} confirmLabel="Remove" text="They will be signed out of the console on their next request." onClose={() => setRemoving(null)} onConfirm={() => save.mutate(emails.filter((x) => x !== removing))} busy={save.isPending} />}
    </Layout>
  );
}
