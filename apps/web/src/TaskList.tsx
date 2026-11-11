import { FormEvent, useEffect, useState } from 'react';

export type Task = { id: number; title: string; done: boolean };

export default function TaskList() {
  const [tasks, setTasks] = useState<Task[] | null>(null);
  const [title, setTitle] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    fetch('/api/tasks')
      .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
      .then((d: Task[]) => setTasks(d))
      .catch(() => setError('Could not load tasks'));
  }, []);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    const res = await fetch('/api/tasks', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title }),
    });
    const data = await res.json();
    if (!res.ok) {
      setError(data.error ?? 'Could not add task');
      return;
    }
    setTasks((prev) => [...(prev ?? []), data as Task]);
    setTitle('');
  }

  return (
    <section>
      <h2>Tasks</h2>
      <form onSubmit={onSubmit}>
        <label htmlFor="task-title">Title</label>{' '}
        <input id="task-title" value={title} onChange={(e) => setTitle(e.target.value)} />{' '}
        <button type="submit">Add task</button>
      </form>
      {error && <p role="alert">{error}</p>}
      {tasks === null ? (
        <p>Loading…</p>
      ) : tasks.length === 0 ? (
        <p>No tasks yet</p>
      ) : (
        <ul>
          {tasks.map((t) => (
            <li key={t.id}>{t.title}</li>
          ))}
        </ul>
      )}
    </section>
  );
}
