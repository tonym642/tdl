-- Idempotent schema. Safe to re-run against an existing database.
-- To start fresh: drop table if exists tasks cascade; drop table if exists projects cascade;

create table if not exists projects (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  category     text not null check (category in ('MHC','TSM','Personal')),
  type         text not null check (type in ('pre-quals','apps','other')),
  priority     boolean not null default false,
  completed    boolean not null default false,
  completed_at timestamptz,
  created_at   timestamptz not null default now()
);

create table if not exists tasks (
  id           uuid primary key default gen_random_uuid(),
  project_id   uuid not null references projects(id) on delete cascade,
  task         text not null,
  comments     text,
  completed    boolean not null default false,
  created_at   timestamptz not null default now(),
  completed_at timestamptz
);

-- Migrations for existing databases (no-op if columns already exist).
alter table projects add column if not exists completed    boolean not null default false;
alter table projects add column if not exists completed_at timestamptz;

create index if not exists projects_category_idx  on projects(category);
create index if not exists projects_type_idx      on projects(type);
create index if not exists projects_completed_idx on projects(completed);
create index if not exists tasks_project_idx      on tasks(project_id);
create index if not exists tasks_completed_idx    on tasks(completed);

alter table projects enable row level security;
alter table tasks    enable row level security;

drop policy if exists "anon_all" on projects;
create policy "anon_all" on projects for all to anon using (true) with check (true);

drop policy if exists "anon_all" on tasks;
create policy "anon_all" on tasks    for all to anon using (true) with check (true);
