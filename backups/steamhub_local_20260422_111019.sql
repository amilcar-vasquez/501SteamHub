--
-- PostgreSQL database dump
--

\restrict Bitm1f30mb4kt0Ikzyg7dA1i26vd49j7YacQD14vz47aNesqTwYqY7Ijq0snNRk

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: mig_audit; Type: SCHEMA; Schema: -; Owner: 501SteamHub
--

CREATE SCHEMA mig_audit;


ALTER SCHEMA mig_audit OWNER TO "501SteamHub";

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: 501SteamHub
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO "501SteamHub";

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: 501SteamHub
--

COMMENT ON SCHEMA public IS '';


--
-- Name: resource_category; Type: TYPE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TYPE mig_audit.resource_category AS ENUM (
    'LessonPlan',
    'Video',
    'Slideshow',
    'Assessment',
    'Other'
);


ALTER TYPE mig_audit.resource_category OWNER TO "501SteamHub";

--
-- Name: resource_status; Type: TYPE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TYPE mig_audit.resource_status AS ENUM (
    'Draft',
    'Submitted',
    'UnderReview',
    'NeedsRevision',
    'Rejected',
    'Approved',
    'DesignCurate',
    'Published',
    'Indexed',
    'Archived'
);


ALTER TYPE mig_audit.resource_status OWNER TO "501SteamHub";

--
-- Name: review_decision; Type: TYPE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TYPE mig_audit.review_decision AS ENUM (
    'Approved',
    'Rejected'
);


ALTER TYPE mig_audit.review_decision OWNER TO "501SteamHub";

--
-- Name: grade_level; Type: TYPE; Schema: public; Owner: 501SteamHub
--

CREATE TYPE public.grade_level AS ENUM (
    'Preschool',
    'Infant 1',
    'Infant 2',
    'Standard 1',
    'Standard 2',
    'Standard 3',
    'Standard 4',
    'Standard 5',
    'Standard 6',
    'Mixed'
);


ALTER TYPE public.grade_level OWNER TO "501SteamHub";

--
-- Name: resource_category; Type: TYPE; Schema: public; Owner: 501SteamHub
--

CREATE TYPE public.resource_category AS ENUM (
    'LessonPlan',
    'Video',
    'Slideshow',
    'Assessment',
    'Other'
);


ALTER TYPE public.resource_category OWNER TO "501SteamHub";

--
-- Name: resource_status; Type: TYPE; Schema: public; Owner: 501SteamHub
--

CREATE TYPE public.resource_status AS ENUM (
    'Draft',
    'Submitted',
    'UnderReview',
    'Rejected',
    'Approved',
    'DesignCurate',
    'Published',
    'Indexed',
    'Archived',
    'NeedsRevision'
);


ALTER TYPE public.resource_status OWNER TO "501SteamHub";

--
-- Name: review_decision; Type: TYPE; Schema: public; Owner: 501SteamHub
--

CREATE TYPE public.review_decision AS ENUM (
    'Approved',
    'Rejected'
);


ALTER TYPE public.review_decision OWNER TO "501SteamHub";

--
-- Name: subject; Type: TYPE; Schema: public; Owner: 501SteamHub
--

CREATE TYPE public.subject AS ENUM (
    'Computer Science',
    'Information Technology',
    'Science',
    'Engineering',
    'Robotics',
    'Arts',
    'Belizean History',
    'Mathematics',
    'English Language Arts',
    'Social Studies',
    'Physical Education'
);


ALTER TYPE public.subject OWNER TO "501SteamHub";

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: mig_audit; Owner: 501SteamHub
--

CREATE FUNCTION mig_audit.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION mig_audit.update_updated_at_column() OWNER TO "501SteamHub";

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: 501SteamHub
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO "501SteamHub";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_tokens; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.auth_tokens (
    token_id integer NOT NULL,
    user_id integer NOT NULL,
    token bytea NOT NULL,
    scope character varying(100),
    expires_at timestamp(0) with time zone NOT NULL,
    created_at timestamp(0) with time zone DEFAULT now()
);


ALTER TABLE mig_audit.auth_tokens OWNER TO "501SteamHub";

--
-- Name: auth_tokens_token_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.auth_tokens_token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.auth_tokens_token_id_seq OWNER TO "501SteamHub";

--
-- Name: auth_tokens_token_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.auth_tokens_token_id_seq OWNED BY mig_audit.auth_tokens.token_id;


