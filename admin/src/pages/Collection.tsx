import { useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate, useParams } from "react-router-dom";
import { api } from "../lib/api";
import { byId } from "../lib/schema";
import { optionLists, useConfigAll } from "../lib/config";
import { downloadCsv, downloadXlsx, downloadTemplate } from "../lib/xlsx";
import { Layout } from "../components/Layout";
import { Cards, FilterBar, Table, applyList, useListState } from "../components/DataTable";
import { ImportDialog } from "../components/ImportDialog";
import { Icon, Skeleton, Empty } from "../components/ui";

export default function Collection() {
  const { collection = "" } = useParams();
  const spec = byId(collection);
  const nav = useNavigate();
  const cfg = useConfigAll();
  const options = useMemo(() => optionLists(cfg.data), [cfg.data]);
  const q = useQuery({ queryKey: ["collection", collection], queryFn: () => api.list(collection), enabled: !!spec });
  const [st, setSt] = useListState(spec?.fields.some((f) => f.key === "name") ? "name" : "id");
  const [view, setView] = useState<"table" | "cards">(() => (window.innerWidth < 720 ? "cards" : "table"));
  const [importing, setImporting] = useState(false);
  const [menu, setMenu] = useState(false);

  if (!spec) return <Layout title="Not found"><Empty title="Unknown collection" /></Layout>;
  const rows = q.data ?? [];
  const shown = applyList(rows, spec, st);

  return (
    <Layout
      title={spec.title}
      crumbs={spec.editable ? "Catalogue" : "People"}
      actions={<>
        <div style={{ position: "relative" }}>
          <button className="btn" onClick={() => setMenu((m) => !m)}><Icon name="download" className="sm" />Export</button>
          {menu && (
            <div className="card" style={{ position: "absolute", right: 0, top: 44, minWidth: 220, zIndex: 30, padding: 6 }} onMouseLeave={() => setMenu(false)}>
              <button className="btn ghost" style={{ width: "100%", justifyContent: "flex-start" }} onClick={() => { downloadCsv(spec, shown); setMenu(false); }}><Icon name="csv" className="sm" />CSV ({shown.length} rows)</button>
              <button className="btn ghost" style={{ width: "100%", justifyContent: "flex-start" }} onClick={() => { downloadXlsx(spec, shown); setMenu(false); }}><Icon name="table_view" className="sm" />Excel ({shown.length} rows)</button>
              {spec.editable && <button className="btn ghost" style={{ width: "100%", justifyContent: "flex-start" }} onClick={() => { downloadTemplate(spec, rows[0], Object.fromEntries(Object.entries(options).map(([k, v]) => [k, v.map((o) => o.value)]))); setMenu(false); }}><Icon name="post_add" className="sm" />Blank Excel template</button>}
            </div>
          )}
        </div>
        {spec.editable && <button className="btn" onClick={() => setImporting(true)}><Icon name="upload_file" className="sm" />Import</button>}
        {spec.editable && <button className="btn primary" onClick={() => nav(`/c/${spec.id}/new`)}><Icon name="add" className="sm" />New {spec.singular}</button>}
      </>}
    >
      <div className="small muted">{spec.description}</div>
      <div className="row between">
        <FilterBar spec={spec} st={st} setSt={setSt} options={options} rows={rows} />
        <div className="seg">
          <button className={view === "table" ? "active" : ""} onClick={() => setView("table")}><Icon name="table_rows" className="sm" />Table</button>
          <button className={view === "cards" ? "active" : ""} onClick={() => setView("cards")}><Icon name="grid_view" className="sm" />Cards</button>
        </div>
      </div>
      {q.isLoading ? <Skeleton /> : q.error ? <Empty icon="error" title="Could not load" text={String(q.error)} /> :
        view === "table"
          ? <Table spec={spec} rows={shown} st={st} setSt={setSt} options={options} onOpen={(r) => nav(`/c/${spec.id}/${encodeURIComponent(r.id)}`)} />
          : <Cards spec={spec} rows={shown} options={options} onOpen={(r) => nav(`/c/${spec.id}/${encodeURIComponent(r.id)}`)} />}
      <div className="pager"><span>{shown.length} of {rows.length} {spec.title.toLowerCase()}</span><span>Sorted by {st.sort} {st.dir === 1 ? "↑" : "↓"}</span></div>
      {importing && <ImportDialog spec={spec} options={options} example={rows[0]} onClose={() => setImporting(false)} />}
    </Layout>
  );
}
