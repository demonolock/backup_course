--
-- PostgreSQL database dump
--

\restrict S4na2z6XKiICM7zE8pdLct2pCBcAAgs2k1negWAxVTGoshf2BrbomZaejqmobfZ

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
-- Name: update_product_timestamp(); Type: FUNCTION; Schema: public; Owner: vshepard
--

CREATE FUNCTION public.update_product_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_product_timestamp() OWNER TO vshepard;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: vshepard
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.categories OWNER TO vshepard;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: vshepard
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO vshepard;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vshepard
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: vshepard
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name text NOT NULL,
    price numeric(10,2) NOT NULL,
    category_id integer,
    last_updated timestamp without time zone DEFAULT now(),
    is_active boolean DEFAULT true,
    CONSTRAINT products_price_check CHECK ((price > (0)::numeric))
);


ALTER TABLE public.products OWNER TO vshepard;

--
-- Name: sales_transactions; Type: TABLE; Schema: public; Owner: vshepard
--

CREATE TABLE public.sales_transactions (
    id integer NOT NULL,
    product_id integer NOT NULL,
    customer_email text NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    total_amount numeric(10,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    sale_date timestamp without time zone DEFAULT now(),
    CONSTRAINT sales_transactions_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.sales_transactions OWNER TO vshepard;

--
-- Name: product_sales_summary; Type: VIEW; Schema: public; Owner: vshepard
--

CREATE VIEW public.product_sales_summary AS
 SELECT p.name AS product_name,
    c.name AS category_name,
    count(st.id) AS total_sales,
    sum(st.total_amount) AS total_revenue
   FROM ((public.products p
     LEFT JOIN public.categories c ON ((p.category_id = c.id)))
     LEFT JOIN public.sales_transactions st ON ((p.id = st.product_id)))
  GROUP BY p.id, p.name, c.name;


ALTER VIEW public.product_sales_summary OWNER TO vshepard;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: vshepard
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO vshepard;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vshepard
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: sales_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: vshepard
--

CREATE SEQUENCE public.sales_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_transactions_id_seq OWNER TO vshepard;

--
-- Name: sales_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vshepard
--

ALTER SEQUENCE public.sales_transactions_id_seq OWNED BY public.sales_transactions.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: sales_transactions id; Type: DEFAULT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.sales_transactions ALTER COLUMN id SET DEFAULT nextval('public.sales_transactions_id_seq'::regclass);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: sales_transactions sales_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.sales_transactions
    ADD CONSTRAINT sales_transactions_pkey PRIMARY KEY (id);


--
-- Name: idx_products_category; Type: INDEX; Schema: public; Owner: vshepard
--

CREATE INDEX idx_products_category ON public.products USING btree (category_id);


--
-- Name: idx_products_name; Type: INDEX; Schema: public; Owner: vshepard
--

CREATE INDEX idx_products_name ON public.products USING btree (name);


--
-- Name: idx_sales_customer; Type: INDEX; Schema: public; Owner: vshepard
--

CREATE INDEX idx_sales_customer ON public.sales_transactions USING btree (customer_email);


--
-- Name: idx_sales_date; Type: INDEX; Schema: public; Owner: vshepard
--

CREATE INDEX idx_sales_date ON public.sales_transactions USING btree (sale_date);


--
-- Name: idx_sales_product_id; Type: INDEX; Schema: public; Owner: vshepard
--

CREATE INDEX idx_sales_product_id ON public.sales_transactions USING btree (product_id);


--
-- Name: products trigger_update_product_timestamp; Type: TRIGGER; Schema: public; Owner: vshepard
--

CREATE TRIGGER trigger_update_product_timestamp BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_product_timestamp();


--
-- Name: products fk_products_category; Type: FK CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: sales_transactions fk_sales_product; Type: FK CONSTRAINT; Schema: public; Owner: vshepard
--

ALTER TABLE ONLY public.sales_transactions
    ADD CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- PostgreSQL database dump complete
--

\unrestrict S4na2z6XKiICM7zE8pdLct2pCBcAAgs2k1negWAxVTGoshf2BrbomZaejqmobfZ

