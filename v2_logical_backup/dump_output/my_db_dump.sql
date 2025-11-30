--
-- PostgreSQL database dump
--

\restrict g6N4jBKAZVRXfanWdvLm5JOwKoZWrzrnn5jfBoHYeXOCYuaXQIgkaR556J4w106

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: vshepard
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.customers OWNER TO vshepard;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: vshepard
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO vshepard;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vshepard
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: vshepard
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    order_date date NOT NULL
);


ALTER TABLE public.orders OWNER TO vshepard;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: vshepard
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO vshepard;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vshepard
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: vshepard
--

COPY public.customers (id, name) FROM stdin;
1	Alice
2	Bob
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: vshepard
--

COPY public.orders (id, customer_id, order_date) FROM stdin;
1	1	2025-11-01
2	2	2025-11-02
\.


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vshepard
--

SELECT pg_catalog.setval('public.customers_id_seq', 2, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vshepard
--

SELECT pg_catalog.setval('public.orders_id_seq', 2, true);


--
-- Name: customers customers_name_key; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_name_key UNIQUE (name);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- PostgreSQL database dump complete
--

\unrestrict g6N4jBKAZVRXfanWdvLm5JOwKoZWrzrnn5jfBoHYeXOCYuaXQIgkaR556J4w106

