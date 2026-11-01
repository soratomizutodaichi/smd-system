-- ============================================================
-- 07. 【切り替え】aisys_form_submissions の直接アクセスを閉じる
-- ★ 必ず「新しい画面（index/confirmation/contract）を公開した後」に実行する。
--   先に実行すると、古い画面のフォーム・確認ページ・入金ボタンが動かなくなる。
-- ★ 03（管理者の登録）が済んでいないと、admin.html で申込が1件も見えなくなる。
-- 元に戻す場合は 99_rollback_07.sql。
-- ============================================================
begin;

-- 誰でも読める／書ける／何でも許す旧ポリシーを廃止
drop policy if exists "allow_select_by_id"         on public.aisys_form_submissions;
drop policy if exists "allow_insert"               on public.aisys_form_submissions;
drop policy if exists "allow_update_anon"          on public.aisys_form_submissions;
drop policy if exists "allow_select_authenticated" on public.aisys_form_submissions;
drop policy if exists "allow_update_authenticated" on public.aisys_form_submissions;
drop policy if exists "allow_delete_authenticated" on public.aisys_form_submissions;

-- 管理者名簿に載った人だけ
drop policy if exists aisys_sub_admin_select on public.aisys_form_submissions;
drop policy if exists aisys_sub_admin_update on public.aisys_form_submissions;
drop policy if exists aisys_sub_admin_delete on public.aisys_form_submissions;

create policy aisys_sub_admin_select on public.aisys_form_submissions
  for select to authenticated
  using ((select public.is_aisys_admin()));

create policy aisys_sub_admin_update on public.aisys_form_submissions
  for update to authenticated
  using ((select public.is_aisys_admin()))
  with check ((select public.is_aisys_admin()));

create policy aisys_sub_admin_delete on public.aisys_form_submissions
  for delete to authenticated
  using ((select public.is_aisys_admin()));

-- 権限そのものも絞る（anon はゼロ。受付・表示・入金は 04〜06 の関数経由のみ）
revoke all on public.aisys_form_submissions from anon;
revoke insert, truncate, references, trigger on public.aisys_form_submissions from authenticated;

commit;

-- 確認（この1つの結果だけが表示される）
select p.policyname::text as name, p.cmd::text as cmd, p.roles::text as roles, p.qual as qual
from pg_policies p
where p.schemaname = 'public' and p.tablename = 'aisys_form_submissions'
union all
select 'grant:' || g.grantee::text, g.privilege_type::text, null, null
from information_schema.role_table_grants g
where g.table_schema = 'public' and g.table_name = 'aisys_form_submissions'
  and g.grantee in ('anon', 'authenticated')
order by 1, 2;
