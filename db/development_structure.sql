--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


SET search_path = public, pg_catalog;

--
-- Name: catname(character varying); Type: FUNCTION; Schema: public; Owner: citizen
--

CREATE FUNCTION catname(character varying) RETURNS character varying
    AS $_$SELECT CASE WHEN char_length($1) = 0 OR $1 IS NULL THEN chr(255) ELSE upper($1) END;$_$
    LANGUAGE sql IMMUTABLE;


--
-- Name: catsort(character varying, character varying); Type: FUNCTION; Schema: public; Owner: citizen
--

CREATE FUNCTION catsort(character varying, character varying) RETURNS boolean
    AS $_$SELECT CASE WHEN char_length($2) = 0 AND char_length($1) > 0 THEN true WHEN char_length($1) = 0 THEN false WHEN upper($1) < upper($2) THEN true ELSE false END;$_$
    LANGUAGE sql IMMUTABLE;


--
-- Name: is_this_user(integer, integer); Type: FUNCTION; Schema: public; Owner: citizen
--

CREATE FUNCTION is_this_user(shelter_id integer, user_id integer) RETURNS boolean
    AS $_$select $2 = any(array(select user_id from shelters_users
      where shelter_id = $1))$_$
    LANGUAGE sql;


--
-- Name: task_count(integer); Type: FUNCTION; Schema: public; Owner: citizen
--

CREATE FUNCTION task_count(project_id integer) RETURNS bigint[]
    AS $_$select array[count(*),
        sum(case when done = true then 1 else 0 end)]
        from tasks where project_id = $1
      $_$
    LANGUAGE sql;


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: citizen
--

CREATE OPERATOR < (
    PROCEDURE = catsort,
    LEFTARG = character varying,
    RIGHTARG = character varying
);


SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE categories (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    lock_version integer DEFAULT 0,
    name character varying(255),
    notes text,
    updated_by_id integer
);


--
-- Name: categories_items; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE categories_items (
    category_id integer NOT NULL,
    item_id integer NOT NULL
);


--
-- Name: conditions; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE conditions (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    lock_version integer DEFAULT 0,
    "type" character varying(255),
    shelter_id integer NOT NULL,
    item_id integer NOT NULL,
    notes text,
    qty_needed integer,
    surplus_individual integer,
    surplus_crates integer,
    qty_per_crate integer,
    must_dispose_of_urgently boolean,
    urgency integer,
    crate_preference integer,
    info_source text,
    updated_by_id integer,
    can_buy_local integer,
    load_id integer,
    packaged_as character varying(20)
);


--
-- Name: faq_categories; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE faq_categories (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updated_by_id integer,
    lock_version integer DEFAULT 0,
    name character varying(255),
    "position" integer
);


--
-- Name: faq_entries; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE faq_entries (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updated_by_id integer,
    lock_version integer DEFAULT 0,
    title character varying(255),
    text text,
    faq_category_id integer NOT NULL,
    "position" integer
);


--
-- Name: histories; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE histories (
    id serial NOT NULL,
    "timestamp" timestamp without time zone,
    objtype character varying(255),
    objid integer,
    updated_by_id integer NOT NULL,
    update_desc text,
    obj text,
    was_new boolean
);


--
-- Name: items; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE items (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    lock_version integer DEFAULT 0,
    name character varying(255),
    notes text,
    updated_by_id integer,
    qty_per_pallet integer
);


