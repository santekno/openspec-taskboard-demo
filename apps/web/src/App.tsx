import BookmarkList from './BookmarkList';

export default function App() {
  return (
    <main style={{ fontFamily: 'system-ui, sans-serif', maxWidth: 640, margin: '48px auto', padding: '0 16px' }}>
      <h1>Bookmarks</h1>
      <BookmarkList />
    </main>
  );
}
