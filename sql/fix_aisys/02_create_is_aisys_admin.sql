-- ============================================================
-- 02. 判定関数 is_aisys_admin()（既存の画面には影響なし）
-- ログイン中の人が管理者名簿に載っていれば true。載っていなければ false（null にしない）。
-- ============================================================
create or replace function public.is_aisys_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    exists (select 1 from public.aisys_admins a where a.user_id = auth.uid()),
    false
  );
$$;

revoke execute on function public.is_aisys_admin() from public, anon;
grant execute on function public.is_aisys_admin() to authenticated;

select 'is_aisys_admin 作成完了' as result;
