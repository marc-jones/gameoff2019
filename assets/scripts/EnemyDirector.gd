extends Node2D

var gnat_idle_offset_distance = 120
var gnat_attack_offset_distance = 30

var attack_angle_vector = Vector2(1, 0)
var idle_start_angle_vector = Vector2(0, -1)

var gnat_difficulty_log_scale = 1.5

const GnatTemplate = preload("res://assets/scenes/Gnat.tscn")
const MothTemplate = preload("res://assets/scenes/Moth.tscn")

var margin_h = 40
var margin_v = 80
var min_enemy_spacing = 60

func _init():
	pass

func get_enemy_vector(current_level):
	# Curve equations
	var number_of_gnats = floor(log(current_level+1) / log(gnat_difficulty_log_scale))
	var number_of_moths = min(floor(current_level / 4), 4)
	# Curve equations end
	var enemy_vector = []
	var viewport_dims = get_viewport_rect().size
	var max_enemies_per_row = floor((viewport_dims.x - (2*margin_h)) / min_enemy_spacing) + 1
	var enemy_spacing = int((viewport_dims.x - (2*margin_h)) / (max_enemies_per_row - 1))
	var current_row = 0
	var current_col = 0
	for idx in range(number_of_moths):
		var starting_x_pos = margin_h
		var remaining_enemies = number_of_moths - (current_row*max_enemies_per_row)
		if remaining_enemies < max_enemies_per_row:
			starting_x_pos = (viewport_dims.x - enemy_spacing*(remaining_enemies-1))/2
		var moth = MothTemplate.instance()
		moth.position.x = starting_x_pos + (current_col*enemy_spacing)
		moth.position.y = margin_v + (current_row*enemy_spacing)
		enemy_vector.append(moth)
		current_col += 1
		if (max_enemies_per_row - 1) < current_col:
			current_col = 0
			current_row += 1
	current_row += 1
	current_col = 0
	var offset_positions = return_gnat_offset_positions(number_of_gnats)
	for idx in range(number_of_gnats):
		var starting_x_pos = margin_h
		var enemies_on_this_row = number_of_gnats
		if max_enemies_per_row < number_of_gnats:
			enemies_on_this_row = number_of_gnats - (
				(current_row - ceil(number_of_moths/max_enemies_per_row))*max_enemies_per_row)
		print(enemies_on_this_row)
		if enemies_on_this_row < max_enemies_per_row:
			starting_x_pos = (viewport_dims.x - enemy_spacing*(enemies_on_this_row-1))/2
		var gnat = GnatTemplate.instance()
		var offset = offset_positions[idx]
		gnat.set_target_offset(offset)
		gnat.position.x = starting_x_pos + (current_col*enemy_spacing)
		gnat.position.y = margin_v + (current_row*enemy_spacing)
		enemy_vector.append(gnat)
		current_col += 1
		if (max_enemies_per_row - 1) < current_col:
			current_col = 0
			current_row += 1
	return(enemy_vector)

func return_gnat_offset_positions(enemy_number):
	var position_vector = []
	# Add the attack positions
	for rotation_offset in [0, PI]:
		position_vector.append(attack_angle_vector.rotated(
			rotation_offset)*gnat_attack_offset_distance)
	# Add the idle positions
	if enemy_number - 2 > 0:
		var idle_offset_positions = return_gnat_idle_offset_positions(enemy_number - 2)
		for idx in range(enemy_number - 2):
			position_vector.append(idle_offset_positions[idx]*gnat_idle_offset_distance)
	return(position_vector)

func return_gnat_idle_offset_positions(idle_number):
	var return_vector = []
	for idx in range(idle_number):
		var vector_to_add = idle_start_angle_vector.rotated(
			(2*idx*PI)/idle_number)
		return_vector.append(vector_to_add)
	if return_vector.has(Vector2(1, 0)):
		for idx in range(idle_number):
			return_vector[idx] = return_vector[idx].rotated(PI/4)
	return(return_vector)

func update_gnat_offset_positions(enemy_array):
	var new_offsets = return_gnat_offset_positions(enemy_array.size())
	var cost_matrix = []
	for enemy_idx in range(enemy_array.size()):
		cost_matrix.append([])
		for offset in new_offsets:
			cost_matrix[enemy_idx].append(enemy_array[enemy_idx].position.distance_to(
				enemy_array[enemy_idx].target - enemy_array[enemy_idx].target_offset + offset))
	var assignments = hungarian_algorithm(cost_matrix)
	for key in assignments:
		enemy_array[key].set_target_offset(new_offsets[assignments[key]])

func hungarian_algorithm(cost_matrix):
	if cost_matrix.size() == 1:
		return({0: cost_matrix[0].find(cost_matrix[0].min())})
	var modified_cost_matrix = hungarian_step1_and_step2(cost_matrix)
	var line_rows_and_cols = hungarian_step3(modified_cost_matrix)
	while (not line_rows_and_cols[0].size() + line_rows_and_cols[1].size() == cost_matrix.size()):
		modified_cost_matrix = hungarian_step4(modified_cost_matrix, line_rows_and_cols)
		line_rows_and_cols = hungarian_step3(modified_cost_matrix)
	var assignments = get_possible_assignments(modified_cost_matrix)
	return(assignments[1])

