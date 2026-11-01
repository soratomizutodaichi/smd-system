-- ============================================================
-- 99. 【緊急時のみ】07 を取り消し、2026-11-01 時点の設定へ戻す
-- ★ 戻すと「誰でも申込を読める・書き換えられる」危険な状態に戻る。
--   画面が動かない等の緊急時に一時的に使い、原因を直したら 07 を再実行すること。
-- 元の設定は check_01_aisys_policies.sql の結果（2026-11-01）から再現。
-- ============================================================
begin;

drop policy if exists aisys_sub_admin_select on public.aisys_form_submissions;
drop policy if exists aisys_sub_admin_update on public.aisys_form_submissions;
drop policy if exists aisys_sub_admin_delete on public.aisys_form_submissions;

drop policy if exists "allow_delete_authenticated" on public.aisys_form_submissions;
drop policy if exists "allow_insert"               on public.aisys_form_submissions;
drop policy if exists "allow_select_authenticated" on public.aisys_form_submissions;
drop policy if exists "allow_select_by_id"         on public.aisys_form_submissions;
drop policy if exists "allow_update_anon"          on public.aisys_form_submissions;
drop policy if exists "allow_update_authenticated" on public.aisys_form_submissions;

create policy "allow_delete_authenticated" on public.aisys_form_submissions
  for delete to authenticated using (true);
create policy "allow_insert" on public.aisys_form_submissions
  for insert to public with check (true);
create policy "allow_select_authenticated" on public.aisys_form_submissions
  for select to authenticated using (true);
create policy "allow_select_by_id" on public.aisys_form_submissions
  for select to public using (true);
create policy "allow_update_anon" on public.aisys_form_submissions
  for update to anon using (true) with check (true);
create policy "allow_update_authenticated" on public.aisys_form_submissions
  for update to authenticated using (true);

grant insert, select, update, references, trigger, truncate on public.aisys_form_submissions to anon;
grant insert, select, update, delete, references, trigger, truncate on public.aisys_form_submissions to authenticated;

commit;

select 'rollback 完了（危険な旧設定に戻っています）' as result;