--
-- Name: contributions; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.contributions (
    contribution_id integer NOT NULL,
    resource_id integer NOT NULL,
    score numeric(6,2) NOT NULL,
    calculated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.contributions OWNER TO "501SteamHub";

--
-- Name: contributions_contribution_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.contributions_contribution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.contributions_contribution_id_seq OWNER TO "501SteamHub";

--
-- Name: contributions_contribution_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.contributions_contribution_id_seq OWNED BY mig_audit.contributions.contribution_id;


--
-- Name: cycles; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.cycles (
    id integer NOT NULL,
    cycle_number integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.cycles OWNER TO "501SteamHub";

--
-- Name: cycles_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.cycles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.cycles_id_seq OWNER TO "501SteamHub";

--
-- Name: cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.cycles_id_seq OWNED BY mig_audit.cycles.id;


--
-- Name: fellow_applications; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.fellow_applications (
    application_id integer NOT NULL,
    user_id integer NOT NULL,
    organization character varying(200) NOT NULL,
    subjects text[] DEFAULT '{}'::text[] NOT NULL,
    grade_levels text[] DEFAULT '{}'::text[] NOT NULL,
    experience_years integer DEFAULT 0 NOT NULL,
    bio text NOT NULL,
    credentials_link character varying(500),
    status character varying(20) DEFAULT 'Pending'::character varying NOT NULL,
    reviewed_by integer,
    reviewed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    moe_identifier character varying(50) NOT NULL,
    moe_doc_path text,
    CONSTRAINT chk_fellow_applications_status CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Approved'::character varying, 'Rejected'::character varying])::text[])))
);


ALTER TABLE mig_audit.fellow_applications OWNER TO "501SteamHub";

--
-- Name: fellow_applications_application_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.fellow_applications_application_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.fellow_applications_application_id_seq OWNER TO "501SteamHub";

--
-- Name: fellow_applications_application_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.fellow_applications_application_id_seq OWNED BY mig_audit.fellow_applications.application_id;


--
-- Name: fellows; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.fellows (
    fellow_id integer NOT NULL,
    user_id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    moe_identifier character varying(50) NOT NULL,
    school character varying(150),
    subject_specialization character varying(100),
    district character varying(100),
    profile_status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    steam_points numeric(10,2) DEFAULT 0.0,
    source_application_id bigint,
    moe_identifier_verified boolean DEFAULT false,
    verified_at timestamp without time zone,
    verified_by bigint
);


ALTER TABLE mig_audit.fellows OWNER TO "501SteamHub";

--
-- Name: fellows_fellow_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.fellows_fellow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.fellows_fellow_id_seq OWNER TO "501SteamHub";

--
-- Name: fellows_fellow_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.fellows_fellow_id_seq OWNED BY mig_audit.fellows.fellow_id;


--
-- Name: grade_levels; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.grade_levels (
    grade_level character varying(50) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE mig_audit.grade_levels OWNER TO "501SteamHub";

--
-- Name: grade_levels_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.grade_levels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.grade_levels_id_seq OWNER TO "501SteamHub";

--
-- Name: grade_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.grade_levels_id_seq OWNED BY mig_audit.grade_levels.id;


--
-- Name: ilos; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.ilos (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    grade_level_id integer NOT NULL,
    cycle_id integer NOT NULL,
    strand_id integer NOT NULL,
    ilo_code text NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.ilos OWNER TO "501SteamHub";

--
-- Name: ilos_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.ilos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.ilos_id_seq OWNER TO "501SteamHub";

--
-- Name: ilos_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.ilos_id_seq OWNED BY mig_audit.ilos.id;


--
-- Name: lesson_versions; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.lesson_versions (
    version_id integer NOT NULL,
    lesson_id integer NOT NULL,
    version_number integer NOT NULL,
    content text NOT NULL,
    change_description text,
    changed_by integer NOT NULL,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.lesson_versions OWNER TO "501SteamHub";

--
-- Name: lesson_versions_version_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.lesson_versions_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.lesson_versions_version_id_seq OWNER TO "501SteamHub";

--
-- Name: lesson_versions_version_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.lesson_versions_version_id_seq OWNED BY mig_audit.lesson_versions.version_id;


--
-- Name: lessons; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.lessons (
    lesson_id integer NOT NULL,
    resource_id integer NOT NULL,
    lesson_number integer NOT NULL,
    title character varying(255) NOT NULL,
    duration_minutes integer,
    objectives text[],
    materials text[],
    content text NOT NULL,
    assessment text,
    differentiation text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.lessons OWNER TO "501SteamHub";

--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.lessons_lesson_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.lessons_lesson_id_seq OWNER TO "501SteamHub";

--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.lessons_lesson_id_seq OWNED BY mig_audit.lessons.lesson_id;


--
-- Name: notifications; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.notifications (
    notification_id integer NOT NULL,
    user_id integer,
    message text NOT NULL,
    channel character varying(50) DEFAULT 'email'::character varying,
    sent_at timestamp without time zone DEFAULT now(),
    read boolean DEFAULT false
);


ALTER TABLE mig_audit.notifications OWNER TO "501SteamHub";

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.notifications_notification_id_seq OWNER TO "501SteamHub";

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.notifications_notification_id_seq OWNED BY mig_audit.notifications.notification_id;


--
-- Name: resource_access; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_access (
    access_id integer NOT NULL,
    resource_id integer NOT NULL,
    user_id integer NOT NULL,
    accessed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.resource_access OWNER TO "501SteamHub";

--
-- Name: resource_access_access_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.resource_access_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.resource_access_access_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_access_access_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.resource_access_access_id_seq OWNED BY mig_audit.resource_access.access_id;


--
-- Name: resource_comments; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_comments (
    comment_id integer NOT NULL,
    resource_id integer NOT NULL,
    user_id integer NOT NULL,
    parent_comment_id integer,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.resource_comments OWNER TO "501SteamHub";

--
-- Name: resource_comments_comment_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.resource_comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.resource_comments_comment_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.resource_comments_comment_id_seq OWNED BY mig_audit.resource_comments.comment_id;


--
-- Name: resource_grade_levels; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_grade_levels (
    resource_id integer NOT NULL,
    grade_level_id integer
);


ALTER TABLE mig_audit.resource_grade_levels OWNER TO "501SteamHub";

--
-- Name: resource_ilos; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_ilos (
    id integer NOT NULL,
    resource_id integer NOT NULL,
    ilo_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.resource_ilos OWNER TO "501SteamHub";

--
-- Name: resource_ilos_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.resource_ilos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.resource_ilos_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_ilos_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.resource_ilos_id_seq OWNED BY mig_audit.resource_ilos.id;


--
-- Name: resource_links; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_links (
    link_id integer NOT NULL,
    parent_resource_id integer NOT NULL,
    linked_resource_id integer NOT NULL,
    relationship_type character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_different_resources CHECK ((parent_resource_id <> linked_resource_id))
);


ALTER TABLE mig_audit.resource_links OWNER TO "501SteamHub";

--
-- Name: resource_links_link_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.resource_links_link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.resource_links_link_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_links_link_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.resource_links_link_id_seq OWNED BY mig_audit.resource_links.link_id;


--
-- Name: resource_reviews; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_reviews (
    review_id integer NOT NULL,
    resource_id integer NOT NULL,
    reviewer_id integer NOT NULL,
    reviewer_role_id integer NOT NULL,
    decision mig_audit.review_decision NOT NULL,
    comment_summary text,
    reviewed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.resource_reviews OWNER TO "501SteamHub";

--
-- Name: resource_reviews_review_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.resource_reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.resource_reviews_review_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.resource_reviews_review_id_seq OWNED BY mig_audit.resource_reviews.review_id;


--
-- Name: resource_status_history; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_status_history (
    history_id integer NOT NULL,
    resource_id integer NOT NULL,
    old_status mig_audit.resource_status,
    new_status mig_audit.resource_status NOT NULL,
    changed_by integer,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.resource_status_history OWNER TO "501SteamHub";

--
-- Name: resource_status_history_history_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.resource_status_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.resource_status_history_history_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_status_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.resource_status_history_history_id_seq OWNED BY mig_audit.resource_status_history.history_id;


--
-- Name: resource_subjects; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resource_subjects (
    resource_id integer NOT NULL,
    subject_id integer
);


ALTER TABLE mig_audit.resource_subjects OWNER TO "501SteamHub";

--
-- Name: resources; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.resources (
    resource_id integer NOT NULL,
    title character varying(255) NOT NULL,
    slug character varying(255),
    summary text,
    category mig_audit.resource_category NOT NULL,
    drive_link text,
    status mig_audit.resource_status DEFAULT 'Draft'::mig_audit.resource_status NOT NULL,
    published_url text,
    contributor_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_published_url_required CHECK (((status <> ALL (ARRAY['Published'::mig_audit.resource_status, 'Indexed'::mig_audit.resource_status, 'Archived'::mig_audit.resource_status])) OR (published_url IS NOT NULL)))
);


ALTER TABLE mig_audit.resources OWNER TO "501SteamHub";

--
-- Name: resources_resource_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.resources_resource_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.resources_resource_id_seq OWNER TO "501SteamHub";

--
-- Name: resources_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.resources_resource_id_seq OWNED BY mig_audit.resources.resource_id;


--
-- Name: review_comments; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.review_comments (
    comment_id integer NOT NULL,
    resource_id integer NOT NULL,
    reviewer_id integer NOT NULL,
    section character varying(100),
    block_index integer,
    comment text NOT NULL,
    resolved boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamp without time zone
);


ALTER TABLE mig_audit.review_comments OWNER TO "501SteamHub";

--
-- Name: review_comments_comment_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.review_comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.review_comments_comment_id_seq OWNER TO "501SteamHub";

--
-- Name: review_comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.review_comments_comment_id_seq OWNED BY mig_audit.review_comments.comment_id;


--
-- Name: roles; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.roles (
    role_id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text
);


ALTER TABLE mig_audit.roles OWNER TO "501SteamHub";

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.roles_role_id_seq OWNER TO "501SteamHub";

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.roles_role_id_seq OWNED BY mig_audit.roles.role_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE mig_audit.schema_migrations OWNER TO "501SteamHub";

--
-- Name: strands; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.strands (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE mig_audit.strands OWNER TO "501SteamHub";

--
-- Name: strands_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.strands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.strands_id_seq OWNER TO "501SteamHub";

--
-- Name: strands_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.strands_id_seq OWNED BY mig_audit.strands.id;


--
-- Name: subjects; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.subjects (
    subject character varying(150) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE mig_audit.subjects OWNER TO "501SteamHub";

--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.subjects_id_seq OWNER TO "501SteamHub";

--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.subjects_id_seq OWNED BY mig_audit.subjects.id;


--
-- Name: users; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.users (
    user_id integer NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role_id integer,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    created_by integer,
    updated_at timestamp without time zone DEFAULT now(),
    updated_by integer
);


ALTER TABLE mig_audit.users OWNER TO "501SteamHub";

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.users_user_id_seq OWNER TO "501SteamHub";

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.users_user_id_seq OWNED BY mig_audit.users.user_id;


--
-- Name: video_metadata; Type: TABLE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TABLE mig_audit.video_metadata (
    id bigint NOT NULL,
    resource_id bigint NOT NULL,
    youtube_title character varying(100) NOT NULL,
    youtube_description text DEFAULT ''::text NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    privacy_status character varying(20) DEFAULT 'unlisted'::character varying NOT NULL,
    made_for_kids boolean DEFAULT false NOT NULL,
    category_id integer DEFAULT 27 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT video_metadata_privacy_status_check CHECK (((privacy_status)::text = ANY ((ARRAY['public'::character varying, 'private'::character varying, 'unlisted'::character varying])::text[])))
);


ALTER TABLE mig_audit.video_metadata OWNER TO "501SteamHub";

--
-- Name: video_metadata_id_seq; Type: SEQUENCE; Schema: mig_audit; Owner: 501SteamHub
--

CREATE SEQUENCE mig_audit.video_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mig_audit.video_metadata_id_seq OWNER TO "501SteamHub";

--
-- Name: video_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: mig_audit; Owner: 501SteamHub
--

ALTER SEQUENCE mig_audit.video_metadata_id_seq OWNED BY mig_audit.video_metadata.id;


--
-- Name: auth_tokens; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.auth_tokens (
    token_id integer NOT NULL,
    user_id integer NOT NULL,
    token bytea NOT NULL,
    scope character varying(100),
    expires_at timestamp(0) with time zone NOT NULL,
    created_at timestamp(0) with time zone DEFAULT now()
);


ALTER TABLE public.auth_tokens OWNER TO "501SteamHub";

--
-- Name: auth_tokens_token_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.auth_tokens_token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auth_tokens_token_id_seq OWNER TO "501SteamHub";

--
-- Name: auth_tokens_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.auth_tokens_token_id_seq OWNED BY public.auth_tokens.token_id;


--
-- Name: contributions; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.contributions (
    contribution_id integer NOT NULL,
    resource_id integer NOT NULL,
    score numeric(6,2) NOT NULL,
    calculated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.contributions OWNER TO "501SteamHub";

--
-- Name: contributions_contribution_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.contributions_contribution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contributions_contribution_id_seq OWNER TO "501SteamHub";

--
-- Name: contributions_contribution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.contributions_contribution_id_seq OWNED BY public.contributions.contribution_id;


--
-- Name: cycles; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.cycles (
    id integer NOT NULL,
    cycle_number integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cycles OWNER TO "501SteamHub";

--
-- Name: cycles_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.cycles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cycles_id_seq OWNER TO "501SteamHub";

--
-- Name: cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.cycles_id_seq OWNED BY public.cycles.id;


--
-- Name: fellow_applications; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.fellow_applications (
    application_id integer NOT NULL,
    user_id integer NOT NULL,
    organization character varying(200) NOT NULL,
    subjects text[] DEFAULT '{}'::text[] NOT NULL,
    grade_levels text[] DEFAULT '{}'::text[] NOT NULL,
    experience_years integer DEFAULT 0 NOT NULL,
    bio text NOT NULL,
    credentials_link character varying(500),
    status character varying(20) DEFAULT 'Pending'::character varying NOT NULL,
    reviewed_by integer,
    reviewed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    moe_identifier character varying(50) NOT NULL,
    moe_doc_path text,
    CONSTRAINT chk_fellow_applications_status CHECK (((status)::text = ANY ((ARRAY['Pending'::character varying, 'Approved'::character varying, 'Rejected'::character varying])::text[])))
);


ALTER TABLE public.fellow_applications OWNER TO "501SteamHub";

--
-- Name: fellow_applications_application_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.fellow_applications_application_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fellow_applications_application_id_seq OWNER TO "501SteamHub";

--
-- Name: fellow_applications_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.fellow_applications_application_id_seq OWNED BY public.fellow_applications.application_id;


--
-- Name: fellows; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.fellows (
    fellow_id integer NOT NULL,
    user_id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    moe_identifier character varying(50) NOT NULL,
    school character varying(150),
    subject_specialization character varying(100),
    district character varying(100),
    profile_status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    steam_points numeric(10,2) DEFAULT 0.0,
    source_application_id bigint,
    moe_identifier_verified boolean DEFAULT false,
    verified_at timestamp without time zone,
    verified_by bigint
);


ALTER TABLE public.fellows OWNER TO "501SteamHub";

--
-- Name: fellows_fellow_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.fellows_fellow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fellows_fellow_id_seq OWNER TO "501SteamHub";

--
-- Name: fellows_fellow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.fellows_fellow_id_seq OWNED BY public.fellows.fellow_id;


--
-- Name: grade_levels; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.grade_levels (
    grade_level character varying(50) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.grade_levels OWNER TO "501SteamHub";

--
-- Name: grade_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.grade_levels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.grade_levels_id_seq OWNER TO "501SteamHub";

--
-- Name: grade_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.grade_levels_id_seq OWNED BY public.grade_levels.id;


--
-- Name: ilos; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.ilos (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    grade_level_id integer NOT NULL,
    cycle_id integer NOT NULL,
    strand_id integer NOT NULL,
    ilo_code text NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ilos OWNER TO "501SteamHub";

--
-- Name: ilos_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.ilos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ilos_id_seq OWNER TO "501SteamHub";

--
-- Name: ilos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.ilos_id_seq OWNED BY public.ilos.id;


--
-- Name: lesson_versions; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.lesson_versions (
    version_id integer NOT NULL,
    lesson_id integer NOT NULL,
    version_number integer NOT NULL,
    content text NOT NULL,
    change_description text,
    changed_by integer NOT NULL,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.lesson_versions OWNER TO "501SteamHub";

--
-- Name: lesson_versions_version_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.lesson_versions_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lesson_versions_version_id_seq OWNER TO "501SteamHub";

--
-- Name: lesson_versions_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.lesson_versions_version_id_seq OWNED BY public.lesson_versions.version_id;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.lessons (
    lesson_id integer NOT NULL,
    resource_id integer NOT NULL,
    lesson_number integer NOT NULL,
    title character varying(255) NOT NULL,
    duration_minutes integer,
    objectives text[],
    materials text[],
    content text NOT NULL,
    assessment text,
    differentiation text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.lessons OWNER TO "501SteamHub";

--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.lessons_lesson_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lessons_lesson_id_seq OWNER TO "501SteamHub";

--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.lessons_lesson_id_seq OWNED BY public.lessons.lesson_id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    user_id integer,
    message text NOT NULL,
    channel character varying(50) DEFAULT 'email'::character varying,
    sent_at timestamp without time zone DEFAULT now(),
    read boolean DEFAULT false
);


ALTER TABLE public.notifications OWNER TO "501SteamHub";

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_notification_id_seq OWNER TO "501SteamHub";

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.notifications_notification_id_seq OWNED BY public.notifications.notification_id;


--
-- Name: resource_access; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_access (
    access_id integer NOT NULL,
    resource_id integer NOT NULL,
    user_id integer NOT NULL,
    accessed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.resource_access OWNER TO "501SteamHub";

--
-- Name: resource_access_access_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.resource_access_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_access_access_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_access_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.resource_access_access_id_seq OWNED BY public.resource_access.access_id;


--
-- Name: resource_comments; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_comments (
    comment_id integer NOT NULL,
    resource_id integer NOT NULL,
    user_id integer NOT NULL,
    parent_comment_id integer,
    content text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.resource_comments OWNER TO "501SteamHub";

--
-- Name: resource_comments_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.resource_comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_comments_comment_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.resource_comments_comment_id_seq OWNED BY public.resource_comments.comment_id;


--
-- Name: resource_grade_levels; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_grade_levels (
    resource_id integer NOT NULL,
    grade_level_id integer NOT NULL
);


ALTER TABLE public.resource_grade_levels OWNER TO "501SteamHub";

--
-- Name: resource_ilos; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_ilos (
    id integer NOT NULL,
    resource_id integer NOT NULL,
    ilo_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.resource_ilos OWNER TO "501SteamHub";

--
-- Name: resource_ilos_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.resource_ilos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_ilos_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_ilos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.resource_ilos_id_seq OWNED BY public.resource_ilos.id;


--
-- Name: resource_links; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_links (
    link_id integer NOT NULL,
    parent_resource_id integer NOT NULL,
    linked_resource_id integer NOT NULL,
    relationship_type character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_different_resources CHECK ((parent_resource_id <> linked_resource_id))
);


ALTER TABLE public.resource_links OWNER TO "501SteamHub";

--
-- Name: resource_links_link_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.resource_links_link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_links_link_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_links_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.resource_links_link_id_seq OWNED BY public.resource_links.link_id;


--
-- Name: resource_reviews; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_reviews (
    review_id integer NOT NULL,
    resource_id integer NOT NULL,
    reviewer_id integer NOT NULL,
    reviewer_role_id integer NOT NULL,
    decision public.review_decision NOT NULL,
    comment_summary text,
    reviewed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.resource_reviews OWNER TO "501SteamHub";

--
-- Name: resource_reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.resource_reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_reviews_review_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.resource_reviews_review_id_seq OWNED BY public.resource_reviews.review_id;


--
-- Name: resource_status_history; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_status_history (
    history_id integer NOT NULL,
    resource_id integer NOT NULL,
    old_status public.resource_status,
    new_status public.resource_status NOT NULL,
    changed_by integer,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.resource_status_history OWNER TO "501SteamHub";

--
-- Name: resource_status_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.resource_status_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_status_history_history_id_seq OWNER TO "501SteamHub";

--
-- Name: resource_status_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.resource_status_history_history_id_seq OWNED BY public.resource_status_history.history_id;


--
-- Name: resource_subjects; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resource_subjects (
    resource_id integer NOT NULL,
    subject_id integer NOT NULL
);


ALTER TABLE public.resource_subjects OWNER TO "501SteamHub";

--
-- Name: resources; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.resources (
    resource_id integer NOT NULL,
    title character varying(255) NOT NULL,
    category public.resource_category NOT NULL,
    drive_link text,
    status public.resource_status DEFAULT 'Draft'::public.resource_status NOT NULL,
    published_url text,
    contributor_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    slug character varying(255),
    summary text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_published_url_required CHECK (((status <> ALL (ARRAY['Published'::public.resource_status, 'Indexed'::public.resource_status, 'Archived'::public.resource_status])) OR (published_url IS NOT NULL)))
);


ALTER TABLE public.resources OWNER TO "501SteamHub";

--
-- Name: resources_resource_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.resources_resource_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resources_resource_id_seq OWNER TO "501SteamHub";

--
-- Name: resources_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.resources_resource_id_seq OWNED BY public.resources.resource_id;


--
-- Name: review_comments; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.review_comments (
    comment_id integer NOT NULL,
    resource_id integer NOT NULL,
    reviewer_id integer NOT NULL,
    section character varying(100),
    block_index integer,
    comment text NOT NULL,
    resolved boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    resolved_at timestamp without time zone
);


ALTER TABLE public.review_comments OWNER TO "501SteamHub";

--
-- Name: review_comments_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.review_comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.review_comments_comment_id_seq OWNER TO "501SteamHub";

--
-- Name: review_comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.review_comments_comment_id_seq OWNED BY public.review_comments.comment_id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.roles (
    role_id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text
);


ALTER TABLE public.roles OWNER TO "501SteamHub";

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_role_id_seq OWNER TO "501SteamHub";

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    dirty boolean NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO "501SteamHub";

--
-- Name: strands; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.strands (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.strands OWNER TO "501SteamHub";

--
-- Name: strands_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.strands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.strands_id_seq OWNER TO "501SteamHub";

--
-- Name: strands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.strands_id_seq OWNED BY public.strands.id;


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.subjects (
    subject character varying(150) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.subjects OWNER TO "501SteamHub";

--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subjects_id_seq OWNER TO "501SteamHub";

--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.subjects_id_seq OWNED BY public.subjects.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role_id integer,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    created_by integer,
    updated_at timestamp without time zone DEFAULT now(),
    updated_by integer
);


ALTER TABLE public.users OWNER TO "501SteamHub";

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO "501SteamHub";

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: video_metadata; Type: TABLE; Schema: public; Owner: 501SteamHub
--

CREATE TABLE public.video_metadata (
    id bigint NOT NULL,
    resource_id bigint NOT NULL,
    youtube_title character varying(100) NOT NULL,
    youtube_description text DEFAULT ''::text NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    privacy_status character varying(20) DEFAULT 'unlisted'::character varying NOT NULL,
    made_for_kids boolean DEFAULT false NOT NULL,
    category_id integer DEFAULT 27 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT video_metadata_privacy_status_check CHECK (((privacy_status)::text = ANY ((ARRAY['public'::character varying, 'private'::character varying, 'unlisted'::character varying])::text[])))
);


ALTER TABLE public.video_metadata OWNER TO "501SteamHub";

--
-- Name: video_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: 501SteamHub
--

CREATE SEQUENCE public.video_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.video_metadata_id_seq OWNER TO "501SteamHub";

--
-- Name: video_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: 501SteamHub
--

ALTER SEQUENCE public.video_metadata_id_seq OWNED BY public.video_metadata.id;


--
-- Name: auth_tokens token_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.auth_tokens ALTER COLUMN token_id SET DEFAULT nextval('mig_audit.auth_tokens_token_id_seq'::regclass);


--
-- Name: contributions contribution_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.contributions ALTER COLUMN contribution_id SET DEFAULT nextval('mig_audit.contributions_contribution_id_seq'::regclass);


--
-- Name: cycles id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.cycles ALTER COLUMN id SET DEFAULT nextval('mig_audit.cycles_id_seq'::regclass);


--
-- Name: fellow_applications application_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellow_applications ALTER COLUMN application_id SET DEFAULT nextval('mig_audit.fellow_applications_application_id_seq'::regclass);


--
-- Name: fellows fellow_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellows ALTER COLUMN fellow_id SET DEFAULT nextval('mig_audit.fellows_fellow_id_seq'::regclass);


--
-- Name: grade_levels id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.grade_levels ALTER COLUMN id SET DEFAULT nextval('mig_audit.grade_levels_id_seq'::regclass);


--
-- Name: ilos id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.ilos ALTER COLUMN id SET DEFAULT nextval('mig_audit.ilos_id_seq'::regclass);


--
-- Name: lesson_versions version_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lesson_versions ALTER COLUMN version_id SET DEFAULT nextval('mig_audit.lesson_versions_version_id_seq'::regclass);


--
-- Name: lessons lesson_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lessons ALTER COLUMN lesson_id SET DEFAULT nextval('mig_audit.lessons_lesson_id_seq'::regclass);


--
-- Name: notifications notification_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.notifications ALTER COLUMN notification_id SET DEFAULT nextval('mig_audit.notifications_notification_id_seq'::regclass);


--
-- Name: resource_access access_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_access ALTER COLUMN access_id SET DEFAULT nextval('mig_audit.resource_access_access_id_seq'::regclass);


--
-- Name: resource_comments comment_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_comments ALTER COLUMN comment_id SET DEFAULT nextval('mig_audit.resource_comments_comment_id_seq'::regclass);


--
-- Name: resource_ilos id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_ilos ALTER COLUMN id SET DEFAULT nextval('mig_audit.resource_ilos_id_seq'::regclass);


--
-- Name: resource_links link_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_links ALTER COLUMN link_id SET DEFAULT nextval('mig_audit.resource_links_link_id_seq'::regclass);


--
-- Name: resource_reviews review_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_reviews ALTER COLUMN review_id SET DEFAULT nextval('mig_audit.resource_reviews_review_id_seq'::regclass);


--
-- Name: resource_status_history history_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_status_history ALTER COLUMN history_id SET DEFAULT nextval('mig_audit.resource_status_history_history_id_seq'::regclass);


--
-- Name: resources resource_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resources ALTER COLUMN resource_id SET DEFAULT nextval('mig_audit.resources_resource_id_seq'::regclass);


--
-- Name: review_comments comment_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.review_comments ALTER COLUMN comment_id SET DEFAULT nextval('mig_audit.review_comments_comment_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.roles ALTER COLUMN role_id SET DEFAULT nextval('mig_audit.roles_role_id_seq'::regclass);


--
-- Name: strands id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.strands ALTER COLUMN id SET DEFAULT nextval('mig_audit.strands_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.subjects ALTER COLUMN id SET DEFAULT nextval('mig_audit.subjects_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.users ALTER COLUMN user_id SET DEFAULT nextval('mig_audit.users_user_id_seq'::regclass);


--
-- Name: video_metadata id; Type: DEFAULT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.video_metadata ALTER COLUMN id SET DEFAULT nextval('mig_audit.video_metadata_id_seq'::regclass);


--
-- Name: auth_tokens token_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.auth_tokens ALTER COLUMN token_id SET DEFAULT nextval('public.auth_tokens_token_id_seq'::regclass);


--
-- Name: contributions contribution_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.contributions ALTER COLUMN contribution_id SET DEFAULT nextval('public.contributions_contribution_id_seq'::regclass);


--
-- Name: cycles id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.cycles ALTER COLUMN id SET DEFAULT nextval('public.cycles_id_seq'::regclass);


--
-- Name: fellow_applications application_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellow_applications ALTER COLUMN application_id SET DEFAULT nextval('public.fellow_applications_application_id_seq'::regclass);


--
-- Name: fellows fellow_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellows ALTER COLUMN fellow_id SET DEFAULT nextval('public.fellows_fellow_id_seq'::regclass);


--
-- Name: grade_levels id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.grade_levels ALTER COLUMN id SET DEFAULT nextval('public.grade_levels_id_seq'::regclass);


--
-- Name: ilos id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.ilos ALTER COLUMN id SET DEFAULT nextval('public.ilos_id_seq'::regclass);


--
-- Name: lesson_versions version_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lesson_versions ALTER COLUMN version_id SET DEFAULT nextval('public.lesson_versions_version_id_seq'::regclass);


--
-- Name: lessons lesson_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lessons ALTER COLUMN lesson_id SET DEFAULT nextval('public.lessons_lesson_id_seq'::regclass);


--
-- Name: notifications notification_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);


--
-- Name: resource_access access_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_access ALTER COLUMN access_id SET DEFAULT nextval('public.resource_access_access_id_seq'::regclass);


--
-- Name: resource_comments comment_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_comments ALTER COLUMN comment_id SET DEFAULT nextval('public.resource_comments_comment_id_seq'::regclass);


--
-- Name: resource_ilos id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_ilos ALTER COLUMN id SET DEFAULT nextval('public.resource_ilos_id_seq'::regclass);


--
-- Name: resource_links link_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_links ALTER COLUMN link_id SET DEFAULT nextval('public.resource_links_link_id_seq'::regclass);


--
-- Name: resource_reviews review_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_reviews ALTER COLUMN review_id SET DEFAULT nextval('public.resource_reviews_review_id_seq'::regclass);


--
-- Name: resource_status_history history_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_status_history ALTER COLUMN history_id SET DEFAULT nextval('public.resource_status_history_history_id_seq'::regclass);


--
-- Name: resources resource_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resources ALTER COLUMN resource_id SET DEFAULT nextval('public.resources_resource_id_seq'::regclass);


--
-- Name: review_comments comment_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.review_comments ALTER COLUMN comment_id SET DEFAULT nextval('public.review_comments_comment_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- Name: strands id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.strands ALTER COLUMN id SET DEFAULT nextval('public.strands_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.subjects ALTER COLUMN id SET DEFAULT nextval('public.subjects_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: video_metadata id; Type: DEFAULT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.video_metadata ALTER COLUMN id SET DEFAULT nextval('public.video_metadata_id_seq'::regclass);


--
-- Data for Name: auth_tokens; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.auth_tokens (token_id, user_id, token, scope, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: contributions; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.contributions (contribution_id, resource_id, score, calculated_at) FROM stdin;
\.


--
-- Data for Name: cycles; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.cycles (id, cycle_number, created_at) FROM stdin;
1	1	2026-04-20 14:04:36.103101
2	2	2026-04-20 14:04:36.103101
3	3	2026-04-20 14:04:36.103101
4	4	2026-04-20 14:04:36.103101
\.


--
-- Data for Name: fellow_applications; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.fellow_applications (application_id, user_id, organization, subjects, grade_levels, experience_years, bio, credentials_link, status, reviewed_by, reviewed_at, created_at, first_name, last_name, moe_identifier, moe_doc_path) FROM stdin;
\.


--
-- Data for Name: fellows; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.fellows (fellow_id, user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status, created_at, steam_points, source_application_id, moe_identifier_verified, verified_at, verified_by) FROM stdin;
\.


--
-- Data for Name: grade_levels; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.grade_levels (grade_level, id) FROM stdin;
Preschool	1
Infant 1	2
Infant 2	3
Standard 1	4
Standard 2	5
Standard 3	6
Standard 4	7
Standard 5	8
Standard 6	9
Mixed	10
\.


--
-- Data for Name: ilos; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.ilos (id, subject_id, grade_level_id, cycle_id, strand_id, ilo_code, description, created_at, updated_at) FROM stdin;
1	7	2	3	1	BS 1.1	Record and express personal information such as age, height, gender, date of birth, house address, ethnicity and language spoken in the house.	2026-04-20 14:04:36.167572	2026-04-20 14:04:36.167572
2	7	2	3	2	BS 2.1	Generate a list and discuss the importance of rules that govern the home.	2026-04-20 14:04:36.167572	2026-04-20 14:04:36.167572
3	7	2	3	2	BS 2.2	Role play and justify a variety of roles and responsibilities of family members.	2026-04-20 14:04:36.167572	2026-04-20 14:04:36.167572
4	12	2	1	26	HE 1.1.1	Identify and practice basic personal hygiene habits such as handwashing, tooth brushing, and bathing.	2026-04-20 14:04:36.167572	2026-04-20 14:04:36.167572
5	12	2	1	26	HE 1.1.2	Recognize and name basic food groups and healthy food choices.	2026-04-20 14:04:36.167572	2026-04-20 14:04:36.167572
6	12	2	1	27	HE 1.2.1	Understand basic safety rules in the home and classroom environment.	2026-04-20 14:04:36.167572	2026-04-20 14:04:36.167572
7	12	2	1	28	HE 1.3.1	Express emotions in appropriate ways and recognize emotions in others.	2026-04-20 14:04:36.167572	2026-04-20 14:04:36.167572
\.


--
-- Data for Name: lesson_versions; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.lesson_versions (version_id, lesson_id, version_number, content, change_description, changed_by, changed_at) FROM stdin;
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.lessons (lesson_id, resource_id, lesson_number, title, duration_minutes, objectives, materials, content, assessment, differentiation, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.notifications (notification_id, user_id, message, channel, sent_at, read) FROM stdin;
\.


--
-- Data for Name: resource_access; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_access (access_id, resource_id, user_id, accessed_at) FROM stdin;
\.


--
-- Data for Name: resource_comments; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_comments (comment_id, resource_id, user_id, parent_comment_id, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: resource_grade_levels; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_grade_levels (resource_id, grade_level_id) FROM stdin;
\.


--
-- Data for Name: resource_ilos; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_ilos (id, resource_id, ilo_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: resource_links; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_links (link_id, parent_resource_id, linked_resource_id, relationship_type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: resource_reviews; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_reviews (review_id, resource_id, reviewer_id, reviewer_role_id, decision, comment_summary, reviewed_at) FROM stdin;
\.


--
-- Data for Name: resource_status_history; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_status_history (history_id, resource_id, old_status, new_status, changed_by, changed_at) FROM stdin;
\.


--
-- Data for Name: resource_subjects; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resource_subjects (resource_id, subject_id) FROM stdin;
\.


--
-- Data for Name: resources; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.resources (resource_id, title, slug, summary, category, drive_link, status, published_url, contributor_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: review_comments; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.review_comments (comment_id, resource_id, reviewer_id, section, block_index, comment, resolved, created_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.roles (role_id, name, description) FROM stdin;
1	admin	System administrator with full access
2	User	Default user with view, rate, and comment access
3	Fellow	Fellow who can submit and manage resources
4	SubjectExpert	Can review and approve resources in their subject area
5	TeamLead	Can review and approve resources across all subjects and manage fellows
6	DSC	Director of Science and Technology, oversees all content and user management
7	Secretary	Administrative Secretary
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.schema_migrations (version, dirty) FROM stdin;
31	f
\.


--
-- Data for Name: strands; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.strands (id, subject_id, name, created_at) FROM stdin;
1	7	Identity in Belize	2026-04-20 14:04:36.167572
2	7	Civics Education	2026-04-20 14:04:36.167572
3	7	African and Maya History	2026-04-20 14:04:36.167572
4	6	Dance and Drama	2026-04-20 14:04:36.167572
5	6	Music	2026-04-20 14:04:36.167572
6	6	Creative Art Forms	2026-04-20 14:04:36.167572
7	6	Three-Dimensional Art	2026-04-20 14:04:36.167572
8	9	Reading Fluency & Accuracy	2026-04-20 14:04:36.167572
9	9	Comprehension	2026-04-20 14:04:36.167572
10	9	Production	2026-04-20 14:04:36.167572
11	9	Language Structure	2026-04-20 14:04:36.167572
12	8	Numbers & Number Operations	2026-04-20 14:04:36.167572
13	8	Patterns	2026-04-20 14:04:36.167572
14	8	Addition & Subtraction	2026-04-20 14:04:36.167572
15	8	Multiplication & Division	2026-04-20 14:04:36.167572
16	8	Fraction and Decimals	2026-04-20 14:04:36.167572
17	8	Geometry	2026-04-20 14:04:36.167572
18	8	Measurement	2026-04-20 14:04:36.167572
19	8	Sets	2026-04-20 14:04:36.167572
20	8	Data	2026-04-20 14:04:36.167572
21	11	Body Skills & Fitness	2026-04-20 14:04:36.167572
22	11	Football	2026-04-20 14:04:36.167572
23	3	Energy Resources	2026-04-20 14:04:36.167572
24	3	Relationships and Communications Plagiarism	2026-04-20 14:04:36.167572
25	3	Plant Diversity	2026-04-20 14:04:36.167572
26	12	Personal Health, Nutrition, and Disease Prevention	2026-04-20 14:04:36.167572
27	12	Environmental Health and Safety	2026-04-20 14:04:36.167572
28	12	Social and Emotional Health and Relationships	2026-04-20 14:04:36.167572
29	12	Personal Safety and Substance Abuse	2026-04-20 14:04:36.167572
30	12	Growth, Development, and Mental Well-being	2026-04-20 14:04:36.167572
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.subjects (subject, id) FROM stdin;
Computer Science	1
Information Technology	2
Engineering	4
Robotics	5
Belizean History	7
Mathematics	8
Social Studies	10
Physical Education	11
Science and Technology	3
Expressive Arts	6
Language Arts	9
Health Education	12
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.users (user_id, username, email, password_hash, role_id, is_active, last_login, created_at, created_by, updated_at, updated_by) FROM stdin;
1	admin	admin@501steamhub.org	$2a$12$U1/ifgjcl0WtBHk4h8CUDu5vwpKSlu4SNesUdPQKsQ88NvqX7bVSy	1	t	\N	2026-04-20 14:04:36.002809	\N	2026-04-20 14:04:36.002809	\N
\.


--
-- Data for Name: video_metadata; Type: TABLE DATA; Schema: mig_audit; Owner: 501SteamHub
--

COPY mig_audit.video_metadata (id, resource_id, youtube_title, youtube_description, tags, privacy_status, made_for_kids, category_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: auth_tokens; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.auth_tokens (token_id, user_id, token, scope, expires_at, created_at) FROM stdin;
2	3	\\xda6dbb9fbab1287bafd9fdcd981c59f1dfd958943815a76ac4695ed11a5813a6	authentication	2026-02-17 11:01:05-06	2026-02-16 11:01:05-06
3	3	\\x27251258d1c72f3497e64175d553a8541fae331f440f9dc14d8a34ea0170de00	authentication	2026-02-17 11:24:14-06	2026-02-16 11:24:14-06
4	3	\\x0b58146b85c23e7e657ae3836d661b6ab2dd87306bd7edde6ff284b7e43aa9dc	authentication	2026-02-17 13:10:54-06	2026-02-16 13:10:54-06
5	3	\\xd65ad6cf46fe7f796e1ca181b50062c4bedd3b5b9ea3cd1cb6f4c887a47d5d85	authentication	2026-02-17 13:41:27-06	2026-02-16 13:41:27-06
6	3	\\x6fd36c554902e4b632db75a34d20956738f9b461bf8cdd20e854da536da0df5e	authentication	2026-02-17 14:09:10-06	2026-02-16 14:09:10-06
7	3	\\x242726dc4be2ae13db6a43ba0ec4cac87e7a10d41c3f26101877ba10eb71fe4d	authentication	2026-02-17 14:11:26-06	2026-02-16 14:11:26-06
8	3	\\x0389bb01784e9015371ea495a18d11ab0a427a84d8deca644c1e14bbab2af826	authentication	2026-02-17 14:14:21-06	2026-02-16 14:14:21-06
9	3	\\x977dcceaa1888828a8be58c1b28e2a48007dc2383bad8a1df5cbec353d3b4f07	authentication	2026-02-17 14:32:30-06	2026-02-16 14:32:30-06
10	3	\\x9b6bd14b272a9b67265c69f74b9e6d4484dbc305eacb241cf08c6ea94a6205d8	authentication	2026-02-17 14:37:58-06	2026-02-16 14:37:58-06
11	3	\\x64e75e45149aa38b4db56769bb31887270ca32c37ac864e2ce6152721032a49f	authentication	2026-02-17 14:44:32-06	2026-02-16 14:44:32-06
12	3	\\xd2757b747f77406af4c1a5ce93d3c176743c1bf6cd4287283a3d1efc30e113bd	authentication	2026-02-17 15:49:22-06	2026-02-16 15:49:22-06
13	3	\\xdd1f28170cc8d0e329eb4005a6c2ca6fb70a8ae288a50e989a53992d2855caf7	authentication	2026-02-17 16:15:04-06	2026-02-16 16:15:04-06
14	3	\\xb1e7c303b6ea88a95c577a222f8e1a3deb137dcdb4fc6b2f7ec9f2d2ef80a38f	authentication	2026-02-19 09:20:09-06	2026-02-18 09:20:09-06
15	3	\\xed249d86ac655477f43359bf799fadf0bcf5e7e3572e7bb9958ed215c516474d	authentication	2026-02-19 11:53:48-06	2026-02-18 11:53:48-06
16	3	\\x43f28fdaf402c3cbb26824abd83c037d7815adc4392e69588251485b60919a4c	authentication	2026-02-20 09:32:45-06	2026-02-19 09:32:45-06
17	3	\\x2689fee7d31d0ccbef2d09af4929d39be1a01e2e99a07d8dfc9421b3f1fc2db3	authentication	2026-02-20 09:50:19-06	2026-02-19 09:50:19-06
18	3	\\x34ba4a06822e71f930174ed7ac23579e23aa4ed03ebf5d6cd9737924c157bdba	authentication	2026-02-20 13:47:32-06	2026-02-19 13:47:32-06
19	3	\\x8b14bcf6a7efb737ba8cdc080ac0a2a209d6b01eb5a7381aba9246866c8f6bd4	authentication	2026-02-24 09:12:44-06	2026-02-23 09:12:44-06
20	3	\\x6437502e2e5562bb7011dcbf563817a70be987896cb5b0af3125353d85840b9b	authentication	2026-02-24 11:31:32-06	2026-02-23 11:31:32-06
21	3	\\x8a646df4aee03c1b288e12763a9ceceae3c3b12729a53171550147b23caab7c6	authentication	2026-02-24 11:31:38-06	2026-02-23 11:31:38-06
22	3	\\x301989d322b84305aabf294e9bb6fb2193d08114714fd836d11a5fd8ff4aa58c	authentication	2026-02-24 12:57:34-06	2026-02-23 12:57:34-06
23	3	\\xfd5b3595dc02fbbeb6c307dfbc97a055f02bf06e8df1c80ccfcb83c2ca838f3e	authentication	2026-02-24 14:03:01-06	2026-02-23 14:03:01-06
24	4	\\x5c64215e8312a56126d8265586ee3728d7aea5b3bab5eb5b5d1584bc1ced4f17	authentication	2026-02-24 14:55:20-06	2026-02-23 14:55:20-06
25	4	\\xcd15dded7d07fdf4b4833f94bdc9cf85a6c01439528cbc5ac93a3e7c4b09d2a8	authentication	2026-02-24 14:55:55-06	2026-02-23 14:55:55-06
26	3	\\xf5e27673845a291946ecb3a373d01a11d4058a063095ec6696fb820f1863b17a	authentication	2026-02-24 14:56:18-06	2026-02-23 14:56:18-06
27	4	\\xe59418fb82b53b16dcb1c824dccdfd5c754924490678cd132bbd939062840e50	authentication	2026-02-25 10:50:00-06	2026-02-24 10:50:00-06
28	4	\\xc514fadbc68b4b43c2fa8aeb26f431d6de0b929d087476d881a71ebd1a965d81	authentication	2026-02-25 11:33:09-06	2026-02-24 11:33:09-06
29	3	\\x0a2723044d90a5414709554e153444282600c20b7a5ad257972a9ea67894e03c	authentication	2026-02-25 11:39:28-06	2026-02-24 11:39:28-06
30	4	\\x6e540fa3bc82103a2885fe222e0873d02ba7d92b92dfc7bfdc26cf0923e38d95	authentication	2026-02-25 11:40:51-06	2026-02-24 11:40:51-06
31	3	\\x64efe5a29128a0cabc15184f3b6205d3b2696165c289ab6cfa38789f4323226e	authentication	2026-02-25 11:46:51-06	2026-02-24 11:46:51-06
32	4	\\x3dc237244f143746e8bb92ec9f0e37834dd1a36986bdf3351c2b277de03355a4	authentication	2026-02-25 12:44:58-06	2026-02-24 12:44:58-06
33	3	\\x224e5e1dad4a51a9e34ecda5360171ad2ba8bdd29e4deb5a58ad322a0249d4be	authentication	2026-02-25 12:45:21-06	2026-02-24 12:45:21-06
34	5	\\x0774d47c1479c2d2c620f85c9b038a6cc74f71a6d073bc555b37279ef5e32b35	authentication	2026-02-25 13:26:27-06	2026-02-24 13:26:27-06
35	3	\\xc4b9d710455e62976c3559a782e860eb2d3dd7cc0d56391a6da9f3e60c4551fd	authentication	2026-02-25 15:43:46-06	2026-02-24 15:43:46-06
36	3	\\x340531acfcbec2d34619747c328ee1f15dca2d94c8c0b65f6d8b23b4fef06f3f	authentication	2026-02-26 13:47:07-06	2026-02-25 13:47:07-06
37	3	\\xbd69bfdd1b482b2d73f49180fcc7e7eb738413137901345c80940aee8f08b048	authentication	2026-02-26 13:54:50-06	2026-02-25 13:54:50-06
38	3	\\x59067731d32a421dec8b6c500a0a02370fe52c9b93200426a5079f3ee8cc4225	authentication	2026-02-26 16:11:10-06	2026-02-25 16:11:10-06
39	3	\\xacc168e44cad75988f7de5f2cbc93f94dad3cc00bfd01fef3c1d20b667fe03fc	authentication	2026-03-04 12:03:10-06	2026-03-03 12:03:10-06
40	3	\\x650880be9addff801a9ed1115cfcabd64be7c5e053469bcd84a3a6ade9212791	authentication	2026-03-05 08:33:19-06	2026-03-04 08:33:19-06
42	12	\\x57780a62715dd699eeef829978cdb3eae71972df408e1accb9985c1dd7338daf	authentication	2026-03-17 12:56:55-06	2026-03-16 12:56:55-06
43	3	\\x0704f8946a636321d1d81b2228c196954cdfc379dacb738c4edf6d1eedbf8535	authentication	2026-03-17 13:07:15-06	2026-03-16 13:07:15-06
44	3	\\x99ed412e5081a582058dd5d7ee8c60f220269bad453892bbdfdfc692834b4e15	authentication	2026-03-18 13:43:50-06	2026-03-17 13:43:50-06
45	4	\\x96563fd412a1a829ec302956c4cfa88336fffc4da0f499d688eff625a9f3421b	authentication	2026-03-18 13:51:29-06	2026-03-17 13:51:29-06
46	3	\\xef13f20cbf9c3d70e5740f381a0f77b5960c3179583d30c033f93720381599ca	authentication	2026-03-18 13:55:21-06	2026-03-17 13:55:21-06
47	4	\\xb63d1200123884a33362c53165d508ca9391951c90b65c95d6dea91a4958c7bd	authentication	2026-03-18 13:56:01-06	2026-03-17 13:56:01-06
48	3	\\xca674d1e554c90e5659d8845bf814c4cce14e93f5c3ebb09aeedd1de35e8ae28	authentication	2026-03-18 14:04:16-06	2026-03-17 14:04:16-06
49	4	\\x34c091a0cb20e10a3f823f80f07fe5f738af4ac82fc1ad2eac9c4be9fe5c8ae2	authentication	2026-03-18 14:04:51-06	2026-03-17 14:04:51-06
50	3	\\xcc936bc832d547a5cfac7c8fa3e0934398e13eb95e7b40696b00c319fcec4119	authentication	2026-03-18 14:10:58-06	2026-03-17 14:10:58-06
51	4	\\x1ef8df4993af72ecad2bba04a4195b916a4f9aaa41dcf46d257f8cdec0198774	authentication	2026-03-18 14:12:29-06	2026-03-17 14:12:29-06
52	12	\\x140e4924ad9e8aad31cf6c920bc31e6c0c577da4909c8d1b4ed39cb5ef7f8654	authentication	2026-03-18 14:13:29-06	2026-03-17 14:13:29-06
53	3	\\xe59ca6109a93f4f63a216fd26ecdb67ed66b8a00406fe9d01a86fff2e6247877	authentication	2026-03-18 14:17:06-06	2026-03-17 14:17:06-06
54	12	\\xa329faadadf105adcf443fd4c08597e1e4e0a8904225194a46384a70ff0297ed	authentication	2026-03-18 14:17:31-06	2026-03-17 14:17:31-06
55	3	\\x0ab8adce01711ca46bb39699dda821a26d3164fd6acc088effe216fe37c61568	authentication	2026-03-18 14:18:21-06	2026-03-17 14:18:21-06
56	5	\\x2b348f4451bbfbdea720b1804245741ceef6eb22a371b2e19352dd768c9b1520	authentication	2026-03-18 14:23:04-06	2026-03-17 14:23:04-06
57	12	\\x8d831f6a92245e82e5e084e06426c1d027c7691ee7f76cc29ef0d75104b6daeb	authentication	2026-03-18 14:30:01-06	2026-03-17 14:30:01-06
58	3	\\xafd4f37cefb09bb48f2663dad45b0aa57ff423e32c35c9a1d5e5be38226aab76	authentication	2026-03-18 14:32:44-06	2026-03-17 14:32:44-06
59	12	\\x522f0d0404b3fd12effb6b391d4f94d336ba2a5ee63f2a9d071161323d8121f5	authentication	2026-03-18 14:33:28-06	2026-03-17 14:33:28-06
60	3	\\xb870bcb24ecea349090e4df1e245382cc79780828e1c76276accf048c586cf4e	authentication	2026-03-18 14:56:47-06	2026-03-17 14:56:47-06
61	5	\\x1a35396b264132b2a826603a51232696313b0eaefc0630865eb0f5c72a79a5fa	authentication	2026-03-18 15:05:40-06	2026-03-17 15:05:40-06
62	3	\\xd57ace8064319b812a1a289bb1ae716e2ce1d358f44fc9078e858519b46f5ec9	authentication	2026-03-18 15:23:37-06	2026-03-17 15:23:37-06
63	5	\\xf5de5f78eb90351c510716e40befb7fe253cc41a6289acdcc9160e78f6bf9d2c	authentication	2026-03-18 15:46:22-06	2026-03-17 15:46:22-06
64	3	\\xb8f0cf80ea70efe09bbb68c66530909912e68141bcf80b5124373c68a3a9ac5a	authentication	2026-03-24 14:23:42-06	2026-03-23 14:23:42-06
65	5	\\xff2ec2ee1d59db530983cedd3f2009079f4c43f7cd91855561ccb0d06c3ebc59	authentication	2026-03-24 14:39:34-06	2026-03-23 14:39:34-06
66	3	\\xb4618e4793452dcfc03d68f095b2f2a7860b302dc1a9b5f3492f8d280eb0a870	authentication	2026-03-24 15:06:21-06	2026-03-23 15:06:21-06
68	13	\\xb3bc360ed7670ac384beacabd1f4c1de7e67cbe8737971cde8fdd37adc2c3cb4	authentication	2026-03-24 15:48:33-06	2026-03-23 15:48:33-06
69	3	\\x56bbb3682851eb4c3aa8456fb7783b1bc008f64bc6ed91646390c0f6a68ad1fd	authentication	2026-03-24 16:03:12-06	2026-03-23 16:03:12-06
71	14	\\xad19c66b42f765d2acb3a22ffe7908a3a3e66ab9418dea56a42509ca5a8631f7	authentication	2026-03-25 10:10:22-06	2026-03-24 10:10:22-06
72	3	\\xb20c2e255e25caa714ec562e03a684714ee08b4ae42d6ea13c851b73c010d9ee	authentication	2026-03-25 11:27:38-06	2026-03-24 11:27:38-06
73	3	\\xa631725636bfa0c0ffcebc7ba7f0854e725bc64219353fe3cbbd5f8e4eea7bff	authentication	2026-03-26 09:38:06-06	2026-03-25 09:38:06-06
74	3	\\xb3fee3c25f4729551d97ffb3f83b743967d29f564e30521a2dd0df589a88c32d	authentication	2026-03-30 12:01:00-06	2026-03-30 10:01:00-06
75	3	\\xc08a9dea73539265deeb7d373f319f0a4ca6cc25ad1f1684f9e89ec9c6bee306	authentication	2026-03-30 16:22:05-06	2026-03-30 14:22:05-06
76	3	\\x7f8d4e27892fc87886d3d7be3a239ecd019f25c4eebb6e128830935e5ddfaa8a	authentication	2026-03-31 17:52:37-06	2026-03-31 15:52:37-06
77	3	\\x2fa2bf5d9302366d9fb75bd7ba85e1794614ceb461e7e1758b55c170bb024c92	authentication	2026-04-01 17:24:47-06	2026-04-01 15:24:47-06
78	3	\\x59bfd595552cd3953c8731f1fc9254e29ad3c4b6b2ae09c974a3295a06b40129	authentication	2026-04-07 17:16:34-06	2026-04-07 15:16:34-06
79	3	\\x8e8a6069986c0cfcb7f370e64a7c49137fda16db86bbf3bb6a0662b259a55a86	authentication	2026-04-15 10:31:47-06	2026-04-15 08:31:47-06
80	13	\\xc8a6c393c9b3f13cd7a38efa1c923c641302c2e9a1f61f5eef2e5c74cb26175b	authentication	2026-04-15 10:35:41-06	2026-04-15 08:35:41-06
81	3	\\xc0a47dbbb15369e2722d94e9f6df564ef0895e78fe03b36fc5da7e366a237813	authentication	2026-04-15 10:38:06-06	2026-04-15 08:38:06-06
82	3	\\x3131e55ce5b81b2e6cda0ec168ffaab1eac856b874d0b8f52065c6652ba5ab94	authentication	2026-04-15 11:39:45-06	2026-04-15 09:39:45-06
83	12	\\x315118ce1f5892d08dee9909f8b45f00877280d3208a70c30f91d545ba0b753d	authentication	2026-04-15 11:49:25-06	2026-04-15 09:49:25-06
\.


--
-- Data for Name: contributions; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.contributions (contribution_id, resource_id, score, calculated_at) FROM stdin;
\.


--
-- Data for Name: cycles; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.cycles (id, cycle_number, created_at) FROM stdin;
1	1	2026-03-30 11:14:47.209574
2	2	2026-03-30 11:14:47.209574
3	3	2026-03-30 11:14:47.209574
4	4	2026-03-30 11:14:47.209574
\.


--
-- Data for Name: fellow_applications; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.fellow_applications (application_id, user_id, organization, subjects, grade_levels, experience_years, bio, credentials_link, status, reviewed_by, reviewed_at, created_at, first_name, last_name, moe_identifier, moe_doc_path) FROM stdin;
1	4	Victorious Nazarene School	{"Information Technology"}	{"Standard 2","Standard 3","Standard 4","Standard 5","Standard 6"}	15	Testing this out but its telling me that it must be at least 50 characters so thats good.		Approved	3	2026-02-24 12:44:19.112767	2026-02-24 11:45:14.158973	501Intern		MOE_1	\N
2	12	Victorious Nazarene	{"Computer Science"}	{"Standard 3","Standard 4","Standard 5","Standard 6","Standard 2"}	15	Im just a tech guy that likes teaching.  You can find me in the lab when you cant find me anywhere else.		Approved	3	2026-03-17 14:11:43.510696	2026-03-16 12:59:40.7422	Amilcar	Vasquez	MOE_2	\N
3	13	Sacred Heart College	{"Information Technology"}	{Mixed}	15	Test Bio that is actually a bio and no just default rambling		Approved	3	2026-03-23 16:03:18.389018	2026-03-23 15:49:24.576885	MilStudent		MOE_3	\N
4	14	Victorious	{"Computer Science","Information Technology"}	{"Infant 1","Infant 2","Standard 1"}	15	this is again a bit about myself without saying much that really matters.		Pending	\N	\N	2026-03-24 11:26:56.950212	Amilcar	Vasquez	cy201100157	moe_docs/d9d44429-288e-4e08-825d-cedc9cb3db54.jpg
\.


--
-- Data for Name: fellows; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.fellows (fellow_id, user_id, first_name, last_name, moe_identifier, school, subject_specialization, district, profile_status, created_at, steam_points, source_application_id, moe_identifier_verified, verified_at, verified_by) FROM stdin;
1	12	Amilcar	Vasquez	user_12	Victorious Nazarene	\N	\N	approved	2026-03-17 14:11:43.510696	3.00	\N	f	\N	\N
2	13	MilStudent		user_13	Sacred Heart College	\N	\N	approved	2026-03-23 16:03:18.389018	0.00	\N	f	\N	\N
\.


--
-- Data for Name: grade_levels; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.grade_levels (grade_level, id) FROM stdin;
Preschool	1
Infant 1	2
Infant 2	3
Standard 1	4
Standard 2	5
Standard 3	6
Standard 4	7
Standard 5	8
Standard 6	9
Mixed	10
\.


--
-- Data for Name: ilos; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.ilos (id, subject_id, grade_level_id, cycle_id, strand_id, ilo_code, description, created_at, updated_at) FROM stdin;
1	7	2	3	5	BS 1.1	Record and express personal information such as age, height, gender, date of birth, house address, ethnicity and language spoken in the house.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
2	7	2	3	6	BS 2.1	Generate a list and discuss the importance of rules that govern the home.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
3	7	2	3	6	BS 2.2	Role play and justify a variety of roles and responsibilities of family members.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
4	7	2	3	6	BS 2.3	Research and consider the impact on family members when family rules are broken.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
5	7	3	3	5	BS 1.2	Investigate and document the cultural aspects, such as food, music & dance, clothing, belief system, and traditional practices, of the different ethnic groups in Belize.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
6	7	4	3	5	BS 1.4	Research and organize a culture day to account for cultural diversity in	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
7	7	4	3	5	BS 1.5	Discuss and design an infomercial promoting respect and appreciation for Belize’s cultural diversity.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
8	7	4	3	5	BS 1.6	0bserve and highlight the traditional and modern cultural	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
9	7	5	3	5	BS 1.7	Investigate and locate on a map of the world the places from which the various ethnic groups originated or had settled before coming to Belize.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
10	7	5	3	5	BS 1.8	Research and create an annotated timeline to describe the emergence or first major arrival of the Central Americans and the modern Q'eqchi, Mopan and Yucatec ethnic groups.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
11	7	6	3	5	BS 1.9	Investigate and trace the voyage taken by different groups to come into	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
12	7	6	3	5	BS 1.10	Hypothesize and report the factors that led to the migration and settlement of groups in Belize. African and Maya History	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
13	7	6	3	7	BS 3.11	Design and annotate a Mundo Maya map highlighting the location of the major settlements of the Maya in the region and Belize.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
14	7	6	3	7	BS 3.12	Conduct research and design a chart comparing the similarities and differences in food, clothing, music, dance, games and technology between the Maya and another ethnic group.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
15	7	6	3	7	BS 3.13	Describe and illustrate some of the structures typically found in ancient	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
16	7	7	3	5	BS 1.11	Investigate and design an annotated timeline detailing major events that have shaped our identity as a nation such as the Mayan Civilization, slavery, colonialism, Caste War, Anglo Guatemala Dispute, the arrival of the Garinagu and independence.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
17	7	7	3	5	BS 1.12	Examine and reframe the impact of major events that have contributed to the development of Belize’s Identity such as the Mayan Civilization, slavery, colonialism, Caste War, Anglo Guatemala Dispute, the arrival of the Garinagu and independence.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
18	7	7	3	5	BS 1.13	Investigate and create a visual representation of key individuals and their contribution to the formation of Belize as a nation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
19	7	8	3	5	BS 1.14	Discuss and trace the development of democratic processes in Belize from the public meetings to the present day.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
20	7	8	3	5	BS 1.15	Investigate and outline the causes, personalities and main events of the protest movements of the 1900s such as the Ex-servicemen revolt and the 1930’s labour movement.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
21	7	8	3	5	BS 1.16	Design and analyse a timeline of major events leading up to Belize's Independence in 1981. African and Maya History	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
22	7	8	3	7	BS 3.16	Investigate and decide what it means to be enslaved and why enslaved people were in Belize in the 1700s and early 1800s.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
23	7	8	3	7	BS 3.17	Examine and summarize some features of the lives led by enslaved people in Belize, including their place of origin, occupation, treatment, living conditions, and acts of resistance.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
24	7	8	3	7	BS 3.18	Explore and articulate the influence of chattel slavery on	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
25	7	9	3	5	BS 1.17	Create a visual representation of what gives Belize its identity such as national symbols, people, landmarks, heritage, archaeological sites, etc.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
26	7	9	3	5	BS 1.18	Defend Belize’s geographical position as both a Central American and Caribbean country.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
27	7	9	3	5	BS 1.19	Design a campaign and propose actions by individuals and organizations encouraging patriotism in the preservation and protection of Belize’s national identity. African and Maya History	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
28	7	9	3	7	BS 3.19	Investigate and account for the existence of chattel slavery in Belize.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
29	7	9	3	7	BS 3.20	Examine the methods used by enslaved peoples in Belize to resist enslavement and improve their working and living conditions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
30	7	9	3	7	BS 3.21	Describe the major events in any particular resistance movement	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
31	6	2	3	8	EA 1.1	Move freely in time to music, changing direction, speed and level.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
32	6	2	3	9	EA 2.1	Sing and dramatize a short nursery rhyme using gestures and movement as appropriate.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
33	6	2	3	10	EA 3.1	Draw and colour lines, arcs and shapes using a variety of art mediums such as coloured pencils or markers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
34	6	3	3	8	EA 1.5	Coordinate dance steps and moves with a partner.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
35	6	3	3	9	EA 2.5	Sing short repetitive or rhyming (echoes) traditional songs, adding gestures and movement as appropriate.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
36	6	4	3	8	EA 1.9	Coordinate dance steps and moves in small groups by counts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
37	6	4	3	9	EA 2.9	Recite and perform patriotic songs and the Belizean National Anthem in English and accompanied by a traditional musical instrument.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
38	6	4	3	10	EA 3.9	Illustrate a story in two or more sketches.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
39	6	4	3	11	EA 4.8	Decorate a bottle, cup, plate or similar household object using a variety of lines and shapes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
40	6	5	3	8	EA 1.13	Act out a traditional story using speech and gestures.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
41	6	6	3	8	EA 1.17	Act in a short skit demonstrating proper stage management, gestures, intonation etc.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
42	6	6	3	8	EA 1.18	Role-play a scene showing conflict resolution.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
43	6	6	3	9	EA 2.16	Explain and demonstrate the difference between beat and rhythm.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
181	9	6	4	14	LA 3.46	Outline and compose a friendly letter.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
44	6	7	3	8	EA 1.22	Enact a short monologue, play or skit based on a short comedial script, poem, story or play.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
45	6	7	3	9	EA 2.20	Compare and perform pieces of music associated with various countries in this region.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
46	6	8	3	8	EA 1.26	Compose and dramatize a short piece of monologue or dialogue script based on an original story idea.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
47	6	8	3	9	EA 2.24	Investigate and present on the life and achievements of a popular Belizean musician.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
48	6	9	3	8	EA 1.30	Design and create costumes, props or masks for use in a short play or performance of an original idea.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
49	6	9	3	8	EA 1.31	Create an original dance for one or two people.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
50	6	9	3	9	EA 2.28	Select and perform a piece of music from Belize, by singing or playing an instrument.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
51	9	2	2	12	LA 1.01	Demonstrate understanding of the organization and basic features of print: - Recognize that words on a page progress from left to right, top to bottom and page by page. - Identify the front cover, back cover, and title page of a book.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
52	9	2	2	12	LA 1.02	Demonstrate, identify and distinguish basic knowledge of one-to- one letter-sound and formation of letters /s/, /a/ (short a), /t/, /p/, /i/ (short i) and /n/.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
53	9	2	2	12	LA 1.03	Demonstrate, identify, and distinguish basic knowledge of one-to- one letter-sound and formation of letters /r/, /e/ (short e), /b/, /c/ (hard c), /m/, /d/, /h/ & /o/ (short o).	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
54	9	2	2	12	LA 1.04	Identify and independently categorize spoken words and pictures that begin with given letter sounds.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
55	9	2	3	13	LA 2.01	Analyze information and appropriately answer questions about a story, poem, nursery rhyme or non- fiction text read by the teacher using prompts such as (who, when, what, why, where, and how). *Ongoing through all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
56	9	2	3	13	LA 2.02	Identify and relate to real life scenarios characters' emotions such as happy, sad, mad, scared, surprised, in stories. *Ongoing through all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
57	9	2	4	14	LA 3.01	Create illustrations to accompany a text and confidently explain through speech, written captions using letters, or short words. (or invented spelling) *Ongoing through all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
58	9	2	4	14	LA 3.02	Contribute meaningfully to class discussion and justify whether an event is real or fictional. *Ongoing through all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
59	9	3	2	12	LA 1.05	Print and identify all upper- and lower-case letters.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
60	9	3	2	12	LA 1.06	Segment spoken CVC words into their complete sequence of individual sounds (phonemes).	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
61	9	3	3	13	LA 2.03	Analyze and arrange in sequential order the main events of a story, nursery rhyme, poem or non- fiction text using pictures.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
62	9	3	3	13	LA 2.04	Use illustrations and details to identify and describe main	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
63	9	3	4	14	LA 3.03	Illustrate a story using a sequence of pictures to retell a story.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
64	9	3	4	14	LA 3.04	Create and illustrate a story with a picture and write a caption using real or invented spelling.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
65	9	4	2	12	LA 1.09	Recognize and apply final -e and common vowel team conventions for representing long vowel sounds.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
66	9	4	2	12	LA 1.10	Read on sight approximately 150-200 high frequency words including many that are not phonetically spelt. *Ongoing for all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
67	9	4	2	12	LA 1.11	Fluently read and write sentences using all learned spelling patterns. *Ongoing for all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
68	9	4	3	13	LA 2.05	Read texts with sufficient accuracy and fluency to support comprehension. *Ongoing for all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
69	9	4	3	13	LA 2.06	Perform and outline at least three consecutive actions after reading and following instructions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
70	9	4	3	13	LA 2.07	Determine the sequence of events and main idea of a story and explain the main idea orally and written.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
71	9	4	4	14	LA 3.06	Orally describes a real-life person, object, event, place, experience, or interest.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
72	9	4	4	14	LA 3.07	Create and write short texts based on various prompts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
73	9	4	4	14	LA 3.08	Read and use voice to indicate question marks, full stops, and exclamation marks. *Ongoing for all cycles	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
74	9	5	2	12	LA 1.12	Build and combine words with a variety of long and short vowel sounds, including multisyllabic words.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
75	9	5	3	13	LA 2.08	Discuss and examine the meaning of a story by referring to the main events, characters and places portrayed.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
76	9	5	4	14	LA 3.09	Create and explain a simple, chronological report of an event.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
77	9	6	2	12	LA 1.14	Analyze and categorize words or word families that have the same vowel sound/spelling patterns. Words (vowel teams): (leave/bead/team, roam/coal) Word Families (word endings): (head/lead/dead, good/wood/hood, dough/bough/though, cow/now/wow, could/ would/should).	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
78	9	6	2	12	LA 1.15	Read on sight approximately three hundred high-frequency words including place names from around the world.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
79	9	6	3	13	LA 2.10	Classify and create fact and opinion statements in original speech and writing.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
80	9	6	3	13	LA 2.11	Evaluate and explain the most important ideas or themes in a fiction/non-fiction text or a short poem.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
81	9	6	3	13	LA 2.12	Compile and Sequence events to create a timeline from historical or other non-fiction narratives.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
82	9	6	4	14	LA 3.11	Plan, proofread, edit, and deliver a short speech on given topics applying language conventions and varying sentences.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
83	9	6	4	14	LA 3.12	Compose a non-fiction report containing at least two informative paragraphs with evidence of their opinion on the topic.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
84	9	7	2	12	LA 1.16	Evaluate and explain a variety of strategies for finding or deducing the meaning of an unknown word using context clues.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
85	9	7	2	12	LA 1.17	Build and compare compound words from two root words.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
86	9	7	3	13	LA 2.13	Analyze and discuss several details after listening to or reading a fiction/ non-fiction text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
87	9	7	3	13	LA 2.14	Discuss choices faced by characters in a story and evaluate the choices and moral decisions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
88	9	7	4	14	LA 3.13	Discuss and justify the main idea in a logical manner after relating an incident or telling a story orally.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
89	9	7	4	14	LA 3.14	Compose an original short story of three paragraphs including vivid descriptions, dialogues and figurative language.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
90	9	8	2	12	LA 1.18	Apply phonics knowledge to sound out unknown words.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
91	9	8	2	12	LA 1.19	Explain a variety of strategies for finding or deducing the meaning of an unknown word.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
92	9	8	2	12	LA 1.20	Interpret and analyze words with a wide range of prefixes and suffixes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
93	9	8	3	13	LA 2.16	Summarize in one sentence the main idea of a page of non-fiction text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
94	9	8	3	13	LA 2.17	Examine and extract the elements of story plots.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
95	9	8	3	13	LA 2.18	Extract relevant information from a variety of printed and online sources.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
96	9	8	4	14	LA 3.16	Compose a variety of simple to complex sentences when writing a text applying effective coordinating and subordinating conjunctions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
97	9	8	4	14	LA 3.17	Outline and compose a story based on existing knowledge of stories, poems, or plays.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
98	9	9	2	12	LA 1.21	Interpret and define words with a wide range of prefixes and suffixes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
99	9	9	2	12	LA 1.22	Apply phonics knowledge to sound out unknown words.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
100	9	9	3	13	LA 2.19	Sequence events in stories with complex structures including flashbacks and "stories within stories.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
101	9	9	3	13	LA 2.20	Examine events from the point of view of different characters to compose reports.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
102	9	9	3	13	LA 2.21	Discuss, with reference to their own lives, complex moral issues encountered during reading.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
103	9	9	4	14	LA 3.18	Explain ideas using devices such as similes, metaphors, anecdotes, and analogies.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
104	9	9	4	14	LA 3.19	Compose a story containing a clearly defined plot, literary devices and detailed descriptions of settings and characters.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
105	9	2	2	12	LA 1.23	Demonstrate, identify, and distinguish basic knowledge of one-to-one letter-sound and formation of letters /g/ (hard g), /f/, /l/, /u/,/k/, /j/, /z/, /v/ & /w/, /x/, /y/, /q/	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
106	9	2	2	12	LA 1.24	Identify and segment individual letter sounds in the beginning, middle and ending positions of spoken, written words and picture cards. (CVC)	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
107	9	2	2	12	LA 1.25	Identify rhyming words from sets of word families.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
108	9	2	3	13	LA 2.22	Predict and relate to real life scenarios in the next section of a story with a repetitive or predictable pattern.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
109	9	2	3	13	LA 2.23	Read and discuss simple pictorial stories and fiction or non- fiction texts based on familiar themes of interest.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
110	9	2	4	14	LA 3.20	Listen attentively to a familiar story and role play scenes using appropriate language skills.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
111	9	2	4	14	LA 3.21	Listen attentively and correctly perform an action from a written or spoken text	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
112	9	3	2	12	LA 1.26	Blend, segment and read with confidence a series of words containing beginning consonant blends such as /bl/, /cl/, /gl/, /fl/, /cr/, /br/, /tr/, /dr/, /st/, /fr/ & /gr/.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
113	9	3	2	12	LA 1.27	Identify and read with confidence words with consonant digraphs /sh/, th & /ch/ in oral and written text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
114	9	3	2	12	LA 1.28	Delete phonemes in one- syllable words (“What is “crust” without the ‘c’?”)	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
115	9	3	3	13	LA 2.24	Compare and contrast characters in familiar stories and respond correctly to a variety of questions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
116	9	3	3	13	LA 2.25	Identify the main idea in various texts and compare the characters.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
117	9	3	3	13	LA 2.26	Analyze stories to identify and discuss connections between individuals, events, and ideas.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
118	9	3	4	14	LA 3.22	Use rhyming schemes to compose two lines of poetry that rhyme.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
119	9	3	4	14	LA 3.23	Observe current weather conditions or items of interest to create an oral or written simple report.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
120	9	3	4	14	LA 3.24	Recall details to role play parts of stories or simple real-life situations to demonstrate central message or theme.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
121	9	4	2	12	LA 1.29	Organize a series of words that begin with the same letter in correct alphabetical order.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
122	9	4	2	12	LA 1.30	Appropriately form plurals by adding -es and by changing y/ey to ies in original writing.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
123	9	4	3	13	LA 2.27	Predict a sequence of events in a story or real life.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
124	9	4	3	13	LA 2.28	Determine the sequence of events and main idea of a story and draw conclusions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
125	9	4	4	14	LA 3.25	Create greeting cards for a variety of purposes, for example get well, Congratulations, birthdays, and anniversaries.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
126	9	4	4	14	LA 3.26	Compose an original story, of at least five sentences, based on a picture, another story or personal experience, and illustrate it with a picture.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
127	9	5	2	12	LA 1.31	Read on sight approximately two hundred high frequency words including addresses and place names of Belize, including multi-syllabic and irregularly spelt ones.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
128	9	5	2	12	LA 1.32	Discover and conclude that some words may have the same sound but different spelling, for example, knew/new, sea/see	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
129	9	5	3	13	LA 2.29	Choose and explain, with reasons, which are the most significant events in a story.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
130	9	5	3	13	LA 2.30	Explain and formulate story predictions by giving examples from the text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
131	9	5	4	14	LA 3.27	Construct at least one cohesive short paragraph that describes a place, person, object, or event.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
132	9	5	4	14	LA 3.28	Compose a short story based on a picture sequence, story starters or ending phrases.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
133	9	6	2	12	LA 1.33	Analyze and Categorize words that have the same vowel sound/spelling patterns. (head/bead, good/moon, dough/rough/thought, cow/low).	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
134	9	6	2	12	LA 1.34	Read on sight approximately three hundred high frequency words including place names from the	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
135	9	6	3	13	LA 2.31	Examine and sequence key events after listening to a short fiction or non-fiction text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
136	9	6	3	13	LA 2.32	Evaluate and explain the most important ideas or themes in a fiction/non-fiction text or a short poem.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
137	9	6	4	14	LA 3.29	Compose a non-fiction report containing at least two informative paragraphs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
138	9	6	4	14	LA 3.30	Construct a well-developed paragraph that describes a real or fictional person or place which includes a topic sentence, supporting sentences and concluding sentence.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
139	9	7	2	12	LA 1.35	Explain how suffixes can be used to change the part of speech of a word, for example, culture (n) cultural (adj), or book (n) bookish (adj).	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
140	9	7	2	12	LA 1.36	Explain and demonstrate that the meaning of a word can depends on the context in which it is used.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
141	9	7	3	13	LA 2.33	Discuss choices faced by characters in a story, relating them to life choices and moral decisions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
142	9	7	3	13	LA 2.34	Compare and contrast the main themes, settings, events, and characters of different stories of the same type.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
143	9	7	4	14	LA 3.31	Rewrite known stories by changing the characters or setting but retaining the original main idea.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
144	9	7	4	14	LA 3.32	Compose multi-paragraph pieces using the writing process.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
145	9	8	2	12	LA 1.37	Explain a variety of strategies for finding or deducing the meaning of an unknown word.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
146	9	8	2	12	LA 1.38	Read to seek information from the internet, newspapers, tables, charts, diagrams, and maps.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
147	9	8	3	13	LA 2.35	Interpret the overt and “hidden’ meaning of a poem.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
148	9	8	3	13	LA 2.36	Compare and contrast different versions of the same story.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
149	9	8	4	14	LA 3.33	Create an original poem, then compose a story on the same theme.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
150	9	8	4	14	LA 3.34	Create an original story with a clear structure, introduction, development, and conclusion.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
151	9	8	4	14	LA 3.35	Compose a report, written in the third person, based on research or observation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
152	9	9	2	12	LA 1.39	Read a variety of texts and relate to personal experiences.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
153	9	9	3	13	LA 2.37	Identify the values and experiences of men, women and children based on reading stories from different countries and different periods of time.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
154	9	9	4	14	LA 3.36	Compose an informative item in the style of a news report or a newspaper.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
155	9	2	2	12	LA 1.41	Determine which words rhyme and independently generate rhyming words.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
156	9	2	2	12	LA 1.42	Read and spell 20-40 high frequency words. *Ongoing for cycles 3 and 4	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
157	9	2	2	12	LA 1.43	Blend, Segment read, and spell CVC words with fluency and accuracy. *Ongoing for cycles 3 and 4	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
158	9	2	3	13	LA 2.40	Discuss characters' emotions in stories and respond to questions about these emotions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
159	9	2	3	13	LA 2.41	Identify words and phrases in stories or poems that suggest feelings or appeal to the senses.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
160	9	2	4	14	LA 3.39	Interpret a scene from a story or nursery rhyme with a picture and a caption made up of one or two letters or short words. (Or invented spelling)	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
161	9	2	4	14	LA 3.40	Model how to use prepositions such as (above, behind, under, in, on, between), in a sentence to describe the location of a person, animal or thing.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
162	9	3	2	12	LA 1.44	Read words with common initial and ending consonant clusters, for example, cl, cr, sp, -nd, nch & -lt.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
163	9	3	2	12	LA 1.45	Decode two-syllable words following basic patterns by breaking the words into syllables.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
164	9	3	3	13	LA 2.42	Predict and create outcomes of stories using supporting details or patterns.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
165	9	3	3	13	LA 2.43	List one or two pieces of information from short non-fiction texts to recall details and answer questions, referring explicitly to the text as the basis for the answers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
166	9	3	4	14	LA 3.41	Describe a picture, person, place, object, or recent experience, orally or in writing, using inventive spelling where necessary.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
167	9	3	4	14	LA 3.42	Write short sentences relating to stories read and draw pictures to illustrate.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
168	9	4	2	12	LA 1.46	Read on sight and understand the meaning of words containing the endings -s (plural), -ing (continuous tense), and -ed (past tense) to read texts accurately.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
169	9	4	3	13	LA 2.44	Identify the meaning of unknown words using background knowledge of the topic.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
170	9	4	4	14	LA 3.43	Write a short letter to a friend to invite them to an event, to accept an invitation or to express thanks.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
171	9	5	2	12	LA 1.47	Discuss and value how similar words can have slightly different meanings, such as happy/glad, contented/satisfied, rigid/hard.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
172	9	5	2	12	LA 1.48	Compare and analyze the causes of events in stories and real- life descriptions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
173	9	5	3	13	LA 2.47	Discover and criticize information from non-fiction texts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
174	9	5	3	13	LA 2.48	Determine and formulate the main idea communicated by a video, poem, story, or nonfiction text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
175	9	5	4	14	LA 3.44	Develop and explain a short, prepared report.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
176	9	5	4	14	LA 3.45	Identify the main parts of a friendly letter and compose a letter to a friend.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
177	9	6	2	12	LA 1.49	Read on sight approximately three hundred high frequency words including place names from the Caribbean region and Central	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
178	9	6	2	12	LA 1.50	Build and compare words from common root words by adding prefixes and suffixes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
179	9	6	3	13	LA 2.49	Assess and explain the most important ideas or themes in a fiction/non-fiction text or a short poem.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
180	9	6	3	13	LA 2.50	Evaluate and explain the actions, views, and relationships between characters in stories.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
182	9	6	4	14	LA 3.47	Compose and perform a short humorous or free verse poem on a given theme.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
183	9	6	4	14	LA 3.48	Plan and develop a paragraph that describes a real or fictional person or place, which includes a topic sentence, supporting sentences and concluding sentence.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
184	9	7	2	12	LA 1.51	Examine the elements of a story plot.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
185	9	7	2	12	LA 1.52	Discuss the features of a poem including its structure, rhyme, patterns, and Figures of Speech.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
186	9	7	3	13	LA 2.51	Evaluate and discuss the ending to a story to create an alternative ending.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
187	9	7	3	13	LA 2.52	Determine and interpret the theme or themes communicated in a poem.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
188	9	7	4	15	LA 4.49	Produce simple, compound, and complex sentences to convey messages to various audiences.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
189	9	7	4	14	LA 3.50	Use the writing process to produce various writing pieces.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
190	9	7	4	14	LA 3.51	Conduct planned interviews with peers or familiar adults based on a given topic.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
191	9	8	2	12	LA 1.53	Analyze text displaying different points of view on the same topic and evaluate the merit of each argument.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
192	9	8	2	12	LA 1.54	Compare and contrast different predictions made about a story and justify a preference with evidence from it.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
193	9	8	3	13	LA 2.53	Compare and contrast the setting of two familiar stories and explain the impact of setting on the characters’ choices and actions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
194	9	8	3	13	LA 2.54	Analyze and evaluate texts in terms of form, structure, and content.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
195	9	8	4	14	LA 3.52	Compare and contrast information from more than one non- fiction source on the same topic.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
196	9	8	4	14	LA 3.53	Explain main ideas with evidence drawn from stories, books, internet, or their own experience.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
197	9	8	4	14	LA 3.54	Compose a short biographical story or historical narrative account of another person’s life.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
198	9	9	2	12	LA 1.55	Explain and apply a variety of strategies for finding or deducing the meaning of an unknown word.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
199	9	9	3	13	LA 2.55	Examine the word choices made by a poet and discuss the difference between the language of poetry and that of prose.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
200	9	9	3	14	LA 3.56	Cite textual evidence to support analysis of what the text states explicitly as well as inferences drawn from the text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
201	9	9	4	14	LA 3.55	Conduct short research on poetry and create poems that include poetic devices such as assonance, alliteration, onomatopoeia etc.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
202	9	9	4	14	LA 3.56	Use figurative language to develop and strengthen writing skills.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
203	9	2	2	12	LA 1.56	Identify name and sound of all upper- and lower-case letters.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
204	9	2	3	13	LA 2.57	Interpret instructions given by the means of gestures, symbols and pictures to complete task or make finish products.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
205	9	2	3	13	LA 2.58	Examine, discuss, and justify with confidence the causes of events in videos and fiction and non-fiction texts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
206	9	2	4	14	LA 3.57	Listen attentively to a familiar story and role play scenes using appropriate language skills.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
207	9	3	2	12	LA 1.57	Correctly read and spell words ending with common spelling patterns, for example, -ss -ck, -ff & -ll, -old, -ing, -op, -end & and.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
208	9	3	3	13	LA 2.59	Sort words into categories (e.g., colors, clothing) to gain a sense of the concepts the categories represent.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
209	9	3	3	13	LA 2.60	Formulate an opinion and answer simple questions about their feelings in response to stories and poetry presented orally.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
210	9	3	4	14	LA 3.58	Use oral and written sentences to express ideas, preferences and needs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
211	9	3	4	14	LA 3.59	Demonstrate understanding of word relationships and nuances in word meanings.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
212	9	4	2	12	LA 1.58	Identify common prefixes and suffixes to define a word.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
213	9	4	3	13	LA 2.61	Distinguish whether information presented is stating facts or opinions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
214	9	4	3	13	LA 2.62	Differentiate between fiction, nonfiction, fact, and fantasy.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
215	9	4	3	13	LA 2.63	Determine the main idea and explain how it is conveyed through key details in texts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
216	9	4	3	13	LA 2.64	Describe characters, settings, and major events in stories, using key details.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
217	9	4	4	14	LA 3.60	Compose a short poem that rhymes or is based on a given structure such as acrostic or diamante.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
218	9	4	4	14	LA 3.61	Prepare a drama to recount a familiar story.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
219	9	4	4	14	LA 3.62	Write, create, and design a paragraph describing a real-life person, object, event, place, experience, or interest.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
220	9	5	2	12	LA 1.59	Read fluently and maximize the use of context clues skills from the text to define unfamiliar words.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
221	9	5	2	12	LA 1.60	Select common prefixes and suffixes to modify the meaning of words.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
222	9	5	2	12	LA 1.61	Read to recall details and describe the relationship between characters.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
223	9	5	3	13	LA 2.65	Analyze and discuss the difference between prose, poetry, fact, fiction, and non-fiction.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
224	9	5	3	13	LA 2.66	Recount stories including folktales and fables to determine the main lesson, message or moral.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
225	9	5	4	14	LA 3.63	Compose short poems that rhyme or to a specified form such as limerick or haiku.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
226	9	5	4	14	LA 3.64	Develop and explain a simple informative text such as menus and instructions on how to perform a simple task.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
227	9	6	2	12	LA 1.62	Read on sight approximately three hundred high frequency words including place names from the Caribbean region and other regions. (Cycle 2, 3 and 4)	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
228	9	6	2	12	LA 1.63	Compare, contrast, and make use of words with similar and opposite meanings in original speech and writing.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
229	9	6	3	13	LA 2.67	Evaluate and explain the most important ideas or themes in a fiction/non-fiction text or a short poem.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
230	9	6	3	13	LA 2.68	Discuss what will happen in a story based on cause and effect or inferences about a character's personality or motivation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
231	9	6	3	13	LA 2.69	Discuss conflict in texts and evaluate the resolutions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
232	9	6	4	14	LA 3.65	Compose a non-fiction report containing at least two informative paragraphs with evidence of their opinion on the topic.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
233	9	6	4	14	LA 3.66	Create a story with a simple setting, simple plot and a small number of characters that includes dialogue	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
234	9	7	2	12	LA 1.64	Determine the meaning of words and phrases as they are used in a text, including figurative and connotative meanings.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
235	9	7	2	12	LA 1.65	Read and analyze the impact of a specific word choice on meaning and tone.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
236	9	7	3	13	LA 2.70	Evaluate stories and poems with the same theme/s.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
237	9	7	3	13	LA 2.71	Read texts and explain how an author/writer develops the point of view of the narrator or speaker.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
238	9	7	4	14	LA 3.67	Compose a multi-paragraph story with dialogue.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
239	9	7	4	14	LA 3.68	Write friendly and formal letters of varying lengths and purposes	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
240	9	8	2	12	LA 1.66	Read and analyze informational texts from non-fiction selection.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
241	9	8	2	12	LA 1.67	Read prose and poetry orally with accuracy, appropriate rate, and expression on continuous readings.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
242	9	8	3	13	LA 2.72	Compare and contrast how settings and relationships in stories can influence a character’s choice and action.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
243	9	8	3	13	LA 2.73	Read and explain how an author uses reasons and evidence to support points of view in a text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
244	9	8	3	13	LA 2.74	Criticize information from more than one non-fiction source on the same topic.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
245	9	8	4	14	LA 3.69	Compose a business letter in full block form.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
246	9	8	4	14	LA 3.70	Apply the appropriate format to a variety of letter types.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
247	9	9	2	12	LA 1.68	Read increasingly complex texts with fluency and confidence.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
248	9	9	2	12	LA 1.69	Read literary works and state view/position on what is read.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
249	9	9	2	12	LA 1.70	Read prose and poetry of appropriate complexity and distinguish the point of view used by the writer.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
250	9	9	3	13	LA 2.75	Compare and contrast the openings, endings, pace, sequencing, plot structure and characterization of different stories.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
251	9	9	3	13	LA 2.76	Support claims with logical reasoning and relevant evidence using accurate, credible sources and demonstrating an understanding of the text.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
252	9	9	4	14	LA 3.71	Deliver a prepared speech for a given purpose, for example to inform, entertain, or persuade.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
253	9	9	4	14	LA 3.72	Compose a formal letter, for example, of request, application, or complaint, to an office, business, or institution.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
254	8	2	1	16	MA 1.01	Identify and count groups of objects through oral exercises such as playing games, singing songs, and saying rhymes, initially to 10 and then beyond, using the counting principles of stable order, one-to-one correspondence, and cardinality.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
255	8	2	1	16	MA 1.02	Arrange, match, and create groups of up to ten objects to written numerical symbols.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
256	8	2	1	16	MA 1.03	Count groups of objects, initially to 10 and then beyond, using the counting principles of abstraction and order irrelevance.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
257	8	2	1	16	MA 1.04	Identify and state how many objects are in a group of up to 10 objects at a glance without having to count them one by one.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
258	8	2	1	16	MA 1.05	Identify an individual number, a sequence of numbers and the number before, after or between given numbers using a number line.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
259	8	2	1	16	MA 1.06	Identify and recite numbers 1 to 30 in sequence with fluency and accuracy.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
260	8	2	1	16	MA 1.07	Compare numbers from 0 to 10 using the less than, greater than and equals signs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
261	8	2	1	16	MA 1.08	Identify and write the numeric symbols for numbers from 0 to 10.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
262	8	2	1	16	MA 1.09	Compose and decompose numbers from 1 - 10, grouping items into given numbers with no remainder.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
263	8	2	1	16	MA 1.10	Identify the position of an item in a group using ordinal numbers from first to tenth.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
264	8	2	2	21	MA 6.01	Find and describe examples of points, lines, squares, circles, rectangles and triangles in the classroom, school and the wider environment.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
265	8	2	2	21	MA 6.02	Explore, classify and compare common shapes through play and use of manipulatives.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
266	8	2	2	21	MA 6.03	Identify and describe the properties of triangles, squares and rectangles in terms of number of sides and corners.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
267	8	2	2	21	MA 6.04	Construct and describe 2-D shapes using straws, sticks, clay, building blocks and other materials.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
268	8	2	2	17	MA 2.01	Identify and discuss examples of patterns in the classroom, school and wider environment.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
269	8	2	2	17	MA 2.02	Find and sort objects and shapes based on their color, size, number of sides and other attributes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
270	8	2	2	17	MA 2.03	Create and describe patterns using objects, actions, shapes, colours, sounds, or numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
271	8	2	2	17	MA 2.04	Group 10 or fewer objects into sets of 2’s, 3’s, 4’s, and 5’s without remainders	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
272	8	2	2	17	MA 2.05	Count objects, initially to 10 and then beyond by 1s and 2s, forwards and backwards.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
273	8	2	2	22	MA 7.01	Compare and discuss the length, height, mass, temperature and capacity of two objects using words such as longer, taller, shorter, lighter, heavier, colder, hotter, more full or emptier.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
274	8	2	3	22	MA 7.05	List and arrange in sequence the days of the week and months of year using ordinal numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
275	8	2	3	22	MA 7.06	Identify and sequence the current dates and days of the month on a calendar or weather chart using ordinal numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
276	8	2	3	22	MA 7.07	Tell, demonstrate and interpret time to the hour using an analogue clock.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
277	8	2	3	18	MA 3.01	Add and subtract sets of up to ten objects including with the use of zero	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
278	8	2	3	18	MA 3.02	Explore and demonstrate strategies to add and subtract sets of up to ten objects with and without the use of concrete objects.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
279	8	2	3	18	MA 3.03	Solve problems involving the adding and subtracting up to 10 objects, using real-life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
280	8	2	3	20	MA 5.01	Explain and demonstrate how a whole object can be divided into parts of equal and different sizes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
281	8	2	3	20	MA 5.02	Describe and identify fractions in everyday situations by using language such as ‘1 out of 2’.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
282	8	2	3	20	MA 5.03	Compose and decompose a region, shape or set of objects using halves and quarters, showing that the fractional parts are equal.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
283	8	2	3	20	MA 5.04	Identify, compare and match halves and quarters and objects in parts with the symbols ½ and ¼ using real-life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
284	8	2	4	21	MA 6.05	Identify and discuss planes in the classroom, school and wider environment.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
285	8	2	4	21	MA 6.06	Find, describe and compare examples of 3-D objects such as spheres, cubes, cylinders and cones in the classroom, school and the wider environment.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
286	8	2	4	24	MA 9.01	Gather and compile data from the environment through observation, counting, sorting and grouping of items such as objects and pictures.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
287	8	2	4	24	MA 9.02	Organize and display data using concrete materials in tally charts and on pictorial representations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
288	8	2	4	24	MA 9.03	Create, display and interpret information presented in pictographs using a variety of data sets.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
289	8	3	1	16	MA 1.11	Identify and count numbers up to 100 using a number and the five counting principles of stable order, one to one correspondence, order irrelevance, cardinality and abstraction.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
290	8	3	1	16	MA 1.12	Identify and match number names with numeric symbols for numbers from 0-100 both orally and in writing.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
291	8	3	1	16	MA 1.13	Apply the concept of zero to real- life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
292	8	3	1	16	MA 1.14	Identify the position and organize items in a group using ordinal numbers from first to one hundredth.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
293	8	3	1	16	MA 1.15	Compose and decompose 2-digit numbers to form groups of tens and ones.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
294	8	3	1	16	MA 1.16	Sequence a set of numbers between 0 and 100 in ascending or descending order using a number line.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
295	8	3	1	16	MA 1.17	Identify the number that is ten more or ten less than a given number using a place value chart and apply it to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
296	8	3	1	16	MA 1.18	Compare numbers from 0 to 100 using the less than, greater than and equal signs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
297	8	3	1	21	MA 6.07	Differentiate between horizontal, vertical and diagonal lines and draw rays and angles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
298	8	3	1	21	MA 6.08	Identify the similarities and differences between triangles, squares, rectangles and circles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
299	8	3	1	21	MA 6.09	Create by drawing or modelling and describe 2-D shapes with a specified number of sides using manipulatives.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
300	8	3	2	17	MA 2.06	Identify and describe patterns in pictures and artistic designs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
301	8	3	2	17	MA 2.07	Create and describe repeated patterns using actions, objects, colours, sounds, shapes, letters and numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
302	8	3	2	22	MA 7.08	Investigate and compare the perimeter and area of 2-D shapes using non-standard measures.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
303	8	3	2	22	MA 7.09	Measure and compare the length of lines, perimeter of shapes and real objects found in the environment using customary units of feet and inches.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
304	8	3	2	22	MA 7.10	Investigate and discuss the volume of 3-D shapes using non-standard units of measurement.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
305	8	3	2	22	MA 7.11	Measure and compare the volume of containers using the customary units of cups and pints and the mass of objects using customary units of pounds and ounces.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
306	8	3	2	18	MA 3.04	Add a 1-digit number to a 2-digit number that ends in a zero and apply to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
307	8	3	2	18	MA 3.05	Subtract a 1-digit number from a 2-digit number without the need to borrow and apply to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
308	8	3	2	18	MA 3.06	Add a 1-digit number to any 2-digit number with the answer not exceeding 99 and without regrouping.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
309	8	3	3	22	MA 7.12	Identify and tell the time as half hour, quarter hour to or past the hour using an analogue clock.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
310	8	3	3	22	MA 7.13	Identify, explain and apply the terms a.m. and p.m. to time in real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
311	8	3	3	18	MA 3.07	Add a single or two 2-digit numbers together with the answer not exceeding 100, vertically and horizontally with or without the place value chart and complete number sentence with sums up to 100 using +,=.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
312	8	3	3	18	MA 3.08	Subtract a single or 2-digit number from a 2-digit number, vertically and horizontally, without the need to barrow, with or without the place value chart and complete number sentence with differences up to 100 using -,=.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
313	8	3	3	18	MA 3.09	Explore and solve problems using the additive identity property.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
314	8	3	3	20	MA 5.05	Compose and decompose a region, shape or set of objects using halves, thirds, quarters and fifths.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
315	8	3	3	20	MA 5.06	Identify and match fractional parts with the symbols ½, 1/3, ¼ and ⅕.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
316	8	3	4	19	MA 4.01	Place and divide up to 50 objects or pictures into groups of 2’s, 3’s, 5’s and 10’s of equal size.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
317	8	3	4	19	MA 4.02	Investigate that multiplication is the same as repeated addition.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
318	8	3	4	19	MA 4.03	Multiply two 1-digit numbers together using manipulatives arranged in groups, multiplication arrays and so on.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
319	8	3	4	21	MA 6.10	Identify, describe and compare 2-D shapes according to specific properties including length of sides and number of vertices through discussion and demonstrations to insert in a table.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
365	8	5	1	16	MA 1.25	Sequence and compare a set of non-consecutive numbers in ascending and descending order up to 100,000 using the place value system.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
320	8	3	4	21	MA 6.11	Create and name models of 3-D shapes such as the cube, cuboid, sphere, cylinder, and cone or objects with specified properties, such as number of faces, edges and vertices through discussions and role-playing.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
321	8	3	4	21	MA 6.12	Investigate and explain the similarities and differences between symmetrical shapes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
322	8	3	4	24	MA 9.04	Collect and organize data from pictures, written sources and the environment through observation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
323	8	3	4	24	MA 9.05	Organize and display data using concrete materials in tally charts and column representations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
324	8	3	4	24	MA 9.06	Collect and Interpret information presented in simple column graphs using a variety of datasets.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
325	8	4	1	16	MA 1.19	Read, write and match numbers up to 1000 using numerical symbols and words and apply to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
326	8	4	1	16	MA 1.20	Identify and explain the value of each column in a place value chart as ten times more or less than the neighbouring column for numbers between 0 and 999.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
327	8	4	1	16	MA 1.21	Compare numbers up to 1000 using the symbols for equals (=), less than (<) and greater than (>) and apply to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
328	8	4	1	16	MA 1.22	State, read and write numbers in expanded form, up to 1000.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
329	8	4	1	17	MA 2.08	Sequence and identify the next, or a missing non-consecutive number between 0 and 1000 in ascending and descending order, using a number line.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
330	8	4	1	17	MA 2.09	Create and describe increasing, decreasing, and alternating patterns using numbers, objects, actions, shapes, colours, or sounds.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
331	8	4	1	17	MA 2.10	Count forward and backward by 2's, 5's, 10's and 100's from any given starting number between 0 and 1000.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
332	8	4	1	21	MA 6.11	Create and describe horizontal, vertical, diagonal, intersecting, parallel and perpendicular lines.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
333	8	4	1	21	MA 6.12	Investigate and discuss how the perimeter of common shapes such as triangles, squares and rectangles are calculated.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
334	8	4	1	21	MA 6.13	Create compound shapes using manipulatives such as pattern blocks, sticks, straws, string or other materials.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
335	8	4	1	21	MA 6.14	Describe the features of 3-D shapes such as cones, cylinders, cubes, cuboids and pyramids.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
336	8	4	2	18	MA 3.10	Add & subtract 2-digit numbers without regrouping using a range of mental and written strategies.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
337	8	4	2	18	MA 3.11	Add and subtract 2-digit numbers with regrouping using manipulatives such as base ten blocks or Legos.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
338	8	4	2	18	MA 3.12	Add three 2-digit numbers with and without regrouping in unit columns.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
339	8	4	2	22	MA 7.14	Estimate, measure, compare and record the length of lines, distances and the size of objects using the customary unit of inches, feet and yards.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
340	8	4	2	22	MA 7.15	Estimate, measure, compare and record the mass of various objects in the customary unit of pounds and ounces.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
341	8	4	2	22	MA 7.16	Estimate, measure compare and record the capacity of a container using the customary unit of cups, pints, quarts and gallons.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
342	8	4	2	18	MA 3.13	Demonstrate and explain the relationship between addition and subtraction.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
343	8	4	2	18	MA 3.14	Add & subtract two 3-digit numbers without regrouping using unit columns.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
344	8	4	2	18	MA 3.15	Add & Subtract two 3-digits with regrouping using manipulatives such as base ten blocks.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
345	8	4	3	22	MA 7.17	Convert among units within the customary system of length, mass and capacity.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
346	8	4	3	22	MA 7.18	Convert a length of time between minutes and seconds.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
347	8	4	3	22	MA 7.19	Identify, measure and record the temperature of the environment, in either degrees Celsius or Fahrenheit.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
348	8	4	3	19	MA 4.04	Explore the multiplicative identity of a number, that is if you multiply a number by 1, the product is that original number and solve problems using the multiplicative identity property.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
349	8	4	3	19	MA 4.05	Represent and solve multiplication problems both horizontally and vertically	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
350	8	4	3	19	MA 4.06	Multiply a 2-digit number by a 1-digit number	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
351	8	4	3	19	MA 4.07	Round-off to the nearest ten to estimate when multiplying.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
352	8	4	3	20	MA 5.07	Describe and illustrate parts of a whole or of a set using fractions with numerators other than one such as ⅔, ¾, ⅖, ⅚, 4/10	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
353	8	4	3	20	MA 5.08	Compare and sequence fractions with like denominators with the aid of manipulatives such as pictures, number line, fraction strips.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
354	8	4	3	20	MA 5.09	Add two or more proper fractions with like denominators.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
355	8	4	3	20	MA 5.10	Read and Convert fractions with tenths to decimals, for example 3/10 is the same as 0.3	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
356	8	4	3	20	MA 5.11	Read, add and subtract numbers with one decimal place.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
357	8	4	4	19	MA 4.08	Investigate that division is the same as repeated subtraction.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
358	8	4	4	19	MA 4.09	Divide single and 2-digit numbers by 2, 3, 4, 5, 10, without remainders.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
359	8	4	4	19	MA 4.10	Identify and explain the relationship between multiplication and division.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
360	8	4	4	19	MA 4.11	Solve word problems with real life applications using multiplication and division.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
361	8	4	4	24	MA 9.07	Collect, analyse and represent data contained in a tally chart or frequency table in different forms like pictographs & bar graphs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
362	8	4	4	24	MA 9.08	Identify and discuss situations that involve chance such as certain, impossible or equally likely events and investigate probability using tables and graphs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
363	8	5	1	16	MA 1.23	Identify and state the value of a digit based on its position in a number up to 6 digits.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
364	8	5	1	16	MA 1.24	Read, write and apply numbers up to 100,000 using numerical symbols and words to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
366	8	5	1	16	MA 1.26	State, read and write whole numbers up to 100,000 in expanded form.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
367	8	5	1	16	MA 1.27	Round whole numbers up to 100,000 to specific place values.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
368	8	5	1	21	MA 6.15	Identify and draw 2-D shapes based on their attributes up to 10 sides.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
369	8	5	1	21	MA 6.16	Identify and draw lines of symmetry in plane figures.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
370	8	5	1	21	MA 6.17	Draw circles of various sizes using a compass and identify the centre, radius, diameter and circumference of the circles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
371	8	5	1	21	MA 6.18	Construct common shapes such as triangles, squares and rectangles and calculate the perimeter by adding the lengths of all sides using metric units.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
372	8	5	1	18	MA 3.16	Add and subtract positive numbers up to 5-digits, with and without regrouping.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
373	8	5	1	18	MA 3.17	Develop and write number sentences using mixed operations of addition and subtraction to solve word problems.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
374	8	5	1	18	MA 3.18	Solve problems using the commutative property of addition.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
375	8	5	2	24	MA 9.09	Collect and represent data on a bar graph, pictograph and dot plot using real-life situation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
376	8	5	2	24	MA 9.10	Determine the median, mode, and range for a given set of data with both odd and even number of elements.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
377	8	5	2	24	MA 9.11	Identify, determine and predict the probability that an event will happen in a real-life situation with a finite number of possible outcomes using the phrase "with a probability of x out of y”.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
378	8	5	2	19	MA 4.12	Define and find multiples of whole numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
379	8	5	2	19	MA 4.13	Multiply two 2-digit numbers with and without regrouping.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
380	8	5	2	19	MA 4.14	Multiply whole numbers up to 100 with one decimal place.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
381	8	5	2	19	MA 4.15	Discuss and explain why commutative property applies to multiplication.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
382	8	5	2	20	MA 5.12	Identify, explain and compare equivalent fractions using pictures, number line, fraction strips or other manipulatives.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
383	8	5	2	20	MA 5.13	Find and solve problems with fractions that are equivalent to another by multiplying both the numerator and the denominator by the same number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
384	8	5	2	20	MA 5.14	Compare and sequence groups of proper fractions with like and unlike denominators.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
385	8	5	3	17	MA 2.11	Create and analyse 2-dimensional pattern using only pictures.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
386	8	5	3	17	MA 2.12	Identify and Explain the difference between odd, even numbers, prime and composite numbers and explore and identify patterns for triangular numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
387	8	5	3	17	MA 2.13	Identify and explore pattern rules for given patterns such as missing element of a pattern and patterns for triangular numbers	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
388	8	5	3	22	MA 7.20	Measure, Compare and record the length of lines and the size of objects using meters, centimeters and millimeters.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
389	8	5	3	22	MA 7.21	Discuss and compare the distances to and from various places using kilometers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
390	8	5	3	22	MA 7.22	Measure, compare, and record the mass of various objects using kilograms and grams and capacity of a container using litre and millilitre.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
391	8	5	3	22	MA 7.23	Record measures of time using minutes, seconds and hours and convert time from minutes to hours, hours to days and days to weeks.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
392	8	5	3	19	MA 4.16	Explore and discuss divisibility rules for division by 2, 5, and 10 by selecting numbers that follow each rule.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
393	8	5	3	19	MA 4.17	Divide1-digit and 2-digit numbers by 2, 3, 4, 5, & 10, with and without remainders.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
394	8	5	3	19	MA 4.18	Divide 2-digit numbers by one-digit numbers using the short form of division without carrying over within the calculation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
395	8	5	4	20	MA 5.16	Add and subtract proper fractions with unlike denominators using area models.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
396	8	5	4	20	MA 5.17	Multiply and divide proper fractions with unlike denominators using area model.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
397	8	5	4	20	MA 5.18	Identify and write the value of any digit in a number that has up to 2 decimal places using the decimal place value chart.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
398	8	5	4	20	MA 5.19	State, read and write decimal numbers up to 2 decimal places in expanded form.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
399	8	5	4	20	MA 5.20	Compare, sequence and round-off numbers with 2 decimal places to the nearest tenth.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
400	8	5	4	20	MA 5.21	Identify the equivalent decimals forms of 1/4, 1/2 and ¾.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
401	8	5	4	20	MA 5.22	Add and subtract decimal numbers, up to 2 decimal places.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
402	8	5	4	21	MA 6.19	Identify the figure and construct 3-D figures from given nets.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
403	8	5	4	21	MA 6.20	Identify and describe turns using quarter, half, three-quarter and full turn and 0°, 90°, 180°, 270°, 360°.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
404	8	5	4	21	MA 6.21	Identify and classify an angle as acute, right, obtuse or straight based on the approximate size of the angle.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
405	8	6	1	16	MA 1.28	Identify and state the value of a digit based on its position in a number up to 7 digits.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
406	8	6	1	16	MA 1.29	Round off very small and very large numbers using an appropriate method and apply to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
407	8	6	1	16	MA 1.30	Read and write numbers using the Mayan and Roman Numeral numbering system.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
408	8	6	1	16	MA 1.31	Explore and apply square numbers to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
409	8	6	1	21	MA 6.22	Draw, measure and record the degrees of various angles and interior angles of various shapes using a protractor.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
410	8	6	1	21	MA 6.23	Identify and name a triangle as being acute, obtuse or right-angled.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
411	8	6	1	21	MA 6.24	Investigate the sum of the interior angles of triangles and quadrilaterals.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
412	8	6	1	18	MA 3.19	Add and subtract numbers up to 7 digits, with and without regrouping.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
413	8	6	1	18	MA 3.20	Solve problems and explain the associative property of addition.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
414	8	6	2	19	MA 4.19	Explain and solve problems using the associative property of multiplication.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
415	8	6	2	19	MA 4.20	List and demonstrate the squares of numbers up to 10, concretely and pictorially.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
416	8	6	2	19	MA 4.21	Discuss and find the lowest common multiples for a range whole number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
417	8	6	2	19	MA 4.22	Multiply a 3-digit number by a 1-digit number or 2-digit number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
418	8	6	2	19	MA 4.23	Multiply a whole number with a number with up to three decimal places.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
419	8	6	2	19	MA 4.24	Explore and solve problems using divisibility rules for division by 3, 6, and 9.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
420	8	6	2	19	MA 4.25	Solve problems by dividing any double-digit number by a single-digit number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
421	8	6	2	19	MA 4.26	Divide 2-digit, 3-digit and 4-digit numbers by 1-digit numbers, using the short form of division including carrying over within the calculation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
422	8	6	2	19	MA 4.27	Divide a number with up to 2 decimal places by a single digit number using the short form of division.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
423	8	6	2	19	MA 4.28	Differentiate between Factors and Greatest Common Factors and find Factors and Greatest Common Factors of various numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
424	8	6	2	20	MA 5.23	Reduce a proper fraction to its simplest form.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
425	8	6	2	20	MA 5.24	Compare and sequence a group containing both mixed numbers and improper fractions and convert improper fraction to mixed number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
426	8	6	2	20	MA 5.25	Identify and justify the mixed number that is equivalent to a given decimal.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
427	8	6	2	20	MA 5.26	Add and subtract mixed numbers in real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
428	8	6	3	17	MA 2.14	Investigate different ways to arrange a set of items to create a variety of patterns related to daily lives.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
429	8	6	3	17	MA 2.15	Solve problems involving the identification of missing elements in a pattern by investigating relationships between successive elements using addition, subtraction, multiplication and division.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
430	8	6	3	22	MA 7.24	Estimate using metric units, length, mass and capacity of a line or object.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
431	8	6	3	22	MA 7.25	Measure and record length, mass, capacity, and temperature, using metric units, including decimals.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
432	8	6	3	22	MA 7.26	Solve problems using metric units of length, mass, capacity and temperature in real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
433	8	6	3	22	MA 7.27	Convert between a 12-hour clock and a 24-hour clock and estimate the length of time an event takes in real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
434	8	6	3	22	MA 7.28	Measure the elapsed time of an event using a stopwatch to the nearest tenth of a second and calculate the elapsed time of an event that are many weeks, months or years apart.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
435	8	6	3	24	MA 9.12	Collect data and determine the median, mode, and range of the set of data with either an even or an odd number of elements.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
436	8	6	3	24	MA 9.13	Compute the mean for a set of numbers related to real-life situation and solve real-world problems involving median, mode and range.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
437	8	6	3	24	MA 9.14	Describe and predict outcomes from data using the language of chance or likelihood.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
438	8	6	3	24	MA 9.15	Collect and represent real-life date in bar graphs and histograms.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
439	8	6	4	20	MA 5.29	State, read and write decimal numbers up to 3 decimal places in usual and expanded form.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
440	8	6	4	20	MA 5.30	Compare, sequence and round off decimal numbers with up to 3 decimal places to the nearest tenth and hundredth.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
441	8	6	4	20	MA 5.31	Add and subtract decimals, up to 3 decimal places.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
442	8	6	4	20	MA 5.32	Converting fractions that have 2, 4, 5, 8, 10, 20, 25 or 50 as the denominator to decimal numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
443	8	6	4	23	MA 8.01	Create and describe sets based on the common features and attributes of numbers, people, objects and other entities.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
444	8	6	4	23	MA 8.02	Identify elements that are not members of a set.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
445	8	6	4	23	MA 8.03	Investigate and empty (null) set.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
446	8	7	1	16	MA 1.32	Read, write and sequence positive and negative integers in ascending and descending order using a number line.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
447	8	7	1	16	MA 1.33	Construct a number line that shows both positive and negative integers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
448	8	7	1	21	MA 6.28	Identify and classify triangles as equilateral, isosceles, scalene, right-angle, acute and obtuse.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
449	8	7	1	21	MA 6.29	Draw and list properties of triangles with given angles and lengths of side using a ruler and protractor.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
450	8	7	1	21	MA 6.30	Investigate angles in triangles to deduce relationships between the interior and exterior angles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
451	8	7	1	21	MA 6.31	Calculate area of a compound shape constructed from squares, rectangles and triangles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
452	8	7	1	18	MA 3.21	Add or subtract a series of at least five numbers mentally.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
453	8	7	1	18	MA 3.22	Add and subtract positive numbers to a negative number using a number line.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
454	8	7	1	18	MA 3.23	Add and subtract a range of decimal numbers from the very small to the very large.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
455	8	7	1	18	MA 3.24	Identify and explain the difference between the commutative and associative properties of addition.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
456	8	7	2	19	MA 4.29	Multiply a positive number with a negative number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
457	8	7	2	19	MA 4.30	Multiply two decimal numbers with up to 3 decimal places.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
458	8	7	2	19	MA 4.31	Explore how the use of brackets can change the order of operations in problems involving multiplication and addition or subtraction.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
459	8	7	2	20	MA 5.33	Explore and demonstrate the steps to find lowest common denominator of two or more fractions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
460	8	7	2	20	MA 5.34	Add and subtract two or more fractions with unlike denominators using the lowest common denominator.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
461	8	7	2	20	MA 5.35	Multiply and divide mixed numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
462	8	7	2	20	MA 5.36	Divide a whole number or a fraction by a fraction.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
463	8	7	2	21	MA 6.32	Find a grid square on a map using coordinates and references.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
464	8	7	2	21	MA 6.33	Locate points and construct shapes and lines on the first quadrant of the coordinate graph using (x,y) coordinates.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
465	8	7	3	20	MA 5.37	Identify common everyday situations where percent is used and represent various percentages using pictures, shaded areas, and fractional parts using real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
466	8	7	3	20	MA 5.38	Identify and investigate the relationship between percentage and fraction with a denominator of 100.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
467	8	7	3	20	MA 5.39	Discuss and describe real-life situations involving comparisons between percentages.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
468	8	7	4	19	MA 4.32	Explore and demonstrate divisibility rules for division by 4, 7 and 8.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
469	8	7	4	19	MA 4.33	Divide a 2-digit number by a 1-digit number with or without remainders	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
470	8	7	4	19	MA 4.34	Divide a whole number by a 2-digit number using long division.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
471	8	7	4	19	MA 4.35	Divide a whole number by a decimal between 0 and 1.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
472	8	7	4	19	MA 4.36	Explain how the use of brackets can change the order of operations in problems involving division and addition or subtraction.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
473	8	7	4	23	MA 8.04	Define and list elements of finite and infinite sets.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
474	8	7	4	23	MA 8.05	Define and create equal sets with objects and different element.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
475	8	7	4	23	MA 8.06	Describe and create Venn diagram with the intersection of two (2) sets using of real world scenarios.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
476	8	7	4	21	MA 6.40	Construct and define the parts of a circles such as center, radius, diameter and circumference.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
477	8	7	4	21	MA 6.41	Illustrate how a circle is divided into 360 equal degrees.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
478	8	7	4	21	MA 6.42	Construct a circle divided into sectors with a given number of degrees using a compass and protractor.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
479	8	8	1	16	MA 1.34	Read and write very large numbers in standard form, expanded form and scientific notation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
480	8	8	1	16	MA 1.35	Round off a whole number to a specified number of significant figures and apply to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
481	8	8	1	16	MA 1.36	Read, write and expand numbers with three or more decimal places.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
482	8	8	1	16	MA 1.37	Categorize and differentiate between odd, even, prime, and composite numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
483	8	8	1	16	MA 1.38	Identify and illustrate the square of all integers between 1 and 20 and of the integers 25 and 100.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
484	8	8	1	16	MA 1.39	Demonstrate and illustrate the concept of cube numbers concretely and pictorially.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
485	8	8	1	17	MA 2.16	Represent and analyse patterns in real life data using tables, graphs, diagrams and manipulatives.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
486	8	8	1	17	MA 2.17	Investigate and solve arithmetic and geometric progressions using real-life data.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
487	8	8	1	18	MA 3.25	Add and subtract, mentally numbers with up to three digits.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
488	8	8	1	18	MA 3.26	Add and subtract integers with like and unlike signs, using real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
489	8	8	1	18	MA 3.27	Add and subtract numbers with decimals to solve real world problems.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
490	8	8	2	19	MA 4.37	Multiply and divide any two-digit number by any number between 1 and 20.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
491	8	8	2	19	MA 4.38	Multiply and divide a positive a number by a negative number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
492	8	8	2	19	MA 4.39	Describe real life situations using the terms multiple and factor.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
493	8	8	2	19	MA 4.40	Identify the prime factor of 1-digit and 2-digit numbers and express natural numbers as products of their prime factors.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
494	8	8	2	20	MA 5.40	Discuss and solve real world problems that require the adding and subtracting of mixed numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
495	8	8	2	20	MA 5.41	Discuss and solve real world problems that require the multiplying and dividing of mixed numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
496	8	8	2	20	MA 5.42	Discuss and solve real world problems with whole number, factions and decimals that involve more than one types of operation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
497	8	8	2	20	MA 5.43	Compare a variety of decimals, fractions, and percent using greater than, less than or equal to and solve problems that involves finding the percentage increase or decrease of real-world quantities.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
498	8	8	2	20	MA 5.49	Express a ratio as part to part and part to whole and solve real-world problems involving ratios with 2 elements.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
499	8	8	2	20	MA 5.50	Explain the difference between ratios and rates and solve real-world problems involving ratio and rates.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
500	8	8	3	21	MA 6.34	Research and solve real world problems involving the perimeter and area of triangles and quadrilaterals.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
501	8	8	3	21	MA 6.35	Draw circles and calculate the circumference, radius and diameter of circles using formulas.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
502	8	8	3	21	MA 6.36	Identify and construct cubes, cuboids, cylinders, cones, pyramids, and other 3-dimensional objects.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
503	8	8	3	21	MA 6.37	Investigate how to calculate the surface area and volume of cuboids.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
504	8	8	3	22	MA 7.32	Solve real-world problems that require conversion between units of measurement within the same system and between the customary and metric units of measurement.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
505	8	8	3	22	MA 7.34	Solve problems that include measurements expressed as negative numbers, such as temperature below zero and BCE.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
506	8	8	3	22	MA 7.35	Calculate speed based in actual real-world measurements of time and distance.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
507	8	8	3	22	MA 7.36	Solve problems in which the start time, end time and elapsed time is an unknown quantity.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
508	8	8	3	21	MA 6.38	Plot a line on the first quadrant of a coordinate graph using given (x,y) coordinates and plot the results of a reflection on a rectangular grid.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
509	8	8	3	21	MA 6.39	Investigate how a variety of polygons can be found in tessellations of triangles and create tessellations from more than one type of polygons.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
510	8	8	4	24	MA 9.19	Construct circle graphs and line graphs from frequency tables using real-world data.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
511	8	8	4	24	MA 9.20	Calculate the mean, median, mode and range of large sets of real-world data.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
512	8	8	4	23	MA 8.07	Identify and describe the elements in the union and intersection of two sets based on a Venn diagram using the set notation: { }, ∩, ∪.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
513	8	8	4	23	MA 8.08	Create subsets from universal sets and indicate the elements in the subsets using set notation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
514	8	8	4	24	MA 9.21	Explore probability and represent the outcome of a probability experiment using fractions and percents.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
515	8	8	4	24	MA 9.22	Represent the outcome of a probability experiment in a frequency table and on a bar graph.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
516	8	8	4	24	MA 9.23	Determine probability from data given in bar graphs, pictographs and circle graphs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
517	8	9	1	16	MA 1.40	Explain the value of digits in numbers smaller than 0.001 with the use of a place value chart and apply to real life situations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
518	8	9	1	16	MA 1.41	Round off decimal numbers up to two significant figures and large numbers to up to three significant figures.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
519	8	9	1	16	MA 1.42	Categorize and differentiate between whole numbers, prime numbers, composite numbers and integers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
520	8	9	1	16	MA 1.43	Define the terms exponent and power to apply the concept of powers using repeated multiplication using 2 as the base number.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
521	8	9	1	16	MA 1.44	Identify and write the square root of a perfect square.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
522	8	9	1	16	MA 1.45	Identify and list the cubes of integers from 1 to 5 and of the number 10.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
523	8	9	1	16	MA 1.46	Convert to and from base 10 and base 2 using place value charts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
524	8	9	1	18	MA 3.28	Add and subtract positive and negative numbers to solve mental and real-world problems.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
525	8	9	1	18	MA 3.29	Solve and discuss real world word problems using addition and subtraction when there is an unknown quantity.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
526	8	9	1	18	MA 3.30	Compare the commutative and associative properties of addition and explain the importance of each using real world examples.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
527	8	9	2	19	MA 4.41	Mentally multiply any 2-digit number by 4,5, 9, multiples of 10 and 25 & 50 using shortcuts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
528	8	9	2	19	MA 4.42	Multiply and divide two negative numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
529	8	9	2	19	MA 4.43	Identify the factors of negative whole numbers.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
530	8	9	2	19	MA 4.44	Solve real-world multiplication and division problems to solve word problems in which there is an unknown quantity.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
531	8	9	2	19	MA 4.45	Explain the importance of the commutative property of multiplication using real world examples.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
532	8	9	2	19	MA 4.46	Solve problems requiring application of order of operations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
533	8	9	2	20	MA 5.44	Convert decimals to fractions for any value between 0 and 1 and vice versa.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
534	8	9	2	20	MA 5.45	Add, subtract, multiply and divide different types of fractions using real-life scenarios.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
535	8	9	3	21	MA 6.40	Determine the perimeter of a 2D shape when the length of one or more sides is not known.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
536	8	9	3	21	MA 6.41	Investigate and calculate the area of quadrilaterals and compound shapes	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
537	8	9	3	21	MA 6.42	Investigate and calculate surface area of cylinders and pyramids.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
538	8	9	3	21	MA 6.43	Investigate and calculate the volume of cylinders, rectangular pyramids and cones using formulas.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
539	8	9	4	24	MA 9.24	Create a line graph, bar graph and a histogram based on two or more data sets and make predictions after analysis	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
540	8	9	4	24	MA 9.25	Use a table of values to plot a line on a coordinate graph.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
541	8	9	4	24	MA 9.26	Analyze, explain and solve real world problems of mean, median and mode.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
542	8	9	4	24	MA 9.27	Explain that probability is a measure on a scale of 0-1 of how likely an event is to occur.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
543	8	9	4	24	MA 9.28	Determine the probability of an event from various types of charts, graphs and tables.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
544	8	9	4	24	MA 9.30	Explore the probabilities involved with games of chance.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
545	8	9	4	24	MA 9.31	Represent the outcome of a probability experiment on a circle graph.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
546	11	2	1	25	PE 1.1	List and explain the rules for staying safe in a Physical Education class.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
547	11	2	1	25	PE 1.2	Move from place to place, forwards, sideways and backwards, by rolling, galloping, skipping, sliding, and leaping.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
548	11	2	1	25	PE 1.3	Make and demonstrate different shapes with the body that are wide, narrow, curled and twisted at low, mid and high levels.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
549	11	2	1	25	PE 1.4	Participate in a variety of movement patterns, while changing directions in response to a whistle or similar signal.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
550	11	2	4	26	PE 2.1	Demonstrate passing and receiving techniques using the instep or side of the foot.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
551	11	2	4	26	PE 2.2	Perform a variety of dribbling drills around cones, marks on the ground or other safe obstacles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
552	11	2	4	26	PE 2.3	Perform exercises on the spot such as arm curls, leg lifts and jumping up and down.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
553	11	2	4	26	PE 2.4	Control a moving ball with the feet while changing directions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
554	11	2	4	26	PE 2.5	Participate in relay races with simple rules using a football.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
555	11	3	1	25	PE 1.5	Perform a variety of twisting, stretching and other on the spot exercises.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
556	11	3	1	25	PE 1.6	Execute a single jump rope with self-turned rope forward with single bounce and backward with single bounce.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
557	11	3	4	26	PE 2.6	Kick a ball safely with the instep or side of the foot towards a partner or other target.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
558	11	3	4	26	PE 2.7	Change direction in a quick, controlled manner while playing dodging and chasing games.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
559	11	4	1	25	PE 1.9	Jump a short rope non-stop for at least 10 seconds, turning the rope both forwards and backwards.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
560	11	4	1	25	PE 1.10	Skip using an individual short rope and a long rope turned by partners.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
561	11	4	1	25	PE 1.11	Demonstrate simple flexibility exercises, for example, stretching arms and legs as high and wide as possible in various directions and at various heights and by twisting and turning the body.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
562	11	4	1	25	PE 1.12	Move individually in general space, changing direction and speed, without interfering with other people while walking, hopping, running, or rolling on the floor.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
563	11	4	4	26	PE 2.11	Demonstrate the proper way of taking a throw in, corner kick and goal kick.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
564	11	4	4	26	PE 2.12	Reduce open space by using locomotor movements, walking, running, changing size and shape in body in combination with movement concepts, reducing the angle in the space, reducing distance between player and goal.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
565	11	4	4	26	PE 2.13	Participate in small group games by passing a ball to a partner or shooting a stationary ball at a goal or other target with a short run up.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
566	11	5	1	25	PE 1.14	Maintain balance while stretching, curling, twisting, and transferring weight from one part of the body to another.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
567	11	5	1	25	PE 1.15	Maintain balance while moving, changing direction, and coming to an abrupt stop.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
568	11	5	1	25	PE 1.16	Skip a short or long rope continuously that is turned by self or others.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
569	11	5	1	25	PE 1.17	Execute flexibility exercises such as reaching as far as possible in different directions with the arms, lifting the knee to the chest and rotating outstretched arms in a circle, while sitting or standing.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
570	11	5	1	25	PE 1.18	Perform various stretches using static and dynamic activities.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
571	11	5	4	26	PE 2.14	Dribble, pass and control a football in general space and through obstacles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
572	11	5	4	26	PE 2.15	Kick a moving ball, using different techniques to hit a target or goal.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
573	11	5	4	26	PE 2.16	Apply combined skills in a simplified football game.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
574	11	6	1	25	PE 1.19	Transfer weight from one foot to another to maintain balance, while stationary or traveling, while moving different body parts in a variety of ways.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
575	11	6	4	26	PE 2.17	Pass, dribble and control a football while changing pace and direction, using different techniques.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
576	11	7	1	25	PE 1.23	Balance, symmetrically and non-symmetrically, on different bases of support, combining levels with shapes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
577	11	7	1	25	PE 1.24	Create an original individual jump-rope routine that includes basic jumps with a short rope or long rope.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
578	11	7	1	25	PE 1.25	Create a jump-rope routine with a partner, using either a short or long rope that includes basic jumps and tricks such as star jumps, side straddles and jumping in and out of the rope.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
579	11	7	1	25	PE 1.26	Explain the importance of and perform basic stretching exercises and aerobic activities to warm-up the body.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
580	11	7	4	26	PE 2.20	Control a passed football with the chest, legs or side of the foot and pass the football to a stationary and moving partner in a variety of ways.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
581	11	7	4	26	PE 2.21	Explain and apply football rules and tactics including commonly used team formations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
582	11	7	4	26	PE 2.22	Shoot a stationary or moving football at a goal or other target from a variety of distances and angles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
583	11	7	4	26	PE 2.23	Regain control of a football from another player with a safe, clean tackle.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
584	11	8	1	25	PE 1.28	Balance on either leg, demonstrating muscular tension and extensions of free body parts.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
585	11	8	1	25	PE 1.29	Perform a routine that includes a variety of postures and body movements while balancing on a painted line.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
586	11	8	1	25	PE 1.30	Discuss the importance and benefits of stretching and safely perform a variety of stretching exercises.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
587	11	8	1	25	PE 1.31	Participate in fitness exercises that increase flexibility, muscular strength, and muscular endurance.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
588	11	8	1	25	PE 1.32	Create an original routine that combines a variety of twisting, curling, bending, and stretching actions.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
589	11	8	4	26	PE 2.25	Identify the roles of the eleven positions on a football team and present on one of the roles.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
590	11	8	4	26	PE 2.26	Shoot a ball to an identified target or goal with the four-step technique.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
591	11	8	4	26	PE 2.27	Explain and demonstrate the standing position technique to hold a ball from a shot.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
592	11	8	4	26	PE 2.28	Demonstrate how to control a passed football with the legs or side of the foot and how to pass it to a stationary or moving partner in a variety of ways.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
593	11	9	1	25	PE 1.33	Perform, individually or with a partner, original jump rope routines that include basic jumps and tricks.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
594	11	9	1	25	PE 1.34	Perform a variety of high and low kicks and turns while maintaining balance.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
595	11	9	1	25	PE 1.35	Perform balancing on stilts for several minutes.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
596	11	9	1	25	PE 1.36	Explain the importance of and perform simple warm up or cool down routines that includes a variety of light aerobic exercises and stretches.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
597	11	9	1	25	PE 1.37	Demonstrate appropriate posture while performing different exercises with different variations.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
598	11	9	4	26	PE 2.29	Control a passed football with the chest, legs or side of the foot and immediately pass it to a partner.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
599	11	9	4	26	PE 2.30	Identify and demonstrate a range of goalkeeping techniques.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
600	11	9	4	26	PE 2.31	Dribble a football showing control of pace and direction and demonstrate how to regain possession of a ball from another player with a safe, clean tackle.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
601	11	9	4	26	PE 2.32	Participate in and demonstrate an understanding of tactics in a modified football game.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
602	3	5	1	27	SC 4.04	Demonstrate how the human ear detects sound and distinguish between the major components of the outer, middle and inner ear. Introduction to Digital	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
603	3	5	1	28	SC 5.01	Interact with and explore a range of digital equipment such as cameras, microphones, microscopes, laptops.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
604	3	5	1	28	SC 5.02	Describe how to position the body, adjust lighting, position equipment and when to take breaks when using digital devices.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
605	3	5	1	28	SC 5.03	Operate a variety of digital tools such as open/close, save, print, navigate, use input and output devices, log on and log off, and unplugging.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
606	3	5	1	28	SC 5.04	Identify, locate and use letters, numbers and special keys on keyboard such as space bar, shift and delete.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
607	3	6	1	27	SC 4.08	Demonstrate how heat can be transmitted through solids, liquids, and gases using conduction, convection, radiation.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
608	3	6	1	27	SC 4.09	Identify and investigate materials that are good heat insulators and good heat conductors and describe some uses of these materials. Online Safety/Surfing the Web	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
609	3	6	1	28	SC 5.05	Identify the differences and Similarities between private and personal information and discuss why keeping personal information such as name, location, phone number and home addresses are considered private.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
610	3	6	1	28	SC 5.06	Discuss and explain the importance of password, passcode, and face Identification as a form of protection for private information.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
611	3	6	1	28	SC 5.07	Explain that devices Such as computers, laptops and tablets can save	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
612	3	6	1	29	SC 6.04	Diagram typical growth cycles of local animals.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
613	3	6	1	29	SC 6.05	Show how a variety of local animals require different habitats during their growth cycle and discuss how habitats provide animals with their basic needs.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
614	3	7	1	27	SC 4.10	Define matter and explain the properties of solids, liquids, and gases based on the particle nature of matter.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
615	3	7	1	27	SC 4.11	Identify solutes and solvents in common solid, liquid, and gaseous solutions and discuss and differentiate between pure substances, mixtures, elements, and compounds by using the particle theory of matter.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
616	3	7	1	27	SC 4.12	Demonstrate different methods such as filtration, distillation and chromatography to separate the components of both solutions and mixtures. (Netiquette)	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
617	3	7	1	28	SC 5.08	Explain proper online etiquette.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
618	3	7	1	28	SC 5.09	Identify different forms of bullying, including cyberbullying and suggest strategies for dealing with it such as screenshot, saving evidence, block, not replying, report.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
619	3	7	1	28	SC 5.10	Identify and discuss online identity theft and security symbols such as padlock, phishing, scam websites.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
620	3	8	1	27	SC 4.15	Demonstrate and explain that light is a form of energy, that travels in a straight line, and can be separated into the visible light spectrum. SC. 4.16 Conduct experiment to explore the differences between reflection and refraction of light and describe how reflected and refracted images formed.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
621	3	8	1	27	SC 4.17	Explain how the human eye detects images and compare the basic functional operation such as eye lids to shutter and lens to retina of the human eye to that of a camera in focussing an image. Ethical Use of Digital Resources	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
622	3	8	1	28	SC 5.11	Define good digital citizenship as using technology safely, responsibly, and ethically.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
623	3	8	1	28	SC 5.12	Discuss that copying the work of others and presenting it as own is called plagiarism.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
624	3	9	1	27	SC 4.22	Analyze the immediate and long- term effects that extraction and uses of natural resources for energy production has on society and the environment and make recommendations for minimizing the effects now and in the future. Relationships and Communications	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
625	3	9	1	28	SC 5.13	Identify and describe how students, teachers, parents, and other workers use many types of technologies in their daily work and personal lives.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
626	3	9	1	28	SC 5.14	Explain the similarities and differences between offline and online communications, including rules to follow when communicating face-to face and online and discuss how online communication can be misinterpreted.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
627	3	9	1	28	SC 5.15	List and explain the advantages of communicating electronically including time and resource saving, cost effectiveness, accessibility to multiple	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
628	3	9	1	29	SC 6.19	Investigate how selected plants have adapted in ways that enable them to survive in their ecosystem.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
629	3	9	1	29	SC 6.20	Explore diversity of plants in different ecosystems in Belize.	2026-03-30 14:08:12.460897	2026-03-30 14:08:12.460897
659	12	2	1	40	HE 1.1.1	Identify and practice basic personal hygiene habits such as handwashing, tooth brushing, and bathing.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
660	12	2	1	40	HE 1.1.2	Recognize and name basic food groups and healthy food choices.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
661	12	2	1	41	HE 1.2.1	Understand basic safety rules in the home and classroom environment.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
662	12	2	1	42	HE 1.3.1	Express emotions in appropriate ways and recognize emotions in others.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
663	12	3	1	40	HE 1.1.3	Discuss and practice the benefits of regular physical activity and rest.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
664	12	3	1	40	HE 1.1.4	Identify foods that provide energy and promote growth and development.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
665	12	3	1	43	HE 1.4.1	Identify trusted adults and understand basic personal safety rules.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
666	12	4	2	40	HE 2.1.1	Analyze the relationship between nutrition, physical activity, and overall health.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
667	12	4	2	41	HE 2.2.1	Develop safe practices in different environments and situations.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
668	12	4	2	42	HE 2.3.1	Build positive relationships and develop healthy communication skills.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
669	12	5	2	40	HE 2.1.2	Examine the impact of lifestyle choices on health and wellness.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
670	12	5	2	43	HE 2.4.1	Understand risks and consequences of substance abuse and peer pressure.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
671	12	6	2	44	HE 2.5.1	Understand physical and emotional changes during puberty and adolescence.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
672	12	6	2	42	HE 2.3.2	Develop strategies for managing stress and maintaining mental health.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
673	12	7	3	40	HE 3.1.1	Evaluate dietary patterns and make informed nutritional choices.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
674	12	7	3	41	HE 3.2.1	Analyze environmental health hazards and develop prevention strategies.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
675	12	8	3	43	HE 3.4.1	Assess risks related to substance use and make responsible decisions.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
676	12	8	3	44	HE 3.5.1	Apply strategies for promoting sexual health, reproduction, and family planning.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
677	12	9	3	42	HE 3.3.1	Demonstrate healthy relationship skills and conflict resolution strategies.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
678	12	9	3	40	HE 3.1.2	Analyze the relationship between health behaviors and chronic disease prevention.	2026-03-30 14:54:43.079302	2026-03-30 14:54:43.079302
\.


--
-- Data for Name: lesson_versions; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.lesson_versions (version_id, lesson_id, version_number, content, change_description, changed_by, changed_at) FROM stdin;
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.lessons (lesson_id, resource_id, lesson_number, title, duration_minutes, objectives, materials, content, assessment, differentiation, created_at) FROM stdin;
1	5	1	Fractions	\N	\N	\N	{"blocks":[{"content":["understand fractions"],"id":"e231644a-ad45-48d4-99f1-f6e9098e299c","title":"","type":"objectives","visibility":"public"}],"version":1}	\N	\N	2026-02-18 12:16:07.712503
2	6	1	If Statement	\N	\N	\N	{"blocks":[{"content":["understand IFs"],"id":"2716fad9-e41b-4264-9e45-72ff75ed3aa6","title":"","type":"objectives","visibility":"public"}],"version":1}	\N	\N	2026-02-19 09:42:27.576697
3	7	1	Binary Numbers	\N	\N	\N	{"blocks":[{"content":["understand how to convert binary to decimal"],"id":"12777559-9915-4a1d-b215-1cd9084733bd","title":"","type":"objectives","visibility":"public"}],"version":1}	\N	\N	2026-02-19 09:58:04.719448
4	15	1	Emailing - Carbon Copying	\N	\N	\N	{"blocks":[{"content":["Students will carbon copy an email to two different email addresses."],"id":"af08c6ae-de91-4608-b651-25c3fc4d63d2","title":"","type":"objectives","visibility":"public"},{"content":["Computers","Internet","Google Workspace apps"],"id":"3c16cf8b-c939-41a2-ba1b-f4c7447ef60e","title":"","type":"materials","visibility":"public"},{"content":[{"step":1,"text":"Click on the compose icon."},{"step":2,"text":"Type amilcar@vns.edu.bz in the ‘to’ field.\\n"},{"step":3,"text":"Click on the letters ‘cc’ on the right hand side of the ‘to’ field.\\n"},{"step":4,"text":"Type a classmate’s email address on the new ‘cc’ field that appears.\\n"},{"step":5,"text":"Type ‘three reasons you are a great friend’ as the subject.\\n"},{"step":6,"text":"Type a paragraph related to the topic in the email body.\\n"},{"step":7,"text":"Click on the ‘send’ button to send the email.\\n"}],"id":"02997f79-2c27-4c23-ae06-8b51fef2c23f","title":"Click on the gmail icon.","type":"activity","visibility":"public"},{"content":{"description":"Students will independently carbon copy an email message","type":"formative"},"id":"682c5a99-fd59-464f-9849-7c2825e3504c","title":"Carbon copy an email message.","type":"assessment","visibility":"public"}],"version":1}	\N	\N	2026-02-25 14:03:55.653064
5	16	1	Typing the Top Row	\N	\N	\N	{"blocks":[{"content":["Type the 10 top row keys using the correct fingers after viewing a finger map."],"id":"52be5519-3c31-46a2-a76d-b471f5b0bd73","title":"","type":"objectives","visibility":"public"},{"content":["Computers","Google Classroom","Typing Club"],"id":"79b33842-4418-4a5a-9499-71458d99d38b","title":"","type":"materials","visibility":"public"},{"content":{"description":"Volunteer students will share the fingers we use to type keys in the home row.\\n","duration_minutes":5},"id":"eab7141b-c754-453b-a196-f1a4748bad11","title":"Home key Warm up","type":"warmup","visibility":"public"},{"content":[{"step":1,"text":"Login in to victorious.edclub.com"},{"step":2,"text":"Observe the placement of the top row keys on the on-screen keyboard."},{"step":3,"text":"Place hands over the home keys and practice moving fingers to the top row key positions, one by one."},{"step":4,"text":"Repeat this at least 10 times per key."},{"step":5,"text":"Complete lessons 20-40 in the Typing Jungle curriculum."}],"id":"9be348a1-9d69-4ab7-89df-27f16572ffa4","title":"Use Typing Club to learn new Keys:","type":"activity","visibility":"public"}],"version":1}	\N	\N	2026-03-16 14:23:08.605629
6	19	1	Test Lesson Plan	\N	\N	\N	{"blocks":[{"content":["testing this lesson objective"],"id":"70bc1cf5-df3c-470e-9e31-6b3e893431e2","title":"","type":"objectives","visibility":"public"}],"version":1}	\N	\N	2026-03-17 10:08:37.497331
7	20	1	Emailing - Carbon Copying	\N	\N	\N	{"blocks":[{"content":["Students will carbon copy an email to two different email addresses."],"id":"34d9f7a7-6c71-4e41-85af-61e0d1b16848","title":"","type":"objectives","visibility":"public"},{"content":["Computers","Typing Club"],"id":"322929ad-12fc-42f0-844a-4911a233669a","title":"","type":"materials","visibility":"public"},{"content":[{"step":1,"text":"Click on the gmail icon."},{"step":2,"text":"Click on the compose icon."}],"id":"dab99257-468b-46c7-b3c8-e4eef9502546","title":"Send an email attachment","type":"activity","visibility":"public"}],"version":1}	\N	\N	2026-03-17 13:54:50.729144
8	21	1	Font Formatting	\N	\N	\N	{"blocks":[{"content":["Students will change a variety of font formatting options within a pre-prepared document."],"id":"4d4fd78e-d5ed-4a70-9679-4d343661a791","title":"","type":"objectives","visibility":"public"},{"content":["computers","word processors","worksheets"],"id":"5b779562-402d-41c5-a02d-3546b91c4c56","title":"","type":"materials","visibility":"public"},{"content":[{"step":1,"text":"Open Google Classroom."},{"step":2,"text":"Go to this week’s assignment."},{"step":3,"text":"Create a copy of the document “fun with fonts”."}],"id":"7a42daf0-f76d-48bb-b2bc-2142b6c46716","title":"Have fun with fonts","type":"activity","visibility":"public"}],"version":1}	\N	\N	2026-03-17 14:03:30.599385
9	22	1	 Emailing - Attachments	\N	\N	\N	{"blocks":[{"content":["Students will attach a file to an email message."],"id":"0d3d010c-0677-42a0-880c-0b093fbee519","title":"","type":"objectives","visibility":"public"},{"content":["Typing Club Web App"],"id":"82d05199-4f4e-4e96-af6c-3396728847b0","title":"","type":"materials","visibility":"public"},{"content":[{"step":1,"text":"Click on the gmail icon."},{"step":2,"text":"Click on the compose icon.\\n"},{"step":3,"text":"Type amilcar@vns.edu.bz in the ‘to’ field.\\n"},{"step":4,"text":"Click on the letters ‘cc’ on the right hand side of the ‘to’ field."}],"id":"ae663105-0b2c-45ad-952f-fc7d327de8a6","title":"Send Attachment using gmail","type":"activity","visibility":"public"}],"version":1}	\N	\N	2026-03-17 14:15:42.495334
10	26	1	The life Cycle of a butterfly	\N	\N	\N	{"blocks":[{"content":["understand the cycles present in a butterflies' life",""],"id":"769d371c-59d5-4f6c-9114-4ae75515a13f","title":"","type":"objectives","visibility":"public"}],"version":1}	\N	\N	2026-03-30 15:24:21.90041
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.notifications (notification_id, user_id, message, channel, sent_at, read) FROM stdin;
\.


--
-- Data for Name: resource_access; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_access (access_id, resource_id, user_id, accessed_at) FROM stdin;
\.


--
-- Data for Name: resource_comments; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_comments (comment_id, resource_id, user_id, parent_comment_id, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: resource_grade_levels; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_grade_levels (resource_id, grade_level_id) FROM stdin;
24	2
17	2
10	2
9	2
8	2
3	2
2	2
25	3
23	3
18	4
1	4
22	5
21	5
16	5
15	5
14	5
4	5
22	6
21	6
20	6
16	6
15	6
20	7
6	7
13	8
19	9
7	9
5	9
26	4
27	6
27	7
28	4
29	4
30	2
30	3
31	2
31	3
\.


--
-- Data for Name: resource_ilos; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_ilos (id, resource_id, ilo_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: resource_links; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_links (link_id, parent_resource_id, linked_resource_id, relationship_type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: resource_reviews; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_reviews (review_id, resource_id, reviewer_id, reviewer_role_id, decision, comment_summary, reviewed_at) FROM stdin;
2	7	3	1	Approved		2026-02-19 13:45:36.874093
3	6	3	1	Approved		2026-02-19 13:51:43.811353
4	10	3	1	Approved		2026-02-23 09:14:06.590612
6	11	3	1	Approved		2026-02-23 14:07:22.862142
7	8	3	1	Approved		2026-02-23 14:07:50.977915
8	5	3	1	Approved		2026-02-23 14:08:07.76868
9	15	3	1	Approved		2026-02-25 14:05:45.207003
11	13	3	1	Approved		2026-03-03 12:04:55.112797
5	14	3	1	Approved		2026-03-03 15:35:45.812022
18	16	3	1	Approved		2026-03-16 14:23:27.051893
19	19	3	1	Approved		2026-03-17 11:57:14.596316
20	20	3	1	Approved		2026-03-17 13:55:29.148763
21	21	3	1	Approved		2026-03-17 14:04:21.863945
22	22	3	1	Approved		2026-03-17 14:17:12.299249
23	23	3	1	Approved		2026-03-17 14:33:01.197846
24	24	3	1	Approved		2026-03-23 16:07:36.00396
25	25	3	1	Approved		2026-03-23 16:10:28.421201
\.


--
-- Data for Name: resource_status_history; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_status_history (history_id, resource_id, old_status, new_status, changed_by, changed_at) FROM stdin;
1	7	Draft	UnderReview	3	2026-02-19 10:32:59.761254
2	7	UnderReview	Approved	3	2026-02-19 13:45:36.888681
3	6	Draft	Approved	3	2026-02-19 13:51:43.821992
4	10	Draft	Approved	3	2026-02-23 09:14:06.601421
5	13	UnderReview	Approved	3	2026-02-23 11:33:46.583528
6	14	Draft	Approved	3	2026-02-23 12:58:40.489454
7	11	UnderReview	Approved	3	2026-02-23 14:07:22.86999
8	8	Draft	Approved	3	2026-02-23 14:07:50.986541
9	5	Draft	Approved	3	2026-02-23 14:08:07.777243
10	6	Approved	Approved	3	2026-02-23 14:56:43.116699
11	9	Draft	Draft	3	2026-02-23 14:58:42.544466
12	15	Draft	Draft	3	2026-02-25 14:04:27.451429
13	15	Draft	Draft	3	2026-02-25 14:04:32.803793
14	15	Draft	Approved	3	2026-02-25 14:05:45.212463
15	13	Published	Approved	3	2026-03-03 12:04:55.127086
16	14	Published	Approved	3	2026-03-03 15:15:47.089037
17	14	Published	Approved	3	2026-03-03 15:17:12.012924
18	14	Published	Approved	3	2026-03-03 15:31:26.891381
19	14	Published	Approved	3	2026-03-03 15:35:45.821038
20	16	Draft	Approved	3	2026-03-16 14:23:27.122228
21	19	Draft	Approved	3	2026-03-17 11:57:14.609516
22	20	Draft	Approved	3	2026-03-17 13:55:29.158936
23	21	Draft	Approved	3	2026-03-17 14:04:21.880333
24	22	Draft	Approved	3	2026-03-17 14:17:12.319319
25	23	Draft	Approved	3	2026-03-17 14:33:01.217666
26	24	Draft	Approved	3	2026-03-23 16:07:36.019985
27	25	Draft	Approved	3	2026-03-23 16:10:28.44757
28	26	Submitted	UnderReview	3	2026-04-15 09:44:30.652023
\.


--
-- Data for Name: resource_subjects; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resource_subjects (resource_id, subject_id) FROM stdin;
23	1
19	1
17	1
10	1
9	1
8	1
7	1
6	1
4	1
3	1
2	1
23	2
22	2
21	2
20	2
16	2
15	2
10	2
9	2
8	2
24	3
18	3
14	3
13	3
11	3
25	4
7	8
5	8
1	9
26	3
27	2
28	2
29	2
30	2
30	1
31	2
31	1
\.


--
-- Data for Name: resources; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.resources (resource_id, title, category, drive_link, status, published_url, contributor_id, created_at, slug, summary, updated_at) FROM stdin;
11	STEAM Test Video	Video	https://drive.google.com/file/d/19vALpAk63hCLW233nhLpe0cMeNaHzj1q/view?usp=sharing	Published	https://www.youtube.com/watch?v=AdNVUngXgAs	3	2026-02-23 11:31:51.545794	steam-test-video-0fa034a1	A test video to verify the YouTube upload pipeline.	2026-02-23 14:07:30.717441
8	Testing a video	Video	https://drive.google.com/file/d/19vALpAk63hCLW233nhLpe0cMeNaHzj1q/view?usp=sharing	Published	https://www.youtube.com/watch?v=VKmKwiZXHuQ	3	2026-02-19 15:31:32.778595	testing-a-video-4fd2206e	this video is for testing purposes	2026-02-23 14:07:58.074685
5	Fractions	LessonPlan	\N	Approved	\N	3	2026-02-18 12:16:07.64455	fractions-55b8df08	brief introduction to fractions and what they do	2026-02-23 14:08:07.77523
6	If Statement	LessonPlan	\N	Approved	\N	3	2026-02-19 09:42:27.568381	if-statement-416b4dff	Basic understanding of the IF conditional	2026-02-23 14:56:43.112059
9	Testing a video	Video	https://drive.google.com/file/d/19vALpAk63hCLW233nhLpe0cMeNaHzj1q/view?usp=sharing	Draft	\N	3	2026-02-19 15:33:02.141476	testing-a-video-897348ae	this video is for testing purposes	2026-02-23 14:58:42.541009
13	STEAM Test Video	Video	https://drive.google.com/file/d/19vALpAk63hCLW233nhLpe0cMeNaHzj1q/view?usp=sharing	Published	https://www.youtube.com/watch?v=7qJy51l5nkY	3	2026-02-23 11:33:46.420051	steam-test-video-e0388ddc	A test video to verify the YouTube upload pipeline.	2026-03-03 12:05:03.1757
15	Emailing - Carbon Copying	LessonPlan	https://docs.google.com/document/d/1bH6uWTo9Wh1p2b74-4QNrQLvkl7YGdEtkzIInSfxiQQ/edit?usp=sharing	Approved	\N	3	2026-02-25 14:03:55.644209	emailing-carbon-copying-87fdfbaa	This lesson introduces students to the concept of email carbon copying.	2026-02-25 14:05:45.211159
14	Intro to Belize Wildlife	Video	https://drive.google.com/file/d/19vALpAk63hCLW233nhLpe0cMeNaHzj1q/view?usp=drive_link	Approved	https://www.youtube.com/watch?v=9S-h6ASlsKw	3	2026-02-23 12:58:24.588771	intro-to-belize-wildlife-e0ad4827	introduces some basic Belize Wildlife concepts	2026-03-03 15:35:45.818659
16	Typing the Top Row	LessonPlan	\N	Approved	\N	3	2026-03-16 14:23:08.537497	typing-the-top-row-2c115210	Students will learn how to type the home row using all fingers.	2026-03-16 14:23:27.117274
17	test resource to see if it appears in panel	Slideshow	https://docs.google.com/presentation/d/1Z8cnrbeoyb-zKUTVKsauZZfEKKz5hc64y3GNIaLyoxs/edit?usp=sharing	Draft	\N	3	2026-03-17 10:04:50.973376	test-resource-to-see-if-it-appears-in-panel-55e1ed11	this is just a test	2026-03-17 10:04:50.973376
18	test assessment	Assessment	https://docs.google.com/presentation/d/1Z8cnrbeoyb-zKUTVKsauZZfEKKz5hc64y3GNIaLyoxs/edit?usp=sharing	Draft	\N	3	2026-03-17 10:07:50.327783	test-assessment-3a4e5ce8		2026-03-17 10:07:50.327783
19	Test Lesson Plan	LessonPlan	\N	Approved	\N	3	2026-03-17 10:08:37.487634	test-lesson-plan-7b26f316		2026-03-17 11:57:14.604149
20	Emailing - Carbon Copying	LessonPlan	\N	Approved	\N	4	2026-03-17 13:54:50.7157	emailing-carbon-copying-fb3dc120	A lesson designed to teach about carbon copying	2026-03-17 13:55:29.156781
21	Font Formatting	LessonPlan	\N	Approved	\N	4	2026-03-17 14:03:30.582707	font-formatting-2ba4c903		2026-03-17 14:04:21.875713
22	 Emailing - Attachments	LessonPlan	\N	Approved	\N	12	2026-03-17 14:15:42.48275	emailing-attachments-e9e483d3		2026-03-17 14:17:12.314421
23	Test submission	Assessment	https://www.youtube.com/watch?v=23ki6LdnYRM&list=RD23ki6LdnYRM&start_radio=1	Approved	\N	12	2026-03-17 14:32:18.4836	test-submission-b878b7a2		2026-03-17 14:33:01.211478
24	test assessment 1.3	Assessment	https://docs.google.com/document/d/1XoC7r0YREhjLbAynfZpX1qnjxH9G8H2thwTFZ4xEhkk/edit?tab=t.0#heading=h.rrhcbdqfaf5t	Approved	\N	3	2026-03-23 16:06:46.780785	test-assessment-13-751e4a72		2026-03-23 16:07:36.013925
25	Test Assessment from ADmin	Assessment	https://docs.google.com/document/d/1XoC7r0YREhjLbAynfZpX1qnjxH9G8H2thwTFZ4xEhkk/edit?usp=sharing	Approved	\N	3	2026-03-23 16:10:09.999465	test-assessment-from-admin-d7449076		2026-03-23 16:10:28.438446
1	testing hopefully this time it works	Video	\N	Submitted	\N	3	2026-02-16 14:14:53.297986	\N	\N	2026-03-24 11:49:08.681099
2	Intro to Functions	LessonPlan	\N	Submitted	\N	3	2026-02-16 14:24:05.311037	\N	\N	2026-03-24 11:49:08.681099
3	Basics of HTML	LessonPlan	\N	Submitted	\N	3	2026-02-18 11:43:21.161878	\N	some descritpion goes here	2026-03-24 11:49:08.681099
7	Binary Numbers	LessonPlan	\N	UnderReview	\N	3	2026-02-19 09:58:04.709633	binary-numbers-c7056832	short intro to binary numbers	2026-03-24 11:49:08.681099
10	Testing a video	Video	https://drive.google.com/file/d/19vALpAk63hCLW233nhLpe0cMeNaHzj1q/view?usp=sharing	UnderReview	\N	3	2026-02-19 15:33:10.2461	testing-a-video-f68178de	this video is for testing purposes	2026-03-24 11:49:08.681099
4	Algorithms	LessonPlan	\N	NeedsRevision	\N	3	2026-02-18 11:54:40.714507	\N	a basic intro to algorithms	2026-03-24 11:49:08.681099
27	test resource for emails	Assessment	https://docs.google.com/document/d/1XoC7r0YREhjLbAynfZpX1qnjxH9G8H2thwTFZ4xEhkk/edit?tab=t.0	Submitted	\N	3	2026-03-31 15:53:43.496027	test-resource-for-emails-ca861f46		2026-03-31 15:53:43.496027
28	Functions in Coding	LessonPlan	\N	Draft	\N	3	2026-04-01 15:37:12.53878	functions-in-coding-cca397c4		2026-04-01 15:37:12.53878
29	Functions in Coding	LessonPlan	\N	Draft	\N	3	2026-04-01 15:37:45.961126	functions-in-coding-db68bc45		2026-04-01 15:37:45.961126
30	Functions in Coding	LessonPlan	\N	Draft	\N	3	2026-04-01 15:54:44.965594	functions-in-coding-cd60a30f		2026-04-01 15:54:44.965594
31	Functions in Coding	LessonPlan	\N	Draft	\N	3	2026-04-01 16:02:28.692152	functions-in-coding-2ad43219		2026-04-01 16:02:28.692152
26	The life Cycle of a butterfly	LessonPlan	\N	UnderReview	\N	3	2026-03-30 15:24:21.833213	the-life-cycle-of-a-butterfly-600c3688		2026-04-15 09:44:30.643393
\.


--
-- Data for Name: review_comments; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.review_comments (comment_id, resource_id, reviewer_id, section, block_index, comment, resolved, created_at, resolved_at) FROM stdin;
1	7	3	objectives	0	test comment	t	2026-02-19 10:32:59.763353	2026-02-19 10:34:46.199998
2	26	3	objectives	0	not related to content	f	2026-04-15 09:44:30.65455	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.roles (role_id, name, description) FROM stdin;
1	admin	System administrator with full access
2	User	Default user with view, rate, and comment access
3	Fellow	Fellow user who can submit and manage resources
4	SubjectExpert	can review and approve resources in their subject area
5	TeamLead	can review and approve resources across all subjects and manage fellows
6	DSC	Director of Science and Technology, oversees all content and user management
7	Secretary	Administrative Secretary
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.schema_migrations (version, dirty) FROM stdin;
39	f
\.


--
-- Data for Name: strands; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.strands (id, subject_id, name, created_at) FROM stdin;
5	7	Identity in Belize	2026-03-30 14:08:05.408935
6	7	Civics Education	2026-03-30 14:08:05.408935
7	7	African and Maya History	2026-03-30 14:08:05.408935
8	6	Dance and Drama	2026-03-30 14:08:05.408935
9	6	Music	2026-03-30 14:08:05.408935
10	6	Creative Art Forms	2026-03-30 14:08:05.408935
11	6	Three-Dimensional Art	2026-03-30 14:08:05.408935
12	9	Reading Fluency & Accuracy	2026-03-30 14:08:05.408935
13	9	Comprehension	2026-03-30 14:08:05.408935
14	9	Production	2026-03-30 14:08:05.408935
15	9	Language Structure	2026-03-30 14:08:05.408935
16	8	Numbers & Number Operations	2026-03-30 14:08:05.408935
17	8	Patterns	2026-03-30 14:08:05.408935
18	8	Addition & Subtraction	2026-03-30 14:08:05.408935
19	8	Multiplication & Division	2026-03-30 14:08:05.408935
20	8	Fraction and Decimals	2026-03-30 14:08:05.408935
21	8	Geometry	2026-03-30 14:08:05.408935
22	8	Measurement	2026-03-30 14:08:05.408935
23	8	Sets	2026-03-30 14:08:05.408935
24	8	Data	2026-03-30 14:08:05.408935
25	11	Body Skills & Fitness	2026-03-30 14:08:05.408935
26	11	Football	2026-03-30 14:08:05.408935
27	3	Energy Resources	2026-03-30 14:08:05.408935
28	3	Relationships and Communications Plagiarism	2026-03-30 14:08:05.408935
29	3	Plant Diversity	2026-03-30 14:08:05.408935
40	12	Personal Health, Nutrition, and Disease Prevention	2026-03-30 14:54:43.016239
41	12	Environmental Health and Safety	2026-03-30 14:54:43.016239
42	12	Social and Emotional Health and Relationships	2026-03-30 14:54:43.016239
43	12	Personal Safety and Substance Abuse	2026-03-30 14:54:43.016239
44	12	Growth, Development, and Mental Well-being	2026-03-30 14:54:43.016239
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.subjects (subject, id) FROM stdin;
Computer Science	1
Information Technology	2
Engineering	4
Robotics	5
Belizean History	7
Mathematics	8
Social Studies	10
Physical Education	11
Science and Technology	3
Expressive Arts	6
Language Arts	9
Health Education	12
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.users (user_id, username, email, password_hash, role_id, is_active, last_login, created_at, created_by, updated_at, updated_by) FROM stdin;
5	TeacherVasquez	amilcar@vns.edu.bz	$2a$12$fIPLF9DrFAyq2zrHEFF4te0yN8xcECFwMRSPuerPJwHaxoudJxRAG	2	t	\N	2026-02-24 13:26:07.410613	\N	2026-02-24 13:26:07.410613	\N
4	501Intern	501academy.intern@moe.gov.bz	$2a$12$dApw3tAl9TwB742pmqF80eqmUWeR0okEFBqRl2fEjmWFcJN.farze	3	t	\N	2026-02-23 14:53:23.405323	\N	2026-03-17 14:11:33.004915	\N
12	amilcarCoder	belizeno@e.email	$2a$12$XZeu3we3Q6LTytWEhMO54uh624zZoC6HtswaiNML6R0BQP93wkBmq	3	t	\N	2026-03-16 12:55:06.355885	\N	2026-03-16 12:56:02.574268	\N
13	MilStudent	2022156707@ub.edu.bz	$2a$12$30S1yHus7r.kNuGmbCDHvu67EBDAa9piB8XKH3uLlo96poqGoGXrC	3	t	\N	2026-03-23 15:48:07.228223	\N	2026-03-23 15:48:23.572959	\N
14	AmilcarDev	amilcar@appspirebz.com	$2a$12$efi0YHIiBRfPwtv3LS3P1OqU5hfCB3smD3b.GEpawBSRWTfvGv6hK	2	t	\N	2026-03-24 10:07:54.425287	\N	2026-03-24 10:09:35.994921	\N
3	amilcar	belizeno@gmail.com	$2a$12$RoVNAWlnUD3RhQfVEVIBs.PBMgk8C5Nxh7QCVo2o3b7oLw6yDyO5W	1	t	\N	2026-02-16 10:54:42.20329	\N	2026-03-24 13:59:46.231434	\N
\.


--
-- Data for Name: video_metadata; Type: TABLE DATA; Schema: public; Owner: 501SteamHub
--

COPY public.video_metadata (id, resource_id, youtube_title, youtube_description, tags, privacy_status, made_for_kids, category_id, created_at, updated_at) FROM stdin;
1	8	Testing a video	this video is for testing purposes	{"Information Technology","Computer Science","Infant 1"}	unlisted	t	27	2026-02-19 15:31:32.778595-06	2026-02-19 15:31:32.778595-06
2	9	Testing a video	this video is for testing purposes	{"Information Technology","Computer Science","Infant 1"}	unlisted	t	27	2026-02-19 15:33:02.141476-06	2026-02-19 15:33:02.141476-06
3	10	Testing a video	this video is for testing purposes	{"Information Technology","Computer Science","Infant 1"}	unlisted	t	27	2026-02-19 15:33:10.2461-06	2026-02-19 15:33:10.2461-06
4	11	STEAM Test Video - 501SteamHub	Test upload from the 501 STEAM Hub automated pipeline.	{STEAM,Education,Belize}	unlisted	f	27	2026-02-23 11:31:51.545794-06	2026-02-23 11:31:51.545794-06
6	13	STEAM Test Video - 501SteamHub	Test upload from the 501 STEAM Hub automated pipeline.	{STEAM,Education,Belize}	unlisted	f	27	2026-02-23 11:33:46.420051-06	2026-02-23 11:33:46.420051-06
7	14	Intro to Belize Wildlife	introduces some basic Belize Wildlife concepts	{Science,"Standard 2"}	unlisted	t	27	2026-02-23 12:58:24.588771-06	2026-02-23 12:58:24.588771-06
\.


--
-- Name: auth_tokens_token_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.auth_tokens_token_id_seq', 1, false);


--
-- Name: contributions_contribution_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.contributions_contribution_id_seq', 1, false);


--
-- Name: cycles_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.cycles_id_seq', 4, true);


--
-- Name: fellow_applications_application_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.fellow_applications_application_id_seq', 1, false);


--
-- Name: fellows_fellow_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.fellows_fellow_id_seq', 1, false);


--
-- Name: grade_levels_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.grade_levels_id_seq', 10, true);


--
-- Name: ilos_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.ilos_id_seq', 7, true);


--
-- Name: lesson_versions_version_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.lesson_versions_version_id_seq', 1, false);


--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.lessons_lesson_id_seq', 1, false);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.notifications_notification_id_seq', 1, false);


--
-- Name: resource_access_access_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.resource_access_access_id_seq', 1, false);


--
-- Name: resource_comments_comment_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.resource_comments_comment_id_seq', 1, false);


--
-- Name: resource_ilos_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.resource_ilos_id_seq', 1, false);


--
-- Name: resource_links_link_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.resource_links_link_id_seq', 1, false);


--
-- Name: resource_reviews_review_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.resource_reviews_review_id_seq', 1, false);


--
-- Name: resource_status_history_history_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.resource_status_history_history_id_seq', 1, false);


--
-- Name: resources_resource_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.resources_resource_id_seq', 1, false);


--
-- Name: review_comments_comment_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.review_comments_comment_id_seq', 1, false);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.roles_role_id_seq', 7, true);


--
-- Name: strands_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.strands_id_seq', 30, true);


--
-- Name: subjects_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.subjects_id_seq', 12, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.users_user_id_seq', 1, true);


--
-- Name: video_metadata_id_seq; Type: SEQUENCE SET; Schema: mig_audit; Owner: 501SteamHub
--

SELECT pg_catalog.setval('mig_audit.video_metadata_id_seq', 1, false);


--
-- Name: auth_tokens_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.auth_tokens_token_id_seq', 83, true);


--
-- Name: contributions_contribution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.contributions_contribution_id_seq', 1, false);


--
-- Name: cycles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.cycles_id_seq', 4, true);


--
-- Name: fellow_applications_application_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.fellow_applications_application_id_seq', 4, true);


--
-- Name: fellows_fellow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.fellows_fellow_id_seq', 2, true);


--
-- Name: grade_levels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.grade_levels_id_seq', 10, true);


--
-- Name: ilos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.ilos_id_seq', 1941, true);


--
-- Name: lesson_versions_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.lesson_versions_version_id_seq', 1, false);


--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.lessons_lesson_id_seq', 10, true);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 1, false);


--
-- Name: resource_access_access_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.resource_access_access_id_seq', 1, false);


--
-- Name: resource_comments_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.resource_comments_comment_id_seq', 1, false);


--
-- Name: resource_ilos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.resource_ilos_id_seq', 1, false);


--
-- Name: resource_links_link_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.resource_links_link_id_seq', 1, false);


--
-- Name: resource_reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.resource_reviews_review_id_seq', 25, true);


--
-- Name: resource_status_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.resource_status_history_history_id_seq', 28, true);


--
-- Name: resources_resource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.resources_resource_id_seq', 31, true);


--
-- Name: review_comments_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.review_comments_comment_id_seq', 2, true);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 7, true);


--
-- Name: strands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.strands_id_seq', 114, true);


--
-- Name: subjects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.subjects_id_seq', 13, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.users_user_id_seq', 14, true);


--
-- Name: video_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: 501SteamHub
--

SELECT pg_catalog.setval('public.video_metadata_id_seq', 7, true);


--
-- Name: auth_tokens auth_tokens_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.auth_tokens
    ADD CONSTRAINT auth_tokens_pkey PRIMARY KEY (token_id);


--
-- Name: auth_tokens auth_tokens_token_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.auth_tokens
    ADD CONSTRAINT auth_tokens_token_key UNIQUE (token);


--
-- Name: contributions contributions_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.contributions
    ADD CONSTRAINT contributions_pkey PRIMARY KEY (contribution_id);


--
-- Name: contributions contributions_resource_id_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.contributions
    ADD CONSTRAINT contributions_resource_id_key UNIQUE (resource_id);


--
-- Name: cycles cycles_cycle_number_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.cycles
    ADD CONSTRAINT cycles_cycle_number_key UNIQUE (cycle_number);


--
-- Name: cycles cycles_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.cycles
    ADD CONSTRAINT cycles_pkey PRIMARY KEY (id);


--
-- Name: fellow_applications fellow_applications_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellow_applications
    ADD CONSTRAINT fellow_applications_pkey PRIMARY KEY (application_id);


--
-- Name: fellows fellows_moe_identifier_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellows
    ADD CONSTRAINT fellows_moe_identifier_key UNIQUE (moe_identifier);


--
-- Name: fellows fellows_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellows
    ADD CONSTRAINT fellows_pkey PRIMARY KEY (fellow_id);


--
-- Name: fellows fellows_user_id_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellows
    ADD CONSTRAINT fellows_user_id_key UNIQUE (user_id);


--
-- Name: grade_levels grade_levels_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.grade_levels
    ADD CONSTRAINT grade_levels_pkey PRIMARY KEY (id);


--
-- Name: ilos ilos_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.ilos
    ADD CONSTRAINT ilos_pkey PRIMARY KEY (id);


--
-- Name: lesson_versions lesson_versions_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lesson_versions
    ADD CONSTRAINT lesson_versions_pkey PRIMARY KEY (version_id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lesson_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: resource_access resource_access_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_access
    ADD CONSTRAINT resource_access_pkey PRIMARY KEY (access_id);


--
-- Name: resource_comments resource_comments_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_comments
    ADD CONSTRAINT resource_comments_pkey PRIMARY KEY (comment_id);


--
-- Name: resource_ilos resource_ilos_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_ilos
    ADD CONSTRAINT resource_ilos_pkey PRIMARY KEY (id);


--
-- Name: resource_ilos resource_ilos_resource_id_ilo_id_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_ilos
    ADD CONSTRAINT resource_ilos_resource_id_ilo_id_key UNIQUE (resource_id, ilo_id);


--
-- Name: resource_links resource_links_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_links
    ADD CONSTRAINT resource_links_pkey PRIMARY KEY (link_id);


--
-- Name: resource_reviews resource_reviews_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_reviews
    ADD CONSTRAINT resource_reviews_pkey PRIMARY KEY (review_id);


--
-- Name: resource_status_history resource_status_history_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_status_history
    ADD CONSTRAINT resource_status_history_pkey PRIMARY KEY (history_id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (resource_id);


--
-- Name: resources resources_slug_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resources
    ADD CONSTRAINT resources_slug_key UNIQUE (slug);


--
-- Name: review_comments review_comments_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.review_comments
    ADD CONSTRAINT review_comments_pkey PRIMARY KEY (comment_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: strands strands_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.strands
    ADD CONSTRAINT strands_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: resource_reviews uniq_resource_review_role; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_reviews
    ADD CONSTRAINT uniq_resource_review_role UNIQUE (resource_id, reviewer_role_id);


--
-- Name: resource_links unique_resource_link; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_links
    ADD CONSTRAINT unique_resource_link UNIQUE (parent_resource_id, linked_resource_id);


--
-- Name: grade_levels uq_grade_levels_grade_level; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.grade_levels
    ADD CONSTRAINT uq_grade_levels_grade_level UNIQUE (grade_level);


--
-- Name: grade_levels uq_grade_levels_id; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.grade_levels
    ADD CONSTRAINT uq_grade_levels_id UNIQUE (id);


--
-- Name: ilos uq_ilos_subject_grade_cycle_code; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.ilos
    ADD CONSTRAINT uq_ilos_subject_grade_cycle_code UNIQUE (subject_id, grade_level_id, cycle_id, ilo_code);


--
-- Name: lesson_versions uq_lesson_versions; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lesson_versions
    ADD CONSTRAINT uq_lesson_versions UNIQUE (lesson_id, version_number);


--
-- Name: lessons uq_lessons_resource_number; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lessons
    ADD CONSTRAINT uq_lessons_resource_number UNIQUE (resource_id, lesson_number);


--
-- Name: strands uq_strands_subject_id_name; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.strands
    ADD CONSTRAINT uq_strands_subject_id_name UNIQUE (subject_id, name);


--
-- Name: subjects uq_subjects_id; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.subjects
    ADD CONSTRAINT uq_subjects_id UNIQUE (id);


--
-- Name: subjects uq_subjects_subject; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.subjects
    ADD CONSTRAINT uq_subjects_subject UNIQUE (subject);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: video_metadata video_metadata_pkey; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.video_metadata
    ADD CONSTRAINT video_metadata_pkey PRIMARY KEY (id);


--
-- Name: video_metadata video_metadata_resource_id_key; Type: CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.video_metadata
    ADD CONSTRAINT video_metadata_resource_id_key UNIQUE (resource_id);


--
-- Name: auth_tokens auth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_pkey PRIMARY KEY (token_id);


--
-- Name: auth_tokens auth_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_token_key UNIQUE (token);


--
-- Name: contributions contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.contributions
    ADD CONSTRAINT contributions_pkey PRIMARY KEY (contribution_id);


--
-- Name: contributions contributions_resource_id_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.contributions
    ADD CONSTRAINT contributions_resource_id_key UNIQUE (resource_id);


--
-- Name: cycles cycles_cycle_number_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.cycles
    ADD CONSTRAINT cycles_cycle_number_key UNIQUE (cycle_number);


--
-- Name: cycles cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.cycles
    ADD CONSTRAINT cycles_pkey PRIMARY KEY (id);


--
-- Name: fellow_applications fellow_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellow_applications
    ADD CONSTRAINT fellow_applications_pkey PRIMARY KEY (application_id);


--
-- Name: fellows fellows_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellows
    ADD CONSTRAINT fellows_pkey PRIMARY KEY (fellow_id);


--
-- Name: grade_levels grade_levels_grade_level_unique; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_grade_level_unique UNIQUE (grade_level);


--
-- Name: grade_levels grade_levels_id_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_id_key UNIQUE (id);


--
-- Name: grade_levels grade_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_pkey PRIMARY KEY (id);


--
-- Name: ilos ilos_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.ilos
    ADD CONSTRAINT ilos_pkey PRIMARY KEY (id);


--
-- Name: lesson_versions lesson_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lesson_versions
    ADD CONSTRAINT lesson_versions_pkey PRIMARY KEY (version_id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lesson_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: resource_access resource_access_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_access
    ADD CONSTRAINT resource_access_pkey PRIMARY KEY (access_id);


--
-- Name: resource_comments resource_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_comments
    ADD CONSTRAINT resource_comments_pkey PRIMARY KEY (comment_id);


--
-- Name: resource_grade_levels resource_grade_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_grade_levels
    ADD CONSTRAINT resource_grade_levels_pkey PRIMARY KEY (resource_id, grade_level_id);


--
-- Name: resource_ilos resource_ilos_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_ilos
    ADD CONSTRAINT resource_ilos_pkey PRIMARY KEY (id);


--
-- Name: resource_ilos resource_ilos_resource_id_ilo_id_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_ilos
    ADD CONSTRAINT resource_ilos_resource_id_ilo_id_key UNIQUE (resource_id, ilo_id);


--
-- Name: resource_links resource_links_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT resource_links_pkey PRIMARY KEY (link_id);


--
-- Name: resource_reviews resource_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_reviews
    ADD CONSTRAINT resource_reviews_pkey PRIMARY KEY (review_id);


--
-- Name: resource_status_history resource_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_status_history
    ADD CONSTRAINT resource_status_history_pkey PRIMARY KEY (history_id);


--
-- Name: resource_subjects resource_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_subjects
    ADD CONSTRAINT resource_subjects_pkey PRIMARY KEY (resource_id, subject_id);


--
-- Name: resources resources_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (resource_id);


--
-- Name: resources resources_slug_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_slug_key UNIQUE (slug);


--
-- Name: review_comments review_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.review_comments
    ADD CONSTRAINT review_comments_pkey PRIMARY KEY (comment_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: strands strands_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.strands
    ADD CONSTRAINT strands_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_id_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_id_key UNIQUE (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_subject_unique; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_subject_unique UNIQUE (subject);


--
-- Name: fellows teachers_moe_identifier_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellows
    ADD CONSTRAINT teachers_moe_identifier_key UNIQUE (moe_identifier);


--
-- Name: fellows teachers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellows
    ADD CONSTRAINT teachers_user_id_key UNIQUE (user_id);


--
-- Name: resource_reviews uniq_resource_review_role; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_reviews
    ADD CONSTRAINT uniq_resource_review_role UNIQUE (resource_id, reviewer_role_id);


--
-- Name: resource_links unique_resource_link; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT unique_resource_link UNIQUE (parent_resource_id, linked_resource_id);


--
-- Name: ilos uq_ilos_subject_grade_cycle_code; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.ilos
    ADD CONSTRAINT uq_ilos_subject_grade_cycle_code UNIQUE (subject_id, grade_level_id, cycle_id, ilo_code);


--
-- Name: lesson_versions uq_lesson_versions; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lesson_versions
    ADD CONSTRAINT uq_lesson_versions UNIQUE (lesson_id, version_number);


--
-- Name: lessons uq_lessons_resource_number; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT uq_lessons_resource_number UNIQUE (resource_id, lesson_number);


--
-- Name: strands uq_strands_subject_id_name; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.strands
    ADD CONSTRAINT uq_strands_subject_id_name UNIQUE (subject_id, name);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: video_metadata video_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.video_metadata
    ADD CONSTRAINT video_metadata_pkey PRIMARY KEY (id);


--
-- Name: video_metadata video_metadata_resource_id_key; Type: CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.video_metadata
    ADD CONSTRAINT video_metadata_resource_id_key UNIQUE (resource_id);


--
-- Name: idx_auth_tokens_user_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_auth_tokens_user_id ON mig_audit.auth_tokens USING btree (user_id);


--
-- Name: idx_fellow_applications_moe_doc_path; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_fellow_applications_moe_doc_path ON mig_audit.fellow_applications USING btree (moe_doc_path);


--
-- Name: idx_fellow_applications_status; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_fellow_applications_status ON mig_audit.fellow_applications USING btree (status);


--
-- Name: idx_fellow_applications_user_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_fellow_applications_user_id ON mig_audit.fellow_applications USING btree (user_id);


--
-- Name: idx_fellows_steam_points; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_fellows_steam_points ON mig_audit.fellows USING btree (steam_points DESC);


--
-- Name: idx_fellows_verified; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_fellows_verified ON mig_audit.fellows USING btree (moe_identifier_verified, verified_at);


--
-- Name: idx_grade_levels_grade_level; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_grade_levels_grade_level ON mig_audit.grade_levels USING btree (grade_level);


--
-- Name: idx_ilos_cycle_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_cycle_id ON mig_audit.ilos USING btree (cycle_id);


--
-- Name: idx_ilos_description; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_description ON mig_audit.ilos USING btree (description);


--
-- Name: idx_ilos_grade_level_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_grade_level_id ON mig_audit.ilos USING btree (grade_level_id);


--
-- Name: idx_ilos_ilo_code; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_ilo_code ON mig_audit.ilos USING btree (ilo_code);


--
-- Name: idx_ilos_strand_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_strand_id ON mig_audit.ilos USING btree (strand_id);


--
-- Name: idx_ilos_subject_grade_cycle; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_subject_grade_cycle ON mig_audit.ilos USING btree (subject_id, grade_level_id, cycle_id);


--
-- Name: idx_ilos_subject_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_subject_id ON mig_audit.ilos USING btree (subject_id);


--
-- Name: idx_lesson_versions_changed_by; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_lesson_versions_changed_by ON mig_audit.lesson_versions USING btree (changed_by);


--
-- Name: idx_lesson_versions_lesson; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_lesson_versions_lesson ON mig_audit.lesson_versions USING btree (lesson_id);


--
-- Name: idx_lessons_resource; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_lessons_resource ON mig_audit.lessons USING btree (resource_id);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_notifications_user_id ON mig_audit.notifications USING btree (user_id);


--
-- Name: idx_resource_access_resource_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_access_resource_id ON mig_audit.resource_access USING btree (resource_id);


--
-- Name: idx_resource_comments_parent; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_comments_parent ON mig_audit.resource_comments USING btree (parent_comment_id);


--
-- Name: idx_resource_comments_resource; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_comments_resource ON mig_audit.resource_comments USING btree (resource_id);


--
-- Name: idx_resource_comments_user; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_comments_user ON mig_audit.resource_comments USING btree (user_id);


--
-- Name: idx_resource_grade_levels_grade_level_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_grade_levels_grade_level_id ON mig_audit.resource_grade_levels USING btree (grade_level_id);


--
-- Name: idx_resource_grade_levels_resource; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_grade_levels_resource ON mig_audit.resource_grade_levels USING btree (resource_id);


--
-- Name: idx_resource_ilos_ilo_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_ilos_ilo_id ON mig_audit.resource_ilos USING btree (ilo_id);


--
-- Name: idx_resource_ilos_resource_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_ilos_resource_id ON mig_audit.resource_ilos USING btree (resource_id);


--
-- Name: idx_resource_links_linked; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_links_linked ON mig_audit.resource_links USING btree (linked_resource_id);


--
-- Name: idx_resource_links_parent; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_links_parent ON mig_audit.resource_links USING btree (parent_resource_id);


--
-- Name: idx_resource_links_type; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_links_type ON mig_audit.resource_links USING btree (relationship_type);


--
-- Name: idx_resource_reviews_resource_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_reviews_resource_id ON mig_audit.resource_reviews USING btree (resource_id);


--
-- Name: idx_resource_status_history_resource; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_status_history_resource ON mig_audit.resource_status_history USING btree (resource_id);


--
-- Name: idx_resource_subjects_resource; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_subjects_resource ON mig_audit.resource_subjects USING btree (resource_id);


--
-- Name: idx_resource_subjects_subject_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resource_subjects_subject_id ON mig_audit.resource_subjects USING btree (subject_id);


--
-- Name: idx_resources_contributor_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resources_contributor_id ON mig_audit.resources USING btree (contributor_id);


--
-- Name: idx_resources_status; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_resources_status ON mig_audit.resources USING btree (status);


--
-- Name: idx_review_comments_resource; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_review_comments_resource ON mig_audit.review_comments USING btree (resource_id);


--
-- Name: idx_strands_subject_id; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_strands_subject_id ON mig_audit.strands USING btree (subject_id);


--
-- Name: idx_subjects_subject; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE INDEX idx_subjects_subject ON mig_audit.subjects USING btree (subject);


--
-- Name: unique_pending_application_per_user; Type: INDEX; Schema: mig_audit; Owner: 501SteamHub
--

CREATE UNIQUE INDEX unique_pending_application_per_user ON mig_audit.fellow_applications USING btree (user_id) WHERE ((status)::text = 'Pending'::text);


--
-- Name: idx_auth_tokens_user_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_auth_tokens_user_id ON public.auth_tokens USING btree (user_id);


--
-- Name: idx_fellow_applications_moe_doc_path; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_fellow_applications_moe_doc_path ON public.fellow_applications USING btree (moe_doc_path);


--
-- Name: idx_fellow_applications_status; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_fellow_applications_status ON public.fellow_applications USING btree (status);


--
-- Name: idx_fellow_applications_user_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_fellow_applications_user_id ON public.fellow_applications USING btree (user_id);


--
-- Name: idx_fellows_steam_points; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_fellows_steam_points ON public.fellows USING btree (steam_points DESC);


--
-- Name: idx_fellows_verified; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_fellows_verified ON public.fellows USING btree (moe_identifier_verified, verified_at);


--
-- Name: idx_ilos_cycle_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_cycle_id ON public.ilos USING btree (cycle_id);


--
-- Name: idx_ilos_description; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_description ON public.ilos USING btree (description);


--
-- Name: idx_ilos_grade_level_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_grade_level_id ON public.ilos USING btree (grade_level_id);


--
-- Name: idx_ilos_ilo_code; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_ilo_code ON public.ilos USING btree (ilo_code);


--
-- Name: idx_ilos_strand_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_strand_id ON public.ilos USING btree (strand_id);


--
-- Name: idx_ilos_subject_grade_cycle; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_subject_grade_cycle ON public.ilos USING btree (subject_id, grade_level_id, cycle_id);


--
-- Name: idx_ilos_subject_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_ilos_subject_id ON public.ilos USING btree (subject_id);


--
-- Name: idx_lesson_versions_changed_by; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_lesson_versions_changed_by ON public.lesson_versions USING btree (changed_by);


--
-- Name: idx_lesson_versions_lesson; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_lesson_versions_lesson ON public.lesson_versions USING btree (lesson_id);


--
-- Name: idx_lessons_resource; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_lessons_resource ON public.lessons USING btree (resource_id);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_resource_access_resource_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_access_resource_id ON public.resource_access USING btree (resource_id);


--
-- Name: idx_resource_comments_parent; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_comments_parent ON public.resource_comments USING btree (parent_comment_id);


--
-- Name: idx_resource_comments_resource; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_comments_resource ON public.resource_comments USING btree (resource_id);


--
-- Name: idx_resource_comments_user; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_comments_user ON public.resource_comments USING btree (user_id);


--
-- Name: idx_resource_grade_levels_grade_level_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_grade_levels_grade_level_id ON public.resource_grade_levels USING btree (grade_level_id);


--
-- Name: idx_resource_grade_levels_resource; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_grade_levels_resource ON public.resource_grade_levels USING btree (resource_id);


--
-- Name: idx_resource_ilos_ilo_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_ilos_ilo_id ON public.resource_ilos USING btree (ilo_id);


--
-- Name: idx_resource_ilos_resource_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_ilos_resource_id ON public.resource_ilos USING btree (resource_id);


--
-- Name: idx_resource_links_linked; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_links_linked ON public.resource_links USING btree (linked_resource_id);


--
-- Name: idx_resource_links_parent; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_links_parent ON public.resource_links USING btree (parent_resource_id);


--
-- Name: idx_resource_links_type; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_links_type ON public.resource_links USING btree (relationship_type);


--
-- Name: idx_resource_reviews_resource_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_reviews_resource_id ON public.resource_reviews USING btree (resource_id);


--
-- Name: idx_resource_status_history_resource; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_status_history_resource ON public.resource_status_history USING btree (resource_id);


--
-- Name: idx_resource_subjects_resource; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_subjects_resource ON public.resource_subjects USING btree (resource_id);


--
-- Name: idx_resource_subjects_subject_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resource_subjects_subject_id ON public.resource_subjects USING btree (subject_id);


--
-- Name: idx_resources_contributor_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resources_contributor_id ON public.resources USING btree (contributor_id);


--
-- Name: idx_resources_status; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_resources_status ON public.resources USING btree (status);


--
-- Name: idx_review_comments_resource; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_review_comments_resource ON public.review_comments USING btree (resource_id);


--
-- Name: idx_strands_name; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_strands_name ON public.strands USING btree (name);


--
-- Name: idx_strands_subject_id; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE INDEX idx_strands_subject_id ON public.strands USING btree (subject_id);


--
-- Name: unique_pending_application_per_user; Type: INDEX; Schema: public; Owner: 501SteamHub
--

CREATE UNIQUE INDEX unique_pending_application_per_user ON public.fellow_applications USING btree (user_id) WHERE ((status)::text = 'Pending'::text);


--
-- Name: ilos ilos_updated_at; Type: TRIGGER; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TRIGGER ilos_updated_at BEFORE UPDATE ON mig_audit.ilos FOR EACH ROW EXECUTE FUNCTION mig_audit.update_updated_at_column();


--
-- Name: resource_comments resource_comments_updated_at; Type: TRIGGER; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TRIGGER resource_comments_updated_at BEFORE UPDATE ON mig_audit.resource_comments FOR EACH ROW EXECUTE FUNCTION mig_audit.update_updated_at_column();


--
-- Name: resource_links resource_links_updated_at; Type: TRIGGER; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TRIGGER resource_links_updated_at BEFORE UPDATE ON mig_audit.resource_links FOR EACH ROW EXECUTE FUNCTION mig_audit.update_updated_at_column();


--
-- Name: resources resources_updated_at; Type: TRIGGER; Schema: mig_audit; Owner: 501SteamHub
--

CREATE TRIGGER resources_updated_at BEFORE UPDATE ON mig_audit.resources FOR EACH ROW EXECUTE FUNCTION mig_audit.update_updated_at_column();


--
-- Name: ilos ilos_updated_at; Type: TRIGGER; Schema: public; Owner: 501SteamHub
--

CREATE TRIGGER ilos_updated_at BEFORE UPDATE ON public.ilos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: resource_comments resource_comments_updated_at; Type: TRIGGER; Schema: public; Owner: 501SteamHub
--

CREATE TRIGGER resource_comments_updated_at BEFORE UPDATE ON public.resource_comments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: resource_links resource_links_updated_at; Type: TRIGGER; Schema: public; Owner: 501SteamHub
--

CREATE TRIGGER resource_links_updated_at BEFORE UPDATE ON public.resource_links FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: resources resources_updated_at; Type: TRIGGER; Schema: public; Owner: 501SteamHub
--

CREATE TRIGGER resources_updated_at BEFORE UPDATE ON public.resources FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: auth_tokens auth_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.auth_tokens
    ADD CONSTRAINT auth_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES mig_audit.users(user_id) ON DELETE CASCADE;


--
-- Name: contributions fk_contributions_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.contributions
    ADD CONSTRAINT fk_contributions_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: fellow_applications fk_fellow_applications_reviewer; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellow_applications
    ADD CONSTRAINT fk_fellow_applications_reviewer FOREIGN KEY (reviewed_by) REFERENCES mig_audit.users(user_id) ON DELETE SET NULL;


--
-- Name: fellow_applications fk_fellow_applications_user; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellow_applications
    ADD CONSTRAINT fk_fellow_applications_user FOREIGN KEY (user_id) REFERENCES mig_audit.users(user_id) ON DELETE CASCADE;


--
-- Name: fellows fk_fellows_source_application; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellows
    ADD CONSTRAINT fk_fellows_source_application FOREIGN KEY (source_application_id) REFERENCES mig_audit.fellow_applications(application_id) ON DELETE SET NULL;


--
-- Name: fellows fk_fellows_user; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellows
    ADD CONSTRAINT fk_fellows_user FOREIGN KEY (user_id) REFERENCES mig_audit.users(user_id) ON DELETE CASCADE;


--
-- Name: fellows fk_fellows_verified_by; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.fellows
    ADD CONSTRAINT fk_fellows_verified_by FOREIGN KEY (verified_by) REFERENCES mig_audit.users(user_id) ON DELETE SET NULL;


--
-- Name: ilos fk_ilos_cycle_id; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.ilos
    ADD CONSTRAINT fk_ilos_cycle_id FOREIGN KEY (cycle_id) REFERENCES mig_audit.cycles(id) ON DELETE CASCADE;


--
-- Name: ilos fk_ilos_grade_level_id; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.ilos
    ADD CONSTRAINT fk_ilos_grade_level_id FOREIGN KEY (grade_level_id) REFERENCES mig_audit.grade_levels(id) ON DELETE CASCADE;


--
-- Name: ilos fk_ilos_strand_id; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.ilos
    ADD CONSTRAINT fk_ilos_strand_id FOREIGN KEY (strand_id) REFERENCES mig_audit.strands(id) ON DELETE CASCADE;


--
-- Name: ilos fk_ilos_subject_id; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.ilos
    ADD CONSTRAINT fk_ilos_subject_id FOREIGN KEY (subject_id) REFERENCES mig_audit.subjects(id) ON DELETE CASCADE;


--
-- Name: lesson_versions fk_lesson_versions_lesson; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lesson_versions
    ADD CONSTRAINT fk_lesson_versions_lesson FOREIGN KEY (lesson_id) REFERENCES mig_audit.lessons(lesson_id) ON DELETE CASCADE;


--
-- Name: lesson_versions fk_lesson_versions_user; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lesson_versions
    ADD CONSTRAINT fk_lesson_versions_user FOREIGN KEY (changed_by) REFERENCES mig_audit.users(user_id);


--
-- Name: lessons fk_lessons_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.lessons
    ADD CONSTRAINT fk_lessons_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_access fk_ra_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_access
    ADD CONSTRAINT fk_ra_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_access fk_ra_user; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_access
    ADD CONSTRAINT fk_ra_user FOREIGN KEY (user_id) REFERENCES mig_audit.users(user_id);


--
-- Name: review_comments fk_rc_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.review_comments
    ADD CONSTRAINT fk_rc_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: review_comments fk_rc_reviewer; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.review_comments
    ADD CONSTRAINT fk_rc_reviewer FOREIGN KEY (reviewer_id) REFERENCES mig_audit.users(user_id);


--
-- Name: resource_comments fk_resource_comments_parent; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_comments
    ADD CONSTRAINT fk_resource_comments_parent FOREIGN KEY (parent_comment_id) REFERENCES mig_audit.resource_comments(comment_id) ON DELETE CASCADE;


--
-- Name: resource_comments fk_resource_comments_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_comments
    ADD CONSTRAINT fk_resource_comments_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_comments fk_resource_comments_user; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_comments
    ADD CONSTRAINT fk_resource_comments_user FOREIGN KEY (user_id) REFERENCES mig_audit.users(user_id) ON DELETE CASCADE;


--
-- Name: resource_grade_levels fk_resource_grade_levels_grade_level_id; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_grade_levels
    ADD CONSTRAINT fk_resource_grade_levels_grade_level_id FOREIGN KEY (grade_level_id) REFERENCES mig_audit.grade_levels(id) ON DELETE CASCADE;


--
-- Name: resource_grade_levels fk_resource_grade_levels_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_grade_levels
    ADD CONSTRAINT fk_resource_grade_levels_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_links fk_resource_links_linked; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_links
    ADD CONSTRAINT fk_resource_links_linked FOREIGN KEY (linked_resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_links fk_resource_links_parent; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_links
    ADD CONSTRAINT fk_resource_links_parent FOREIGN KEY (parent_resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_subjects fk_resource_subjects_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_subjects
    ADD CONSTRAINT fk_resource_subjects_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_subjects fk_resource_subjects_subject_id; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_subjects
    ADD CONSTRAINT fk_resource_subjects_subject_id FOREIGN KEY (subject_id) REFERENCES mig_audit.subjects(id) ON DELETE CASCADE;


--
-- Name: resources fk_resources_contributor; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resources
    ADD CONSTRAINT fk_resources_contributor FOREIGN KEY (contributor_id) REFERENCES mig_audit.users(user_id);


--
-- Name: resource_reviews fk_rr_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_reviews
    ADD CONSTRAINT fk_rr_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_reviews fk_rr_reviewer; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_reviews
    ADD CONSTRAINT fk_rr_reviewer FOREIGN KEY (reviewer_id) REFERENCES mig_audit.users(user_id);


--
-- Name: resource_reviews fk_rr_reviewer_role; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_reviews
    ADD CONSTRAINT fk_rr_reviewer_role FOREIGN KEY (reviewer_role_id) REFERENCES mig_audit.roles(role_id);


--
-- Name: resource_status_history fk_rsh_resource; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_status_history
    ADD CONSTRAINT fk_rsh_resource FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: strands fk_strands_subject_id; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.strands
    ADD CONSTRAINT fk_strands_subject_id FOREIGN KEY (subject_id) REFERENCES mig_audit.subjects(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES mig_audit.users(user_id) ON DELETE CASCADE;


--
-- Name: resource_ilos resource_ilos_ilo_id_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_ilos
    ADD CONSTRAINT resource_ilos_ilo_id_fkey FOREIGN KEY (ilo_id) REFERENCES mig_audit.ilos(id) ON DELETE CASCADE;


--
-- Name: resource_ilos resource_ilos_resource_id_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.resource_ilos
    ADD CONSTRAINT resource_ilos_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: users users_created_by_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.users
    ADD CONSTRAINT users_created_by_fkey FOREIGN KEY (created_by) REFERENCES mig_audit.users(user_id) ON DELETE SET NULL;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES mig_audit.roles(role_id) ON DELETE SET NULL;


--
-- Name: users users_updated_by_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.users
    ADD CONSTRAINT users_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES mig_audit.users(user_id) ON DELETE SET NULL;


--
-- Name: video_metadata video_metadata_resource_id_fkey; Type: FK CONSTRAINT; Schema: mig_audit; Owner: 501SteamHub
--

ALTER TABLE ONLY mig_audit.video_metadata
    ADD CONSTRAINT video_metadata_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES mig_audit.resources(resource_id) ON DELETE CASCADE;


--
-- Name: auth_tokens auth_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: contributions fk_contributions_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.contributions
    ADD CONSTRAINT fk_contributions_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: fellow_applications fk_fellow_applications_reviewer; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellow_applications
    ADD CONSTRAINT fk_fellow_applications_reviewer FOREIGN KEY (reviewed_by) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: fellow_applications fk_fellow_applications_user; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellow_applications
    ADD CONSTRAINT fk_fellow_applications_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: fellows fk_fellows_source_application; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellows
    ADD CONSTRAINT fk_fellows_source_application FOREIGN KEY (source_application_id) REFERENCES public.fellow_applications(application_id) ON DELETE SET NULL;


--
-- Name: fellows fk_fellows_user; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellows
    ADD CONSTRAINT fk_fellows_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: fellows fk_fellows_verified_by; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.fellows
    ADD CONSTRAINT fk_fellows_verified_by FOREIGN KEY (verified_by) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: ilos fk_ilos_cycle_id; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.ilos
    ADD CONSTRAINT fk_ilos_cycle_id FOREIGN KEY (cycle_id) REFERENCES public.cycles(id) ON DELETE CASCADE;


--
-- Name: ilos fk_ilos_grade_level_id; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.ilos
    ADD CONSTRAINT fk_ilos_grade_level_id FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id) ON DELETE CASCADE;


--
-- Name: ilos fk_ilos_strand_id; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.ilos
    ADD CONSTRAINT fk_ilos_strand_id FOREIGN KEY (strand_id) REFERENCES public.strands(id) ON DELETE CASCADE;


--
-- Name: ilos fk_ilos_subject_id; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.ilos
    ADD CONSTRAINT fk_ilos_subject_id FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: lesson_versions fk_lesson_versions_lesson; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lesson_versions
    ADD CONSTRAINT fk_lesson_versions_lesson FOREIGN KEY (lesson_id) REFERENCES public.lessons(lesson_id) ON DELETE CASCADE;


--
-- Name: lesson_versions fk_lesson_versions_user; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lesson_versions
    ADD CONSTRAINT fk_lesson_versions_user FOREIGN KEY (changed_by) REFERENCES public.users(user_id);


--
-- Name: lessons fk_lessons_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT fk_lessons_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_access fk_ra_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_access
    ADD CONSTRAINT fk_ra_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_access fk_ra_user; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_access
    ADD CONSTRAINT fk_ra_user FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: review_comments fk_rc_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.review_comments
    ADD CONSTRAINT fk_rc_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: review_comments fk_rc_reviewer; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.review_comments
    ADD CONSTRAINT fk_rc_reviewer FOREIGN KEY (reviewer_id) REFERENCES public.users(user_id);


--
-- Name: resource_comments fk_resource_comments_parent; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_comments
    ADD CONSTRAINT fk_resource_comments_parent FOREIGN KEY (parent_comment_id) REFERENCES public.resource_comments(comment_id) ON DELETE CASCADE;


--
-- Name: resource_comments fk_resource_comments_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_comments
    ADD CONSTRAINT fk_resource_comments_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_comments fk_resource_comments_user; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_comments
    ADD CONSTRAINT fk_resource_comments_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: resource_grade_levels fk_resource_grade_levels_grade_level_id; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_grade_levels
    ADD CONSTRAINT fk_resource_grade_levels_grade_level_id FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id) ON DELETE RESTRICT;


--
-- Name: resource_grade_levels fk_resource_grade_levels_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_grade_levels
    ADD CONSTRAINT fk_resource_grade_levels_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_links fk_resource_links_linked; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT fk_resource_links_linked FOREIGN KEY (linked_resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_links fk_resource_links_parent; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_links
    ADD CONSTRAINT fk_resource_links_parent FOREIGN KEY (parent_resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_subjects fk_resource_subjects_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_subjects
    ADD CONSTRAINT fk_resource_subjects_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_subjects fk_resource_subjects_subject_id; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_subjects
    ADD CONSTRAINT fk_resource_subjects_subject_id FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE RESTRICT;


--
-- Name: resources fk_resources_contributor; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resources
    ADD CONSTRAINT fk_resources_contributor FOREIGN KEY (contributor_id) REFERENCES public.users(user_id);


--
-- Name: resource_reviews fk_rr_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_reviews
    ADD CONSTRAINT fk_rr_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: resource_reviews fk_rr_reviewer; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_reviews
    ADD CONSTRAINT fk_rr_reviewer FOREIGN KEY (reviewer_id) REFERENCES public.users(user_id);


--
-- Name: resource_reviews fk_rr_reviewer_role; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_reviews
    ADD CONSTRAINT fk_rr_reviewer_role FOREIGN KEY (reviewer_role_id) REFERENCES public.roles(role_id);


--
-- Name: resource_status_history fk_rsh_resource; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_status_history
    ADD CONSTRAINT fk_rsh_resource FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: strands fk_strands_subject_id; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.strands
    ADD CONSTRAINT fk_strands_subject_id FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: resource_ilos resource_ilos_ilo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_ilos
    ADD CONSTRAINT resource_ilos_ilo_id_fkey FOREIGN KEY (ilo_id) REFERENCES public.ilos(id) ON DELETE CASCADE;


--
-- Name: resource_ilos resource_ilos_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.resource_ilos
    ADD CONSTRAINT resource_ilos_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: users users_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON DELETE SET NULL;


--
-- Name: users users_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(user_id) ON DELETE SET NULL;


--
-- Name: video_metadata video_metadata_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: 501SteamHub
--

ALTER TABLE ONLY public.video_metadata
    ADD CONSTRAINT video_metadata_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resources(resource_id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: 501SteamHub
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict Bitm1f30mb4kt0Ikzyg7dA1i26vd49j7YacQD14vz47aNesqTwYqY7Ijq0snNRk

