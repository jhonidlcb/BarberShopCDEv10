
-- Script para agregar la columna available_slots a la tabla service_hours
-- Ejecutar manualmente en la base de datos

-- Agregar la columna available_slots como jsonb
ALTER TABLE service_hours 
ADD COLUMN IF NOT EXISTS available_slots jsonb;

-- Verificar que la columna se haya agregado correctamente
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'service_hours' 
ORDER BY ordinal_position;

-- Opcional: Agregar algunos horarios de ejemplo para el primer día (Lunes = 1)
UPDATE service_hours 
SET available_slots = '["09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"]'::jsonb
WHERE day_of_week = 1 AND available_slots IS NULL;

-- Verificar los datos actualizados
SELECT id, day_name, day_of_week, is_available, available_slots 
FROM service_hours 
WHERE day_of_week = 1;
