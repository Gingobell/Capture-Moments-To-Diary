-- M1: account-isolated local-first records and atomic last-write-wins sync.
create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists pg_cron with schema pg_catalog;
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create table public.moments (
  id          uuid primary key,
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  text        text not null default '',
  date        date not null,
  source      text not null check (source in ('typed','guided','voice')),
  chat_id     uuid,                       -- the chat it was saved from; null if typed
  created_at  timestamptz not null,
  updated_at  timestamptz not null,
  deleted_at  timestamptz,
  synced_at   timestamptz not null default now(),
  check (deleted_at is not null or char_length(text) between 1 and 4000)
);
create index on public.moments (user_id, date);

create table public.diaries (
  id                uuid primary key,     -- UUIDv5, see 2.3
  user_id           uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date              date not null,
  text              text not null default '',
  style             text not null default 'plain' check (style in ('plain','playful','poetic','film')),
  source_moment_ids uuid[] not null default '{}',
  generated_at      timestamptz,
  edited_by_user    boolean not null default false,
  sources_changed   boolean not null default false,
  incomplete        boolean not null default false,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  synced_at         timestamptz not null default now(),
  unique (user_id, date)
);

create table public.chats (
  id               uuid primary key,
  user_id          uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date             date not null,
  messages         jsonb not null default '[]',  -- [{role:'user'|'assistant', content, tp?:'same'|'new'}]
  state            jsonb not null default '{}',  -- {cards, cardsAt, offer, keptTopics, input, concern}
  saved_through    int not null default 0,
  saved_moment_ids uuid[] not null default '{}',
  created_at       timestamptz not null,
  updated_at       timestamptz not null,
  deleted_at       timestamptz,
  synced_at        timestamptz not null default now(),
  check (octet_length(messages::text) + octet_length(state::text) < 260000)
);

create table public.drafts (
  id          uuid primary key,
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  kind        text not null check (kind in ('quick','add')),
  text        text not null default '',
  date        date not null,
  created_at  timestamptz not null,
  updated_at  timestamptz not null,
  deleted_at  timestamptz,
  synced_at   timestamptz not null default now()
);

create table public.settings (
  user_id      uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  theme        text not null default 'auto' check (theme in ('auto','day','night')),
  display_name text not null default '' check (char_length(display_name) <= 30),
  lang         text not null default 'en' check (lang in ('en','zh')),
  diary_style  text not null default 'plain',
  tips         jsonb not null default '{}',
  tips_off     boolean not null default false,
  seen_ai_note boolean not null default false,
  seen_guide   boolean not null default false,
  updated_at   timestamptz not null,
  synced_at    timestamptz not null default now()
);

create table public.ai_usage (            -- written only by Edge Functions (service role)
  user_id uuid not null references auth.users(id) on delete cascade,
  day     date not null,                   -- UTC day
  kind    text not null check (kind in ('chat','draft','diary')),
  count   int not null default 0,
  primary key (user_id, day, kind)
);

alter table public.diaries add constraint diaries_deterministic_id check (
  id = extensions.uuid_generate_v5('3f6c2b1e-8a4d-4c7e-9b2f-5d1a7e6c9b30'::uuid,
    user_id::text || ':' || to_char(date, 'YYYY-MM-DD'))
);
create function private.set_synced_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.synced_at := clock_timestamp();
  return new;
end;
$$;
create function private.clear_deleted_content() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.deleted_at is not null then
    if tg_table_name = 'chats' then
      new.messages := '[]'::jsonb;
      new.state := '{}'::jsonb;
      new.saved_moment_ids := '{}'::uuid[];
    else
      new.text := '';
    end if;
  end if;
  return new;
