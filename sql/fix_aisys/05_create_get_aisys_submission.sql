-- ============================================================
-- 05. 申込の表示 get_aisys_submission()（既存の画面には影響なし）
-- confirmation.html / contract.html から呼ぶ。申込番号(uuid)を知っている人に、
-- その1件だけ、画面で使う項目だけを返す（ふりがな・電話済みフラグ・削除フラグ等は返さない）。
-- 電話番号は確認ページで本人に表示しているため返す。
-- 番号が無い・削除済みなら null。
-- ============================================================
create or replace function public.get_aisys_submission(p_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id',                        s.id,
    'type',                      s.type,
    'name',                      s.name,
    'company',                   s.company,
    'phone',                     s.phone,
    'email',                     s.email,
    'plan',                      s.plan,
    'message',                   s.message,
    'preferred_date_1',          s.preferred_date_1,
    'preferred_date_2',          s.preferred_date_2,
    'confirmed_date',            s.confirmed_date,
    'service_date',              s.service_date,
    'contract_url',              s.contract_url,
    'contract_sent_at',          s.contract_sent_at,
    'applicant_paid_at',         s.applicant_paid_at,
    'company_confirmed_paid_at', s.company_confirmed_paid_at,
    'created_at',                s.created_at
  )
  from public.aisys_form_submissions s
  where s.id = p_id
    and s.deleted_at is null;
$$;

revoke execute on function public.get_aisys_submission(uuid) from public;
grant execute on function public.get_aisys_submission(uuid) to anon, authenticated;

select 'get_aisys_submission 作成完了' as result;
