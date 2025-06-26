const { test, expect } = require('@playwright/test');

test.describe('eeprom data', () => {
  test('verify bitstream for happy path simple text message', async ({ page }) => {
    await page.goto('/');

    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('TEST');

    await page.getByRole('button', { name: 'Go' }).click();
    const messageData = await page.locator('#message_data').inputValue();

    expect(messageData).toEqual('1,30,4,29,14,28,29');
    // 1 message, 30 is the config byte for the message, 4 data bytes in message, T=29, E=14, S=28, T=29
  });

  test('verify bitstream for simple pixel message', async ({ page }) => {
    await page.goto('http://localhost:3000/');

    await page.getByRole('radio', { name: 'Pixel' }).check();
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message');
    await page.locator('#msg_0_delay').selectOption('7');

    await page.locator('div > img').first().click();
    await page.locator('div:nth-child(2) > img:nth-child(2)').click();
    await page.locator('div:nth-child(3) > img:nth-child(3)').click();
    await page.locator('div:nth-child(4) > img:nth-child(4)').click();
    await page.locator('div:nth-child(5) > img:nth-child(5)').click();
    await page.locator('div:nth-child(6) > img:nth-child(6)').click();
    await page.locator('div:nth-child(7) > img:nth-child(7)').click();
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,158,7,128,64,32,16,8,4,2');
  });

  test('verify bitstream for multiple text messages', async ({ page }) => {
    await page.goto('/');

    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('Hello');

    await page.locator('input[value="Add New Message"]').click();
    await page.locator('#msg_1_anim_marq').check();
    await page.locator('#msg_1_end_type').selectOption('Advance to next message');
    await page.locator('#msg_1_delay').selectOption('7');
    await page.locator('#msg_1_text_message').fill('World');

    await page.getByRole('button', { name: 'Go' }).click();
    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('2,30,5,17,14,21,21,24,30,5,32,24,27,21,13');
  });

  test('verify bitstream for animation-style text message', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_anim').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('animation');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,94,9,10,23,18,22,10,29,18,24,23');
  });

  test('verify bitstream for marquee-style text message', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('marquee');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,30,7,22,10,27,26,30,14,14');
  });

  test('verify bitstream for text message that ends by stopping', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Stop');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('stop');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,28,4,28,29,24,25');
  });

  test('verify bitstream for text message that ends by repeating', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Repeat this message');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('repeat');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,29,6,27,14,25,14,10,29');
  });

  test('verify bitstream for text message that ends by advancing', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('advance');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,30,7,10,13,31,10,23,12,14');
  });

  test('verify bitstream for easter egg text message', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Easter egg...');
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('egg');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,31,3,14,16,16');
  });

  test('verify bitstream for low delay text message', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message'); // advance
    await page.locator('#msg_0_delay').selectOption('0');
    await page.locator('#msg_0_text_message').fill('fast');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,2,4,15,10,28,29');
  });

  test('verify bitstream for middle delay text message', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message'); // advance
    await page.locator('#msg_0_delay').selectOption('5');
    await page.locator('#msg_0_text_message').fill('medium');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,22,6,22,14,13,18,30,22');
  });

  test('verify bitstream for slow delay text message', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('Advance to next message'); // advance
    await page.locator('#msg_0_delay').selectOption('15');
    await page.locator('#msg_0_text_message').fill('sloooow');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,62,7,28,21,24,24,24,24,32');
  });

  test('verify bitstream for all the advertised text characters', async ({ page }) => {
    await page.goto('/');
    await page.locator('#msg_0_anim_marq').check();
    await page.locator('#msg_0_end_type').selectOption('2'); // advance
    await page.locator('#msg_0_delay').selectOption('7');
    await page.locator('#msg_0_text_message').fill('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!?&,.');
    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    expect(messageData).toEqual('1,30,67,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,37,39,38,40,36');
  });
});

  test('verify initial square state is black for data and clock', async ({ page }) => {
    await page.goto('/');

    const clockBg = await page.evaluate(() => {
      return window.getComputedStyle(document.getElementById('divclock')).backgroundColor;
    });

    const dataBg = await page.evaluate(() => {
      return window.getComputedStyle(document.getElementById('divdata')).backgroundColor;
    });

    // Both should start as black (rgb(0, 0, 0))
    expect(clockBg).toBe('rgb(0, 0, 0)');
    expect(dataBg).toBe('rgb(0, 0, 0)');
  });


  test('verify stop button resets to black', async ({ page }) => {
    await page.goto('/');

    await page.locator('#msg_0_text_message').fill('TEST');
    await page.getByRole('button', { name: 'Go' }).click();
    await page.waitForTimeout(100);
    await page.getByRole('button', { name: 'Stop' }).click();
    await page.waitForTimeout(50);

    const clockBg = await page.evaluate(() => {
      return window.getComputedStyle(document.getElementById('divclock')).backgroundColor;
    });

    const dataBg = await page.evaluate(() => {
      return window.getComputedStyle(document.getElementById('divdata')).backgroundColor;
    });

    expect(clockBg).toBe('rgb(0, 0, 0)');
    expect(dataBg).toBe('rgb(0, 0, 0)');
  });

  test('verify pixel animation data padding', async ({ page }) => {
    await page.goto('/');

    // Switch to pixel mode with animation
    await page.getByRole('radio', { name: 'Pixel' }).check();
    await page.locator('#msg_0_anim_anim').check();

    // Set some pixels in first 3 columns
    await page.locator('#msg_0_pixel_leds > div > img').first().click();
    await page.locator('#msg_0_pixel_leds > div:nth-child(2) > img:nth-child(3)').click();
    await page.locator('#msg_0_pixel_leds > div:nth-child(3) > img:nth-child(5)').click();

    await page.getByRole('button', { name: 'Go' }).click();

    const messageData = await page.locator('#message_data').inputValue();
    // Should be padded to 7 columns for animation mode
    expect(messageData).toBe('1,222,7,128,32,8,0,0,0,0');
    // Config byte 222 = 0xDE = 11011110 (pixel=1, anim=1, delay=7, advance=2)
  });


