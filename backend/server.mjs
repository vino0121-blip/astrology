import { createHash } from "node:crypto";
import http from "node:http";
import {
  applicationDefault,
  getApps,
  initializeApp,
} from "firebase-admin/app";
import { getAppCheck } from "firebase-admin/app-check";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

if (getApps().length === 0) {
  initializeApp({ credential: applicationDefault() });
}

const db = getFirestore();
const port = Number(process.env.PORT || 8080);
const openAiModel = process.env.OPENAI_MODEL || "gpt-5.4-mini";
const promptVersion = process.env.PROMPT_VERSION || "2026-06-08.2";
const requireAppCheck = process.env.REQUIRE_APP_CHECK !== "false";
const allowTestPremium = process.env.ALLOW_TEST_PREMIUM === "true";
const dailyLimit = Number(process.env.MAX_DAILY_GENERATIONS || 2);
const monthlyLimit = Number(process.env.MAX_MONTHLY_GENERATIONS_PER_DAY || 3);
const revenueCatEntitlement =
  process.env.REVENUECAT_ENTITLEMENT_ID || "premium";

const entitlementCache = new Map();

const dailySchema = {
  type: "object",
  additionalProperties: false,
  required: ["position", "aspect", "action", "time_plan", "checklist"],
  properties: {
    position: { type: "string", minLength: 80, maxLength: 520 },
    aspect: { type: "string", minLength: 80, maxLength: 560 },
    action: { type: "string", minLength: 80, maxLength: 560 },
    time_plan: {
      type: "array",
      minItems: 3,
      maxItems: 3,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["label", "body"],
        properties: {
          label: { type: "string", enum: ["午前", "午後", "夜"] },
          body: { type: "string", minLength: 30, maxLength: 240 },
        },
      },
    },
    checklist: {
      type: "array",
      minItems: 3,
      maxItems: 3,
      items: { type: "string", minLength: 12, maxLength: 120 },
    },
  },
};

const monthlySchema = {
  type: "object",
  additionalProperties: false,
  required: ["title", "blocks"],
  properties: {
    title: { type: "string", minLength: 20, maxLength: 180 },
    blocks: {
      type: "array",
      minItems: 4,
      maxItems: 4,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["title", "body"],
        properties: {
          title: {
            type: "string",
            enum: ["今月の核", "伸ばすこと", "注意点", "具体アクション"],
          },
          body: { type: "string", minLength: 30, maxLength: 320 },
        },
      },
    },
  },
};

const server = http.createServer(async (req, res) => {
  try {
    if (req.method === "GET" && req.url === "/health") {
      return json(res, 200, { ok: true });
    }
    if (req.method !== "POST") {
      return json(res, 404, { error: "not_found" });
    }

    const route = req.url?.split("?")[0];
    const type =
      route === "/v1/diagnoses/daily"
        ? "daily"
        : route === "/v1/diagnoses/monthly"
          ? "monthly"
          : null;
    if (!type) return json(res, 404, { error: "not_found" });

    const uid = await authenticate(req);
    if (!(await hasPremium(uid))) {
      return json(res, 403, { error: "premium_required" });
    }

    const payload = await readJson(req);
    validatePayload(type, payload);
    const response = await generateDiagnosis(type, uid, payload);
    return json(res, 200, response);
  } catch (error) {
    const status = Number(error?.statusCode || 500);
    if (status >= 500) console.error(error);
    return json(res, status, {
      error: error?.code || "internal_error",
    });
  }
});

server.listen(port, () => {
  console.log(`Hoshimeguri AI backend listening on ${port}`);
});

async function authenticate(req) {
  const authorization = req.headers.authorization || "";
  if (!authorization.startsWith("Bearer ")) {
    throw httpError(401, "missing_auth");
  }
  const idToken = authorization.slice("Bearer ".length);
  const decoded = await getAuth().verifyIdToken(idToken, true);

  if (requireAppCheck) {
    const appCheckToken = req.headers["x-firebase-appcheck"];
    if (typeof appCheckToken !== "string" || appCheckToken.length === 0) {
      throw httpError(401, "missing_app_check");
    }
    await getAppCheck().verifyToken(appCheckToken);
  }
  return decoded.uid;
}

