-- ============================================================
-- 【確認用・読み取りのみ】aisys_* テーブルの RLS・ポリシー・権限の現物
-- 2026-11-01 作成。何も変更しません。結果をそのまま報告してください。
-- ============================================================
select 'rls' as kind, c.relname::text as tbl, null::text as name,
       c.relrowsecurity::text as cmd, c.relforcerowsecurity::text as roles,
       null::text as qual, null::text as with_check
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relname like 'aisys%' and c.relkind = 'r'
union all
select 'policy', p.tablename::text, p.policyname::text, p.cmd::text, p.roles::text,
       p.qual, p.with_check
from pg_policies p
where p.schemaname = 'public' and p.tablename like 'aisys%'
union all
select 'grant', g.table_name::text, g.grantee::text, g.privilege_type::text, null, null, null
from information_schema.role_table_grants g
where g.table_schema = 'public' and g.table_name like 'aisys%'
  and g.grantee in ('anon', 'authenticated', 'PUBLIC')
order by 1, 2, 3, 4;
