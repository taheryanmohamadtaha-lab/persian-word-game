#!/usr/bin/env python3
"""کنترل کیفیت سؤال‌ها: تکراری، حروف نامعتبر، طول پاسخ، لو رفتن پاسخ در سرنخ."""
import json, sys, os, collections
ALPHABET = "آابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی"
root = os.path.join(os.path.dirname(__file__), "..", "data", "questions")
index = json.load(open(os.path.join(root, "index.json"), encoding="utf-8"))
errors, ids, answers = [], set(), collections.defaultdict(list)
for fn in index["files"]:
    for q in json.load(open(os.path.join(root, fn), encoding="utf-8")):
        for k in ("id","age","diff","topic","answer","clue","hint","points"):
            if k not in q: errors.append(f"{q.get('id')}: فیلد {k} ندارد")
        if q["id"] in ids: errors.append(f"{q['id']}: شناسه تکراری")
        ids.add(q["id"]); answers[(q["age"], q["answer"])].append(q["id"])
        bad = [c for c in q["answer"] if c not in ALPHABET]
        if bad: errors.append(f"{q['id']}: حرف نامعتبر {bad}")
        if not 2 <= len(q["answer"]) <= 10: errors.append(f"{q['id']}: طول پاسخ نامناسب")
        if q["answer"] in q["clue"]: errors.append(f"{q['id']}: پاسخ در سرنخ آمده")
        if q["answer"] in q["hint"]: errors.append(f"{q['id']}: پاسخ در راهنما آمده")
        if q["age"] not in ("kids","teens","adults"): errors.append(f"{q['id']}: گروه سنی نامعتبر")
        if q["diff"] not in ("easy","medium","hard"): errors.append(f"{q['id']}: سطح نامعتبر")
for k, v in answers.items():
    if len(v) > 1: errors.append(f"پاسخ تکراری {k}: {v}")
print(f"{len(ids)} سؤال بررسی شد؛ {len(errors)} خطا")
for e in errors: print(" -", e)
sys.exit(1 if errors else 0)
