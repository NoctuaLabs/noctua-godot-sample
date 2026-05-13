extends Control

# ── Color Palette ──────────────────────────────────────────────────────────
const COL_BG        := Color(0.051, 0.051, 0.102)       # #0D0D1A
const COL_CARD      := Color(0.082, 0.082, 0.157)       # #151528
const COL_HEADER_BG := Color(0.071, 0.055, 0.176)       # #120E2D
const COL_ACCENT    := Color(0.424, 0.278, 1.000)       # #6C47FF
const COL_ACCENT_DK := Color(0.314, 0.196, 0.784)       # #5032C8
const COL_TEXT      := Color(0.886, 0.906, 0.941)       # #E2E8F0
const COL_SUBTEXT   := Color(0.576, 0.639, 0.722)       # #93A3B8
const COL_SUCCESS   := Color(0.133, 0.773, 0.369)       # #22C55E
const COL_WARNING   := Color(0.961, 0.620, 0.043)       # #F59E0B
const COL_ERROR     := Color(0.937, 0.267, 0.267)       # #EF4444
const COL_INPUT     := Color(0.063, 0.063, 0.118)       # #101020
const COL_BORDER    := Color(0.176, 0.176, 0.294)       # #2D2D4B

# ── Layout Constants ───────────────────────────────────────────────────────
const MARGIN    := 16
const S_RADIUS  := 12
const BTN_H     := 52
const INPUT_H   := 48
const BTN_R     := 8
const S_PAD     := 16
const MAX_LOG   := 60

# ── UI References ──────────────────────────────────────────────────────────
var _status_dot   : ColorRect
var _status_label : Label
var _rev_event    : LineEdit
var _rev_amount   : LineEdit
var _rev_currency : OptionButton
var _order_id     : LineEdit
var _pur_amount   : LineEdit
var _ad_source    : OptionButton
var _ad_revenue   : LineEdit
var _session_tag  : LineEdit
var _custom_ev    : LineEdit
var _log_rtl      : RichTextLabel

# ══════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_refresh_status()

func _refresh_status() -> void:
	if Engine.has_singleton("GodotNoctua"):
		_set_status(COL_SUCCESS, "Native SDK Connected")
	elif OS.has_feature("editor"):
		_set_status(COL_WARNING, "Editor  —  SDK Inactive")
	else:
		_set_status(COL_ERROR, "Plugin Not Found")

func _set_status(color: Color, text: String) -> void:
	_status_dot.color      = color
	_status_label.text     = text
	_status_label.modulate = color

# ══════════════════════════════════════════════════════════════════════════
# UI BUILDER
# ══════════════════════════════════════════════════════════════════════════

func _build_ui() -> void:
	# full-screen background
	var bg := ColorRect.new()
	bg.color = COL_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# scrollable wrapper
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 12)
	scroll.add_child(root)

	_build_header(root)
	_build_section_events(root)
	_build_section_revenue(root)
	_build_section_purchase(root)
	_build_section_ad_revenue(root)
	_build_section_session(root)
	_build_section_log(root)

	var pad := Control.new()
	pad.custom_minimum_size.y = 48
	root.add_child(pad)

# ── Header ─────────────────────────────────────────────────────────────────

func _build_header(p: VBoxContainer) -> void:
	var panel := _panel(COL_HEADER_BG, 0)
	p.add_child(panel)

	var mc := _margin_c(MARGIN, 18, MARGIN, 18)
	panel.add_child(mc)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	mc.add_child(row)

	# title block
	var lv := VBoxContainer.new()
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lv.add_theme_constant_override("separation", 3)
	row.add_child(lv)

	lv.add_child(_lbl("NOCTUA SDK", COL_TEXT, 22))
	lv.add_child(_lbl("Analytics & Attribution Demo", COL_SUBTEXT, 12))

	# status block
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 5)
	sv.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(sv)

	var dot_wrap := CenterContainer.new()
	sv.add_child(dot_wrap)
	_status_dot = ColorRect.new()
	_status_dot.custom_minimum_size = Vector2(10, 10)
	_status_dot.color = COL_WARNING
	dot_wrap.add_child(_status_dot)

	_status_label = _lbl("Checking...", COL_SUBTEXT, 10)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sv.add_child(_status_label)

# ── Track Events ───────────────────────────────────────────────────────────

