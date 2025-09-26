
-- Script para verificar y corregir la tabla service_hours
-- Ejecutar manualmente en la base de datos

-- Verificar la estructura actual de la tabla service_hours
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'service_hours' 
ORDER BY ordinal_position;

-- Si la tabla no existe, crearla
CREATE TABLE IF NOT EXISTS service_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    day_name VARCHAR(20) NOT NULL,
    day_name_es VARCHAR(20),
    day_name_pt VARCHAR(20) NOT NULL,
    is_available BOOLEAN DEFAULT true,
    start_time TIME,
    end_time TIME,
    break_start_time TIME,
    break_end_time TIME,
    slot_duration_minutes INTEGER DEFAULT 30,
    available_slots JSONB,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos por defecto si no existen registros
INSERT INTO service_hours (day_of_week, day_name, day_name_es, day_name_pt, is_available, start_time, end_time, slot_duration_minutes, available_slots) 
SELECT * FROM (
    VALUES 
    (1, 'Monday', 'Lunes', 'Segunda-feira', true, '08:00', '20:00', 30, '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb),
    (2, 'Tuesday', 'Martes', 'Terça-feira', true, '08:00', '20:00', 30, '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb),
    (3, 'Wednesday', 'Miércoles', 'Quarta-feira', true, '08:00', '20:00', 30, '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb),
    (4, 'Thursday', 'Jueves', 'Quinta-feira', true, '08:00', '20:00', 30, '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb),
    (5, 'Friday', 'Viernes', 'Sexta-feira', true, '08:00', '20:00', 30, '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"]'::jsonb),
    (6, 'Saturday', 'Sábado', 'Sábado', true, '08:00', '18:00', 30, '["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"]'::jsonb),
    (0, 'Sunday', 'Domingo', 'Domingo', false, null, null, 30, null)
) AS t(day_of_week, day_name, day_name_es, day_name_pt, is_available, start_time, end_time, slot_duration_minutes, available_slots)
WHERE NOT EXISTS (SELECT 1 FROM service_hours WHERE service_hours.day_of_week = t.day_of_week);

-- Verificar los datos insertados
SELECT id, day_of_week, day_name, day_name_es, is_available, start_time, end_time, 
       slot_duration_minutes, 
       CASE WHEN available_slots IS NOT NULL 
            THEN jsonb_array_length(available_slots) 
            ELSE 0 
       END as slots_count
FROM service_hours 
ORDER BY day_of_week;

-- Opcional: Si hay problemas con las columnas de timestamp, recrearlas
-- ALTER TABLE service_hours ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP;
-- ALTER TABLE service_hours ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

-- Actualizar registros existentes para asegurar que tengan timestamps válidos
UPDATE service_hours 
SET updated_at = CURRENT_TIMESTAMP 
WHERE updated_at IS NULL;

UPDATE service_hours 
SET created_at = CURRENT_TIMESTAMP 
WHERE created_at IS NULL;
