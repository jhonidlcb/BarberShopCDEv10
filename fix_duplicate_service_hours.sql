
-- Script para eliminar días duplicados en service_hours y crear estructura correcta
-- Ejecutar manualmente en la base de datos

-- 1. Verificar duplicados actuales
SELECT day_of_week, COUNT(*) as count
FROM service_hours 
GROUP BY day_of_week 
HAVING COUNT(*) > 1
ORDER BY day_of_week;

-- 2. Respaldo de datos importantes antes de limpiar
CREATE TEMP TABLE service_hours_backup AS
SELECT DISTINCT ON (day_of_week) *
FROM service_hours
ORDER BY day_of_week, created_at DESC;

-- 3. Eliminar todos los registros existentes
DELETE FROM service_hours;

-- 4. Insertar registros únicos y correctos (uno por día de la semana)
INSERT INTO service_hours (
    day_of_week, 
    day_name, 
    day_name_es, 
    day_name_pt, 
    is_available, 
    start_time, 
    end_time, 
    slot_duration_minutes, 
    available_slots,
    active,
    created_at,
    updated_at
) VALUES 
-- Domingo (0)
(0, 'Sunday', 'Domingo', 'Domingo', false, null, null, 30, null, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Lunes (1)
(1, 'Monday', 'Lunes', 'Segunda-feira', true, '08:00', '20:00', 30, 
 '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Martes (2)
(2, 'Tuesday', 'Martes', 'Terça-feira', true, '08:00', '20:00', 30, 
 '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Miércoles (3)
(3, 'Wednesday', 'Miércoles', 'Quarta-feira', true, '08:00', '20:00', 30, 
 '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Jueves (4)
(4, 'Thursday', 'Jueves', 'Quinta-feira', true, '08:00', '20:00', 30, 
 '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Viernes (5)
(5, 'Friday', 'Viernes', 'Sexta-feira', true, '08:00', '20:00', 30, 
 '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Sábado (6)
(6, 'Saturday', 'Sábado', 'Sábado', true, '08:00', '18:00', 30, 
 '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"]'::jsonb, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 5. Crear restricción única para evitar duplicados futuros
ALTER TABLE service_hours DROP CONSTRAINT IF EXISTS unique_day_of_week;
ALTER TABLE service_hours ADD CONSTRAINT unique_day_of_week UNIQUE (day_of_week);

-- 6. Verificar que ahora tenemos exactamente 7 días únicos
SELECT 
    day_of_week,
    day_name,
    day_name_es,
    is_available,
    start_time,
    end_time,
    CASE WHEN available_slots IS NOT NULL 
         THEN jsonb_array_length(available_slots) 
         ELSE 0 
    END as slots_count
FROM service_hours 
ORDER BY day_of_week;

-- 7. Contar total de registros (debe ser exactamente 7)
SELECT COUNT(*) as total_days FROM service_hours;

-- 8. Eliminar tabla temporal de respaldo
DROP TABLE IF EXISTS service_hours_backup;
