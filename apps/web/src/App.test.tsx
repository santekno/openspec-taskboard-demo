import { render, screen } from '@testing-library/react';
import App from './App';

test('shows the Bookmarks heading', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: true, json: async () => [] }));
  render(<App />);
  expect(screen.getByRole('heading', { level: 1, name: 'Bookmarks' })).toBeInTheDocument();
  expect(await screen.findByText('No bookmarks yet')).toBeInTheDocument();
  vi.unstubAllGlobals();
});