test('verify delete message with drag objects', async ({ page }) => {
  await page.goto('/');

  // Add multiple messages
  await page.locator('input[value="Add New Message"]').click();
  await page.locator('input[value="Add New Message"]').click();

  // Try to delete the middle message
  await page.locator('#msg_1 .delete').click();

  // Handle the confirmation dialog
  page.on('dialog', dialog => dialog.accept());

  // Click delete again with dialog handler active
  await page.locator('#msg_1 .delete').click();

  // Verify message is removed
  await expect(page.locator('#msg_1')).not.toBeVisible();

  // Verify other messages still exist
  await expect(page.locator('#msg_0')).toBeVisible();
  await expect(page.locator('#msg_2')).toBeVisible();
});

test('verify message ordering after deletion', async ({ page }) => {
  await page.goto('/');

  // Add 3 messages
  await page.locator('input[value="Add New Message"]').click();
  await page.locator('input[value="Add New Message"]').click();

  await page.locator('#msg_0_text_message').fill('FIRST');
  await page.locator('#msg_1_text_message').fill('SECOND');
  await page.locator('#msg_2_text_message').fill('THIRD');

  // Delete middle message
  page.on('dialog', dialog => dialog.accept());
  await page.locator('#msg_1 .delete').click();

  // make sure they're in the right order on the screen

  // Verifies messages remain visible in correct positions
  await expect(page.locator('#msg_0')).toBeVisible();
  await expect(page.locator('#msg_2')).toBeVisible();

  // Checks vertical positioning
  const msg0Rect = await page.locator('#msg_0').boundingBox();
  const msg2Rect = await page.locator('#msg_2').boundingBox();
  expect(msg0Rect.y).toBeLessThan(msg2Rect.y);

  //make sure msg_1 doesn't exist anymore
  await expect(page.locator('#msg_1')).not.toBeVisible();

  // Transmit and verify order
  await page.getByRole('button', { name: 'Go' }).click();

  // check message data
  const messageData = await page.locator('#message_data').inputValue();
  expect(messageData).toEqual('2,30,5,15,18,27,28,29,30,5,29,17,18,27,13');
});



test.describe('transmission data validation', () => {
  test('verify transmission data', async ({ page }) => {
    await page.goto('/');

    await page.locator('#msg_0_text_message').fill('A');
    await page.getByRole('button', { name: 'Go' }).click();

    const xmitDataHex = await page.locator('#xmit_data_hex').inputValue();
    const hexValues = xmitDataHex.split(',');

    expect(xmitDataHex).toEqual('04,00,00,06,01,1E,01,0A,CC,00,00,00,01,FF');
  });

  test('verify 16-byte record splitting', async ({ page }) => {
    await page.goto('/');

    // Create a message longer than 16 bytes
    await page.locator('#msg_0_text_message').fill('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    await page.getByRole('button', { name: 'Go' }).click();

    const xmitDataHex = await page.locator('#xmit_data_hex').inputValue();

    expect(xmitDataHex).toEqual('10,00,00,06,01,1E,1A,0A,0B,0C,0D,0E,0F,10,11,12,13,14,15,16,E1,0D,00,10,06,17,18,19,1A,1B,1C,1D,1E,1F,20,21,22,23,64,00,00,00,01,FF');
  });

  test('verify end-of-transmission record', async ({ page }) => {
    await page.goto('/');

    await page.locator('#msg_0_text_message').fill('TEST');
    await page.getByRole('button', { name: 'Go' }).click();

    const xmitData = await page.locator('#xmit_data').inputValue();
    const bytes = xmitData.split(',').map(Number);

    // Last 5 bytes should be the reset record: 0,0,0,1,255
    const lastFive = bytes.slice(-5);
    expect(lastFive).toEqual([0, 0, 0, 1, 255]);
  });
});
