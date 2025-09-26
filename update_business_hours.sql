
-- Script para insertar/actualizar horarios de atención
-- Ejecutar manualmente en la base de datos

-- Insertar horarios por defecto si no existen
INSERT INTO site_config (key, value, description) VALUES
('hours_monday', '8:00 - 20:00', 'Horario de atención - Lunes'),
('hours_tuesday', '8:00 - 20:00', 'Horario de atención - Martes'),
('hours_wednesday', '8:00 - 20:00', 'Horario de atención - Miércoles'),
('hours_thursday', '8:00 - 20:00', 'Horario de atención - Jueves'),
('hours_friday', '8:00 - 20:00', 'Horario de atención - Viernes'),
('hours_saturday', '8:00 - 18:00', 'Horario de atención - Sábado'),
('hours_sunday', 'Cerrado', 'Horario de atención - Domingo')
ON CONFLICT (key) DO NOTHING;

-- Verificar los horarios insertados
SELECT key, value, description 
FROM site_config 
WHERE key LIKE 'hours_%' 
ORDER BY key;