func _build_section_events(p: VBoxContainer) -> void:
	var vb := _section(p, "TRACK EVENTS")
	vb.add_child(_lbl("Tap an event to send it", COL_SUBTEXT, 11))
	vb.add_child(_vspace(8))

	var events := [
		["level_start",          "Level Start"],
		["level_end",            "Level End"],
		["tutorial_start",       "Tutorial Start"],
		["tutorial_end",         "Tutorial End"],
		["game_start",           "Game Start"],
		["achievement_unlocked", "Achievement"],
	]

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vb.add_child(grid)

	for ev in events:
		var key: String = ev[0]
		var lbl: String = ev[1]
		var btn := _btn_secondary(lbl, func(): _on_event_pressed(key))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(btn)

	vb.add_child(_vspace(10))
	vb.add_child(_lbl("Custom Event", COL_SUBTEXT, 11))
	vb.add_child(_vspace(4))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vb.add_child(row)

	_custom_ev = _lineedit("my_custom_event")
	_custom_ev.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_custom_ev)

	var track_btn := _btn_accent("Track", _on_custom_event_pressed)
	track_btn.custom_minimum_size.x = 88
	row.add_child(track_btn)

# ── Track Revenue ──────────────────────────────────────────────────────────

func _build_section_revenue(p: VBoxContainer) -> void:
	var vb := _section(p, "TRACK REVENUE")

	vb.add_child(_lbl("Event Name", COL_SUBTEXT, 11))
	vb.add_child(_vspace(4))
	_rev_event = _lineedit("purchase")
	_rev_event.text = "purchase"
	vb.add_child(_rev_event)

	vb.add_child(_vspace(10))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vb.add_child(row)

	var ac := VBoxContainer.new()
	ac.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ac.add_theme_constant_override("separation", 4)
	row.add_child(ac)
	ac.add_child(_lbl("Amount", COL_SUBTEXT, 11))
	_rev_amount = _lineedit("0.99")
	ac.add_child(_rev_amount)

	var cc := VBoxContainer.new()
	cc.add_theme_constant_override("separation", 4)
	row.add_child(cc)
	cc.add_child(_lbl("Currency", COL_SUBTEXT, 11))
	_rev_currency = _option_currencies()
	cc.add_child(_rev_currency)

	vb.add_child(_vspace(12))
	vb.add_child(_btn_primary("Track Revenue", _on_revenue_pressed))

# ── Track Purchase ─────────────────────────────────────────────────────────

func _build_section_purchase(p: VBoxContainer) -> void:
	var vb := _section(p, "TRACK PURCHASE")

	vb.add_child(_lbl("Order ID", COL_SUBTEXT, 11))
	vb.add_child(_vspace(4))
	_order_id = _lineedit("ORDER-%d" % randi_range(10000, 99999))
	vb.add_child(_order_id)

	vb.add_child(_vspace(10))
	vb.add_child(_lbl("Amount (USD)", COL_SUBTEXT, 11))
	vb.add_child(_vspace(4))
	_pur_amount = _lineedit("4.99")
	vb.add_child(_pur_amount)

	vb.add_child(_vspace(12))
	vb.add_child(_btn_primary("Track Purchase", _on_purchase_pressed))

# ── Track Ad Revenue ───────────────────────────────────────────────────────

func _build_section_ad_revenue(p: VBoxContainer) -> void:
	var vb := _section(p, "TRACK AD REVENUE")

	vb.add_child(_lbl("Ad Network", COL_SUBTEXT, 11))
	vb.add_child(_vspace(4))
	_ad_source = OptionButton.new()
	for src in ["admob", "applovin", "ironsource", "unity_ads", "mopub", "vungle", "chartboost"]:
		_ad_source.add_item(src)
	_ad_source.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ad_source.custom_minimum_size.y = INPUT_H
	_style_option(_ad_source)
	vb.add_child(_ad_source)

	vb.add_child(_vspace(10))
	vb.add_child(_lbl("Revenue (USD)", COL_SUBTEXT, 11))
	vb.add_child(_vspace(4))
	_ad_revenue = _lineedit("0.0025")
	vb.add_child(_ad_revenue)

	vb.add_child(_vspace(12))
	vb.add_child(_btn_primary("Track Ad Revenue", _on_ad_revenue_pressed))

# ── Session Tag ────────────────────────────────────────────────────────────

func _build_section_session(p: VBoxContainer) -> void:
	var vb := _section(p, "SESSION TAG")

	vb.add_child(_lbl("Tag Name", COL_SUBTEXT, 11))
	vb.add_child(_vspace(4))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vb.add_child(row)

	_session_tag = _lineedit("main_gameplay")
	_session_tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_session_tag)

	var btn := _btn_accent("Set Tag", _on_session_tag_pressed)
	btn.custom_minimum_size.x = 100
	row.add_child(btn)

# ── Event Log ──────────────────────────────────────────────────────────────

