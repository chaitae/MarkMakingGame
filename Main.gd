extends Node2D

var drawing = false
var trail_points = []
var target_start = Vector2()
var target_end = Vector2()
var target_length = 0
var accuracy = 0.0
var font : Font
var label_node

func _ready():
	generate_target_line()
	set_process(true)
	var font = load("res://LEMONMILK-Regular.otf")
	label_node = get_node("Label")



func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				trail_points.clear()
				trail_points.append(event.position)
				drawing = true
			else:
				drawing = false
				accuracy = calculate_accuracy()
				print(trail_points.size())
				if accuracy >= 85:
					generate_target_line()
	elif event is InputEventMouseMotion and drawing:
		trail_points.append(event.position)

func _process(delta):
	queue_redraw()

func _draw():
	draw_line(target_start, target_end, Color.RED, 2)
	if trail_points.size() > 1:
		for i in range(trail_points.size() - 1):
			draw_line(trail_points[i], trail_points[i + 1], Color.BLACK, 3)

	label_node.text = str(round(accuracy))
#	draw_string(font, Vector2(50, 50), "Accuracy: " + str(round(accuracy)) + "%",HORIZONTAL_ALIGNMENT_LEFT)


func generate_target_line():
	var center_x = get_viewport().size.x / 2
	var center_y = get_viewport().size.y / 2
	var angle = randf() * TAU
	var length = 200 + randf() * 60  # Vary length between 200 and 260
	target_length = length
	target_start = Vector2(center_x + length * cos(angle), center_y + length * sin(angle))
	target_end = Vector2(center_x - length * cos(angle), center_y - length * sin(angle))

func calculate_accuracy():
	if trail_points.size() < 2:
		return 0.0
	
	var total_distance = 0.0
	for point in trail_points:
		total_distance += point.distance_to(closest_point_on_line(point, target_start, target_end))
	
	var threshold_distance = 20;
		# Check first point
	var first_point = trail_points[0]
	if first_point.distance_to(target_start) >= threshold_distance and first_point.distance_to(target_end) >= threshold_distance:
		return 0.0

	# Check last point
	var last_point = trail_points[trail_points.size() - 1]
	if last_point.distance_to(target_start) >= threshold_distance and last_point.distance_to(target_end) >= threshold_distance:
		return 0.0
	var avg_distance = total_distance / trail_points.size()
# Apply a penalty factor to make assessment harsher
	var penalty_factor = 2.0
	var harsh_avg_distance = avg_distance * penalty_factor
	var max_distance = 50.0  # Example maximum distance

	
	var accuracy_percentage = (1.0 - harsh_avg_distance / max_distance) * 100.0
	return accuracy_percentage;
	
	#var distance_penalty = avg_distance * 3  # Adjust this to make the accuracy calculation less harsh
	#var length_penalty = abs(target_length - trail_points.size()) * 1  # Adjust this as needed
	#return max(0, 100 - distance_penalty - length_penalty)

func closest_point_on_line(point, line_start, line_end):
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_len = line_vec.length()
	var line_unitvec = line_vec / line_len
	var projection = point_vec.dot(line_unitvec)
	if projection < 0:
		return line_start
	elif projection > line_len:
		return line_end
	else:
		return line_start + line_unitvec * projection
