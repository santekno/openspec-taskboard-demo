import { render, screen } from '@testing-library/react';
import App from './App';

test('shows the API health status', async () => {
  vi.stubGlobal(
    'fetch',
    vi.fn((url: string) =>
      Promise.resolve({ ok: true, json: async () => (url === '/api/health' ? { status: 'ok' } : []) }),
    ),
  );
  render(<App />);
  expect(screen.getByRole('heading', { name: 'Taskboard' })).toBeInTheDocument();
  expect(await screen.findByText('API: ok')).toBeInTheDocument();
  vi.unstubAllGlobals();
});
