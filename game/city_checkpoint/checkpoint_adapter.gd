extends RefCounted
## In-memory adapter seam only. No disk/browser save or restore claim.
## Replace with accepted ARCH-002 transaction/validation interface before Review.
var last_snapshot: Dictionary = {}
func capture(state: Dictionary) -> void:
	last_snapshot = state.duplicate(true)
