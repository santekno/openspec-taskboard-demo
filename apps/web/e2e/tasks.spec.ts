import { test, expect } from '@playwright/test';

test('user adds a task and sees it listed', async ({ page }) => {
  const title = `Write demo notes ${Date.now()}`;
  await page.goto('/');
  await page.getByLabel('Title').fill(title);
  await page.getByRole('button', { name: 'Add task' }).click();
  await expect(page.getByRole('listitem').filter({ hasText: title })).toBeVisible();
  await expect(page.getByLabel('Title')).toHaveValue('');
});

test('empty title shows the API error', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Add task' }).click();
  await expect(page.getByRole('alert')).toHaveText('title is required');
});
