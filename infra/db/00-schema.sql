-- Create the Replication publication
CREATE PUBLICATION supabase_realtime FOR ALL TABLES;

-- Create a second schema
CREATE SCHEMA personal;

-- USERS
CREATE TYPE public.user_status AS ENUM ('ONLINE', 'OFFLINE');
CREATE TABLE public.users (
  username text primary key,
  data jsonb DEFAULT null,
  age_range int4range DEFAULT null,
  status user_status DEFAULT 'ONLINE'::public.user_status,
  catchphrase tsvector DEFAULT null,
  interests text[] DEFAULT null
);
ALTER TABLE public.users REPLICA IDENTITY FULL; -- Send "previous data" to supabase 
COMMENT ON COLUMN public.users.data IS 'For unstructured data and prototyping.';

-- CHANNELS
CREATE TABLE public.channels (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  data jsonb DEFAULT null,
  slug text
);
ALTER TABLE public.users REPLICA IDENTITY FULL; -- Send "previous data" to supabase
COMMENT ON COLUMN public.channels.data IS 'For unstructured data and prototyping.';

-- MESSAGES
CREATE TABLE public.messages (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  data jsonb DEFAULT null,
  message text,
  username text REFERENCES users NOT NULL,
  channel_id bigint REFERENCES channels NOT NULL,
  inserted_at timestamp with time zone default timezone('utc'::text, now()) not null
);
ALTER TABLE public.messages REPLICA IDENTITY FULL; -- Send "previous data" to supabase
COMMENT ON COLUMN public.messages.data IS 'For unstructured data and prototyping.';

-- STORED FUNCTION
CREATE FUNCTION public.get_status(name_param text)
RETURNS user_status AS $$
  SELECT status from users WHERE username=name_param;
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION public.get_username_and_status(name_param text)
RETURNS TABLE(username text, status user_status) AS $$
  SELECT username, status from users WHERE username=name_param;
$$ LANGUAGE SQL IMMUTABLE;

CREATE FUNCTION public.void_func() 
RETURNS void AS $$
$$ LANGUAGE SQL;

-- SECOND SCHEMA USERS
CREATE TYPE personal.user_status AS ENUM ('ONLINE', 'OFFLINE');
CREATE TABLE personal.users(
  username text primary key,
  data jsonb DEFAULT null,
  age_range int4range DEFAULT null,
  status user_status DEFAULT 'ONLINE'::public.user_status
);

-- SECOND SCHEMA STORED FUNCTION
CREATE FUNCTION personal.get_status(name_param text)
RETURNS user_status AS $$
  SELECT status from users WHERE username=name_param;
$$ LANGUAGE SQL IMMUTABLE;

-- UPPERCASE TABLE NAME
CREATE TABLE public."TestTable" (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  slug text
);

-- ROW LEVEL SECURITY ERROR TEST
create table public.sample (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  name text not null
);
alter table public.sample enable row level security;