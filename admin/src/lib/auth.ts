import { initializeApp } from "firebase/app";
import {
  GoogleAuthProvider,
  browserLocalPersistence,
  getAuth,
  onAuthStateChanged,
  setPersistence,
  signInWithPopup,
  signOut,
  type User,
} from "firebase/auth";

// Web app "WineBro Console" in Firebase project winebro (public client config).
const app = initializeApp({
  apiKey: "AIzaSyAxtMi2c1KVRu1YtgVZwLM44zWLG6IFVDU",
  authDomain: "winebro.firebaseapp.com",
  projectId: "winebro",
  storageBucket: "winebro.firebasestorage.app",
  messagingSenderId: "708385389571",
  appId: "1:708385389571:web:9173c7679a7e951d78a236",
});

export const auth = getAuth(app);
void setPersistence(auth, browserLocalPersistence);

export function watchUser(cb: (u: User | null) => void) {
  return onAuthStateChanged(auth, cb);
}

export async function signInWithGoogle() {
  const provider = new GoogleAuthProvider();
  provider.setCustomParameters({ prompt: "select_account" });
  await signInWithPopup(auth, provider);
}

export function signOutUser() {
  return signOut(auth);
}

/** Fresh ID token for API calls; null when signed out. */
export async function idToken(): Promise<string | null> {
  const u = auth.currentUser;
  return u ? u.getIdToken() : null;
}
