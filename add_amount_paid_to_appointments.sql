
-- Script para agregar los campos de pago multimoneda a la tabla appointments
-- Ejecutar manualmente en la base de datos

-- 1. Agregar la columna amount_paid a la tabla appointments
ALTER TABLE appointments 
ADD COLUMN IF NOT EXISTS amount_paid DECIMAL(10,2) DEFAULT NULL;

-- 2. Agregar la columna payment_currency para la moneda del pago
ALTER TABLE appointments 
ADD COLUMN IF NOT EXISTS payment_currency VARCHAR(3) DEFAULT 'USD';

-- 3. Agregar comentarios a las columnas para documentación
COMMENT ON COLUMN appointments.amount_paid IS 'Monto total cobrado al cliente cuando la cita está completada';
COMMENT ON COLUMN appointments.payment_currency IS 'Moneda en la que se realizó el pago (USD, BRL, PYG)';

-- 4. Verificar que las columnas se hayan agregado correctamente
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'appointments' AND column_name IN ('amount_paid', 'payment_currency');

-- 5. Verificar la estructura completa de la tabla appointments
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'appointments' 
ORDER BY ordinal_position;

-- 6. Opcional: Actualizar citas ya completadas con el precio del servicio (si existe)
-- UPDATE appointments 
-- SET amount_paid = (
--     SELECT s.price_usd 
--     FROM services s 
--     WHERE s.id = appointments.service_type
-- ),
-- payment_currency = 'USD'
-- WHERE status = 'completed' AND amount_paid IS NULL;

-- 7. Mostrar algunas citas para verificar
SELECT id, customer_name, service_type, status, amount_paid, payment_currency, appointment_date
FROM appointments 
ORDER BY created_at DESC 
LIMIT 5;
