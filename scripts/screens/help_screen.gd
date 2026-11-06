extends Screen
## راهنمای بازی: هر مورد یک ردیف جدا با شمارهٔ گرد؛ متن‌ها کوتاه و کاملاً داخل کادرند.

const ITEMS := [
	"حرف‌ها را لمس کن. هر حرف درست، همهٔ خانه‌های خودش را پر می‌کند.",
	"هر حرف اشتباه یک گوی شیشه‌ای را می‌شکند.",
	"اگر همهٔ گوی‌ها بشکنند، مرحله از اول شروع می‌شود.",
	"راهنما با ۵ سکه یک حرف درست می‌گذارد و عبور ۱۰ امتیاز کم می‌کند.",
	"پاسخ سریع و بی‌اشتباه امتیاز بیشتری دارد.",
	"سطح سخت ۶۰ ثانیه وقت دارد و با تمام شدنش یک گوی می‌شکند.",
	"از «ظاهر بازی» رنگ، شخصیت و از «تنظیمات» موسیقی را انتخاب کن.",
]

func build() -> void:
	main.bg.set_palette(3)
	back_button("start")
	title_bar("راهنمای بازی")
	var panel_h := minf(1040.0, H - 150.0)
	var p := UI.panel(self, Vector2(x(30), 110), Vector2(660, panel_h), UI.CREAM, 28, UI.GOLD, 4)
	var row_h := (panel_h - 40.0) / ITEMS.size()
	for i in ITEMS.size():
		var y := 20.0 + i * row_h
		var badge := UI.panel(p, Vector2(590, y + row_h / 2.0 - 24.0), Vector2(48, 48), UI.col("primary"), 24)
		UI.label(badge, UI.fa(i + 1), Vector2.ZERO, Vector2(48, 48), 26)
		var l := UI.label(p, ITEMS[i], Vector2(20, y), Vector2(555, row_h - 8.0), 25, UI.INK, HORIZONTAL_ALIGNMENT_RIGHT)
		l.text_direction = Control.TEXT_DIRECTION_RTL
		l.clip_text = true
		if i < ITEMS.size() - 1:
			var line := ColorRect.new()
			line.color = Color(UI.GOLD, 0.35)
			line.position = Vector2(24, y + row_h - 4.0)
			line.size = Vector2(612, 2)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			p.add_child(line)
