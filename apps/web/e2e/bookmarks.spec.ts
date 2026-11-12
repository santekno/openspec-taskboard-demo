import { test, expect } from '@playwright/test';

test('user saves a bookmark and sees it at the top', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'Bookmarks' })).toBeVisible();
  const title = `Go docs ${Date.now()}`;
  await page.getByLabel('URL').fill('https://go.dev/doc');
  await page.getByLabel('Title').fill(title);
  await page.getByRole('button', { name: 'Save' }).click();
  const first = page.getByRole('listitem').first().getByRole('link');
  await expect(first).toHaveText(title);
  await expect(first).toHaveAttribute('href', 'https://go.dev/doc');
  await expect(page.getByLabel('URL')).toHaveValue('');
});

test('invalid URL shows the API error', async ({ page }) => {
  await page.goto('/');
  await page.getByLabel('URL').fill('go.dev');
  await page.getByLabel('Title').fill('Go');
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByRole('alert')).toHaveText('url must be an absolute http(s) URL');
});
