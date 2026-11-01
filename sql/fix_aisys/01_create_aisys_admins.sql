-- ============================================================
-- 01. 管理者名簿 aisys_admins を作成（既存の画面には影響なし）
-- 管理画面（admin.html）で申込を読み書きできるのは、この名簿に載った人だけにする。
-- ============================================================
create table if not exists public.aisys_admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.aisys_admins enable row level security;

-- 新規テーブルへ自動付与される権限を外す（anon は一切触れない）
revoke all on public.aisys_admins from anon, authenticated;
grant select on public.aisys_admins to authenticated;

-- 本人が「自分が名簿に載っているか」だけ見られる。書き込みは SQL Editor からのみ。
drop policy if exists aisys_admins_select_self on public.aisys_admins;
create policy aisys_admins_select_self on public.aisys_admins
  for select to authenticated
  using (user_id = (select auth.uid()));

select 'aisys_admins 作成完了' as result;
