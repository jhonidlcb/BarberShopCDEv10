
import bcrypt from "bcryptjs";
import { storage } from "./storage";

async function initAdmin() {
  try {
    console.log("Iniciando script de inicialización de admin...");
    
    // Verificar conexión a la base de datos
    const connected = await storage.testConnection();
    if (!connected) {
      console.error("No se pudo conectar a la base de datos");
      process.exit(1);
    }

    // Verificar si ya existe un admin
    const existingAdmin = await storage.getAdminUserByUsername("admin");
    if (existingAdmin) {
      console.log("✅ Ya existe un usuario administrador");
      console.log(`Usuario: ${existingAdmin.username}`);
      console.log(`Email: ${existingAdmin.email}`);
      console.log(`Activo: ${existingAdmin.active}`);
      return;
    }

    // Crear admin inicial
    const hashedPassword = await bcrypt.hash("admin123", 10);
    
    const adminUser = await storage.createAdminUser({
      username: "admin",
      email: "admin@barbershop.com",
      password: hashedPassword,
      role: "admin"
    });

    console.log("✅ Usuario administrador creado exitosamente");
    console.log(`Usuario: ${adminUser.username}`);
    console.log(`Email: ${adminUser.email}`);
    console.log(`Contraseña: admin123`);
    console.log("\n⚠️  IMPORTANTE: Cambia la contraseña después del primer login");
    
  } catch (error) {
    console.error("❌ Error al inicializar admin:", error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

initAdmin();
