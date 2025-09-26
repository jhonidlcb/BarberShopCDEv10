
-- Script para inicializar las configuraciones de moneda
-- Ejecutar manualmente en la base de datos

-- 1. Primero actualizar la estructura de la tabla para soportar números más grandes
ALTER TABLE currency_settings ALTER COLUMN exchange_rate_to_usd TYPE numeric(15,6);

-- 2. Insertar configuraciones de moneda si no existen
INSERT INTO currency_settings (currency_code, currency_name, currency_symbol, exchange_rate_to_usd, is_active)
VALUES 
  ('USD', 'Dólar Estadounidense', '$', 1.0, true),
  ('BRL', 'Real Brasileño', 'R$', 5.20, true),
  ('PYG', 'Guaraní Paraguayo', '₲', 7200.0, true)
ON CONFLICT (currency_code) DO UPDATE SET
  currency_name = EXCLUDED.currency_name,
  currency_symbol = EXCLUDED.currency_symbol,
  exchange_rate_to_usd = EXCLUDED.exchange_rate_to_usd,
  is_active = EXCLUDED.is_active;

-- 3. Verificar que las monedas se hayan insertado correctamente
SELECT * FROM currency_settings ORDER BY currency_code;

-- 4. Mostrar el estado actual de las tasas de cambio
SELECT 
  currency_code,
  currency_name,
  currency_symbol,
  exchange_rate_to_usd,
  CASE 
    WHEN currency_code = 'USD' THEN '1 USD = 1 USD'
    ELSE '1 USD = ' || exchange_rate_to_usd || ' ' || currency_code
  END as exchange_rate_display,
  is_active
FROM currency_settings 
WHERE is_active = true
ORDER BY currency_code;
