// server/index.ts
import express2 from "express";

// server/routes.ts
import { createServer } from "http";

// server/storage.ts
import { drizzle } from "drizzle-orm/neon-http";
import { neon } from "@neondatabase/serverless";
import { eq, desc, and } from "drizzle-orm";

// shared/schema.ts
import { sql } from "drizzle-orm";
import { pgTable, text, varchar, timestamp, integer, boolean, date, time, unique, check, numeric, serial } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
var users = pgTable("users", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  username: text("username").notNull().unique(),
  password: text("password").notNull()
});
var adminUsers = pgTable("admin_users", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  username: text("username").notNull().unique(),
  email: text("email").notNull().unique(),
  password: text("password").notNull(),
  role: text("role").notNull().default("admin"),
  active: boolean("active").notNull().default(true),
  createdAt: timestamp("created_at").notNull().default(sql`now()`),
  updatedAt: timestamp("updated_at").notNull().default(sql`now()`)
});
var adminSessions = pgTable("admin_sessions", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  userId: varchar("user_id").notNull().references(() => adminUsers.id, { onDelete: "cascade" }),
  token: text("token").notNull().unique(),
  expiresAt: timestamp("expires_at").notNull(),
  createdAt: timestamp("created_at").notNull().default(sql`now()`)
});
var appointments = pgTable("appointments", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  customerName: text("customer_name").notNull(),
  customerPhone: text("customer_phone").notNull(),
  customerEmail: text("customer_email"),
  serviceType: text("service_type").notNull(),
  appointmentDate: date("appointment_date").notNull(),
  appointmentTime: time("appointment_time").notNull(),
  notes: text("notes"),
  status: text("status").notNull().default("pending"),
  createdAt: timestamp("created_at").notNull().default(sql`now()`)
}, (table) => ({
  uniqueSlot: unique().on(table.appointmentDate, table.appointmentTime),
  statusCheck: check("status_check", sql`status IN ('pending', 'confirmed', 'completed', 'cancelled')`)
}));
var blogPosts = pgTable("blog_posts", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  title: text("title").notNull(),
  titleEs: text("title_es"),
  titlePt: text("title_pt"),
  slug: text("slug").notNull().unique(),
  content: text("content").notNull(),
  contentEs: text("content_es"),
  contentPt: text("content_pt"),
  excerpt: text("excerpt").notNull(),
  excerptEs: text("excerpt_es"),
  excerptPt: text("excerpt_pt"),
  category: text("category").notNull(),
  imageUrl: text("image_url"),
  published: boolean("published").notNull().default(false),
  createdAt: timestamp("created_at").notNull().default(sql`now()`),
  updatedAt: timestamp("updated_at").notNull().default(sql`now()`)
}, (table) => ({
  categoryCheck: check("category_check", sql`category IN ('hair-care', 'beard-care', 'styling-tips')`)
}));
var reviews = pgTable("reviews", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  customerName: text("customer_name").notNull(),
  rating: integer("rating").notNull(),
  comment: text("comment").notNull(),
  serviceType: text("service_type"),
  approved: boolean("approved").notNull().default(false),
  createdAt: timestamp("created_at").notNull().default(sql`now()`)
}, (table) => ({
  ratingCheck: check("rating_check", sql`rating >= 1 AND rating <= 5`)
}));
var siteConfig = pgTable("site_config", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  key: text("key").notNull().unique(),
  value: text("value").notNull(),
  description: text("description"),
  createdAt: timestamp("created_at").notNull().default(sql`now()`),
  updatedAt: timestamp("updated_at").notNull().default(sql`now()`)
});
var services = pgTable("services", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  name: text("name").notNull(),
  nameEs: text("name_es"),
  namePt: text("name_pt"),
  description: text("description").notNull(),
  descriptionEs: text("description_es"),
  descriptionPt: text("description_pt"),
  price: varchar("price").notNull(),
  // Keep original for compatibility
  priceUsd: numeric("price_usd", { precision: 10, scale: 2 }),
  priceBrl: numeric("price_brl", { precision: 10, scale: 2 }),
  pricePyg: numeric("price_pyg", { precision: 12, scale: 2 }),
  durationMinutes: integer("duration_minutes").notNull(),
  imageUrl: text("image_url"),
  active: boolean("active").notNull().default(true),
  sortOrder: integer("sort_order").default(0),
  createdAt: timestamp("created_at").notNull().default(sql`now()`),
  updatedAt: timestamp("updated_at").notNull().default(sql`now()`)
});
var galleryImages = pgTable("gallery_images", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  title: text("title"),
  titleEs: text("title_es"),
  titlePt: text("title_pt"),
  imageUrl: text("image_url").notNull(),
  description: text("description"),
  descriptionEs: text("description_es"),
  descriptionPt: text("description_pt"),
  category: text("category").default("general"),
  active: boolean("active").notNull().default(true),
  sortOrder: integer("sort_order").default(0),
  createdAt: timestamp("created_at").notNull().default(sql`now()`)
});
var companyInfo = pgTable("company_info", {
  id: varchar("id").primaryKey().default(sql`gen_random_uuid()`),
  section: text("section").notNull().unique(),
  title: text("title"),
  titlePt: text("title_pt"),
  content: text("content"),
  contentEs: text("content_es"),
  contentPt: text("content_pt"),
  metadata: text("metadata"),
  createdAt: timestamp("created_at").notNull().default(sql`now()`),
  updatedAt: timestamp("updated_at").notNull().default(sql`now()`)
});
var currencySettings = pgTable("currency_settings", {
  id: serial("id").primaryKey(),
  currencyCode: varchar("currency_code", { length: 3 }).notNull().unique(),
  currencyName: varchar("currency_name", { length: 50 }).notNull(),
  currencySymbol: varchar("currency_symbol", { length: 10 }).notNull(),
  exchangeRateToUsd: numeric("exchange_rate_to_usd", { precision: 10, scale: 6 }).default("1.0"),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").notNull().default(sql`now()`),
  updatedAt: timestamp("updated_at").notNull().default(sql`now()`)
});
var languageSettings = pgTable("language_settings", {
  id: serial("id").primaryKey(),
  languageCode: varchar("language_code", { length: 2 }).notNull().unique(),
  languageName: varchar("language_name", { length: 50 }).notNull(),
  isDefault: boolean("is_default").notNull().default(false),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").notNull().default(sql`now()`)
});
var insertUserSchema = createInsertSchema(users).pick({
  username: true,
  password: true
});
var insertAppointmentSchema = createInsertSchema(appointments).omit({
  id: true,
  createdAt: true
}).extend({
  appointmentTime: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, "Time must be in HH:MM format"),
  appointmentDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Date must be in YYYY-MM-DD format"),
  status: z.enum(["pending", "confirmed", "completed", "cancelled"]).optional()
});
var insertBlogPostSchema = createInsertSchema(blogPosts).omit({
  id: true,
  createdAt: true,
  updatedAt: true
}).extend({
  category: z.enum(["hair-care", "beard-care", "styling-tips"])
});
var insertReviewSchema = createInsertSchema(reviews).omit({
  id: true,
  createdAt: true,
  approved: true
}).extend({
  rating: z.number().min(1).max(5)
});
var insertServiceSchema = createInsertSchema(services).omit({
  id: true,
  createdAt: true,
  updatedAt: true
});
var insertGalleryImageSchema = createInsertSchema(galleryImages).omit({
  id: true,
  createdAt: true
});
var insertCompanyInfoSchema = createInsertSchema(companyInfo).omit({
  id: true,
  createdAt: true,
  updatedAt: true
});
var insertSiteConfigSchema = createInsertSchema(siteConfig).omit({
  id: true,
  createdAt: true,
  updatedAt: true
});
var insertAdminUserSchema = createInsertSchema(adminUsers).pick({
  username: true,
  email: true,
  password: true,
  role: true
});
var insertAdminSessionSchema = createInsertSchema(adminSessions).omit({
  id: true,
  createdAt: true
});
var insertCurrencySettingsSchema = createInsertSchema(currencySettings).omit({
  id: true,
  createdAt: true,
  updatedAt: true
});
var insertLanguageSettingsSchema = createInsertSchema(languageSettings).omit({
  id: true,
  createdAt: true
});

