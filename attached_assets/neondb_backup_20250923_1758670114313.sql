--
-- PostgreSQL database dump
--

\restrict gtAVu7T5VzADzsaOl3HHstPixFTmfFzc4oJdWaAU3HZ8zdLQ8fS7Yo8OvzVuzwn

-- Dumped from database version 17.5 (84bec44)
-- Dumped by pg_dump version 17.6 (Ubuntu 17.6-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_sessions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.admin_sessions (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    user_id character varying NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_sessions OWNER TO neondb_owner;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.admin_users (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    username text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    role text DEFAULT 'admin'::text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_users OWNER TO neondb_owner;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.appointments (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    customer_name text NOT NULL,
    customer_phone text NOT NULL,
    customer_email text,
    service_type text NOT NULL,
    appointment_date date NOT NULL,
    appointment_time time without time zone NOT NULL,
    notes text,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT status_check CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'completed'::text, 'cancelled'::text])))
);


ALTER TABLE public.appointments OWNER TO neondb_owner;

--
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.blog_posts (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    title_pt text NOT NULL,
    slug text NOT NULL,
    content text NOT NULL,
    content_pt text NOT NULL,
    excerpt text NOT NULL,
    excerpt_pt text NOT NULL,
    category text NOT NULL,
    image_url text,
    published boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    title_es text,
    content_es text,
    excerpt_es text,
    CONSTRAINT category_check CHECK ((category = ANY (ARRAY['hair-care'::text, 'beard-care'::text, 'styling-tips'::text])))
);


ALTER TABLE public.blog_posts OWNER TO neondb_owner;

--
-- Name: company_info; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.company_info (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    section text NOT NULL,
    title text,
    title_pt text,
    content text,
    content_pt text,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    content_es text
);


ALTER TABLE public.company_info OWNER TO neondb_owner;

