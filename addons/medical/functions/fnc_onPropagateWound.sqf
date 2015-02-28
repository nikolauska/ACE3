/*
 * Author: Glowbal
 * Adds a new injury to the wounds collection from remote clients. Is used to split up the large collection of injuries broadcasting across network.
 *
 * Arguments:
 * 0: The remote unit <OBJECT>
 * 1: injury <ARRAY>
 *
 * Return Value:
 * None <NIL>
 *
 * Public: No
 */

#include "script_component.hpp"

private ["_unit", "_injury", "_openWounds", "_injuryID", "_exists"];
_unit = _this select 0;
_injury = _this select 1;

if (!local _unit) then {
	_openWounds = _unit getvariable[QGVAR(openWounds), []];
	_injuryID = _injury select 0;

	_exists = false;
	{
		if (_x select 0 == _injuryID) exitwith {
			_exists = true;
			_openWounds set [_foreachIndex, _injury];
		};
	}foreach _openWounds;

	if (!_exists) then {
		_openWounds pushback _injury;
	};
	_unit setvariable [GVAR(openWounds), _openWounds];
};