--
-- Name: loads; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE loads (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updated_by_id integer,
    lock_version integer DEFAULT 0,
    info_source text,
    notes text,
    source_id integer NOT NULL,
    destination_id integer,
    title character varying(255),
    trucker_name character varying(255),
    truck_reg character varying(255),
    status integer,
    ready_by timestamp without time zone,
    etd timestamp without time zone,
    eta timestamp without time zone,
    transport_avail integer,
    routing_type integer
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE projects (
    id serial NOT NULL,
    created_on timestamp without time zone,
    updated_on timestamp without time zone,
    lock_version integer DEFAULT 0,
    shelter_id integer,
    project_name character varying(255),
    project_notes text
);


--
-- Name: resources; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE resources (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updated_by_id integer NOT NULL,
    lock_version integer DEFAULT 0,
    name character varying(255),
    kind character varying(255),
    notes text
);


--
-- Name: resources_shelters; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE resources_shelters (
    resource_id integer NOT NULL,
    shelter_id integer NOT NULL
);


--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE schema_info (
    version integer
);


--
-- Name: searches; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE searches (
    id serial NOT NULL,
    user_id integer,
    save_name character varying(30),
    save_data text,
    created_on timestamp without time zone,
    updated_on timestamp without time zone
);


--
-- Name: shelters; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE shelters (
    id serial NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    lock_version integer DEFAULT 0,
    state character varying(2),
    parish character varying(255),
    town character varying(255),
    name character varying(255),
    dc boolean,
    main_phone character varying(255),
    mgt_contact character varying(255),
    mgt_phone character varying(255),
    supply_contact character varying(255),
    supply_phone character varying(255),
    address text,
    notes text,
    zip integer,
    other_contacts text,
    latitude double precision,
    longitude double precision,
    info_source text,
    red_cross_status integer,
    region character varying(255),
    capacity integer,
    current_population integer,
    updated_by_id integer,
    status integer,
    organization character varying(255),
    dc_population integer,
    dc_shelters integer,
    website character varying(255),
    make_payable_to character varying(255),
    facility_type integer,
    cond_updated_at timestamp without time zone,
    cond_updated_by_id integer,
    dc_more integer,
    hours character varying(255),
    email character varying(255),
    loading_dock integer,
    forklift integer,
    workers integer,
    pallet_jack integer,
    client_contact_name character varying(255),
    client_contact_address character varying(255),
    client_contact_phone character varying(255),
    client_contact_email character varying(255),
    waiting_list integer,
    areas_served character varying(255),
    eligibility character varying(255),
    is_fee_required character varying(255),
    fee_amount numeric(7,2) DEFAULT (0)::double precision,
    payment_forms character varying(255),
    temp_perm character varying(255),
    planned_enddate date,
    fee_is_for character varying(255),
    mission text,
    cat_notes text,
    clients_must_bring character varying(255),
    fee_explanation character varying(255),
    temp_perm_explanation character varying(255),
    waiting_list_explanation character varying(255)
);


--
-- Name: shelters_users; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE shelters_users (
    shelter_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE tasks (
    id serial NOT NULL,
    created_on timestamp without time zone,
    updated_on timestamp without time zone,
    lock_version integer DEFAULT 0,
    project_id integer,
    task_name character varying(255),
    done boolean DEFAULT false,
    "position" integer DEFAULT 0
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: citizen; Tablespace: 
--

CREATE TABLE users (
    id serial NOT NULL,
    "login" character varying(255),
    salted_password character varying(255),
    email character varying(255),
    firstname character varying(255),
    lastname character varying(255),
    salt character varying(255),
    verified integer DEFAULT 0,
    "role" character varying(255),
    security_token character varying(255),
    token_expiry timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    logged_in_at timestamp without time zone,
    deleted integer DEFAULT 0,
    delete_after timestamp without time zone,
    priv_admin boolean,
    priv_write boolean,
    priv_read boolean,
    priv_read_sensitive boolean,
    priv_new_shelters boolean
);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: faq_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY faq_categories
    ADD CONSTRAINT faq_categories_pkey PRIMARY KEY (id);


--
-- Name: faq_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY faq_entries
    ADD CONSTRAINT faq_entries_pkey PRIMARY KEY (id);


--
-- Name: histories_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY histories
    ADD CONSTRAINT histories_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: loads_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY loads
    ADD CONSTRAINT loads_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: resources_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: searches_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY searches
    ADD CONSTRAINT searches_pkey PRIMARY KEY (id);


--
-- Name: shelters_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY shelters
    ADD CONSTRAINT shelters_pkey PRIMARY KEY (id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: citizen; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: item_id; Type: INDEX; Schema: public; Owner: citizen; Tablespace: 
--

CREATE INDEX item_id ON conditions USING btree (item_id);


--
-- Name: su_shelter_id; Type: INDEX; Schema: public; Owner: citizen; Tablespace: 
--

CREATE INDEX su_shelter_id ON shelters_users USING btree (shelter_id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT "$1" FOREIGN KEY (shelter_id) REFERENCES shelters(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY categories_items
    ADD CONSTRAINT "$1" FOREIGN KEY (item_id) REFERENCES items(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY shelters_users
    ADD CONSTRAINT "$1" FOREIGN KEY (shelter_id) REFERENCES shelters(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY shelters
    ADD CONSTRAINT "$1" FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY items
    ADD CONSTRAINT "$1" FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT "$1" FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY histories
    ADD CONSTRAINT "$1" FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT "$1" FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY resources_shelters
    ADD CONSTRAINT "$1" FOREIGN KEY (resource_id) REFERENCES resources(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY faq_entries
    ADD CONSTRAINT "$1" FOREIGN KEY (faq_category_id) REFERENCES faq_categories(id);


--
-- Name: $1; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY loads
    ADD CONSTRAINT "$1" FOREIGN KEY (source_id) REFERENCES shelters(id);


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT "$2" FOREIGN KEY (item_id) REFERENCES items(id);


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY categories_items
    ADD CONSTRAINT "$2" FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY shelters_users
    ADD CONSTRAINT "$2" FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY resources_shelters
    ADD CONSTRAINT "$2" FOREIGN KEY (shelter_id) REFERENCES shelters(id);


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY shelters
    ADD CONSTRAINT "$2" FOREIGN KEY (cond_updated_by_id) REFERENCES users(id);


--
-- Name: $2; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY loads
    ADD CONSTRAINT "$2" FOREIGN KEY (destination_id) REFERENCES shelters(id);


--
-- Name: $3; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT "$3" FOREIGN KEY (updated_by_id) REFERENCES users(id);


--
-- Name: $4; Type: FK CONSTRAINT; Schema: public; Owner: citizen
--

ALTER TABLE ONLY conditions
    ADD CONSTRAINT "$4" FOREIGN KEY (load_id) REFERENCES loads(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_info (version) VALUES (37)