--
-- Name: currency_settings; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.currency_settings (
    id integer NOT NULL,
    currency_code character varying(3) NOT NULL,
    currency_name character varying(50) NOT NULL,
    currency_symbol character varying(10) NOT NULL,
    exchange_rate_to_usd numeric(10,6) DEFAULT 1.0,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.currency_settings OWNER TO neondb_owner;

--
-- Name: currency_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.currency_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.currency_settings_id_seq OWNER TO neondb_owner;

--
-- Name: currency_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.currency_settings_id_seq OWNED BY public.currency_settings.id;


--
-- Name: gallery_images; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.gallery_images (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    title text,
    title_pt text,
    image_url text NOT NULL,
    description text,
    description_pt text,
    category text DEFAULT 'general'::text,
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    title_es text,
    description_es text
);


ALTER TABLE public.gallery_images OWNER TO neondb_owner;

--
-- Name: language_settings; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.language_settings (
    id integer NOT NULL,
    language_code character varying(2) NOT NULL,
    language_name character varying(50) NOT NULL,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.language_settings OWNER TO neondb_owner;

--
-- Name: language_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.language_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.language_settings_id_seq OWNER TO neondb_owner;

--
-- Name: language_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.language_settings_id_seq OWNED BY public.language_settings.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.reviews (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    customer_name text NOT NULL,
    rating integer NOT NULL,
    comment text NOT NULL,
    service_type text,
    approved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO neondb_owner;

--
-- Name: services; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.services (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    name_pt text NOT NULL,
    description text NOT NULL,
    description_pt text NOT NULL,
    price numeric(10,2) NOT NULL,
    duration_minutes integer NOT NULL,
    image_url text,
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    price_usd numeric(10,2),
    price_brl numeric(10,2),
    price_pyg numeric(12,0),
    is_popular boolean DEFAULT false,
    name_es text,
    description_es text
);


ALTER TABLE public.services OWNER TO neondb_owner;

--
-- Name: site_config; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.site_config (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    value text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.site_config OWNER TO neondb_owner;

--
-- Name: currency_settings id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.currency_settings ALTER COLUMN id SET DEFAULT nextval('public.currency_settings_id_seq'::regclass);


--
-- Name: language_settings id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.language_settings ALTER COLUMN id SET DEFAULT nextval('public.language_settings_id_seq'::regclass);


--
-- Data for Name: admin_sessions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.admin_sessions (id, user_id, token, expires_at, created_at) FROM stdin;
526199fb-ad9a-4c79-bf42-2b2a47b18af8	23ebe38b-3e9b-47cd-857c-82d34e3b3d70	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIyM2ViZTM4Yi0zZTliLTQ3Y2QtODU3Yy04MmQzNGUzYjNkNzAiLCJpYXQiOjE3NTg2Njk0MDJ9.Bf62RDiGRlViTd6yEhLkBSgJPU5NHZea_o1Ruh2LZdM	2025-09-24 23:16:42.819	2025-09-23 23:16:42.917025
\.


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.admin_users (id, username, email, password, role, active, created_at, updated_at) FROM stdin;
23ebe38b-3e9b-47cd-857c-82d34e3b3d70	admin	admin@barberia.com	$2b$10$FuHFhTc0ctLQqAfTWnUk9e5fbbha/vx2AhragKYn6MRT5R4SM4336	admin	t	2025-09-23 10:10:35.799212	2025-09-23 23:11:53.509984
\.


--
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.appointments (id, customer_name, customer_phone, customer_email, service_type, appointment_date, appointment_time, notes, status, created_at) FROM stdin;
2e32c7d5-5a5a-4196-bc30-11c2eb1015a9	Juan Pérez	+1234567890	juan@example.com	corte-cabello	2024-01-15	10:00:00	\N	confirmed	2025-09-22 22:28:24.249496
94bd9999-8f1a-4474-abf6-16ec6674ecf9	María García	+1234567891	maria@example.com	barba	2024-01-15	11:00:00	\N	pending	2025-09-22 22:28:24.249496
\.


--
-- Data for Name: blog_posts; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.blog_posts (id, title, title_pt, slug, content, content_pt, excerpt, excerpt_pt, category, image_url, published, created_at, updated_at, title_es, content_es, excerpt_es) FROM stdin;
a32894d9-98ff-4d32-b0d6-7cd75fc256fd	Cuidado del Cabello	Cuidado do Cabelo	cuidado-cabello	Contenido completo...	Conteúdo completo...	Extracto...	Extrato...	hair-care	\N	t	2025-09-22 22:28:24.602445	2025-09-22 22:28:24.602445	\N	\N	\N
\.


--
-- Data for Name: company_info; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.company_info (id, section, title, title_pt, content, content_pt, metadata, created_at, updated_at, content_es) FROM stdin;
080ffbfc-5ef5-4cf0-8590-0ed6c51c098e	hero	Barbería Clásica	Barbearia Clássica	Tu barbería de confianza en Ciudad del Este	Sua barbearia de confiança em Ciudad del Este	{"subtitle": "BARBEARIA TRADICIONAL", "subtitle_pt": "BARBEARIA TRADICIONAL"}	2025-09-22 22:39:05.134276	2025-09-23 10:14:26.207826	\N
705eebe0-dca1-4494-8182-0d1c05096f5c	about	Sobre Nosotros	Sobre Nós	Más de 15 años ofreciendo los mejores servicios de barbería en Ciudad del Este. Combinamos técnicas tradicionales con un toque moderno.	Mais de 15 anos oferecendo os melhores serviços de barbearia em Ciudad del Este. Combinamos técnicas tradicionais com um toque moderno.	{"clients_count": "5000+", "experience_years": "15"}	2025-09-22 22:39:05.134276	2025-09-23 10:14:26.207826	\N
1021f62d-1dd6-42ab-b9a6-9bb22befadc5	contact	Contacto	Contato	Av. San Blas 123, Ciudad del Este	Av. San Blas 123, Ciudad del Este	{"email": "info@barberiaclasica.com", "phone": "+595 61 123456", "whatsapp": "+595984123456"}	2025-09-23 10:14:26.207826	2025-09-23 10:14:26.207826	\N
c5e94ccc-06e2-42bc-8f87-6882c9e5093e	hours	Horarios	Horários	Lunes a Viernes: 8:00 - 20:00\\nSábados: 8:00 - 18:00\\nDomingos: Cerrado	Segunda a Sexta: 8:00 - 20:00\\nSábados: 8:00 - 18:00\\nDomingos: Fechado	{}	2025-09-23 10:14:26.207826	2025-09-23 10:14:26.207826	\N
\.


--
-- Data for Name: currency_settings; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.currency_settings (id, currency_code, currency_name, currency_symbol, exchange_rate_to_usd, is_active, created_at, updated_at) FROM stdin;
1	USD	Dólar Estadounidense	$	1.000000	t	2025-09-23 21:44:41.079202	2025-09-23 21:44:41.079202
2	BRL	Real Brasileño	R$	5.500000	t	2025-09-23 21:44:41.079202	2025-09-23 21:44:41.079202
3	PYG	Guaraní Paraguayo	₲	7300.000000	t	2025-09-23 21:44:41.079202	2025-09-23 21:44:41.079202
\.


--
-- Data for Name: gallery_images; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.gallery_images (id, title, title_pt, image_url, description, description_pt, category, active, sort_order, created_at, title_es, description_es) FROM stdin;
4e6658a9-638d-4eb6-b75e-9600bb16f254	Interior Principal	Interior Principal	https://images.unsplash.com/photo-1585747860715-2ba37e788b70	\N	\N	interior	t	0	2025-09-22 22:39:05.326406	\N	\N
85da0677-9e95-45c1-86f1-a45cf1da9d36	Herramientas	Ferramentas	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	\N	\N	tools	t	0	2025-09-22 22:39:05.326406	\N	\N
204c7fb8-ef4d-4f09-a21e-41e8b480536d	Corte Clásico	Corte Clássico	https://images.unsplash.com/photo-1621605815971-fbc98d665033	\N	\N	services	t	0	2025-09-22 22:39:05.326406	\N	\N
a4bf2f1d-3532-45b5-aff1-12bf5b7275ef	Interior Principal	Interior Principal	https://images.unsplash.com/photo-1585747860715-2ba37e788b70	\N	\N	interior	t	0	2025-09-22 22:39:41.094772	\N	\N
21b1ea0e-3e30-418b-8680-aa7a7a543780	Herramientas	Ferramentas	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	\N	\N	tools	t	0	2025-09-22 22:39:41.094772	\N	\N
b778dff2-b379-4d3c-83f3-ecdac6f2bf83	Corte Clásico	Corte Clássico	https://images.unsplash.com/photo-1621605815971-fbc98d665033	\N	\N	services	t	0	2025-09-22 22:39:41.094772	\N	\N
7e65279f-9de7-4e17-8a81-a5c7010e4054	Corte Clásico 1	Corte Clássico 1	https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400	Ejemplo de corte clásico	Exemplo de corte clássico	haircuts	t	1	2025-09-23 10:10:36.155991	\N	\N
a44be9df-8bb9-40ca-b54c-5d699590cf1c	Barbería Interior	Interior da Barbearia	https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400	Interior de nuestra barbería	Interior da nossa barbearia	interior	t	2	2025-09-23 10:10:36.155991	\N	\N
b3761149-8a67-499d-9ccf-2bb5f7941d4d	Corte Clásico Masculino	Corte Clássico Masculino	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	Ejemplo de nuestro corte clásico	Exemplo do nosso corte clássico	cortes	t	1	2025-09-23 10:14:26.032883	\N	\N
035e37a8-1ee7-43b0-9a93-787237451724	Arreglo de Barba	Arreglo de Barba	https://images.unsplash.com/photo-1621605815971-fbc98d665033	Barba perfectamente arreglada	Barba perfeitamente arrumada	barbas	t	2	2025-09-23 10:14:26.032883	\N	\N
4804dc49-737a-4db3-9d09-778f43b96bdf	Interior Barbería	Interior Barbearia	https://images.unsplash.com/photo-1585747860715-2ba37e788b70	Nuestro acogedor interior	Nosso interior aconchegante	local	t	3	2025-09-23 10:14:26.032883	\N	\N
\.


--
-- Data for Name: language_settings; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.language_settings (id, language_code, language_name, is_default, is_active, created_at) FROM stdin;
1	es	Español	t	t	2025-09-23 21:44:41.432026
2	pt	Português	f	t	2025-09-23 21:44:41.432026
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.reviews (id, customer_name, rating, comment, service_type, approved, created_at) FROM stdin;
ca0c6576-8f31-4159-a610-87ca975aab4c	Carlos López	5	Excelente servicio, muy profesional	corte-cabello	t	2025-09-22 22:28:24.427301
98c3006c-39ce-4c5c-9d11-397015d5d520	Ana Martín	4	Muy buena atención, recomendado	barba	t	2025-09-22 22:28:24.427301
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.services (id, name, name_pt, description, description_pt, price, duration_minutes, image_url, active, sort_order, created_at, updated_at, price_usd, price_brl, price_pyg, is_popular, name_es, description_es) FROM stdin;
1bdc6481-6d1e-43f3-87fe-63469f89b5c3	Corte Clásico	Corte Clássico	Corte tradicional con tijera y navaja	Corte tradicional com tesoura e navalha	25.00	45	\N	t	0	2025-09-22 22:39:04.939692	2025-09-22 22:39:04.939692	25.00	137.50	182500	f	\N	\N
fa015ba4-057d-472d-ac14-2bdd47c0e9ac	Barba y Bigote	Barba e Bigode	Arreglo completo de barba y bigote	Arranjo completo de barba e bigode	20.00	30	\N	t	0	2025-09-22 22:39:04.939692	2025-09-22 22:39:04.939692	20.00	110.00	146000	f	\N	\N
8d6de9d6-8b88-499d-b910-2fcb63b79cb5	Corte + Barba	Corte + Barba	Servicio completo de corte y barba	Serviço completo de corte e barba	40.00	75	\N	t	0	2025-09-22 22:39:04.939692	2025-09-22 22:39:04.939692	40.00	220.00	292000	f	\N	\N
7766f643-4ef4-4ea4-bb09-28e0727de03f	Corte Clásico	Corte Clássico	Corte tradicional con tijera y navaja	Corte tradicional com tesoura e navalha	25.00	45	\N	t	0	2025-09-22 22:39:40.742657	2025-09-22 22:39:40.742657	25.00	137.50	182500	f	\N	\N
58965c31-bd45-4b08-abbf-7b88f8325473	Barba y Bigote	Barba e Bigode	Arreglo completo de barba y bigote	Arranjo completo de barba e bigode	20.00	30	\N	t	0	2025-09-22 22:39:40.742657	2025-09-22 22:39:40.742657	20.00	110.00	146000	f	\N	\N
25458afb-61cc-48f9-91a9-6ed0e6cc7174	Corte + Barba	Corte + Barba	Servicio completo de corte y barba	Serviço completo de corte e barba	40.00	75	\N	t	0	2025-09-22 22:39:40.742657	2025-09-22 22:39:40.742657	40.00	220.00	292000	f	\N	\N
c26bcf4a-27df-4df7-806b-bd87b64856f9	Corte Clásico	Corte Clássico	Corte tradicional con tijera y navaja	Corte tradicional com tesoura e navalha	25.00	30	\N	t	1	2025-09-23 10:10:35.975213	2025-09-23 10:10:35.975213	25.00	137.50	182500	f	\N	\N
17db7365-360a-438d-8746-02e9e6e60e6f	Afeitado	Barbeado	Afeitado tradicional con navaja	Barbeado tradicional com navalha	20.00	20	\N	t	2	2025-09-23 10:10:35.975213	2025-09-23 10:10:35.975213	20.00	110.00	146000	f	\N	\N
21bcad20-91d3-4b9b-b142-b03904cbb8a9	Corte + Barba	Corte + Barba	Corte completo más arreglo de barba	Corte completo mais design de barba	40.00	45	\N	t	3	2025-09-23 10:10:35.975213	2025-09-23 10:10:35.975213	40.00	220.00	292000	f	\N	\N
ee13f67c-15cf-4756-a222-e0f31d755d93	Corte Clásico	Corte Clássico	Corte tradicional con tijera y máquina, incluye lavado	Corte tradicional com tesoura e máquina, inclui lavagem	25.00	30	https://images.unsplash.com/photo-1503951914875-452162b0f3f1	t	1	2025-09-23 10:14:25.858824	2025-09-23 10:14:25.858824	25.00	137.50	182500	f	\N	\N
16bd17a9-610a-4fde-9ee4-42d210945e16	Barba Completa	Barba Completa	Arreglo de barba con navaja, incluye toallas calientes	Arreglo de barba com navalha, inclui toalhas quentes	20.00	25	https://images.unsplash.com/photo-1621605815971-fbc98d665033	t	2	2025-09-23 10:14:25.858824	2025-09-23 10:14:25.858824	20.00	110.00	146000	f	\N	\N
b4dd0da7-6334-4734-be3e-3f681e142e92	Corte + Barba	Corte + Barba	Servicio completo de corte y arreglo de barba	Serviço completo de corte e arreglo de barba	40.00	50	https://images.unsplash.com/photo-1599351431202-1e0f0137899a	t	3	2025-09-23 10:14:25.858824	2025-09-23 10:14:25.858824	40.00	220.00	292000	f	\N	\N
\.


--
-- Data for Name: site_config; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.site_config (id, key, value, description, created_at, updated_at) FROM stdin;
144d2e9c-2578-4dfe-89ec-b8d597983188	site_email	info@barberiaclasica.com	Email de contacto	2025-09-22 22:39:40.562549	2025-09-22 22:39:40.562549
53277746-1fca-4d98-b153-72f3c05ebc70	site_phone	+1234567890	Teléfono principal	2025-09-22 22:39:40.562549	2025-09-22 22:39:40.562549
fd38e581-b99f-44f9-a98e-059ff8d73143	whatsapp_number	+1234567890	Número de WhatsApp	2025-09-22 22:39:40.562549	2025-09-22 22:39:40.562549
db7e39f0-3636-4f0d-9c69-3164769c1fa3	address	Calle Principal 123, Ciudad	Dirección física	2025-09-22 22:39:40.562549	2025-09-22 22:39:40.562549
de6fb741-ae55-4055-a91f-2b7b0883dd98	site_name	Barbería Clásica	Nombre del sitio	2025-09-22 22:39:40.562549	2025-09-23 10:14:26.392693
7ccaa500-ab6a-43f5-9448-fdd6991cfe55	site_description	Tu barbería de confianza en Ciudad del Este	Descripción del sitio	2025-09-23 10:14:26.392693	2025-09-23 10:14:26.392693
f1d2330f-f0df-4c97-a7f4-b456b78846d6	google_maps_url	https://maps.google.com/?q=Ciudad+del+Este	URL de Google Maps	2025-09-23 10:14:26.392693	2025-09-23 10:14:26.392693
c17175d4-7e1f-417d-849d-78ac9de58078	facebook_url	https://facebook.com/barberiaclasica	URL de Facebook	2025-09-22 22:39:40.562549	2025-09-23 10:14:26.392693
49ca6006-9592-4e88-a792-7ddef4c6009c	instagram_url	https://instagram.com/barberiaclasica	URL de Instagram	2025-09-22 22:39:40.562549	2025-09-23 10:14:26.392693
01d84fff-76a8-425d-bb9d-12582f4c5374	business_hours	{"monday": "8:00-20:00", "tuesday": "8:00-20:00", "wednesday": "8:00-20:00", "thursday": "8:00-20:00", "friday": "8:00-20:00", "saturday": "8:00-18:00", "sunday": "closed"}	Horarios de atención	2025-09-23 10:14:26.392693	2025-09-23 10:14:26.392693
\.


--
-- Name: currency_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.currency_settings_id_seq', 7, true);


--
-- Name: language_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: neondb_owner
--

SELECT pg_catalog.setval('public.language_settings_id_seq', 5, true);


--
-- Name: admin_sessions admin_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_pkey PRIMARY KEY (id);


--
-- Name: admin_sessions admin_sessions_token_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_token_key UNIQUE (token);


--
-- Name: admin_users admin_users_email_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_email_key UNIQUE (email);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_username_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_username_key UNIQUE (username);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_slug_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_slug_key UNIQUE (slug);


--
-- Name: company_info company_info_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.company_info
    ADD CONSTRAINT company_info_pkey PRIMARY KEY (id);


--
-- Name: company_info company_info_section_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.company_info
    ADD CONSTRAINT company_info_section_key UNIQUE (section);


--
-- Name: currency_settings currency_settings_currency_code_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.currency_settings
    ADD CONSTRAINT currency_settings_currency_code_key UNIQUE (currency_code);


--
-- Name: currency_settings currency_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.currency_settings
    ADD CONSTRAINT currency_settings_pkey PRIMARY KEY (id);


--
-- Name: gallery_images gallery_images_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gallery_images
    ADD CONSTRAINT gallery_images_pkey PRIMARY KEY (id);


--
-- Name: language_settings language_settings_language_code_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.language_settings
    ADD CONSTRAINT language_settings_language_code_key UNIQUE (language_code);


--
-- Name: language_settings language_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.language_settings
    ADD CONSTRAINT language_settings_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: site_config site_config_key_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.site_config
    ADD CONSTRAINT site_config_key_key UNIQUE (key);


--
-- Name: site_config site_config_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.site_config
    ADD CONSTRAINT site_config_pkey PRIMARY KEY (id);


--
-- Name: appointments unique_slot; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT unique_slot UNIQUE (appointment_date, appointment_time);


--
-- Name: admin_sessions admin_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.admin_users(id) ON DELETE CASCADE;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

\unrestrict gtAVu7T5VzADzsaOl3HHstPixFTmfFzc4oJdWaAU3HZ8zdLQ8fS7Yo8OvzVuzwn

