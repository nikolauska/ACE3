/*
 * Author: Ruthberg
 *
 * Calculates the speed of sound for a given temperature
 *
 * Arguments:
 * temperature - degrees celcius <NUMBER>
 *
 * Return Value:
 * speed of sound - m/s <NUMBER>
 *
 * Return value:
 * None
 */
#include "script_component.hpp"

params ["_temperature"];

(331.3 + (0.6 * _temperature))
