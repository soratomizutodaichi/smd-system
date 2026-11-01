-- ============================================================
-- 03. 管理者を名簿に登録（既存の画面には影響なし）
-- 2026-11-01 社長指示：admin.html にログインするのは yamamoto@soratomizutodaichi.com
-- 結果に 1 行出れば成功。0 行ならアドレスの綴り違い。
-- ============================================================
insert into public.aisys_admins (user_id)
select u.id from auth.users u
where lower(u.email) = lower('yamamoto@soratomizutodaichi.com')
on conflict (user_id) do nothing;

select u.email, a.created_at
from public.aisys_admins a
join auth.users u on u.id = a.user_id;
