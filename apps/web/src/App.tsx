import { useEffect, useState } from 'react';
import TaskList from './TaskList';

export default function App() {
  const [api, setApi] = useState('checking…');

  useEffect(() => {
    fetch('/api/health')
      .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
      .then((d: { status: string }) => setApi(d.status))
      .catch(() => setApi('unreachable'));
  }, []);

  return (
    <main style={{ fontFamily: 'system-ui, sans-serif', maxWidth: 640, margin: '48px auto', padding: '0 16px' }}>
      <h1>Taskboard</h1>
      <p>API: {api}</p>
      <TaskList />
    </main>
  );
}
