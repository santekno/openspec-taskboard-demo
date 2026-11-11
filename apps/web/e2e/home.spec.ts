import { test, expect } from '@playwright/test';

test('home page reaches the API', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'Taskboard' })).toBeVisible();
  await expect(page.getByText('API: ok')).toBeVisible();
});
