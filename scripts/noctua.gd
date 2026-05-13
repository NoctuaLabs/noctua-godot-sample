extends Node

var _noctua = null

func _ready() -> void:
	if Engine.has_singleton("GodotNoctua"):
		_noctua = Engine.get_singleton("GodotNoctua")
	else:
		push_warning("Noctua plugin not found! Running without native SDK.")
	if ProjectSettings.has_setting("Noctua/AppToken"):
		var token: String = ProjectSettings.get_setting("Noctua/AppToken")
		if not token.is_empty():
			init(token, not OS.is_debug_build())
	else:
		push_warning("Noctua/AppToken not configured. Call adjust.init() manually.")

# --- Core ---

func init(token: String, production := false) -> void:
	if _noctua != null:
		_noctua.init(token, production)
		print("Noctua SDK initialized (production=%s)" % str(production))

# --- Event Tracking ---

func track_event(event: String) -> void:
	if _noctua != null:
		_noctua.trackEvent(event)

func track_event_with_params(event: String, params: Dictionary) -> void:
	if _noctua != null:
		_noctua.track_event(event, params)

# --- Revenue Tracking ---

func track_revenue(event: String, revenue: float, currency := "USD") -> void:
	if _noctua != null:
		_noctua.trackRevenue(event, revenue, currency)

func track_purchase(order_id: String, amount: String, currency: String, payload: Dictionary) -> void:
	if _noctua != null:
		_noctua.track_purchase(order_id, amount, currency, payload)

func track_ad_revenue(ad_source: String, revenue: String, currency: String, params: Dictionary) -> void:
	if _noctua != null:
		_noctua.track_ad_revenue(ad_source, revenue, currency, params)

func track_custom_event_with_revenue(event_name: String, revenue: String, currency: String, payload: Dictionary) -> void:
	if _noctua != null:
		_noctua.track_custom_event_with_revenue(event_name, revenue, currency, payload)

# --- Session ---

func set_session_tag(session_name: String) -> void:
	if _noctua != null:
		_noctua.set_session_tag(session_name)
