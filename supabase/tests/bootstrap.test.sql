begin;
create extension if not exists pgtap with schema extensions;
select plan(2);
select has_schema('auth', 'Supabase auth schema is available');
select has_function('auth', 'uid', 'Supabase auth.uid is available');
select * from finish();
rollback;
