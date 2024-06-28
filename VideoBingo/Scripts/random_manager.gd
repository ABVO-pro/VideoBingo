class_name RandomManager
##This class stores functions to help with number generation in the game.

##This function generates a random number within the specified range. The maximum value of the range must be higher than the minimum value.
##[br]
##[br][param range_min]: the minimum value of the range (inclusive).
##[br][param range_max]: the maximum value of the range (inclusive).
static func generate_random_number_in_range(range_min:int, range_max:int) -> int:
	assert(range_min < range_max, "The provided minimum value in the range must be lower than the maximum value. Provided values: min: %s, max: %s" % [range_min, range_max])
	
	return randi_range(range_min, range_max)

##This function generates the provided amount of random numbers within the specified range. The maximum value of the range must be higher than the minimum value.
##[br]
##[br][param range_min]: the minimum value of the range (inclusive).
##[br][param range_max]: the maximum value of the range (inclusive).
##[br][param amount_of_numbers]: the amount of numbers to generate (must be at least 1).
##[br][param allow_duplicars]: determines wether the random numbers generated can contain duplicate values
static func generate_x_random_numbers_in_range(range_min:int, range_max:int, amount_of_numbers: int, allow_duplicates: bool = false) -> Array[int]:
	assert(amount_of_numbers > 0, "The provided amount of numbers to generate must be at least 1. Provided value: %s" % [amount_of_numbers])
	
	var generated_numbers: Array[int] = []
	
	if (allow_duplicates):
		for i in amount_of_numbers:
			generated_numbers.append(generate_random_number_in_range(range_min, range_max))
	else:
		var balls_in_range: Array[int] = []
		for i in range(range_min, range_max + 1):
			balls_in_range.append(i)
			
		assert(balls_in_range.size() >= amount_of_numbers, "Can't generate more numbers (%s) in the selected range (%s, %s) without duplicates than there are values in that same range." % [amount_of_numbers, range_min, range_max])
		
		balls_in_range.shuffle()
		generated_numbers = balls_in_range.slice(0,amount_of_numbers)
	
	
	return generated_numbers
