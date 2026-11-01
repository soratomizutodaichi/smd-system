-- ============================================================
-- 【確認用・読み取りのみ】このプロジェクトにログインできるアカウントの一覧
-- 管理者名簿（aisys_admins）に載せるアカウントを決めるため。何も変更しません。
-- 知らないアカウントが無いかも確認してください（公開登録の有無の確認）。
-- ============================================================
select email,
       created_at::date            as created,
       last_sign_in_at::date       as last_sign_in,
       raw_app_meta_data->>'provider' as provider
from auth.users
order by created_at;
