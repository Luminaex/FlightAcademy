params [["_action", {}]];

private _fadeDuration = 0.6;
private _holdDuration = 0.3;

// Fade to black
cutText ["", "BLACK OUT", _fadeDuration];
private _sleepDuration = _fadeDuration + _holdDuration;
sleep _sleepDuration;

// Execute the action while screen is black
call _action;

// Fade back in
cutText ["", "BLACK IN", _fadeDuration];
