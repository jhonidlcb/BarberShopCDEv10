
-- Script para verificar y corregir la funcionalidad del panel de administración
-- Ejecutar manualmente en la base de datos

-- 1. Verificar que las tablas principales existen
DO $$ 
BEGIN
    -- Verificar tabla gallery_images
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'gallery_images') THEN
        RAISE NOTICE 'Tabla gallery_images no existe - creándola...';
        CREATE TABLE gallery_images (
            id VARCHAR DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            title TEXT,
            title_pt TEXT,
            image_url TEXT NOT NULL,
            description TEXT,
            description_pt TEXT,
            category TEXT DEFAULT 'general' NOT NULL,
            active BOOLEAN DEFAULT true NOT NULL,
            sort_order INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT NOW() NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW() NOT NULL
        );
    END IF;

    -- Verificar tabla services
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'services') THEN
        RAISE NOTICE 'Tabla services no existe - creándola...';
        CREATE TABLE services (
            id VARCHAR DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            name_pt TEXT,
            description TEXT,
            description_pt TEXT,
            price_usd DECIMAL(10,2),
            price_brl DECIMAL(10,2),
            price_pyg DECIMAL(10,2),
            duration INTEGER DEFAULT 30,
            active BOOLEAN DEFAULT true NOT NULL,
            sort_order INTEGER DEFAULT 0,
            category TEXT DEFAULT 'general',
            image_url TEXT,
            created_at TIMESTAMP DEFAULT NOW() NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW() NOT NULL
        );
    END IF;

    -- Verificar tabla company_info
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'company_info') THEN
        RAISE NOTICE 'Tabla company_info no existe - creándola...';
        CREATE TABLE company_info (
            id VARCHAR DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            section TEXT NOT NULL UNIQUE,
            title TEXT,
            title_pt TEXT,
            content TEXT,
            content_pt TEXT,
            metadata JSONB DEFAULT '{}',
            created_at TIMESTAMP DEFAULT NOW() NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW() NOT NULL
        );
    END IF;

    -- Verificar tabla site_config
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'site_config') THEN
        RAISE NOTICE 'Tabla site_config no existe - creándola...';
        CREATE TABLE site_config (
            id VARCHAR DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            key TEXT NOT NULL UNIQUE,
            value TEXT,
            description TEXT,
            created_at TIMESTAMP DEFAULT NOW() NOT NULL,
            updated_at TIMESTAMP DEFAULT NOW() NOT NULL
        );
    END IF;
END $$;

-- 2. Insertar configuración básica si no existe
INSERT INTO site_config (key, value, description) VALUES
('site_name', 'Barbería Elite', 'Nombre del sitio web'),
('site_email', 'info@barberia.com', 'Email principal de contacto'),
('site_phone', '+595 21 123456', 'Teléfono principal'),
('address', 'Calle Principal 123, Asunción', 'Dirección física'),
('whatsapp_number', '+595987654321', 'Número de WhatsApp'),
('instagram_url', 'https://instagram.com/barberia', 'URL de Instagram'),
('facebook_url', 'https://facebook.com/barberia', 'URL de Facebook')
ON CONFLICT (key) DO NOTHING;

-- 3. Insertar información básica de la empresa si no existe
INSERT INTO company_info (section, title, title_pt, content, content_pt) VALUES
('hero', 
 'Bienvenido a Barbería Elite', 
 'Bem-vindo à Barbearia Elite',
 'El lugar donde el estilo se encuentra con la tradición. Ofrecemos servicios de barbería de primera calidad.',
 'O lugar onde o estilo encontra a tradição. Oferecemos serviços de barbearia de primeira qualidade.'),
('about',
 'Sobre Nosotros',
 'Sobre Nós', 
 'Somos una barbería con más de 10 años de experiencia, especializada en cortes modernos y clásicos.',
 'Somos uma barbearia com mais de 10 anos de experiência, especializada em cortes modernos e clássicos.'),
('contact',
 'Contáctanos',
 'Entre em Contato',
 'Estamos aquí para atenderte. No dudes en contactarnos para cualquier consulta.',
 'Estamos aqui para atendê-lo. Não hesite em nos contatar para qualquer consulta.')
ON CONFLICT (section) DO NOTHING;

-- 4. Verificar que el usuario admin tenga una contraseña segura
UPDATE admin_users 
SET password = '$2b$10$K7L.1Y4.6Vm7LhFQ1Q1KAeKwF0.5B5.F5.F5.F5.F5.F5.F5.F5.F5'
WHERE username = 'admin' AND (password IS NULL OR password = 'admin123' OR LENGTH(password) < 20);

-- 5. Limpiar sesiones expiradas
DELETE FROM admin_sessions WHERE expires_at < NOW();

-- 6. Mostrar estadísticas finales
SELECT 
  'Verificación completa' as status,
  (SELECT COUNT(*) FROM gallery_images) as imagenes_galeria,
  (SELECT COUNT(*) FROM services) as servicios_activos,
  (SELECT COUNT(*) FROM company_info) as secciones_empresa,
  (SELECT COUNT(*) FROM site_config) as configuraciones,
  (SELECT COUNT(*) FROM admin_users WHERE active = true) as usuarios_admin_activos;

-- 7. Verificar permisos del directorio uploads (esto se hace a nivel de sistema)
-- mkdir -p uploads && chmod 755 uploads
