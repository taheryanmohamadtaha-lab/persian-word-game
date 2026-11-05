extends Screen
## صفحهٔ انتخاب گروه سنی یا سطح دشواری (دو انتخاب مستقل).

const AGE_DESC := {
	"kids": "حروف، حیوانات، میوه‌ها، رنگ‌ها و وسایل مدرسه",
	"teens": "علوم، جغرافیا، تاریخ، ادبیات، ورزش و فناوری",
	"adults": "اطلاعات عمومی، ادبیات، فرهنگ و معماهای فکری",
}
const DIFF_DESC := {
	"easy": "کلمه‌های کوتاه، حروف کمتر و زمان آزاد",
	"medium": "حروف بیشتر و سرنخ‌های مفهومی، زمان آزاد",
	"hard": "همهٔ حروف الفبا، ۶۰ ثانیه وقت و امتیاز دوبرابر",
}
const COLORS := [Color("86d36b"), Color("f2c14e"), Color("ee8a5a")]

func build() -> void:
	var kind: String = args.get("kind", "age")
	main.bg.set_palette(0 if kind == "age" else 1)
	var is_age := kind == "age"
	back_button("start" if is_age else "choice", {} if is_age else {"kind": "age"})
	title_bar("انتخاب گروه سنی" if is_age else "انتخاب سطح دشواری")
	var ids: Array = Game.AGES.keys() if is_age else Game.DIFFS.keys()
	var yy := 130.0 + maxf(0.0, (H - 1280.0) * 0.25)
	for i in ids.size():
		var id: String = ids[i]
		var title: String = Game.AGES[id] if is_age else Game.DIFFS[id]
		var desc: String = AGE_DESC[id] if is_age else DIFF_DESC[id]
		var b := UI.button(self, "", Vector2(x(50), yy + i * 300.0), Vector2(620, 270), COLORS[i], 40)
		UI.label(b, title, Vector2(0, 40), Vector2(620, 100), 64)
		UI.label(b, desc, Vector2(40, 150), Vector2(540, 90), 28)
		b.pressed.connect(func():
			if is_age:
				Game.cur_age = id
				main.go("choice", {"kind": "diff"})
			else:
				Game.cur_diff = id
				main.go("map"))