end;
$$;
alter table public.moments enable row level security;
revoke all on public.moments from anon, authenticated;
grant all on public.moments to service_role;
grant select, insert, update, delete on public.moments to authenticated;
create policy owner_records on public.moments for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create index moments_user_synced on public.moments (user_id, synced_at);
create trigger set_synced_at before insert or update on public.moments
for each row execute function private.set_synced_at();
alter publication supabase_realtime add table public.moments;
create trigger clear_deleted_content before insert or update on public.moments
for each row execute function private.clear_deleted_content();
alter table public.diaries enable row level security;
revoke all on public.diaries from anon, authenticated;
grant all on public.diaries to service_role;
grant select, insert, update, delete on public.diaries to authenticated;
create policy owner_records on public.diaries for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create index diaries_user_synced on public.diaries (user_id, synced_at);
create trigger set_synced_at before insert or update on public.diaries
for each row execute function private.set_synced_at();
alter publication supabase_realtime add table public.diaries;
create trigger clear_deleted_content before insert or update on public.diaries
for each row execute function private.clear_deleted_content();
alter table public.chats enable row level security;
revoke all on public.chats from anon, authenticated;
grant all on public.chats to service_role;
grant select, insert, update, delete on public.chats to authenticated;
create policy owner_records on public.chats for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create index chats_user_synced on public.chats (user_id, synced_at);
create trigger set_synced_at before insert or update on public.chats
for each row execute function private.set_synced_at();
alter publication supabase_realtime add table public.chats;
create trigger clear_deleted_content before insert or update on public.chats
for each row execute function private.clear_deleted_content();
alter table public.drafts enable row level security;
revoke all on public.drafts from anon, authenticated;
grant all on public.drafts to service_role;
grant select, insert, update, delete on public.drafts to authenticated;
create policy owner_records on public.drafts for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create index drafts_user_synced on public.drafts (user_id, synced_at);
create trigger set_synced_at before insert or update on public.drafts
for each row execute function private.set_synced_at();
alter publication supabase_realtime add table public.drafts;
create trigger clear_deleted_content before insert or update on public.drafts
for each row execute function private.clear_deleted_content();
alter table public.settings enable row level security;
revoke all on public.settings from anon, authenticated;
grant all on public.settings to service_role;
grant select, insert, update, delete on public.settings to authenticated;
create policy owner_records on public.settings for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create index settings_user_synced on public.settings (user_id, synced_at);
create trigger set_synced_at before insert or update on public.settings
for each row execute function private.set_synced_at();
alter publication supabase_realtime add table public.settings;
alter table public.ai_usage enable row level security;
revoke all on public.ai_usage from anon, authenticated;
grant all on public.ai_usage to service_role;
grant select on public.ai_usage to authenticated;
create policy owner_read on public.ai_usage for select to authenticated using (user_id = (select auth.uid()));