func _build_section_log(p: VBoxContainer) -> void:
	var vb := _section(p, "EVENT LOG")

	var log_bg := PanelContainer.new()
	var ls := StyleBoxFlat.new()
	ls.bg_color                  = COL_INPUT
	ls.corner_radius_top_left    = 8
	ls.corner_radius_top_right   = 8
	ls.corner_radius_bottom_left = 8
	ls.corner_radius_bottom_right = 8
	ls.border_width_left   = 1
	ls.border_width_right  = 1
	ls.border_width_top    = 1
	ls.border_width_bottom = 1
	ls.border_color        = COL_BORDER
	log_bg.add_theme_stylebox_override("panel", ls)
	vb.add_child(log_bg)

	var lm := _margin_c(10, 10, 10, 10)
	log_bg.add_child(lm)

	_log_rtl = RichTextLabel.new()
	_log_rtl.bbcode_enabled         = true
	_log_rtl.custom_minimum_size.y  = 220
	_log_rtl.scroll_following       = true
	_log_rtl.size_flags_vertical    = Control.SIZE_EXPAND_FILL
	_log_rtl.add_theme_color_override("default_color", COL_TEXT)
	_log_rtl.add_theme_font_size_override("normal_font_size", 11)
	lm.add_child(_log_rtl)

	vb.add_child(_vspace(8))
	vb.add_child(_btn_secondary("Clear Log", _on_clear_log))

# ══════════════════════════════════════════════════════════════════════════
# EVENT HANDLERS
# ══════════════════════════════════════════════════════════════════════════

func _on_event_pressed(event_name: String) -> void:
	adjust.track_event(event_name)
	_log("EVENT", event_name, COL_ACCENT)

func _on_custom_event_pressed() -> void:
	var ev := _custom_ev.text.strip_edges()
	if ev.is_empty():
		_log("ERROR", "Event name cannot be empty", COL_ERROR)
		return
	adjust.track_event(ev)
	_log("EVENT", ev, COL_ACCENT)

func _on_revenue_pressed() -> void:
	var event  := _rev_event.text.strip_edges()
	var amount := _rev_amount.text.strip_edges()
	var cur    := _rev_currency.get_item_text(_rev_currency.selected)
	if event.is_empty() or amount.is_empty():
		_log("ERROR", "Event name and amount are required", COL_ERROR)
		return
	adjust.track_revenue(event, amount.to_float(), cur)
	_log("REVENUE", "%s  %.4f %s" % [event, amount.to_float(), cur], COL_SUCCESS)

func _on_purchase_pressed() -> void:
	var order  := _order_id.text.strip_edges()
	var amount := _pur_amount.text.strip_edges()
	if order.is_empty() or amount.is_empty():
		_log("ERROR", "Order ID and amount are required", COL_ERROR)
		return
	adjust.track_purchase(order, amount, "USD", {})
	_log("PURCHASE", "order=%s  amount=%s USD" % [order, amount], COL_SUCCESS)

func _on_ad_revenue_pressed() -> void:
	var source  := _ad_source.get_item_text(_ad_source.selected)
	var revenue := _ad_revenue.text.strip_edges()
	if revenue.is_empty():
		_log("ERROR", "Revenue amount is required", COL_ERROR)
		return
	adjust.track_ad_revenue(source, revenue, "USD", {})
	_log("AD_REV", "%s  %s USD" % [source, revenue], COL_WARNING)

func _on_session_tag_pressed() -> void:
	var tag := _session_tag.text.strip_edges()
	if tag.is_empty():
		_log("ERROR", "Session tag cannot be empty", COL_ERROR)
		return
	adjust.set_session_tag(tag)
	_log("SESSION", "tag set: %s" % tag, COL_ACCENT)

func _on_clear_log() -> void:
	_log_rtl.clear()

# ══════════════════════════════════════════════════════════════════════════
# LOG HELPER
# ══════════════════════════════════════════════════════════════════════════

func _log(type: String, message: String, color: Color) -> void:
	var hex  := "#%02x%02x%02x" % [int(color.r * 255), int(color.g * 255), int(color.b * 255)]
	var time := Time.get_time_string_from_system()
	_log_rtl.append_text(
		"[color=%s][%-8s][/color] [color=#64748b]%s[/color]  %s\n" % [hex, type, time, message]
	)

# ══════════════════════════════════════════════════════════════════════════
# WIDGET FACTORIES
# ══════════════════════════════════════════════════════════════════════════

func _section(parent: VBoxContainer, title: String) -> VBoxContainer:
	var mc := _margin_c(MARGIN, 0, MARGIN, 0)
	parent.add_child(mc)

	var pc := PanelContainer.new()
	var s  := StyleBoxFlat.new()
	s.bg_color                   = COL_CARD
	s.corner_radius_top_left     = S_RADIUS
	s.corner_radius_top_right    = S_RADIUS
	s.corner_radius_bottom_left  = S_RADIUS
	s.corner_radius_bottom_right = S_RADIUS
	s.border_width_left   = 1
	s.border_width_right  = 1
	s.border_width_top    = 1
	s.border_width_bottom = 1
	s.border_color        = COL_BORDER
	pc.add_theme_stylebox_override("panel", s)
	mc.add_child(pc)

	var inner := _margin_c(S_PAD, S_PAD, S_PAD, S_PAD)
	pc.add_child(inner)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	inner.add_child(vb)

	vb.add_child(_lbl(title, COL_ACCENT, 11))

	var sep := HSeparator.new()
	var ds  := StyleBoxFlat.new()
	ds.bg_color             = COL_BORDER
	ds.content_margin_top    = 0
	ds.content_margin_bottom = 0
	sep.add_theme_stylebox_override("separator", ds)
	vb.add_child(sep)

	vb.add_child(_vspace(2))
	return vb

