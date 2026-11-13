import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import TaskList from './TaskList';

function mockFetch(list: unknown[], post?: { ok: boolean; body: unknown }) {
  vi.stubGlobal(
    'fetch',
    vi.fn((_url: string, init?: RequestInit) =>
      Promise.resolve(
        init?.method === 'POST'
          ? { ok: post!.ok, json: async () => post!.body }
          : { ok: true, json: async () => list },
      ),
    ),
  );
}

afterEach(() => vi.unstubAllGlobals());

test('empty state: shows "No tasks yet"', async () => {
  mockFetch([]);
  render(<TaskList />);
  expect(await screen.findByText('No tasks yet')).toBeInTheDocument();
});

test('tasks listed: each title is a list item', async () => {
  mockFetch([{ id: 1, title: 'Buy milk', done: false }, { id: 2, title: 'Call mom', done: false }]);
  render(<TaskList />);
  expect(await screen.findAllByRole('listitem')).toHaveLength(2);
  expect(screen.getByText('Call mom')).toBeInTheDocument();
});

test('task added: appears in the list and input is cleared', async () => {
  mockFetch([], { ok: true, body: { id: 1, title: 'Buy milk', done: false } });
  render(<TaskList />);
  await screen.findByText('No tasks yet');
  await userEvent.type(screen.getByLabelText('Title'), 'Buy milk');
  await userEvent.click(screen.getByRole('button', { name: 'Add task' }));
  expect(await screen.findByRole('listitem')).toHaveTextContent('Buy milk');
  expect(screen.getByLabelText('Title')).toHaveValue('');
});

test('API rejects the title: shows the error as an alert and keeps the text', async () => {
  mockFetch([], { ok: false, body: { error: 'title is required' } });
  render(<TaskList />);
  await screen.findByText('No tasks yet');
  await userEvent.type(screen.getByLabelText('Title'), '   ');
  await userEvent.click(screen.getByRole('button', { name: 'Add task' }));
  expect(await screen.findByRole('alert')).toHaveTextContent('title is required');
  expect(screen.getByLabelText('Title')).toHaveValue('   ');
});

test('task added with an assignee: shows "Assigned to" and sends assigneeId', async () => {
  mockFetch([], { ok: true, body: { id: 1, title: 'Buy milk', done: false, assignee: { id: 'u-1', name: 'Ayu Lestari' } } });
  render(<TaskList />);
  await screen.findByText('No tasks yet');
  await userEvent.type(screen.getByLabelText('Title'), 'Buy milk');
  await userEvent.type(screen.getByLabelText('Assignee ID'), 'u-1');
  await userEvent.click(screen.getByRole('button', { name: 'Add task' }));
  expect(await screen.findByRole('listitem')).toHaveTextContent('Assigned to Ayu Lestari');
  const post = vi.mocked(fetch).mock.calls.find(([, init]) => init?.method === 'POST')!;
  expect(JSON.parse(post[1]!.body as string)).toEqual({ title: 'Buy milk', assigneeId: 'u-1' });
  expect(screen.getByLabelText('Assignee ID')).toHaveValue('');
});

test('mixed list: only the assigned task shows its assignee', async () => {
  mockFetch([
    { id: 1, title: 'Buy milk', done: false, assignee: { id: 'u-1', name: 'Ayu Lestari' } },
    { id: 2, title: 'Call mom', done: false },
  ]);
  render(<TaskList />);
  const items = await screen.findAllByRole('listitem');
  expect(items[0]).toHaveTextContent('Assigned to Ayu Lestari');
  expect(items[1]).not.toHaveTextContent('Assigned to');
});
