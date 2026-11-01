// 無料Excel診断の申込フォーム。保存は既存の submit_aisys_form（関数経由）、受付メールは既存の EmailJS テンプレートを使う
(function () {
  'use strict';

  var SUPABASE_URL = 'https://gcmtnzvcoovjqxanbmqc.supabase.co';
  // anon キー（公開前提の鍵。申込表への直接アクセスは閉じてあり、関数経由の登録のみ可能）
  var SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdjbXRuenZjb292anF4YW5ibXFjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NDczNTksImV4cCI6MjA5MzAyMzM1OX0.30xm_Vd7UdfkombPOfSjg-nYxmuwYlnHHEgqRzWE4fQ';
  var EMAILJS_PUBLIC_KEY = 'sydEkxfsmryplEbcO';
  var EMAILJS_SERVICE = 'service_7m0hycl';
  var EMAILJS_TEMPLATE = 'template_3p7ngs9';
  var SITE_URL = 'https://aisys.soratomizutodaichi.com';
  var MIN_FILL_MS = 3000; // これより早い送信は機械的な送信とみなす

  var form = document.getElementById('diagnosis-form');
  if (!form) return;
  var errorBox = document.getElementById('form-error');
  var doneBox = document.getElementById('form-done');
  var submitBtn = form.querySelector('button[type="submit"]');
  var openedAt = Date.now();

  var sbClient = null;
  try {
    sbClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
  } catch (e) {
    console.error('Supabase init error', e);
  }
  try {
    window.emailjs.init({ publicKey: EMAILJS_PUBLIC_KEY });
  } catch (e) {
    console.error('EmailJS init error', e);
  }

  function value(name) {
    var el = form.elements[name];
    return el ? el.value.trim() : '';
  }

  function showError(message) {
    errorBox.textContent = message;
    errorBox.hidden = false;
  }

  function showDone() {
    form.hidden = true;
    doneBox.hidden = false;
  }

  function validate(data) {
    if (!data.company) return '会社名を入力してください。';
    if (!data.name) return 'お名前を入力してください。';
    if (!data.email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(data.email)) return 'メールアドレスを正しく入力してください。';
    if (data.phone && !/^[0-9０-９+\-‐－()（） ]{6,30}$/.test(data.phone)) return '電話番号を正しく入力してください。';
    return '';
  }

  form.addEventListener('submit', async function (e) {
    e.preventDefault();
    errorBox.hidden = true;

    var data = {
      company: value('company'),
      name: value('name'),
      email: value('email'),
      phone: value('phone'),
      task: value('task')
    };

    // おとり欄に入力がある・早すぎる送信は、保存せずに完了表示だけ出す
    if (value('website') || Date.now() - openedAt < MIN_FILL_MS) {
      showDone();
      return;
    }

    var problem = validate(data);
    if (problem) {
      showError(problem);
      return;
    }
    if (!sbClient) {
      showError('送信の準備ができませんでした。お手数ですが、お電話かメールでお申し込みください。');
      return;
    }

    submitBtn.disabled = true;
    submitBtn.textContent = '送信中…';

    var result = await sbClient.rpc('submit_aisys_form', {
      p_type: 'meeting',
      p_name: data.name,
      p_furigana: null,
      p_company: data.company,
      p_phone: data.phone || null,
      p_email: data.email,
      p_preferred_date_1: null,
      p_preferred_date_2: null,
      p_plan: '無料Excel診断',
      p_message: data.task || null
    });

    if (result.error) {
      console.error('submit error', result.error);
      showError('送信できませんでした。時間をおいて再度お試しいただくか、お電話かメールでお申し込みください。');
      submitBtn.disabled = false;
      submitBtn.textContent = '無料診断を申し込む';
      return;
    }

    var newId = result.data;
    try {
      await window.emailjs.send(EMAILJS_SERVICE, EMAILJS_TEMPLATE, {
        to_name: data.name,
        to_email: data.email,
        phone: data.phone,
        form_type: '無料Excel診断のお申し込み',
        preferred_date_1: '',
        preferred_date_2: '',
        plan: '無料Excel診断',
        message: data.task,
        confirmation_url: newId ? SITE_URL + '/confirmation.html?id=' + encodeURIComponent(newId) : SITE_URL
      });
    } catch (mailErr) {
      // 申込自体は保存済みのため、メール失敗では利用者にエラーを見せない
      console.error('Email error', mailErr);
    }
    showDone();
  });
})();
