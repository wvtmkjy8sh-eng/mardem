-- CicloFit - base inicial para a migração do modo local para Supabase
-- Execute no SQL Editor do Supabase.
-- Esta estrutura prepara autenticação e dados separados por usuário.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  username text unique,
  phone text,
  birth_date date,
  weight numeric,
  height numeric,
  goal text,
  level text,
  max_hr integer,
  ftp integer,
  photo_path text,
  role text not null default 'student' check (role in ('admin','student')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workouts (
  id uuid primary key default gen_random_uuid(),
  created_by uuid references public.profiles(id) on delete set null,
  student_id uuid references public.profiles(id) on delete cascade,
  title text not null,
  category text not null default 'gym',
  group_name text,
  duration text,
  intensity text,
  weekday integer,
  start_date date,
  valid_until date,
  note text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workout_logs (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  workout_id uuid references public.workouts(id) on delete set null,
  workout_date date not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rides (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  ride_date date not null,
  ride_type text,
  distance_km numeric,
  duration_seconds integer,
  avg_speed numeric,
  elevation_gain numeric,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.app_state (
  scope_key text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.app_health (
  id integer generated always as identity primary key,
  created_at timestamptz not null default now()
);
insert into public.app_health default values on conflict do nothing;

-- RLS: base segura para a futura migração para Supabase Auth.
alter table public.profiles enable row level security;
alter table public.workouts enable row level security;
alter table public.workout_logs enable row level security;
alter table public.rides enable row level security;
alter table public.app_state enable row level security;
alter table public.app_health enable row level security;

-- O próprio usuário pode ler/alterar o próprio perfil.
create policy "profiles_select_own" on public.profiles
for select to authenticated using (id = auth.uid());
create policy "profiles_insert_own" on public.profiles
for insert to authenticated with check (id = auth.uid());
create policy "profiles_update_own" on public.profiles
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Alunos leem os próprios treinos; administradores serão ampliados via função/role na etapa 2.
create policy "workouts_select_own" on public.workouts
for select to authenticated using (student_id = auth.uid() or created_by = auth.uid());
create policy "workouts_insert_owner" on public.workouts
for insert to authenticated with check (created_by = auth.uid());
create policy "workouts_update_owner" on public.workouts
for update to authenticated using (created_by = auth.uid()) with check (created_by = auth.uid());
create policy "workouts_delete_owner" on public.workouts
for delete to authenticated using (created_by = auth.uid());

create policy "workout_logs_own" on public.workout_logs
for all to authenticated using (student_id = auth.uid()) with check (student_id = auth.uid());

create policy "rides_own" on public.rides
for all to authenticated using (student_id = auth.uid()) with check (student_id = auth.uid());

-- app_state/app_health ficam protegidos por padrão. O modo cloud-sync de teste só será
-- habilitado depois de definirmos políticas específicas para o ambiente de teste.
create policy "health_read" on public.app_health
for select to authenticated using (true);
