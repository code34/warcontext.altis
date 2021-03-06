	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2013-2018 Nicolas BOITEUX
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/

	private ["_body", "_dir", "_index", "_position", "_mark", "_group", "_units", "_view"];

	15203 cutText ["Loading...","BLACK FADED", 1000];
	//startLoadingScreen ["Loading Mission", _layer2];

	diag_log "Waiting BIS_fnc_init ...";
	waitUntil {BIS_fnc_init;};

	diag_log "Waiting Time over 0 ...";
	waitUntil {time > 0};

	diag_log "Waiting client read briefing ...";
	waitUntil {getClientState == "BRIEFING READ"};

	diag_log "Waiting player is alive ...";
	waitUntil {alive player && !(isNull player);};
	disableUserInput true;

	while { (getMarkerPos "globalbase") isEqualTo [0,0,0] } do { 
		sleep 0.1; 
	};

	//progressLoadingScreen 1;
	_position = ((getMarkerPos "globalbase") findEmptyPosition [10,100]);
	player setpos _position;

	WC_fnc_spawndialog 	= compilefinal preprocessFileLineNumbers "client\scripts\spawndialog.sqf";
	WC_fnc_paradrop	= compilefinal preprocessFileLineNumbers "client\scripts\paradrop.sqf";
	WC_fnc_keymapperup 	= compilefinal preprocessFileLineNumbers "client\scripts\WC_fnc_keymapperup.sqf";
	WC_fnc_keymapperdown = compilefinal preprocessFileLineNumbers "client\scripts\WC_fnc_keymapperdown.sqf";
	WC_fnc_introcam 	= compileFinal preprocessFileLineNumbers "client\scripts\intro_cam.sqf";
	WC_fnc_spawncam 	= compileFinal preprocessFileLineNumbers "client\scripts\spawn_cam.sqf";

	call compile preprocessFileLineNumbers "client\scripts\task.sqf";
	call compile preprocessFileLineNumbers "warcontext\scripts\paramsarray_parser.sqf";
	call compile preprocessFileLineNumbers "client\scripts\BME_clienthandler.sqf";
	call compile preprocessFileLineNumbers "client\objects\oo_bme.sqf";
	call compile preprocessFileLineNumbers "client\objects\oo_circularlist.sqf";
	call compile preprocessFileLineNumbers "client\objects\oo_marker.sqf";
	call compile preprocessFileLineNumbers "client\objects\oo_inventory.sqf";
	call compile preprocessFileLineNumbers "client\objects\oo_reloadplane.sqf";
	call compile preprocessFileLineNumbers "client\objects\oo_playersmarker.sqf";
	call compile preprocessFileLineNumbers "client\objects\oo_camera.sqf";
	call compile preprocessFileLineNumbers "warcontext\objects\oo_grid.sqf";
	call compile preprocessFileLineNumbers "warcontext\objects\oo_hashmap.sqf";

	client_bme = "new" call OO_BME;
	wcwithfriendsmarkers = true;
	wcearplugs = false;

	// Wait for server initialization
	private _result = false;
	while { _result isEqualTo false} do { 
		_result= ["remoteCall", ["serverIsReady", "" , 2, false, 2]] call client_bme;
		sleep 0.1;
	};
	
	15203 cutText ["","PLAIN", 0];
	disableUserInput false;
	[] call WC_fnc_introcam;
	
	_size = getNumber (configfile >> "CfgWorlds" >> worldName >> "mapSize");
	client_grid = ["new", [0,0, _size, _size,100,100]] call OO_GRID;
	
	playersmarkers = ["new", []] call OO_PLAYERSMARKER;
	"start" spawn playersmarkers;
	
	inventory = ["new", []] call OO_INVENTORY;
	["save", player] call inventory;

	[] execVM "real_weather\real_weather.sqf";

	setGroupIconsVisible [false,false];
	if(wcambiant == 2) then {
		enableEnvironment false;
		enableSentences false;
		player disableConversation true;
		enableRadio false;
		showSubtitles false;
		player setVariable ["BIS_noCoreConversations", true];
	};

	player addEventHandler ['Killed', {
		killer = (_this select 1);
	}];

	player addEventHandler ['HandleDamage', {
		if(side(_this select 3) in [east, resistance]) then {
			if(alive (_this select 0)) then {
				_damage = 1 - damage(_this select 0);
				(_this select 0) setdamage (damage(_this select 0) + random(_damage));
			};
		};
	}];

	playertype = "ammobox";
	[] spawn {
		private ["_action", "_script", "_oldplayertype", "_earplug"];
		_oldplayertype = playertype;

		while { true} do {
			if(_oldplayertype != playertype) then {
				_oldplayertype = playertype;
				if(!isnil "_action") then {
					player removeAction _action;
					_action = nil;
				};
			};
			if(vehicle player == player) then {
				if(isnil "_action") then {
					_action = player addAction [localize "STR_VEHICLESSERVICING_TITLE", "client\scripts\popvehicle.sqf", nil, 1.5, false];
				};
			} else {
				if(!isnil "_action") then {
					player removeAction _action;
					_action = nil;
				};
			};
			if(isnil "_earplug") then {
				_earplug = player addAction ["Add/Remove earplugs", "client\scripts\earplugs.sqf", nil, 1.5, false, true];	
			};
			if(!alive player) then {
				_action = nil; 
				_earplug = nil;
			};
			sleep 1;
		};
	};
	
	[] spawn {
		while { true } do {
			//if((damage player > 0) and (damage player  < 1.01)) then {
			//	player setDamage (damage player - 0.01); 
			//	player setBleedingRemaining 30;
			//};
			switch (true) do {
				case (damage player < 0.40) : {
					player setDamage (damage player - 0.01); 
					player setBleedingRemaining 30;
					sleep 0.5;
				};

				case (damage player < 0.60) : {
					player setDamage (damage player - 0.01); 
					player setBleedingRemaining 30;
					sleep 0.6;
				};

				case (damage player < 0.70) : {
					player setDamage (damage player - 0.01); 
					player setBleedingRemaining 30;
					sleep 0.7;
				};

				case (damage player < 0.80) : {
					player setDamage (damage player - 0.01); 
					player setBleedingRemaining 30;
					sleep 0.8;
				};			

				case (damage player < 1.01) : {
					player setDamage (damage player - 0.01); 
					player setBleedingRemaining 30;
					sleep 0.9;
				};			
			};

		};
	};

	[] spawn {
		sleep 5;
		findDisplay 46 displayAddEventHandler ["KeyDown", {_this call WC_fnc_keymapperdown;}];
		findDisplay 46 displayAddEventHandler ["KeyUp", {_this call WC_fnc_keymapperup;}];
	};

	_body = player;
	_view = cameraView;
	_mark = ["new", [position player, true]] call OO_MARKER;

	// set viewdistance
	[] spawn {
		while { true} do {
			if(vehicle player == player) then {
				setviewdistance wcviewdistance;
			} else {
				if(vehicle player isKindOf "Air") then {
					setviewdistance wcairvehicleviewdistance;
				} else {
					setviewdistance wcvehicleviewdistance;
				};
			};
			sleep 10;
		};
	};

		if(wcspeedcoeef == 1) then {
			player setAnimSpeedCoef 1.2;
		};
		
		// Should be here to be effective each respawn
		if(wcfatigue == 2) then { 
			player enableFatigue false; 
			player enableStamina false;
			player allowSprint true;
		} ;

		if(wcsway == 2) then { player setCustomAimCoef 0;};

		_index = player addEventHandler ["HandleDamage", {false}];

		["load", player] spawn inventory;	
		(position _body) call WC_fnc_spawndialog;
		 player switchCamera _view;

		// debug end	
		player removeEventHandler ["HandleDamage", _index];
		["attachTo", player] spawn _mark;
		["setText", name player] spawn _mark;
		["setColor", "ColorGreen"] spawn _mark;
		["setType", "mil_arrow2"] spawn _mark;
		["setSize", [0.5,0.5]] spawn _mark;