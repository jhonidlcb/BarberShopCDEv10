
-- Script para actualizar toda la configuración del sitio
-- Ejecutar manualmente en la base de datos

-- Insertar/actualizar toda la configuración necesaria para el sitio
INSERT INTO site_config (key, value, description) VALUES
('site_name', 'Barbería Elite', 'Nombre del sitio web'),
('site_description', 'Tu barbería de confianza en Ciudad del Este', 'Descripción del sitio web'),
('site_email', 'info@barberiaelite.com', 'Email principal de contacto'),
('site_phone', '+595 61 570123', 'Teléfono principal'),
('address', 'Av. Monseñor Rodríguez 1245, Ciudad del Este, Paraguay', 'Dirección completa'),
('whatsapp_number', '+595971234567', 'Número de WhatsApp'),
('instagram_url', 'https://instagram.com/barberiaelite', 'URL de Instagram'),
('facebook_url', 'https://facebook.com/barberiaelite', 'URL de Facebook'),
('google_maps_url', 'https://maps.google.com/?q=Ciudad+del+Este', 'URL de Google Maps'),
('hours_monday', '8:00 - 20:00', 'Horario de atención - Lunes'),
('hours_tuesday', '8:00 - 20:00', 'Horario de atención - Martes'),
('hours_wednesday', '8:00 - 20:00', 'Horario de atención - Miércoles'),
('hours_thursday', '8:00 - 20:00', 'Horario de atención - Jueves'),
('hours_friday', '8:00 - 20:00', 'Horario de atención - Viernes'),
('hours_saturday', '8:00 - 18:00', 'Horario de atención - Sábado'),
('hours_sunday', 'Cerrado', 'Horario de atención - Domingo')
ON CONFLICT (key) DO UPDATE SET 
  value = EXCLUDED.value,
  description = EXCLUDED.description,
  updated_at = CURRENT_TIMESTAMP;

-- Verificar toda la configuración
SELECT key, value, description 
FROM site_config 
ORDER BY 
  CASE 
    WHEN key LIKE 'site_%' THEN 1
    WHEN key IN ('address', 'google_maps_url') THEN 2
    WHEN key LIKE '%_url' OR key = 'whatsapp_number' THEN 3
    WHEN key LIKE 'hours_%' THEN 4
    ELSE 5
  END,
  key;
