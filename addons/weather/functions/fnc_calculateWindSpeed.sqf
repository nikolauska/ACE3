/*
 * Author: Ruthberg
 *
 * Calculates the true wind speed at a given world position
 *
 * Arguments:
 * 0: world position - posASL <POSTION>
 * 1: Account for wind gradient <BOOL>
 * 2: Account for terrain <BOOL>
 * 3: Account for obstacles <BOOL>
 *
 * Return Value:
 * 0: wind speed - m/s <NUMBER>
 *
 * Public: No
 */
#include "script_component.hpp"

private ["_windSpeed", "_windDir", "_height", "_windSource", "_roughnessLength", "_fnc_polar2vect"];

params ["_position", "_windGradientEnabled", "_terrainEffectEnabled", "_obstacleEffectEnabled"];

_fnc_polar2vect = {
    private ["_mag2D"];
    params ["_mag", "_dir", "_elev"];
    _mag2D = _mag * cos(_elev);
    [_mag2D * sin(_dir), _mag2D * cos(_dir), _mag * sin(_elev)];
};

_windSpeed = vectorMagnitude ACE_wind;
_windDir = (ACE_wind select 0) atan2 (ACE_wind select 1);

if (_windSpeed > 0.05) then {

    // Wind gradient
    if (_windGradientEnabled) then {
        _height = (ASLToATL _position) select 2;
        _height = 0 max _height min 20;
        if (_height < 20) then {
            _roughnessLength = _position call FUNC(calculateRoughnessLength);
            _windSpeed = _windSpeed * abs(ln(_height / _roughnessLength) / ln(20 / _roughnessLength));
        };
    };

    // Terrain effect on wind
    if (_terrainEffectEnabled) then {
        {
            _windSource = [100, _windDir + 180, _x] call _fnc_polar2vect;
            if (!(terrainIntersectASL [_position, _position vectorAdd _windSource])) exitWith {
                _windSpeed = cos(_x * 9) * _windSpeed;
            };
            _windSource = [100, _windDir + 180 + _x, 0] call _fnc_polar2vect;
            if (!(terrainIntersectASL [_position, _position vectorAdd _windSource])) exitWith {
                _windSpeed = cos(_x * 9) * _windSpeed;
            };
            _windSource = [100, _windDir + 180 - _x, 0] call _fnc_polar2vect;
            if (!(terrainIntersectASL [_position, _position vectorAdd _windSource])) exitWith {
                _windSpeed = cos(_x * 9) * _windSpeed;
            };
            true;
        } count [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    };

    // Obstacle effect on wind
    if (_obstacleEffectEnabled) then {
        {
            _windSource = [20, _windDir + 180, _x] call _fnc_polar2vect;
            if (!(lineIntersects [_position, _position vectorAdd _windSource])) exitWith {
                _windSpeed = cos(_x * 2) * _windSpeed;
            };
            _windSource = [20, _windDir + 180 + _x, 0] call _fnc_polar2vect;
            if (!(lineIntersects [_position, _position vectorAdd _windSource])) exitWith {
                _windSpeed = cos(_x * 2) * _windSpeed;
            };
            _windSource = [20, _windDir + 180 - _x, 0] call _fnc_polar2vect;
            if (!(lineIntersects [_position, _position vectorAdd _windSource])) exitWith {
                _windSpeed = cos(_x * 2) * _windSpeed;
            };
            true;
        } count [0, 5, 10, 15, 20, 25, 30, 35, 40, 45];
    };
};

0 max _windSpeed