func get_possible_assignments(cost_matrix):
	var row_to_col_assignments = {}
	var col_to_row_assignments = {}
	var iters = 0
	while (not row_to_col_assignments.size() == cost_matrix.size()) and iters < 3:
		iters += 1
		for row_idx in range(cost_matrix.size()):
			if not row_to_col_assignments.has(row_idx):
				var zero_idicies = []
				for col_idx in range(cost_matrix[row_idx].size()):
					if cost_matrix[row_idx][col_idx] == 0:
						if not col_to_row_assignments.has(col_idx):
							zero_idicies.append(col_idx)
				if zero_idicies.size() == 1 or (zero_idicies.size() > 1 and iters > 1):
					row_to_col_assignments[row_idx] = zero_idicies[0]
					col_to_row_assignments[zero_idicies[0]] = row_idx
					iters = 0
	return([row_to_col_assignments, col_to_row_assignments])

func hungarian_step1_and_step2(cost_matrix):
	var modified_cost_matrix = []
	for row in cost_matrix:
		modified_cost_matrix.append(remove_min_from_array(row))
	for col_idx in range(cost_matrix[0].size()):
		var column_array = return_column(col_idx, modified_cost_matrix)
		modified_cost_matrix = replace_column(col_idx,
			modified_cost_matrix, remove_min_from_array(column_array))
	return(modified_cost_matrix)

func hungarian_step3(cost_matrix):
	var assignments = get_possible_assignments(cost_matrix)
	var row_to_col_assignments = assignments[0]
	var col_to_row_assignments = assignments[1]
	var marked_rows = []
	for row_idx in range(cost_matrix.size()):
		if not row_to_col_assignments.has(row_idx):
			marked_rows.append(row_idx)
	var marked_cols = []
	var prev_marked_row_size = null
	var prev_marked_col_size = null
	while ((not prev_marked_row_size == marked_rows.size()) and 
		(not prev_marked_col_size == marked_cols.size())):
		prev_marked_row_size = marked_rows.size()
		prev_marked_col_size = marked_cols.size()
		for row_idx in marked_rows:
			for col_idx in range(cost_matrix[row_idx].size()):
				if cost_matrix[row_idx][col_idx] == 0 and not marked_cols.has(col_idx):
					marked_cols.append(col_idx)
		for col_idx in marked_cols:
			if col_to_row_assignments.has(col_idx) and not marked_rows.has(col_to_row_assignments[col_idx]):
				marked_rows.append(col_to_row_assignments[col_idx])
	var unmarked_rows = []
	for row_idx in range(cost_matrix.size()):
		if not marked_rows.has(row_idx):
			unmarked_rows.append(row_idx)
	return([ unmarked_rows, marked_cols])

func hungarian_step4(cost_matrix, line_row_and_col):
	var line_rows = line_row_and_col[0]
	var line_cols = line_row_and_col[1]
	var min_val = null
	for row_idx in range(cost_matrix.size()):
		if not line_rows.has(row_idx):
			for col_idx in range(cost_matrix[row_idx].size()):
				if not line_cols.has(col_idx):
					if min_val == null:
						min_val = cost_matrix[row_idx][col_idx]
					else:
						min_val = min(min_val, cost_matrix[row_idx][col_idx])
	var return_matrix = []
	for row_idx in range(cost_matrix.size()):
		return_matrix.append([])
		for col_idx in range(cost_matrix[row_idx].size()):
			return_matrix[row_idx].append(cost_matrix[row_idx][col_idx])
			if line_rows.has(row_idx) and line_cols.has(col_idx):
				return_matrix[row_idx][col_idx] += min_val
			if (not line_rows.has(row_idx)) and (not line_cols.has(col_idx)):
				return_matrix[row_idx][col_idx] -= min_val
	return(return_matrix)

func remove_min_from_array(input_array):
	var return_array = []
	var min_value = input_array.min()
	for value in input_array:
		return_array.append(value - min_value)
	return(return_array)

func return_column(idx, input_matrix):
	var return_array = []
	for row in input_matrix:
		return_array.append(row[idx])
	return(return_array)

func remove_column(idx, input_matrix):
	var return_matrix = []
	for row in input_matrix:
		var row_duplicate = [] + row
		row_duplicate.remove(idx)
		return_matrix.append(row_duplicate)
	return(return_matrix)

func replace_column(idx, input_matrix, replacement_array):
	var return_matrix = []
	for row_idx in range(input_matrix.size()):
		var row_duplicate = [] + input_matrix[row_idx]
		row_duplicate[idx] = replacement_array[row_idx]
		return_matrix.append(row_duplicate)
	return(return_matrix)

		
		
		
		
		
		
		
		
		
		
		
		