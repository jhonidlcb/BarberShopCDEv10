
-- Script para verificar y corregir fechas de citas
-- Ejecutar manualmente en la base de datos

-- Verificar todas las citas y sus fechas
SELECT 
    id,
    customer_name,
    appointment_date,
    appointment_time,
    status,
    created_at,
    EXTRACT(DOW FROM appointment_date) as day_of_week,
    TO_CHAR(appointment_date, 'DD/MM/YYYY') as formatted_date
FROM appointments 
WHERE status != 'cancelled'
ORDER BY appointment_date, appointment_time;

-- Verificar si hay citas con fechas incorrectas (ejemplo: cita de Shirley)
SELECT 
    id,
    customer_name,
    appointment_date,
    appointment_time,
    status,
    created_at AT TIME ZONE 'America/Asuncion' as created_at_paraguay
FROM appointments 
WHERE customer_name ILIKE '%shirley%'
   OR customer_name ILIKE '%inchausti%';

-- Si necesitas corregir la fecha de una cita específica (ejemplo):
-- UPDATE appointments 
-- SET appointment_date = '2025-09-26'
-- WHERE id = '40bb11b8-c61d-469b-a93b-df9a2c2e6f06';

-- Verificar citas para fechas específicas
SELECT 
    appointment_date,
    appointment_time,
    customer_name,
    status,
    service_type
FROM appointments 
WHERE appointment_date IN ('2025-09-25', '2025-09-26', '2025-09-27')
ORDER BY appointment_date, appointment_time;
