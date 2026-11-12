import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import BookmarkList from './BookmarkList';

const json = (status: number, body: unknown) =>
  Promise.resolve({ ok: status < 400, status, json: async () => body });

afterEach(() => vi.unstubAllGlobals());

test('shows the empty state', async () => {
  vi.stubGlobal('fetch', vi.fn(() => json(200, [])));
  render(<BookmarkList />);
  expect(await screen.findByText('No bookmarks yet')).toBeInTheDocument();
});

test('lists bookmarks as links', async () => {
  vi.stubGlobal('fetch', vi.fn(() => json(200, [{ id: 1, url: 'https://go.dev', title: 'Go' }])));
  render(<BookmarkList />);
  const link = await screen.findByRole('link', { name: 'Go' });
  expect(link).toHaveAttribute('href', 'https://go.dev');
  expect(link.closest('li')).not.toBeNull();
});

test('saves a bookmark at the top and clears the inputs', async () => {
  const fetchMock = vi.fn((_: string, init?: RequestInit) =>
    init?.method === 'POST'
      ? json(201, { id: 2, url: 'https://vite.dev', title: 'Vite' })
      : json(200, [{ id: 1, url: 'https://go.dev', title: 'Go' }]),
  );
  vi.stubGlobal('fetch', fetchMock);
  render(<BookmarkList />);
  await screen.findByRole('link', { name: 'Go' });
  await userEvent.type(screen.getByLabelText('URL'), 'https://vite.dev');
  await userEvent.type(screen.getByLabelText('Title'), 'Vite');
  await userEvent.click(screen.getByRole('button', { name: 'Save' }));
  const links = await screen.findAllByRole('link');
  expect(links.map((l) => l.textContent)).toEqual(['Vite', 'Go']);
  expect(screen.getByLabelText('URL')).toHaveValue('');
  expect(screen.getByLabelText('Title')).toHaveValue('');
});

test('shows the API error and keeps the typed text', async () => {
  vi.stubGlobal('fetch', vi.fn((_: string, init?: RequestInit) =>
    init?.method === 'POST' ? json(400, { error: 'url must be an absolute http(s) URL' }) : json(200, []),
  ));
  render(<BookmarkList />);
  await screen.findByText('No bookmarks yet');
  await userEvent.type(screen.getByLabelText('URL'), 'go.dev');
  await userEvent.type(screen.getByLabelText('Title'), 'Go');
  await userEvent.click(screen.getByRole('button', { name: 'Save' }));
  expect(await screen.findByRole('alert')).toHaveTextContent('url must be an absolute http(s) URL');
  expect(screen.getByLabelText('URL')).toHaveValue('go.dev');
});