func _panel(color: Color, radius: int) -> PanelContainer:
	var pc := PanelContainer.new()
	var s  := StyleBoxFlat.new()
	s.bg_color                   = color
	s.corner_radius_top_left     = radius
	s.corner_radius_top_right    = radius
	s.corner_radius_bottom_left  = radius
	s.corner_radius_bottom_right = radius
	pc.add_theme_stylebox_override("panel", s)
	pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return pc

func _btn_primary(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size.y = BTN_H
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var n := _sbox_flat(COL_ACCENT, BTN_R)
	var h := _sbox_flat(COL_ACCENT_DK, BTN_R)
	btn.add_theme_stylebox_override("normal",  n)
	btn.add_theme_stylebox_override("hover",   h)
	btn.add_theme_stylebox_override("pressed", h)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(cb)
	return btn

func _btn_secondary(text: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size.y = BTN_H
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var n := _sbox_outline(COL_BORDER, Color.TRANSPARENT, BTN_R)
	var h := _sbox_outline(COL_ACCENT, Color(COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b, 0.15), BTN_R)
	btn.add_theme_stylebox_override("normal",  n)
	btn.add_theme_stylebox_override("hover",   h)
	btn.add_theme_stylebox_override("pressed", h)
	btn.add_theme_color_override("font_color", COL_TEXT)
	btn.add_theme_font_size_override("font_size", 13)
	btn.pressed.connect(cb)
	return btn

func _btn_accent(text: String, cb: Callable) -> Button:
	return _btn_primary(text, cb)

func _lineedit(placeholder: String) -> LineEdit:
	var le := LineEdit.new()
	le.placeholder_text      = placeholder
	le.custom_minimum_size.y = INPUT_H
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var n := _sbox_outline_padded(COL_BORDER, COL_INPUT, 6, 12)
	var f := _sbox_outline_padded(COL_ACCENT, COL_INPUT, 6, 12)
	le.add_theme_stylebox_override("normal", n)
	le.add_theme_stylebox_override("focus",  f)
	le.add_theme_color_override("font_color",             COL_TEXT)
	le.add_theme_color_override("font_placeholder_color", COL_SUBTEXT)
	le.add_theme_font_size_override("font_size", 13)
	return le

## Creates a Label. Parameter named `font_sz` to avoid shadowing Control.size.
func _lbl(text: String, color: Color, font_sz: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", font_sz)
	return l

func _option_currencies() -> OptionButton:
	var o := OptionButton.new()
	for c in ["USD", "EUR", "GBP", "JPY", "IDR", "SGD", "MYR", "THB"]:
		o.add_item(c)
	o.custom_minimum_size = Vector2(88, INPUT_H)
	_style_option(o)
	return o

func _style_option(o: OptionButton) -> void:
	var s := _sbox_outline(COL_BORDER, COL_INPUT, 6)
	o.add_theme_stylebox_override("normal", s)
	o.add_theme_color_override("font_color", COL_TEXT)
	o.add_theme_font_size_override("font_size", 13)

func _margin_c(l: int, t: int, r: int, b: int) -> MarginContainer:
	var mc := MarginContainer.new()
	mc.add_theme_constant_override("margin_left",   l)
	mc.add_theme_constant_override("margin_top",    t)
	mc.add_theme_constant_override("margin_right",  r)
	mc.add_theme_constant_override("margin_bottom", b)
	return mc

func _vspace(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = h
	return c

# ── StyleBox helpers ──────────────────────────────────────────────────────

func _sbox_flat(color: Color, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color                   = color
	s.corner_radius_top_left     = radius
	s.corner_radius_top_right    = radius
	s.corner_radius_bottom_left  = radius
	s.corner_radius_bottom_right = radius
	return s

func _sbox_outline(border: Color, bg: Color, radius: int) -> StyleBoxFlat:
	var s := _sbox_flat(bg, radius)
	s.border_width_left   = 1
	s.border_width_right  = 1
	s.border_width_top    = 1
	s.border_width_bottom = 1
	s.border_color        = border
	return s

func _sbox_outline_padded(border: Color, bg: Color, radius: int, pad_h: int) -> StyleBoxFlat:
	var s := _sbox_outline(border, bg, radius)
	s.content_margin_left  = pad_h
	s.content_margin_right = pad_h
	return s