create function public.sync_push(changes jsonb) returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare
  change jsonb;
  incoming jsonb;
  written integer;
  record_id uuid;
  applied jsonb := '[]';
  stale jsonb := '[]';
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;
  if jsonb_typeof(changes) is distinct from 'array' then
    raise exception 'Changes must be an array' using errcode = '22023';
  end if;
  if jsonb_array_length(changes) > 200 then
    raise exception 'At most 200 changes per call' using errcode = '22023';
  end if;
  for change in select value from jsonb_array_elements(changes) loop
    if jsonb_typeof(change) is distinct from 'object'
       or jsonb_typeof(change->'row') is distinct from 'object' then
      raise exception 'Each change needs a row object' using errcode = '22023';
    end if;
    incoming := change->'row';
    case change->>'table'
    when 'moments' then
      incoming := '{"text": ""}'::jsonb || incoming || jsonb_build_object('user_id', auth.uid());
      record_id := (incoming->>'id')::uuid;
      insert into public.moments as stored (id, user_id, text, date, source, chat_id, created_at, updated_at, deleted_at)
      select r.id, r.user_id, r.text, r.date, r.source, r.chat_id, r.created_at, r.updated_at, r.deleted_at
      from jsonb_populate_record(null::public.moments, incoming) r
      on conflict (id) do update set
        text = excluded.text,
        date = excluded.date,
        source = excluded.source,
        chat_id = excluded.chat_id,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
      where stored.updated_at < excluded.updated_at;
    when 'diaries' then
      incoming := '{"text": "", "style": "plain", "source_moment_ids": [], "edited_by_user": false, "sources_changed": false, "incomplete": false}'::jsonb || incoming || jsonb_build_object('user_id', auth.uid());
      record_id := (incoming->>'id')::uuid;
      insert into public.diaries as stored (id, user_id, date, text, style, source_moment_ids, generated_at, edited_by_user, sources_changed, incomplete, created_at, updated_at, deleted_at)
      select r.id, r.user_id, r.date, r.text, r.style, r.source_moment_ids, r.generated_at, r.edited_by_user, r.sources_changed, r.incomplete, r.created_at, r.updated_at, r.deleted_at
      from jsonb_populate_record(null::public.diaries, incoming) r
      on conflict (id) do update set
        date = excluded.date,
        text = excluded.text,
        style = excluded.style,
        source_moment_ids = excluded.source_moment_ids,
        generated_at = excluded.generated_at,
        edited_by_user = excluded.edited_by_user,
        sources_changed = excluded.sources_changed,
        incomplete = excluded.incomplete,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
      where stored.updated_at < excluded.updated_at;
    when 'chats' then
      incoming := '{"messages": [], "state": {}, "saved_through": 0, "saved_moment_ids": []}'::jsonb || incoming || jsonb_build_object('user_id', auth.uid());
      record_id := (incoming->>'id')::uuid;
      insert into public.chats as stored (id, user_id, date, messages, state, saved_through, saved_moment_ids, created_at, updated_at, deleted_at)
      select r.id, r.user_id, r.date, r.messages, r.state, r.saved_through, r.saved_moment_ids, r.created_at, r.updated_at, r.deleted_at
      from jsonb_populate_record(null::public.chats, incoming) r
      on conflict (id) do update set
        date = excluded.date,
        messages = excluded.messages,
        state = excluded.state,
        saved_through = excluded.saved_through,
        saved_moment_ids = excluded.saved_moment_ids,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
      where stored.updated_at < excluded.updated_at;
    when 'drafts' then
      incoming := '{"text": ""}'::jsonb || incoming || jsonb_build_object('user_id', auth.uid());
      record_id := (incoming->>'id')::uuid;
      insert into public.drafts as stored (id, user_id, kind, text, date, created_at, updated_at, deleted_at)
      select r.id, r.user_id, r.kind, r.text, r.date, r.created_at, r.updated_at, r.deleted_at
      from jsonb_populate_record(null::public.drafts, incoming) r
      on conflict (id) do update set
        kind = excluded.kind,
        text = excluded.text,
        date = excluded.date,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
      where stored.updated_at < excluded.updated_at;
    when 'settings' then
      incoming := '{"theme": "auto", "display_name": "", "lang": "en", "diary_style": "plain", "tips": {}, "tips_off": false, "seen_ai_note": false, "seen_guide": false}'::jsonb || incoming || jsonb_build_object('user_id', auth.uid());
      record_id := auth.uid();
      insert into public.settings as stored (user_id, theme, display_name, lang, diary_style, tips, tips_off, seen_ai_note, seen_guide, updated_at)
      select r.user_id, r.theme, r.display_name, r.lang, r.diary_style, r.tips, r.tips_off, r.seen_ai_note, r.seen_guide, r.updated_at
      from jsonb_populate_record(null::public.settings, incoming) r
      on conflict (user_id) do update set
        theme = excluded.theme,
        display_name = excluded.display_name,
        lang = excluded.lang,
        diary_style = excluded.diary_style,
        tips = excluded.tips,
        tips_off = excluded.tips_off,
        seen_ai_note = excluded.seen_ai_note,
        seen_guide = excluded.seen_guide,
        updated_at = excluded.updated_at
      where stored.updated_at < excluded.updated_at;
    else
      raise exception 'Unsupported sync table' using errcode = '22023';
    end case;
    get diagnostics written = row_count;
    if written = 1 then
      applied := applied || jsonb_build_array(record_id);
    else
      stale := stale || jsonb_build_array(record_id);
    end if;
  end loop;
  return jsonb_build_object('applied', applied, 'stale', stale);
end;
$$;
revoke all on function public.sync_push(jsonb) from public, anon;
grant execute on function public.sync_push(jsonb) to authenticated;

create function private.purge_tombstones() returns void
language sql security invoker set search_path = '' as $$
  delete from public.moments where deleted_at < now() - interval '90 days';
  delete from public.diaries where deleted_at < now() - interval '90 days';
  delete from public.chats where deleted_at < now() - interval '90 days';
  delete from public.drafts where deleted_at < now() - interval '90 days';
$$;
revoke all on all functions in schema private from public, anon, authenticated;
select cron.schedule('purge-capture-tombstones', '17 3 * * *',
  'select private.purge_tombstones()');
