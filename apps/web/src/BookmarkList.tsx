import { FormEvent, useEffect, useState } from 'react';

export type Bookmark = { id: number; url: string; title: string };

export default function BookmarkList() {
  const [items, setItems] = useState<Bookmark[] | null>(null);
  const [url, setUrl] = useState('');
  const [title, setTitle] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/bookmarks')
      .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
      .then((d: Bookmark[]) => setItems(d))
      .catch(() => setError('Could not load bookmarks'));
  }, []);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    const res = await fetch('/api/bookmarks', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ url, title }),
    });
    const data = await res.json();
    if (!res.ok) {
      setError(data.error ?? 'Could not save bookmark');
      return;
    }
    setItems((prev) => [data as Bookmark, ...(prev ?? [])]);
    setUrl('');
    setTitle('');
  }

  return (
    <section>
      <form onSubmit={onSubmit}>
        <label htmlFor="bm-url">URL</label>{' '}
        <input id="bm-url" value={url} onChange={(e) => setUrl(e.target.value)} />{' '}
        <label htmlFor="bm-title">Title</label>{' '}
        <input id="bm-title" value={title} onChange={(e) => setTitle(e.target.value)} />{' '}
        <button type="submit">Save</button>
      </form>
      {error && <p role="alert">{error}</p>}
      {items === null ? (
        <p>Loading…</p>
      ) : items.length === 0 ? (
        <p>No bookmarks yet</p>
      ) : (
        <ul>
          {items.map((b) => (
            <li key={b.id}>
              <a href={b.url}>{b.title}</a>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
