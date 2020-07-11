extends Node2D

# Shows a particle explosion, then dies.

# Elapsed time.
var elapsed = 0.0

# Duration before killing itself.
const duration = 2.0

var emitted = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !emitted:
		get_node("CPUParticles2D").set_emitting(true)
		emitted = true
	
	elapsed += delta
	if (elapsed > duration):
		queue_free()