// server/storage.ts
if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL environment variable is not set. Please configure it in Secrets.");
}
console.log("\u{1F50C} Database URL configured:", process.env.DATABASE_URL ? "\u2705 SET" : "\u274C NOT SET");
console.log("\u{1F50C} Connecting to Neon PostgreSQL...");
var expectedHost = "ep-still-term-acjgon5c-pooler.sa-east-1.aws.neon.tech";
var currentUrl = process.env.DATABASE_URL;
if (!currentUrl?.includes(expectedHost)) {
  console.warn("\u26A0\uFE0F  Warning: DATABASE_URL might not be pointing to the expected Neon database");
  console.log("Expected host:", expectedHost);
  console.log("Current URL contains expected host:", currentUrl?.includes(expectedHost));
}
var sql2 = neon(process.env.DATABASE_URL);
var db = drizzle(sql2, {
  schema: {
    users,
    appointments,
    blogPosts,
    reviews,
    siteConfig,
    services,
    galleryImages,
    companyInfo,
    adminUsers,
    adminSessions,
    currencySettings,
    languageSettings
  }
});
var getUser = async (username) => {
  const result = await db.select().from(users).where(eq(users.username, username)).limit(1);
  return result[0];
};
var createUser = async (userData) => {
  const result = await db.insert(users).values(userData).returning();
  return result[0];
};
var getAdminUser = async (id) => {
  const result = await db.select().from(adminUsers).where(eq(adminUsers.id, id)).limit(1);
  return result[0];
};
var getAdminUserByUsername = async (username) => {
  const result = await db.select().from(adminUsers).where(eq(adminUsers.username, username)).limit(1);
  return result[0];
};
var getAdminUserByEmail = async (email) => {
  const result = await db.select().from(adminUsers).where(eq(adminUsers.email, email)).limit(1);
  return result[0];
};
var createAdminUser = async (userData) => {
  const result = await db.insert(adminUsers).values(userData).returning();
  return result[0];
};
var createAdminSession = async (sessionData) => {
  const result = await db.insert(adminSessions).values(sessionData).returning();
  return result[0];
};
var getAdminSession = async (token) => {
  const result = await db.select().from(adminSessions).where(eq(adminSessions.token, token)).orderBy(desc(adminSessions.expiresAt)).limit(1);
  if (result[0] && /* @__PURE__ */ new Date() <= result[0].expiresAt) {
    return result[0];
  }
  return void 0;
};
var deleteAdminSession = async (token) => {
  await db.delete(adminSessions).where(eq(adminSessions.token, token));
};
var getAppointments = async () => {
  return await db.select().from(appointments).orderBy(desc(appointments.createdAt));
};
var getAppointmentsByDate = async (date2) => {
  return await db.select().from(appointments).where(eq(appointments.appointmentDate, date2)).orderBy(appointments.appointmentTime);
};
var createAppointment = async (appointmentData) => {
  const result = await db.insert(appointments).values(appointmentData).returning();
  return result[0];
};
var updateAppointment = async (id, appointmentData) => {
  const result = await db.update(appointments).set({ ...appointmentData, createdAt: /* @__PURE__ */ new Date() }).where(eq(appointments.id, id)).returning();
  return result[0];
};
var updateAppointmentStatus = async (id, status) => {
  const result = await db.update(appointments).set({ status }).where(eq(appointments.id, id)).returning();
  return result[0];
};
var deleteAppointment = async (id) => {
  await db.delete(appointments).where(eq(appointments.id, id));
};
var getServices = async () => {
  return await db.select().from(services).orderBy(services.sortOrder);
};
var getActiveServices = async () => {
  return await db.select().from(services).where(eq(services.active, true)).orderBy(services.sortOrder);
};
var createService = async (serviceData) => {
  const result = await db.insert(services).values(serviceData).returning();
  return result[0];
};
var updateService = async (id, serviceData) => {
  const result = await db.update(services).set({ ...serviceData, updatedAt: /* @__PURE__ */ new Date() }).where(eq(services.id, id)).returning();
  return result[0];
};
var deleteService = async (id) => {
  await db.delete(services).where(eq(services.id, id));
};
var getApprovedReviews = async () => {
  return await db.select().from(reviews).where(eq(reviews.approved, true)).orderBy(desc(reviews.createdAt));
};
var getReviews = async () => {
  return await db.select().from(reviews).orderBy(desc(reviews.createdAt));
};
var createReview = async (reviewData) => {
  const result = await db.insert(reviews).values(reviewData).returning();
  return result[0];
};
var updateReview = async (id, reviewData) => {
  const result = await db.update(reviews).set(reviewData).where(eq(reviews.id, id)).returning();
  return result[0];
};
var approveReview = async (id) => {
  const result = await db.update(reviews).set({ approved: true }).where(eq(reviews.id, id)).returning();
  return result[0];
};
var deleteReview = async (id) => {
  await db.delete(reviews).where(eq(reviews.id, id));
};
var getActiveGalleryImages = async () => {
  return await db.select().from(galleryImages).where(eq(galleryImages.active, true)).orderBy(galleryImages.sortOrder);
};
var getGalleryImages = async () => {
  return await db.select().from(galleryImages).orderBy(galleryImages.sortOrder);
};
var createGalleryImage = async (imageData) => {
  const result = await db.insert(galleryImages).values(imageData).returning();
  return result[0];
};
var updateGalleryImage = async (id, imageData) => {
  const result = await db.update(galleryImages).set(imageData).where(eq(galleryImages.id, id)).returning();
  return result[0];
};
var deleteGalleryImage = async (id) => {
  await db.delete(galleryImages).where(eq(galleryImages.id, id));
};
var getPublishedBlogPosts = async () => {
  return await db.select().from(blogPosts).where(eq(blogPosts.published, true)).orderBy(desc(blogPosts.createdAt));
};
var getBlogPosts = async () => {
  return await db.select().from(blogPosts).orderBy(desc(blogPosts.createdAt));
};
var getBlogPost = async (slug) => {
  const result = await db.select().from(blogPosts).where(eq(blogPosts.slug, slug)).limit(1);
  return result[0];
};
var getBlogPostsByCategory = async (category) => {
  return await db.select().from(blogPosts).where(and(
    eq(blogPosts.category, category),
    eq(blogPosts.published, true)
  )).orderBy(desc(blogPosts.createdAt));
};
var createBlogPost = async (postData) => {
  const result = await db.insert(blogPosts).values(postData).returning();
  return result[0];
};
var updateBlogPost = async (id, postData) => {
  const result = await db.update(blogPosts).set({ ...postData, updatedAt: /* @__PURE__ */ new Date() }).where(eq(blogPosts.id, id)).returning();
  return result[0];
};
var deleteBlogPost = async (id) => {
  await db.delete(blogPosts).where(eq(blogPosts.id, id));
};
var getCompanyInfo = async () => {
  return await db.select().from(companyInfo).orderBy(companyInfo.section);
};
var getCompanyInfoBySection = async (section) => {
  const result = await db.select().from(companyInfo).where(eq(companyInfo.section, section)).limit(1);
  return result[0];
};
var upsertCompanyInfo = async (infoData) => {
  const existing = await getCompanyInfoBySection(infoData.section);
  if (existing) {
    const result = await db.update(companyInfo).set({ ...infoData, updatedAt: /* @__PURE__ */ new Date() }).where(eq(companyInfo.section, infoData.section)).returning();
    return result[0];
  } else {
    const result = await db.insert(companyInfo).values(infoData).returning();
    return result[0];
  }
};
var getSiteConfig = async () => {
  const result = await db.select().from(siteConfig).orderBy(siteConfig.key);
  return result.reduce((acc, config) => {
    acc[config.key] = config.value;
    return acc;
  }, {});
};
var getSiteConfigByKey = async (key) => {
  const result = await db.select().from(siteConfig).where(eq(siteConfig.key, key)).limit(1);
  return result[0];
};
var updateSiteConfig = async (configData) => {
  const results = [];
  for (const [key, value] of Object.entries(configData)) {
    const existing = await getSiteConfigByKey(key);
    if (existing) {
      const result = await db.update(siteConfig).set({ value, updatedAt: /* @__PURE__ */ new Date() }).where(eq(siteConfig.key, key)).returning();
      results.push(result[0]);
    } else {
      const result = await db.insert(siteConfig).values({ key, value }).returning();
      results.push(result[0]);
    }
  }
  return results;
};
var createSiteConfig = async (configData) => {
  const result = await db.insert(siteConfig).values(configData).returning();
  return result[0];
};
var getCurrencySettings = async () => {
  return await db.select().from(currencySettings).where(eq(currencySettings.isActive, true));
};
var getAllCurrencySettings = async () => {
  return await db.select().from(currencySettings);
};
var updateCurrencySettings = async (id, data) => {
  const result = await db.update(currencySettings).set({ ...data, updatedAt: /* @__PURE__ */ new Date() }).where(eq(currencySettings.id, id)).returning();
  return result[0];
};
var getLanguageSettings = async () => {
  return await db.select().from(languageSettings).where(eq(languageSettings.isActive, true));
};
var getAllLanguageSettings = async () => {
  return await db.select().from(languageSettings);
};
var getDefaultLanguage = async () => {
  const result = await db.select().from(languageSettings).where(eq(languageSettings.isDefault, true)).limit(1);
  return result[0];
};
var updateLanguageSettings = async (id, data) => {
  const result = await db.update(languageSettings).set(data).where(eq(languageSettings.id, id)).returning();
  return result[0];
};
var testConnection = async () => {
  try {
    await db.select().from(users).limit(1);
    console.log("\u2705 Database connection successful");
    return true;
  } catch (error) {
    console.error("\u274C Database connection failed:", error);
    return false;
  }
};
var storage = {
  // User operations
  getUser,
  createUser,
  // Admin operations
  getAdminUser,
  getAdminUserByUsername,
  getAdminUserByEmail,
  createAdminUser,
  createAdminSession,
  getAdminSession,
  deleteAdminSession,
  // Appointments
  getAppointments,
  getAppointmentsByDate,
  createAppointment,
  updateAppointment,
  updateAppointmentStatus,
  deleteAppointment,
  // Services
  getServices,
  getActiveServices,
  createService,
  updateService,
  deleteService,
  // Reviews
  getApprovedReviews,
  getReviews,
  createReview,
  updateReview,
  approveReview,
  deleteReview,
  // Gallery
  getActiveGalleryImages,
  getGalleryImages,
  createGalleryImage,
  updateGalleryImage,
  deleteGalleryImage,
  // Blog
  getPublishedBlogPosts,
  getBlogPosts,
  getBlogPost,
  getBlogPostsByCategory,
  createBlogPost,
  updateBlogPost,
  deleteBlogPost,
  // Company info
  getCompanyInfo,
  getCompanyInfoBySection,
  upsertCompanyInfo,
  // Site config
  getSiteConfig,
  getSiteConfigByKey,
  updateSiteConfig,
  createSiteConfig,
  // Currency settings
  getCurrencySettings,
  getAllCurrencySettings,
  updateCurrencySettings,
  // Language settings
  getLanguageSettings,
  getAllLanguageSettings,
  getDefaultLanguage,
  updateLanguageSettings,
  // Test
  testConnection
};

