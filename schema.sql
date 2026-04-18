-- Per-user schema. Rows are scoped to auth.uid() via RLS.
-- Clean-slate migration: drops existing tables. Safe because data so far is test-only.

drop table if exists tasks    cascade;
drop table if exists projects cascade;

create table projects (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade default auth.uid(),
  name         text not null,
  category     text not null check (category in ('MHC','TSM','Personal')),
  type         text not null check (type in ('pre-quals','apps','other')),
  priority     boolean not null default false,
  completed    boolean not null default false,
  completed_at timestamptz,
  created_at   timestamptz not null default now()
);

create table tasks (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade default auth.uid(),
  project_id   uuid not null references projects(id) on delete cascade,
  task         text not null,
  comments     text,
  completed    boolean not null default false,
  created_at   timestamptz not null default now(),
  completed_at timestamptz
);

create index projects_user_idx      on projects(user_id);
create index projects_category_idx  on projects(category);
create index projects_type_idx      on projects(type);
create index projects_completed_idx on projects(completed);
create index tasks_user_idx         on tasks(user_id);
create index tasks_project_idx      on tasks(project_id);
create index tasks_completed_idx    on tasks(completed);

alter table projects enable row level security;
alter table tasks    enable row level security;

create policy "own_projects" on projects
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "own_tasks" on tasks
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
