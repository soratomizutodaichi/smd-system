-- ============================================================
-- aisys_form_submissions テーブル 全SQLまとめ
-- 空と水と大地合同会社 システムサービス部門
-- ============================================================


-- ============================================================
-- 1. テーブル作成（初期）
-- ============================================================
-- Supabase管理画面で手動作成（GUI操作）
-- カラム: id, type, name, company, phone, email,
--         preferred_date_1, preferred_date_2, plan, message, created_at


-- ============================================================
-- 2. anon INSERT権限（フォーム送信用）
-- ============================================================
DROP POLICY IF EXISTS "allow_insert" ON aisys_form_submissions;
CREATE POLICY "allow_insert" ON aisys_form_submissions FOR INSERT WITH CHECK (true);
GRANT INSERT ON aisys_form_submissions TO anon;


-- ============================================================
-- 3. authenticated SELECT/UPDATE/DELETE権限（管理画面用）
-- ============================================================
CREATE POLICY "allow_select_authenticated" ON aisys_form_submissions
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "allow_update_authenticated" ON aisys_form_submissions
  FOR UPDATE TO authenticated USING (true);

CREATE POLICY "allow_delete_authenticated" ON aisys_form_submissions
  FOR DELETE TO authenticated USING (true);

GRANT SELECT, UPDATE, DELETE ON aisys_form_submissions TO authenticated;


-- ============================================================
-- 4. anon UPDATE権限（申込者の入金確認ボタン用）
-- ============================================================
CREATE POLICY "allow_update_anon" ON aisys_form_submissions
  FOR UPDATE TO anon USING (true) WITH CHECK (true);
GRANT UPDATE ON aisys_form_submissions TO anon;


-- ============================================================
-- 5. カラム追加
-- ============================================================

-- 電話済みフラグ・確定日程
ALTER TABLE aisys_form_submissions ADD COLUMN called boolean DEFAULT false;
ALTER TABLE aisys_form_submissions ADD COLUMN confirmed_date text DEFAULT NULL;

-- 仮想削除
ALTER TABLE aisys_form_submissions ADD COLUMN deleted_at timestamptz DEFAULT NULL;

-- 契約管理
ALTER TABLE aisys_form_submissions ADD COLUMN contract_url text DEFAULT NULL;
ALTER TABLE aisys_form_submissions ADD COLUMN contract_sent_at timestamptz DEFAULT NULL;
ALTER TABLE aisys_form_submissions ADD COLUMN applicant_paid_at timestamptz DEFAULT NULL;
ALTER TABLE aisys_form_submissions ADD COLUMN company_confirmed_paid_at timestamptz DEFAULT NULL;

-- サービス実施予定日
ALTER TABLE aisys_form_submissions ADD COLUMN service_date text DEFAULT NULL;

-- フリガナ
ALTER TABLE aisys_form_submissions ADD COLUMN furigana text DEFAULT NULL;


-- ============================================================
-- 6. 商品マスタテーブル（products.html用）
-- ============================================================
CREATE TABLE aisys_products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  product_no text NOT NULL,
  product_name text NOT NULL,
  description text,
  initial_fee integer DEFAULT 0,
  monthly_fee integer DEFAULT 0,
  contract_months integer DEFAULT 0,
  auto_renewal boolean DEFAULT false,
  start_date date DEFAULT NULL,
  end_date date DEFAULT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE POLICY "allow_all_authenticated" ON aisys_products
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

GRANT ALL ON aisys_products TO authenticated;

ALTER TABLE aisys_products ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- 7. anon スキーマ・INSERT権限の追加付与（トラブル時に実行）
-- ============================================================
GRANT USAGE ON SCHEMA public TO anon;
GRANT INSERT ON aisys_form_submissions TO anon;


-- ============================================================
-- 7. 現在のポリシー確認クエリ（確認用・実行不要）
-- ============================================================
-- SELECT policyname, cmd, roles, qual, with_check
-- FROM pg_policies
-- WHERE tablename = 'aisys_form_submissions';

-- ============================================================
-- ※ 現在有効なポリシー一覧（2026-06-26時点）
-- allow_select_authenticated  SELECT  {authenticated}
-- allow_update_authenticated  UPDATE  {authenticated}
-- allow_delete_authenticated  DELETE  {authenticated}
-- allow_select_by_id          SELECT  {public}
-- allow_update_anon           UPDATE  {anon}
-- allow_insert                INSERT  {public}
-- ============================================================
