import { createContext, useContext, useEffect, useState } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import type { User } from "firebase/auth";
import { watchUser } from "./lib/auth";
import { api } from "./lib/api";
import Dashboard from "./pages/Dashboard";
import Collection from "./pages/Collection";
import Editor from "./pages/Editor";
import { UsersList, UserDetail } from "./pages/Users";
import Rules from "./pages/Rules";
import RuleEditor from "./pages/RuleEditor";
import Access from "./pages/Access";
import Releases from "./pages/Releases";
import Sources from "./pages/Sources";
import GrapeMinds from "./pages/GrapeMinds";
import { Checking, Denied, Login } from "./pages/Login";

export const MeCtx = createContext<{ email: string; name: string }>({ email: "", name: "" });
export const useMe = () => useContext(MeCtx);

export default function App() {
  const qc = useQueryClient();
  const [user, setUser] = useState<User | null | undefined>(undefined);
  useEffect(() => watchUser((u) => { setUser(u); qc.clear(); }), [qc]);
  const me = useQuery({ queryKey: ["me", user?.uid], queryFn: api.me, enabled: !!user, retry: false });

  if (user === undefined) return <Checking />;
  if (user === null) return <Login />;
  if (me.isLoading) return <Checking />;
  if (me.error || !me.data?.allowed) return <Denied email={me.data?.email ?? user.email ?? ""} />;

  return (
    <MeCtx.Provider value={{ email: me.data.email, name: me.data.name }}>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/c/:collection" element={<Collection />} />
        <Route path="/c/:collection/:id" element={<Editor />} />
        <Route path="/users" element={<UsersList />} />
        <Route path="/users/:uid" element={<UserDetail />} />
        <Route path="/rules" element={<Rules />} />
        <Route path="/rules/:doc" element={<RuleEditor />} />
        <Route path="/access" element={<Access me={me.data.email} />} />
        <Route path="/releases" element={<Releases />} />
        <Route path="/sources" element={<Sources />} />
        <Route path="/sources/grapeminds" element={<GrapeMinds />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </MeCtx.Provider>
  );
}
