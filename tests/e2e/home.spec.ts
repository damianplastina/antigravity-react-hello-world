import { test, expect } from '@playwright/test';

test('Página de inicio', async ({ page }) => {
    await page.goto('/');

    // Verifica que el encabezado con "Hola Damián!" esté presente
    const heading = page.getByRole('heading', { level: 1 });
    await expect(heading).toBeVisible();
    await expect(heading).toHaveText('Hola Damián!');

    // Verifica que el mensaje de bienvenida esté presente
    const paragraph = page.getByText(/Bienvenido a tu primer proyecto usando Antigravity/i);
    await expect(paragraph).toBeVisible();
});