// server/routes.ts
import { z as z2 } from "zod";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
var JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error("JWT_SECRET environment variable is required for security");
}
var verifyAdminToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace("Bearer ", "");
    if (!token) {
      return res.status(401).json({ error: "Token required" });
    }
    const session = await storage.getAdminSession(token);
    if (!session) {
      return res.status(401).json({ error: "Invalid or expired token" });
    }
    const adminUser = await storage.getAdminUser(session.userId);
    if (!adminUser || !adminUser.active) {
      return res.status(401).json({ error: "User not found or inactive" });
    }
    req.adminUser = adminUser;
    next();
  } catch (error) {
    console.error("Auth error:", error);
    res.status(401).json({ error: "Authentication failed" });
  }
};
async function registerRoutes(app2) {
  app2.post("/api/admin/login", async (req, res) => {
    try {
      const { username, password } = req.body;
      if (!username || !password) {
        return res.status(400).json({ error: "Username and password required" });
      }
      const adminUser = await storage.getAdminUserByUsername(username);
      if (!adminUser || !adminUser.active) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
      const isValidPassword = await bcrypt.compare(password, adminUser.password);
      if (!isValidPassword) {
        return res.status(401).json({ error: "Invalid credentials" });
      }
      const token = jwt.sign({ userId: adminUser.id }, JWT_SECRET);
      const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1e3);
      await storage.createAdminSession({
        userId: adminUser.id,
        token,
        expiresAt
      });
      res.json({
        token,
        user: {
          id: adminUser.id,
          username: adminUser.username,
          email: adminUser.email,
          role: adminUser.role
        }
      });
    } catch (error) {
      console.error("Login error:", error);
      res.status(500).json({ error: "Login failed" });
    }
  });
  app2.post("/api/admin/logout", verifyAdminToken, async (req, res) => {
    try {
      const token = req.headers.authorization?.replace("Bearer ", "");
      if (token) {
        await storage.deleteAdminSession(token);
      }
      res.json({ message: "Logged out successfully" });
    } catch (error) {
      console.error("Logout error:", error);
      res.status(500).json({ error: "Logout failed" });
    }
  });
  app2.get("/api/admin/me", async (req, res) => {
    try {
      const token = req.cookies?.token || req.headers.authorization?.replace("Bearer ", "");
      if (!token) {
        return res.status(401).json({ error: "Token required" });
      }
      const session = await storage.getAdminSession(token);
      if (!session) {
        return res.status(401).json({ error: "Invalid or expired token" });
      }
      const user = await storage.getAdminUser(session.userId);
      if (!user) {
        return res.status(401).json({ error: "User not found" });
      }
      res.json({
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      });
    } catch (error) {
      console.error("Auth check error:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  });
  app2.get("/api/admin/appointments", verifyAdminToken, async (req, res) => {
    try {
      const appointments2 = await storage.getAppointments();
      res.json(appointments2);
    } catch (error) {
      console.error("Error fetching admin appointments:", error);
      res.status(500).json({ error: "Failed to fetch appointments" });
    }
  });
  app2.put("/api/admin/appointments/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      const appointment = await storage.updateAppointment(id, req.body);
      if (!appointment) {
        return res.status(404).json({ error: "Appointment not found" });
      }
      res.json(appointment);
    } catch (error) {
      console.error("Error updating appointment:", error);
      res.status(500).json({ error: "Failed to update appointment" });
    }
  });
  app2.delete("/api/admin/appointments/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      await storage.deleteAppointment(id);
      res.json({ message: "Appointment deleted" });
    } catch (error) {
      console.error("Error deleting appointment:", error);
      res.status(500).json({ error: "Failed to delete appointment" });
    }
  });
  app2.get("/api/admin/services", verifyAdminToken, async (req, res) => {
    try {
      const services2 = await storage.getServices();
      res.json(services2);
    } catch (error) {
      console.error("Error fetching admin services:", error);
      res.status(500).json({ error: "Failed to fetch services" });
    }
  });
  app2.post("/api/admin/services", verifyAdminToken, async (req, res) => {
    try {
      const validatedData = insertServiceSchema.parse(req.body);
      const service = await storage.createService(validatedData);
      res.status(201).json(service);
    } catch (error) {
      if (error instanceof z2.ZodError) {
        res.status(400).json({ error: "Invalid service data", details: error.errors });
      } else {
        console.error("Error creating service:", error);
        res.status(500).json({ error: "Failed to create service" });
      }
    }
  });
  app2.put("/api/admin/services/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      const service = await storage.updateService(id, req.body);
      if (!service) {
        return res.status(404).json({ error: "Service not found" });
      }
      res.json(service);
    } catch (error) {
      console.error("Error updating service:", error);
      res.status(500).json({ error: "Failed to update service" });
    }
  });
  app2.delete("/api/admin/services/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      await storage.deleteService(id);
      res.json({ message: "Service deleted" });
    } catch (error) {
      console.error("Error deleting service:", error);
      res.status(500).json({ error: "Failed to delete service" });
    }
  });
  app2.get("/api/admin/gallery", verifyAdminToken, async (req, res) => {
    try {
      const images = await storage.getGalleryImages();
      res.json(images);
    } catch (error) {
      console.error("Error fetching admin gallery:", error);
      res.status(500).json({ error: "Failed to fetch gallery images" });
    }
  });
  app2.post("/api/admin/gallery", verifyAdminToken, async (req, res) => {
    try {
      const validatedData = insertGalleryImageSchema.parse(req.body);
      const image = await storage.createGalleryImage(validatedData);
      res.status(201).json(image);
    } catch (error) {
      if (error instanceof z2.ZodError) {
        res.status(400).json({ error: "Invalid gallery image data", details: error.errors });
      } else {
        console.error("Error creating gallery image:", error);
        res.status(500).json({ error: "Failed to create gallery image" });
      }
    }
  });
  app2.put("/api/admin/gallery/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      const image = await storage.updateGalleryImage(id, req.body);
      if (!image) {
        return res.status(404).json({ error: "Gallery image not found" });
      }
      res.json(image);
    } catch (error) {
      console.error("Error updating gallery image:", error);
      res.status(500).json({ error: "Failed to update gallery image" });
    }
  });
  app2.delete("/api/admin/gallery/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      await storage.deleteGalleryImage(id);
      res.json({ message: "Gallery image deleted" });
    } catch (error) {
      console.error("Error deleting gallery image:", error);
      res.status(500).json({ error: "Failed to delete gallery image" });
    }
  });
  app2.get("/api/admin/blog", verifyAdminToken, async (req, res) => {
    try {
      const posts = await storage.getBlogPosts();
      res.json(posts);
    } catch (error) {
      console.error("Error fetching admin blog posts:", error);
      res.status(500).json({ error: "Failed to fetch blog posts" });
    }
  });
  app2.put("/api/admin/blog/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      const post = await storage.updateBlogPost(id, req.body);
      if (!post) {
        return res.status(404).json({ error: "Blog post not found" });
      }
      res.json(post);
    } catch (error) {
      console.error("Error updating blog post:", error);
      res.status(500).json({ error: "Failed to update blog post" });
    }
  });
  app2.delete("/api/admin/blog/:id", verifyAdminToken, async (req, res) => {
    try {
      const { id } = req.params;
      await storage.deleteBlogPost(id);
      res.json({ message: "Blog post deleted" });
    } catch (error) {
      console.error("Error deleting blog post:", error);
      res.status(500).json({ error: "Failed to delete blog post" });
    }
  });
  app2.get("/api/admin/reviews", verifyAdminToken, async (req, res) => {
    try {
      const reviews2 = await storage.getReviews();
      res.json(reviews2);
    } catch (error) {
      console.error("Error fetching admin reviews:", error);
      res.status(500).json({ error: "Failed to fetch reviews" });
    }
  });
  app2.get("/api/admin/company", verifyAdminToken, async (req, res) => {
    try {
      const companyInfo2 = await storage.getCompanyInfo();
      res.json(companyInfo2);
    } catch (error) {
      console.error("Error fetching admin company info:", error);
      res.status(500).json({ error: "Failed to fetch company info" });
    }
  });
  app2.post("/api/admin/company", verifyAdminToken, async (req, res) => {
    try {
      const companyInfoArray = req.body;
      const results = [];
      for (const info of companyInfoArray) {
        const result = await storage.upsertCompanyInfo(info);
        results.push(result);
      }
      res.json(results);
    } catch (error) {
      console.error("Error updating company info:", error);
      res.status(500).json({ error: "Failed to update company info" });
    }
  });
  app2.get("/api/admin/config", verifyAdminToken, async (req, res) => {
    try {
      const config = await storage.getSiteConfig();
      res.json(config);
    } catch (error) {
      console.error("Error fetching admin config:", error);
      res.status(500).json({ error: "Failed to fetch config" });
    }
  });
  app2.post("/api/admin/config", verifyAdminToken, async (req, res) => {
    try {
      await storage.updateSiteConfig(req.body);
      res.json({ message: "Config updated successfully" });
    } catch (error) {
      console.error("Error updating config:", error);
      res.status(500).json({ error: "Failed to update config" });
    }
  });
  app2.get("/api/appointments", async (req, res) => {
    try {
      const appointments2 = await storage.getAppointments();
      res.json(appointments2);
    } catch (error) {
      console.error("Error fetching appointments:", error);
      res.status(500).json({ error: "Failed to fetch appointments" });
    }
  });
  app2.get("/api/appointments/date/:date", async (req, res) => {
    try {
      const { date: date2 } = req.params;
      const appointments2 = await storage.getAppointmentsByDate(date2);
      res.json(appointments2);
    } catch (error) {
      console.error("Error fetching appointments by date:", error);
      res.status(500).json({ error: "Failed to fetch appointments" });
    }
  });
  app2.post("/api/appointments", async (req, res) => {
    try {
      const validatedData = insertAppointmentSchema.parse(req.body);
      const appointment = await storage.createAppointment(validatedData);
      res.status(201).json(appointment);
    } catch (error) {
      if (error instanceof z2.ZodError) {
        res.status(400).json({ error: "Invalid appointment data", details: error.errors });
      } else {
        console.error("Error creating appointment:", error);
        res.status(500).json({ error: "Failed to create appointment" });
      }
    }
  });
  app2.patch("/api/appointments/:id/status", async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body;
      if (!["pending", "confirmed", "completed", "cancelled"].includes(status)) {
        return res.status(400).json({ error: "Invalid status" });
      }
      const appointment = await storage.updateAppointmentStatus(id, status);
      if (!appointment) {
        return res.status(404).json({ error: "Appointment not found" });
      }
      res.json(appointment);
    } catch (error) {
      console.error("Error updating appointment status:", error);
      res.status(500).json({ error: "Failed to update appointment" });
    }
  });
  app2.get("/api/services", async (req, res) => {
    try {
      const servicesList = await storage.getActiveServices();
      res.json(servicesList);
    } catch (error) {
      console.error("Error fetching services:", error);
      res.status(500).json({ error: "Failed to fetch services" });
    }
  });
  app2.get("/api/gallery", async (req, res) => {
    try {
      const images = await storage.getActiveGalleryImages();
      res.json(images);
    } catch (error) {
      console.error("Error fetching gallery:", error);
      res.status(500).json({ error: "Failed to fetch gallery" });
    }
  });
  app2.get("/api/blog", async (req, res) => {
    try {
      const posts = await storage.getPublishedBlogPosts();
      res.json(posts);
    } catch (error) {
      console.error("Error fetching blog posts:", error);
      res.status(500).json({ error: "Failed to fetch blog posts" });
    }
  });
  app2.get("/api/blog/category/:category", async (req, res) => {
    try {
      const { category } = req.params;
      const posts = await storage.getBlogPostsByCategory(category);
      res.json(posts);
    } catch (error) {
      console.error("Error fetching blog posts by category:", error);
      res.status(500).json({ error: "Failed to fetch blog posts" });
    }
  });
  app2.get("/api/blog/:slug", async (req, res) => {
    try {
      const { slug } = req.params;
      const post = await storage.getBlogPost(slug);
      if (!post) {
        return res.status(404).json({ error: "Blog post not found" });
      }
      res.json(post);
    } catch (error) {
      console.error("Error fetching blog post:", error);
      res.status(500).json({ error: "Failed to fetch blog post" });
    }
  });
  app2.post("/api/blog", async (req, res) => {
    try {
      const validatedData = insertBlogPostSchema.parse(req.body);
      const post = await storage.createBlogPost(validatedData);
      res.status(201).json(post);
    } catch (error) {
      if (error instanceof z2.ZodError) {
        res.status(400).json({ error: "Invalid blog post data", details: error.errors });
      } else {
        console.error("Error creating blog post:", error);
        res.status(500).json({ error: "Failed to create blog post" });
      }
    }
  });
  app2.get("/api/reviews", async (req, res) => {
    try {
      const reviews2 = await storage.getApprovedReviews();
      res.json(reviews2);
    } catch (error) {
      console.error("Error fetching reviews:", error);
      res.status(500).json({ error: "Failed to fetch reviews" });
    }
  });
  app2.post("/api/reviews", async (req, res) => {
    try {
      const validatedData = insertReviewSchema.parse(req.body);
      const review = await storage.createReview(validatedData);
      res.status(201).json(review);
    } catch (error) {
      if (error instanceof z2.ZodError) {
        res.status(400).json({ error: "Invalid review data", details: error.errors });
      } else {
        console.error("Error creating review:", error);
        res.status(500).json({ error: "Failed to create review" });
      }
    }
  });
  app2.patch("/api/reviews/:id/approve", async (req, res) => {
    try {
      const { id } = req.params;
      const review = await storage.approveReview(id);
      if (!review) {
        return res.status(404).json({ error: "Review not found" });
      }
      res.json(review);
    } catch (error) {
      console.error("Error approving review:", error);
      res.status(500).json({ error: "Failed to approve review" });
    }
  });
  app2.post("/api/contact", async (req, res) => {
    try {
      const { name, phone, service, message } = req.body;
      if (!name || !phone || !message) {
        return res.status(400).json({ error: "Name, phone and message are required" });
      }
      console.log("Contact form submission:", { name, phone, service, message });
      res.json({ message: "Contact form submitted successfully" });
    } catch (error) {
      console.error("Error processing contact form:", error);
      res.status(500).json({ error: "Failed to process contact form" });
    }
  });
  app2.get("/api/currencies", async (req, res) => {
    try {
      const currencies = await storage.getCurrencySettings();
      res.json(currencies);
    } catch (error) {
      console.error("Error fetching currencies:", error);
      res.status(500).json({ error: "Failed to fetch currencies" });
    }
  });
  app2.get("/api/languages", async (req, res) => {
    try {
      const languages = await storage.getLanguageSettings();
      res.json(languages);
    } catch (error) {
      console.error("Error fetching languages:", error);
      res.status(500).json({ error: "Failed to fetch languages" });
    }
  });
  app2.get("/api/languages/default", async (req, res) => {
    try {
      const defaultLanguage = await storage.getDefaultLanguage();
      res.json(defaultLanguage);
    } catch (error) {
      console.error("Error fetching default language:", error);
      res.status(500).json({ error: "Failed to fetch default language" });
    }
  });
  const httpServer = createServer(app2);
  return httpServer;
}

