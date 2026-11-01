-- ============================================================
-- 06. 「入金しました」mark_aisys_applicant_paid()（既存の画面には影響なし）
-- contract.html のボタンから呼ぶ。契約書を送った申込の「申込者の入金日」だけを記録する。
-- 時刻はサーバーの now()。記録済み・削除済み・契約書未送付なら何もしない。
-- 戻り値は記録された入金日時（何もしなかった場合は既存値または null）。
-- ============================================================
create or replace function public.mark_aisys_applicant_paid(p_id uuid)
returns timestamptz
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_paid timestamptz;
begin
  update public.aisys_form_submissions s
     set applicant_paid_at = now()
   where s.id = p_id
     and s.deleted_at is null
     and s.contract_sent_at is not null
     and s.applicant_paid_at is null
  returning s.applicant_paid_at into v_paid;

  if v_paid is null then
    select s.applicant_paid_at into v_paid
      from public.aisys_form_submissions s
     where s.id = p_id and s.deleted_at is null;
  end if;

  return v_paid;
end;
$$;

revoke execute on function public.mark_aisys_applicant_paid(uuid) from public;
grant execute on function public.mark_aisys_applicant_paid(uuid) to anon, authenticated;

select 'mark_aisys_applicant_paid 作成完了' as result;
