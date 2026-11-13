import { test, expect } from '@playwright/test';

// Runs across three processes: browser → Vite → Taskboard API → users-auth.
test('user assigns a task to u-1 and sees the name from users-auth', async ({ page }) => {
  const title = `Review contract ${Date.now()}`;
  await page.goto('/');
  await page.getByLabel('Title').fill(title);
  await page.getByLabel('Assignee ID').fill('u-1');
  await page.getByRole('button', { name: 'Add task' }).click();
  const item = page.getByRole('listitem').filter({ hasText: title });
  await expect(item).toContainText('Assigned to Ayu Lestari');
});

test('unknown assignee shows the API error and creates nothing', async ({ page }) => {
  const title = `Ghost task ${Date.now()}`;
  await page.goto('/');
  await page.getByLabel('Title').fill(title);
  await page.getByLabel('Assignee ID').fill('u-404');
  await page.getByRole('button', { name: 'Add task' }).click();
  await expect(page.getByRole('alert')).toHaveText('assignee not found');
  await expect(page.getByRole('listitem').filter({ hasText: title })).toHaveCount(0);
});