// server/vite.ts
import express from "express";
import fs from "fs";
import path2 from "path";
import { createServer as createViteServer, createLogger } from "vite";

// vite.config.ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
import runtimeErrorOverlay from "@replit/vite-plugin-runtime-error-modal";
var vite_config_default = defineConfig({
  plugins: [
    react(),
    runtimeErrorOverlay(),
    ...process.env.NODE_ENV !== "production" && process.env.REPL_ID !== void 0 ? [
      await import("@replit/vite-plugin-cartographer").then(
        (m) => m.cartographer()
      ),
      await import("@replit/vite-plugin-dev-banner").then(
        (m) => m.devBanner()
      )
    ] : []
  ],
  resolve: {
    alias: {
      "@": path.resolve(import.meta.dirname, "client", "src"),
      "@shared": path.resolve(import.meta.dirname, "shared"),
      "@assets": path.resolve(import.meta.dirname, "attached_assets")
    }
  },
  root: path.resolve(import.meta.dirname, "client"),
  build: {
    outDir: path.resolve(import.meta.dirname, "dist/public"),
    emptyOutDir: true
  },
  server: {
    host: "0.0.0.0",
    port: 5e3,
    fs: {
      strict: true,
      deny: ["**/.*"]
    }
  }
});

// server/vite.ts
import { nanoid } from "nanoid";
var viteLogger = createLogger();
function log(message, source = "express") {
  const formattedTime = (/* @__PURE__ */ new Date()).toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
    second: "2-digit",
    hour12: true
  });
  console.log(`${formattedTime} [${source}] ${message}`);
}
async function setupVite(app2, server) {
  const serverOptions = {
    middlewareMode: true,
    hmr: { server },
    allowedHosts: true
  };
  const vite = await createViteServer({
    ...vite_config_default,
    configFile: false,
    customLogger: {
      ...viteLogger,
      error: (msg, options) => {
        viteLogger.error(msg, options);
        process.exit(1);
      }
    },
    server: serverOptions,
    appType: "custom"
  });
  app2.use(vite.middlewares);
  app2.use("*", async (req, res, next) => {
    const url = req.originalUrl;
    try {
      const clientTemplate = path2.resolve(
        import.meta.dirname,
        "..",
        "client",
        "index.html"
      );
      let template = await fs.promises.readFile(clientTemplate, "utf-8");
      template = template.replace(
        `src="/src/main.tsx"`,
        `src="/src/main.tsx?v=${nanoid()}"`
      );
      const page = await vite.transformIndexHtml(url, template);
      res.status(200).set({ "Content-Type": "text/html" }).end(page);
    } catch (e) {
      vite.ssrFixStacktrace(e);
      next(e);
    }
  });
}
function serveStatic(app2) {
  const distPath = path2.resolve(import.meta.dirname, "public");
  if (!fs.existsSync(distPath)) {
    throw new Error(
      `Could not find the build directory: ${distPath}, make sure to build the client first`
    );
  }
  app2.use(express.static(distPath));
  app2.use("*", (_req, res) => {
    res.sendFile(path2.resolve(distPath, "index.html"));
  });
}

