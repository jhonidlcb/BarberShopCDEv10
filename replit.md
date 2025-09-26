# Overview

This is a modern barbershop website built as a full-stack web application. The project showcases a classic barbershop's services, gallery, and contact information with bilingual support (Spanish and Portuguese). It features a professional dark theme design with elegant typography and smooth animations, targeting customers in Ciudad del Este.

The application serves as a business showcase and potential booking platform for a traditional barbershop, emphasizing premium grooming services and classic styling.

## Current Setup Status
✅ **Fully configured and operational in Replit environment**
- Frontend development server running on port 5000 with proper host configuration
- Database schema deployed and connected to Neon PostgreSQL (ep-still-term-acjgon5c-pooler.sa-east-1.aws.neon.tech)
- Admin panel accessible with credentials (username: admin, password: admin123)
- Deployment configuration set for autoscale production environment
- All TypeScript compilation issues resolved
- **Statistics system fully operational**: All admin dashboard analytics working correctly
- **Multi-currency system functioning**: USD, BRL, PYG support with exchange rate management
- **Database connection verified**: Confirmed connection to correct Neon PostgreSQL instance

## Admin Access
- Admin Panel: Visit `/admin` and login with:
  - Username: `admin`
  - Password: `admin123`
  - **Important**: Change default password after first login

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Frontend Architecture
- **Framework**: React 18 with TypeScript for type safety and modern development practices
- **Routing**: Wouter for lightweight client-side routing with minimal bundle size
- **Styling**: Tailwind CSS with a custom dark theme design system featuring warm orange/amber accents
- **UI Components**: Radix UI primitives with shadcn/ui component library for accessible, customizable components
- **State Management**: TanStack Query (React Query) for server state management and data fetching
- **Build Tool**: Vite for fast development and optimized production builds

## Backend Architecture
- **Runtime**: Node.js with Express.js web framework
- **Language**: TypeScript for full-stack type safety
- **Development Setup**: TSX for TypeScript execution in development
- **API Design**: RESTful API structure with `/api` prefix routing
- **Error Handling**: Centralized error middleware with proper HTTP status codes and JSON responses

## Data Storage Solutions
- **ORM**: Drizzle ORM for type-safe database interactions and schema management
- **Database**: PostgreSQL configured through environment variables
- **Connection**: Neon Database serverless driver for PostgreSQL connectivity
- **Migrations**: Drizzle Kit for database schema migrations and version control
- **Development Storage**: In-memory storage implementation for development/testing

## Authentication and Authorization
- **Session Management**: Express sessions with PostgreSQL session store (connect-pg-simple)
- **User Schema**: Basic user model with username/password authentication
- **Security**: Prepared for implementing authentication flows with existing user schema

## External Dependencies
- **Database Hosting**: Neon Database (serverless PostgreSQL)
- **Font Loading**: Google Fonts (Inter, Playfair Display, Fira Code, DM Sans, Geist Mono, Architects Daughter)
- **Image Assets**: Unsplash for stock photography
- **Development Tools**: Replit-specific plugins for development environment integration
- **Form Handling**: React Hook Form with Zod validation schemas
- **Internationalization**: Custom translation system supporting Spanish and Portuguese languages
- **Icons**: Lucide React for consistent iconography
- **Date Utilities**: date-fns for date manipulation and formatting

## Design System
- **Theme**: Custom dark theme with CSS variables for consistent color palette
- **Typography**: Font hierarchy using Inter (sans), Playfair Display (serif), and monospace fonts
- **Component Variants**: Class Variance Authority (CVA) for systematic component styling
- **Responsive Design**: Mobile-first approach with Tailwind's responsive utilities
- **Animations**: CSS-based transitions and hover effects for enhanced user experience

## Development Experience
- **Hot Reload**: Vite HMR with custom error overlays for development
- **Type Checking**: Strict TypeScript configuration with path mapping
- **Code Quality**: ESM modules throughout the stack for modern JavaScript practices
- **Build Process**: Separate client and server builds with esbuild for server bundling