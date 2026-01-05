--
-- PostgreSQL database dump
--

\restrict 8GMfrAWOXTGgSsEMXObNckYzFOavnLvZRrv91WgtmCRhUk2eS0DfTut0LK7z1P1

-- Dumped from database version 18.0 (Ubuntu 18.0-1.pgdg22.04+3)
-- Dumped by pg_dump version 18.0 (Ubuntu 18.0-1.pgdg22.04+3)

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

--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: vshepard
--

COPY public.categories (id, name, description, created_at) FROM stdin;
1	Electronics	Electronic devices and gadgets	2026-01-05 12:46:38.57109
2	Office	Office supplies and equipment	2026-01-05 12:46:38.57109
3	Gaming	Gaming accessories and peripherals	2026-01-05 12:46:38.57109
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: vshepard
--

COPY public.products (id, name, price, category_id, last_updated, is_active) FROM stdin;
1	MacBook Pro	1999.99	1	2026-01-05 12:46:38.57109	t
2	Wireless Mouse	59.99	2	2026-01-05 12:46:38.57109	t
3	Gaming Keyboard	149.99	3	2026-01-05 12:46:38.57109	t
4	Monitor 4K	399.99	1	2026-01-05 12:46:38.57109	t
\.


--
-- Data for Name: sales_transactions; Type: TABLE DATA; Schema: public; Owner: vshepard
--

COPY public.sales_transactions (id, product_id, customer_email, quantity, unit_price, sale_date) FROM stdin;
1	1	alice@example.com	1	1999.99	2026-01-05 12:46:38.57109
2	2	bob@example.com	2	59.99	2026-01-05 12:46:38.57109
3	3	charlie@example.com	1	149.99	2026-01-05 12:46:38.57109
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vshepard
--

SELECT pg_catalog.setval('public.categories_id_seq', 3, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vshepard
--

SELECT pg_catalog.setval('public.products_id_seq', 4, true);


--
-- Name: sales_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vshepard
--

SELECT pg_catalog.setval('public.sales_transactions_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--

\unrestrict 8GMfrAWOXTGgSsEMXObNckYzFOavnLvZRrv91WgtmCRhUk2eS0DfTut0LK7z1P1

