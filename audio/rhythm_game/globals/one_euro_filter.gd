# Copyright (c) 2023 Patryk Kalinowski (patrykkalinowski.com)
# SPDX-License-Identifier: MIT

## Implementation of the 1€ filter (https://gery.casiez.net/1euro/).[br]
## Modification of https://github.com/patrykkalinowski/godot-xr-kit/blob/master/addons/xr-kit/smooth-input-filter/scripts/one_euro_filter.gd
class_name OneEuroFilter

var min_cutoff: float
var beta: float
var d_cutoff: float
var x_filter: LowPassFilter
var dx_filter: LowPassFilter

func _init(args: Variant) -> void:
	min_cutoff = args.cutoff
	beta = args.beta
	d_cutoff = args.cutoff
	x_filter = LowPassFilter.new()
	dx_filter = LowPassFilter.new()

func alpha(rate: float, cutoff: float) -> float:
	var tau: float = 1.0 / (2 * PI * cutoff)
	var te: float = 1.0 / rate

	return 1.0 / (1.0 + tau/te)

func filter(value: float, delta: float) -> float:
	var rate: float = 1.0 / delta
	var dx: float = (value - x_filter.last_value) * rate

	var edx: float = dx_filter.filter(dx, alpha(rate, d_cutoff))
	var cutoff: float = min_cutoff + beta * abs(edx)
	return x_filter.filter(value, alpha(rate, cutoff))

class LowPassFilter:
	var last_value: float

	func _init() -> void:
		last_value = 0

	func filter(value: float, alpha: float) -> float:
		var result := alpha * value + (1 - alpha) * last_value
		last_value = result

		return result
