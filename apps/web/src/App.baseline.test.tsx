// Characterization tests: they lock the home page behavior that existed before
// any spec-driven change (openspec/specs/web/home). Do not edit them in a
// feature change; if behavior must change, write a MODIFIED delta first.
import { render, screen } from '@testing-library/react';
import App from './App';

const healthOnly = (health: () => Promise<unknown>) =>
  vi.fn((url: string) =>
    url === '/api/health' ? health() : Promise.resolve({ ok: true, json: async () => [] }),
  );

afterEach(() => vi.unstubAllGlobals());

test('baseline: shows "API: checking…" before the health response', () => {
  vi.stubGlobal('fetch', healthOnly(() => new Promise(() => {})));
  render(<App />);
  expect(screen.getByRole('heading', { level: 1, name: 'Taskboard' })).toBeInTheDocument();
  expect(screen.getByText('API: checking…')).toBeInTheDocument();
});

test('baseline: shows "API: unreachable" when the health request fails', async () => {
  vi.stubGlobal('fetch', healthOnly(() => Promise.reject(new Error('down'))));
  render(<App />);
  expect(await screen.findByText('API: unreachable')).toBeInTheDocument();
});

test('baseline: shows "API: unreachable" on a non-2xx health status', async () => {
  vi.stubGlobal('fetch', healthOnly(() => Promise.resolve({ ok: false, status: 503 })));
  render(<App />);
  expect(await screen.findByText('API: unreachable')).toBeInTheDocument();
});
