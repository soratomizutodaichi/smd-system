-- ============================================================
-- 04. 申込の受付 submit_aisys_form()（既存の画面には影響なし）
-- index.html のフォームから呼ぶ。入力を検査して1件保存し、申込番号(uuid)だけ返す。
-- 管理用の列（確定日・契約書URL・入金日など）は、ここからは一切書けない。
-- ============================================================
create or replace function public.submit_aisys_form(
  p_type             text,
  p_name             text,
  p_furigana         text default null,
  p_company          text default null,
  p_phone            text default null,
  p_email            text default null,
  p_preferred_date_1 text default null,
  p_preferred_date_2 text default null,
  p_plan             text default null,
  p_message          text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  if p_type is null or p_type not in ('inquiry', 'meeting') then
    raise exception '申込の種類が正しくありません' using errcode = '22023';
  end if;
  if p_name is null or length(btrim(p_name)) = 0 or length(p_name) > 100 then
    raise exception 'お名前を100文字以内で入力してください' using errcode = '22023';
  end if;
  if p_email is null or length(p_email) > 254
     or p_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' then
    raise exception 'メールアドレスが正しくありません' using errcode = '22023';
  end if;
  if coalesce(length(p_furigana), 0) > 100
     or coalesce(length(p_company), 0) > 200
     or coalesce(length(p_phone), 0) > 30
     or coalesce(length(p_preferred_date_1), 0) > 100
     or coalesce(length(p_preferred_date_2), 0) > 100
     or coalesce(length(p_plan), 0) > 200
     or coalesce(length(p_message), 0) > 5000 then
    raise exception '入力が長すぎます' using errcode = '22023';
  end if;

  insert into public.aisys_form_submissions
    (type, name, furigana, company, phone, email,
     preferred_date_1, preferred_date_2, plan, message)
  values
    (p_type, btrim(p_name), nullif(btrim(p_furigana), ''), nullif(btrim(p_company), ''),
     nullif(btrim(p_phone), ''), btrim(p_email),
     nullif(btrim(p_preferred_date_1), ''), nullif(btrim(p_preferred_date_2), ''),
     nullif(btrim(p_plan), ''), nullif(btrim(p_message), ''))
  returning id into v_id;

  return v_id;
end;
$$;

revoke execute on function public.submit_aisys_form(text, text, text, text, text, text, text, text, text, text) from public;
grant execute on function public.submit_aisys_form(text, text, text, text, text, text, text, text, text, text) to anon, authenticated;

select 'submit_aisys_form 作成完了' as result;
