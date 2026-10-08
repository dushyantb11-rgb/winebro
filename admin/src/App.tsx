import { Navigate, Route, Routes } from "react-router-dom";
import Dashboard from "./pages/Dashboard";
import Collection from "./pages/Collection";
import Editor from "./pages/Editor";
import { UsersList, UserDetail } from "./pages/Users";
import Rules from "./pages/Rules";
import RuleEditor from "./pages/RuleEditor";

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Dashboard />} />
      <Route path="/c/:collection" element={<Collection />} />
      <Route path="/c/:collection/:id" element={<Editor />} />
      <Route path="/users" element={<UsersList />} />
      <Route path="/users/:uid" element={<UserDetail />} />
      <Route path="/rules" element={<Rules />} />
      <Route path="/rules/:doc" element={<RuleEditor />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
