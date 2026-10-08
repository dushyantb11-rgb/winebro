import { useRef, useState } from "react";
import { api, fileToBase64 } from "../lib/api";
import { Icon, useToast } from "./ui";

/** Shrinks an image in the browser to keep uploads small (max 1600px, JPEG). */
async function shrink(file: File): Promise<{ blob: Blob; type: string }> {
  if (file.size < 600 * 1024 && file.type !== "image/heic") return { blob: file, type: file.type };
  const bitmap = await createImageBitmap(file).catch(() => null);
  if (!bitmap) return { blob: file, type: file.type };
  const scale = Math.min(1, 1600 / Math.max(bitmap.width, bitmap.height));
  const canvas = document.createElement("canvas");
  canvas.width = Math.round(bitmap.width * scale);
  canvas.height = Math.round(bitmap.height * scale);
  canvas.getContext("2d")!.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  const blob = await new Promise<Blob | null>((r) => canvas.toBlob(r, "image/jpeg", 0.86));
  return blob ? { blob, type: "image/jpeg" } : { blob: file, type: file.type };
}

export function ImageUpload({ value, fallback, credit, folder, id, onChange }: {
  value?: string; fallback?: string; credit?: string; folder: "products" | "dishes" | "home" | "categories"; id: string;
  onChange: (url: string | undefined) => void;
}) {
  const toast = useToast();
  const [busy, setBusy] = useState(false);
  const [over, setOver] = useState(false);
  const input = useRef<HTMLInputElement>(null);
  const shown = value || fallback;

  const upload = async (file: File) => {
    if (!file.type.startsWith("image/")) return toast("Please choose an image file", "err");
    if (!id) return toast("Give the item an ID first", "err");
    setBusy(true);
    try {
      const { blob, type } = await shrink(file);
      const ext = type === "image/png" ? "png" : type === "image/webp" ? "webp" : "jpg";
      const b64 = await fileToBase64(new File([blob], file.name, { type }));
      const res = await api.upload(`catalogue/${folder}/${id}/${Date.now()}.${ext}`, type, b64);
      onChange(res.url);
      toast(`Photo uploaded (${Math.round(res.bytes / 1024)} KB)`);
    } catch (e) {
      toast(e instanceof Error ? e.message : "Upload failed", "err");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="photo-box">
      {shown ? <img src={shown} alt="" /> : <div className="thumb thumb-ph" style={{ width: 160, height: 160, borderRadius: 14 }}><Icon name="image" /></div>}
      <div className="stack">
        <div className={`dropzone ${over ? "over" : ""}`}
          onClick={() => input.current?.click()}
          onDragOver={(e) => { e.preventDefault(); setOver(true); }}
          onDragLeave={() => setOver(false)}
          onDrop={(e) => { e.preventDefault(); setOver(false); const f = e.dataTransfer.files[0]; if (f) void upload(f); }}>
          <Icon name={busy ? "hourglass_top" : "upload"} />
          <div><b>{busy ? "Uploading…" : "Drop a photo here or click to choose"}</b></div>
          <div className="small">JPEG, PNG or WebP. Large photos are shrunk to 1600 px before upload.</div>
          <input ref={input} type="file" accept="image/*" hidden onChange={(e) => { const f = e.target.files?.[0]; if (f) void upload(f); e.target.value = ""; }} />
        </div>
        {value ? (
          <div className="row between">
            <span className="small muted">Our own photo (overrides open-licence photo)</span>
            <button type="button" className="btn sm danger" onClick={() => onChange(undefined)}><Icon name="delete" className="sm" />Remove</button>
          </div>
        ) : fallback ? (
          <div className="credit">Showing open-licence photo{credit ? ` · ${credit}` : ""}. Upload your own to replace it.</div>
        ) : (
          <div className="credit">No photo yet. The app shows a placeholder.</div>
        )}
      </div>
    </div>
  );
}