async function hasPremium(uid) {
  if (allowTestPremium) return true;
  const secret = process.env.REVENUECAT_SECRET_API_KEY;
  if (!secret) throw httpError(503, "billing_not_configured");

  const cached = entitlementCache.get(uid);
  if (cached && cached.expiresAt > Date.now()) return cached.active;

  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`,
    { headers: { Authorization: `Bearer ${secret}` } },
  );
  if (!response.ok) {
    if (response.status === 404) return false;
    throw httpError(502, "billing_check_failed");
  }
  const data = await response.json();
  const entitlement =
    data?.subscriber?.entitlements?.[revenueCatEntitlement] ?? null;
  const expiresDate = entitlement?.expires_date;
  const active =
    entitlement !== null &&
    (expiresDate === null || Date.parse(expiresDate) > Date.now());
  entitlementCache.set(uid, {
    active,
    expiresAt: Date.now() + 60_000,
  });
  return active;
}

async function generateDiagnosis(type, uid, payload) {
  if (!process.env.OPENAI_API_KEY) {
    throw httpError(503, "openai_not_configured");
  }

  const period = type === "daily" ? payload.date : payload.month;
  const payloadHash = hash(stableJson(payload));
  const cacheId = hash(
    `${uid}|${type}|${period}|${promptVersion}|${payloadHash}`,
  );
  const cacheRef = db.collection("aiDiagnosisCache").doc(cacheId);
  const usageDate = new Date().toISOString().slice(0, 10);
  const usageRef = db.collection("aiUsage").doc(`${uid}_${usageDate}`);
  const limit = type === "daily" ? dailyLimit : monthlyLimit;

  const reservation = await db.runTransaction(async (transaction) => {
    const cacheSnap = await transaction.get(cacheRef);
    if (cacheSnap.exists && cacheSnap.data()?.status === "complete") {
      return { cached: true, result: cacheSnap.data().result };
    }
    if (cacheSnap.exists && cacheSnap.data()?.status === "generating") {
      const started = cacheSnap.data().startedAt?.toMillis?.() || 0;
      if (Date.now() - started < 120_000) {
        throw httpError(409, "generation_in_progress");
      }
    }

    const usageSnap = await transaction.get(usageRef);
    const current = Number(usageSnap.data()?.[type] || 0);
    if (current >= limit) throw httpError(429, "generation_limit_reached");

    transaction.set(
      usageRef,
      {
        uid,
        date: usageDate,
        [type]: current + 1,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.set(cacheRef, {
      uid,
      type,
      period,
      promptVersion,
      payloadHash,
      status: "generating",
      startedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { cached: false };
  });

  if (reservation.cached) {
    return {
      result: reservation.result,
      cached: true,
      model: openAiModel,
      prompt_version: promptVersion,
    };
  }

  try {
    const result = await callOpenAi(type, payload);
    await cacheRef.set(
      {
        status: "complete",
        result,
        model: openAiModel,
        completedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return {
      result,
      cached: false,
      model: openAiModel,
      prompt_version: promptVersion,
    };
  } catch (error) {
    await Promise.allSettled([
      cacheRef.set(
        {
          status: "failed",
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      ),
      usageRef.set(
        {
          [type]: FieldValue.increment(-1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      ),
    ]);
    throw error;
  }
}

async function callOpenAi(type, payload) {
  const schema = type === "daily" ? dailySchema : monthlySchema;
  const prompt =
    type === "daily"
      ? dailyDeveloperPrompt()
      : monthlyDeveloperPrompt();
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: openAiModel,
      reasoning: { effort: "low" },
      input: [
        {
          role: "developer",
          content: [{ type: "input_text", text: prompt }],
        },
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: `診断材料(JSON):\n${JSON.stringify(payload)}`,
            },
          ],
        },
      ],
      text: {
        verbosity: type === "daily" ? "medium" : "low",
        format: {
          type: "json_schema",
          name: `${type}_astrology_diagnosis`,
          strict: true,
          schema,
        },
      },
      max_output_tokens: type === "daily" ? 2200 : 1800,
    }),
  });
  const body = await response.json();
  if (!response.ok) {
    console.error("OpenAI error", response.status, body);
    throw httpError(502, "generation_failed");
  }
  const text = outputText(body);
  if (!text) throw httpError(502, "empty_generation");
  return JSON.parse(text);
}

function dailyDeveloperPrompt() {
  return [
    "あなたは日本語の占星術アプリ「星巡」の診断編集者です。",
    "入力された計算済み材料だけを根拠に、日常で使える自然な文章へ編集してください。",
    "専門用語を前面に出さず、断定や恐怖訴求を避けてください。",
    "医療、法律、投資、妊娠、寿命、事故を予言・診断しないでください。",
    "恋愛、退職、契約など重大な決断を命令しないでください。",
    "toneがやさしめ診断なら穏やかに、鋭め診断なら率直に、直球診断なら短く強めにします。",
    "position、aspect、actionはそれぞれ2〜3文で書き、1文だけで終わらせないでください。",
    "各セクションは、状態の説明、使いどころ、今日の小さな行動の順で具体化してください。",
    "position、aspect、action、時間帯、チェック項目の内容を重複させないでください。",
    "占いは参考情報として、具体的だが小さく実行できる行動に落としてください。",
  ].join("\n");
}

function monthlyDeveloperPrompt() {
  return [
    "あなたは日本語の占星術アプリ「星巡」の月間診断編集者です。",
    "入力された月内スコア、週ごとの流れ、重要日だけを根拠に文章化してください。",
    "同じ説明を言い換えて繰り返さず、今月の核、伸ばすこと、注意点、具体アクションを分担させてください。",
    "専門用語、断定、恐怖訴求を避け、日常の予定や振り返りに使える内容にしてください。",
    "医療、法律、投資、妊娠、寿命、事故の予言や、重大な決断の命令は禁止です。",
  ].join("\n");
}

function outputText(response) {
  for (const item of response.output || []) {
    if (item.type !== "message") continue;
    for (const content of item.content || []) {
      if (content.type === "output_text" && typeof content.text === "string") {
        return content.text;
      }
    }
  }
  return null;
}

function validatePayload(type, payload) {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    throw httpError(400, "invalid_payload");
  }
  if (type === "daily") {
    assertString(payload.date, 10, 10);
    assertInteger(payload.score, 0, 100);
    assertString(payload.monthly_rank, 1, 20);
    assertString(payload.tone, 1, 20);
    assertString(payload.position_seed, 1, 700);
    assertString(payload.aspect_seed, 1, 700);
    assertString(payload.action_seed, 1, 700);
    if (!Array.isArray(payload.time_plan) || payload.time_plan.length !== 3) {
      throw httpError(400, "invalid_payload");
    }
    if (!Array.isArray(payload.checklist) || payload.checklist.length !== 3) {
      throw httpError(400, "invalid_payload");
    }
  } else {
    assertString(payload.month, 7, 7);
    assertInteger(payload.average_score, 0, 100);
    assertInteger(payload.best_day, 1, 31);
    assertInteger(payload.careful_day, 1, 31);
    if (!Array.isArray(payload.weeks) || payload.weeks.length > 6) {
      throw httpError(400, "invalid_payload");
    }
    if (!Array.isArray(payload.highlights) || payload.highlights.length > 8) {
      throw httpError(400, "invalid_payload");
    }
  }
}

async function readJson(req) {
  const chunks = [];
  let size = 0;
  for await (const chunk of req) {
    size += chunk.length;
    if (size > 64 * 1024) throw httpError(413, "payload_too_large");
    chunks.push(chunk);
  }
  try {
    return JSON.parse(Buffer.concat(chunks).toString("utf8"));
  } catch {
    throw httpError(400, "invalid_json");
  }
}

function stableJson(value) {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value && typeof value === "object") {
    return `{${Object.keys(value)
      .sort()
      .map((key) => `${JSON.stringify(key)}:${stableJson(value[key])}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}

function hash(value) {
  return createHash("sha256").update(value).digest("hex");
}

function assertString(value, min, max) {
  if (
    typeof value !== "string" ||
    value.length < min ||
    value.length > max
  ) {
    throw httpError(400, "invalid_payload");
  }
}

function assertInteger(value, min, max) {
  if (!Number.isInteger(value) || value < min || value > max) {
    throw httpError(400, "invalid_payload");
  }
}

function httpError(statusCode, code) {
  const error = new Error(code);
  error.statusCode = statusCode;
  error.code = code;
  return error;
}

function json(res, status, body) {
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
    "X-Content-Type-Options": "nosniff",
  });
  res.end(JSON.stringify(body));
}
