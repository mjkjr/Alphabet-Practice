extends Node

const A = preload("res://assets/audio/letters/a.wav")
const B = preload("res://assets/audio/letters/b.wav")
const C = preload("res://assets/audio/letters/c.wav")
const D = preload("res://assets/audio/letters/d.wav")
const E = preload("res://assets/audio/letters/e.wav")
const F = preload("res://assets/audio/letters/f.wav")
const G = preload("res://assets/audio/letters/g.wav")
const H = preload("res://assets/audio/letters/h.wav")
const I = preload("res://assets/audio/letters/i.wav")
const J = preload("res://assets/audio/letters/j.wav")
const K = preload("res://assets/audio/letters/k.wav")
const L = preload("res://assets/audio/letters/l.wav")
const M = preload("res://assets/audio/letters/m.wav")
const N = preload("res://assets/audio/letters/n.wav")
const O = preload("res://assets/audio/letters/o.wav")
const P = preload("res://assets/audio/letters/p.wav")
const Q = preload("res://assets/audio/letters/q.wav")
const R = preload("res://assets/audio/letters/r.wav")
const S = preload("res://assets/audio/letters/s.wav")
const T = preload("res://assets/audio/letters/t.wav")
const U = preload("res://assets/audio/letters/u.wav")
const V = preload("res://assets/audio/letters/v.wav")
const W = preload("res://assets/audio/letters/w.wav")
const X = preload("res://assets/audio/letters/x.wav")
const Y = preload("res://assets/audio/letters/y.wav")
const Z = preload("res://assets/audio/letters/z.wav")
const letters: Array = [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]

const WHICH_ONE_IS = preload("res://assets/audio/which_one_is.wav")
const THATS_RIGHT = preload("res://assets/audio/thats_right.wav")
const OOPS_TRY_AGAIN = preload("res://assets/audio/oops_try_again.wav")

const FINGER_UP = preload("res://assets/finger/finger_up.png")
const FINGER_DOWN = preload("res://assets/finger/finger_down.png")

enum FingerState { UP, DOWN }

var finger_state: FingerState = FingerState.UP
var mouse_position: Vector2

var quiz_me: bool = false
var try_again: bool = false
var answer: int = -1
var given: int = -1


func _ready() -> void:
	$Bg/Version.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	if not OS.has_feature("mobile"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		var mouse_cursor = Sprite2D.new()
		mouse_cursor.texture = FINGER_UP
		mouse_cursor.name = "finger"
		add_child(mouse_cursor, true)


func _process(_delta: float) -> void:
	if not OS.has_feature("mobile"):
		mouse_position = get_viewport().get_mouse_position()
		$finger.global_position = Vector2(mouse_position.x + 16, mouse_position.y + 40)
		
		if Input.is_action_pressed("Tap"):
			if finger_state == FingerState.UP:
				finger_state = FingerState.DOWN
				$finger.texture = FINGER_DOWN
		else:
			if finger_state == FingerState.DOWN:
				finger_state = FingerState.UP
				$finger.texture = FINGER_UP


func _unhandled_key_input(event: InputEvent) -> void:
	var key = event.get_key_label() - 65
	if (
			key >= 0
			and key <= 25
	):
		_on_letter_pressed(key)
	else:
		if event.key_label == KEY_SPACE:
			_on_quiz_me_button_pressed()


func _on_letter_pressed(extra_arg_0: int) -> void:
	if not $Audio/Quiz.playing:
		$Audio/Letters.stream = letters[extra_arg_0]
		$Audio/Letters.play()
		if quiz_me:
			given = extra_arg_0


func _on_quiz_me_button_pressed() -> void:
	if $Audio/Letters.playing:
		$Audio/Letters.stop()
	quiz_me = true
	$Audio/Quiz.stream = WHICH_ONE_IS
	$Audio/Quiz.play()
	get_tree().set_group("buttons", "disabled", true)


func _on_quiz_finished() -> void:
	if quiz_me:
		if try_again:
			if $Audio/Quiz.stream == OOPS_TRY_AGAIN:
				$Audio/Quiz.stream = WHICH_ONE_IS
				$Audio/Quiz.play()
				get_tree().set_group("buttons", "disabled", true)
			elif $Audio/Quiz.stream == WHICH_ONE_IS: 
				$Audio/Quiz.stream = letters[answer]
				$Audio/Quiz.play()
				get_tree().set_group("buttons", "disabled", true)
			else:
				get_tree().set_group("buttons", "disabled", false)
		else:
			if $Audio/Quiz.stream == WHICH_ONE_IS:
				answer = randi_range(0, 25)
				$Audio/Quiz.stream = letters[answer]
				$Audio/Quiz.play()
				get_tree().set_group("buttons", "disabled", true)
			else:
				get_tree().set_group("buttons", "disabled", false)


func _on_letters_finished() -> void:
	if quiz_me:
		if (
				answer != -1
				and given != -1
				and answer == given
		):
			$Audio/Quiz.stream = THATS_RIGHT
			$Audio/Quiz.play()
			answer = -1
			given = -1
			quiz_me = false
			try_again = false
		else:
			try_again = true
			$Audio/Quiz.stream = OOPS_TRY_AGAIN
			$Audio/Quiz.play()
			get_tree().set_group("buttons", "disabled", true)