// server/index.ts
var app = express2();
app.use(express2.json());
app.use(express2.urlencoded({ extended: false }));
app.use((req, res, next) => {
  const start = Date.now();
  const path3 = req.path;
  let capturedJsonResponse = void 0;
  const originalResJson = res.json;
  res.json = function(bodyJson, ...args) {
    capturedJsonResponse = bodyJson;
    return originalResJson.apply(res, [bodyJson, ...args]);
  };
  res.on("finish", () => {
    const duration = Date.now() - start;
    if (path3.startsWith("/api")) {
      let logLine = `${req.method} ${path3} ${res.statusCode} in ${duration}ms`;
      if (capturedJsonResponse) {
        logLine += ` :: ${JSON.stringify(capturedJsonResponse)}`;
      }
      if (logLine.length > 80) {
        logLine = logLine.slice(0, 79) + "\u2026";
      }
      log(logLine);
    }
  });
  next();
});
(async () => {
  const server = await registerRoutes(app);
  app.use((err, _req, res, _next) => {
    const status = err.status || err.statusCode || 500;
    const message = err.message || "Internal Server Error";
    res.status(status).json({ message });
    throw err;
  });
  if (app.get("env") === "development") {
    await setupVite(app, server);
  } else {
    serveStatic(app);
  }
  const port = parseInt(process.env.PORT || "5000", 10);
  server.listen({
    port,
    host: "0.0.0.0",
    reusePort: true
  }, () => {
    log(`serving on port ${port}`);
  });
})();
