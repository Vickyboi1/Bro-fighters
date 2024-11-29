extends CharacterBody2D
const BASESPEED = 3000.0
const BASEJUMP_VELOCITY = -2250.0
const GRAVITY =3000
var SPEED =  BASESPEED

var JUMP_VELOCITY = BASEJUMP_VELOCITY
var gravityon = true
@export_range(0.0, 1.0) var friction = 0.2

@export_range(0.0 , 1.0) var acceleration = 0.25
@onready var animation_tree : AnimationTree = $AnimationTree
@export var jumps = 2
var basejumps = jumps
var statuses = []

var needdirupdate = true
var basescale = self.scale

@export var player = 0
@export var playerneeded = 0
func ready():

	animation_tree.active = true
	statuses = []
	
func spriteanims():
	print(statuses)
	if !statuses.has("hitstun"):
		if abs(velocity.x) <= 150:
			animation_tree["parameters/conditions/IDLE"] = true
			animation_tree["parameters/conditions/MOVING"] = false
			animation_tree["parameters/conditions/JUMPING"] = false
			animation_tree["parameters/conditions/ATTACKING"] = false
		if !is_on_floor() :
			animation_tree["parameters/conditions/IDLE"] = false
			animation_tree["parameters/conditions/MOVING"] = false
			animation_tree["parameters/conditions/JUMPING"] = true
			animation_tree["parameters/conditions/GROUNDED"] = false
			animation_tree["parameters/conditions/ATTACKING"] = false
		elif abs(velocity.x) >= 200.0:
			animation_tree["parameters/conditions/IDLE"] = false
			animation_tree["parameters/conditions/MOVING"] = true
			animation_tree["parameters/conditions/JUMPING"] = false
			animation_tree["parameters/conditions/ATTACKING"] = false
		if is_on_floor():
			animation_tree["parameters/conditions/GROUNDED"] = true

		if Input.is_action_just_pressed("leftclick"):
			animation_tree["parameters/conditions/IDLE"] = false
			animation_tree["parameters/conditions/MOVING"] = false
			animation_tree["parameters/conditions/JUMPING"] = false
			animation_tree["parameters/conditions/ATTACKING"] = true

			
		
	if Input.is_action_just_pressed("something"):
		recieveknockback(Vector2(self.position.x + 200,self.position.y + 200) ,5000,1000)

	

func _physics_process(delta: float) -> void:
	if player == playerneeded:
		if gravityon:
			if velocity.y > 0:
				velocity.y += GRAVITY * delta * 3
			else:
				velocity.y += GRAVITY * delta 
		else:
			velocity.y = 0
		var dir = Input.get_axis("left", "right")
		var prevdir = dir
		if !statuses.has("immobile"):
			if dir != 0:
				velocity.x = lerp(velocity.x, dir * SPEED, acceleration)
			else:
				velocity.x = lerp(velocity.x,0.0,friction)
				
			if Input.is_action_pressed("right"):
				self.scale = basescale
				self.rotation_degrees = 0

			if Input.is_action_pressed("left"):
				self.scale = basescale
				self.scale.x = -basescale.x
				self.rotation_degrees = 0
		
		if Input.is_action_just_pressed("jump") and (jumps > 0 or !$coyotetime.is_stopped()): 
			if !velocity.y < 0:
				velocity.y = JUMP_VELOCITY
			elif jumps > 0:
				velocity.y = JUMP_VELOCITY / 2
				velocity.x *= 1.5
			$coyotetime.stop()
			jumps -= 1
		if Input.is_action_just_pressed("dash"):
			pass
		move_and_slide()

		
	#	Controls coyote time
		if is_on_floor():
			$coyotetime.start()
			for i in statuses:
				statuses.erase("hitstun")
			jumps = basejumps

func _process(delta: float) -> void:
	if player == playerneeded:
		spriteanims()
		handlestatuses()



func applyforce(y : Vector2):
	velocity += GF.applyforce(velocity,y)

func multiplyforce(y : Vector2):
	velocity *= y
func applystatus(status : String):
	statuses.append(status)

func clearstatus(status : String):
	statuses.erase(status)
func gravcontrol(grav : bool):
	gravityon = grav
	
func handlestatuses():
	if statuses.has("slow"):
		SPEED *= 0.5
	else:
		SPEED = BASESPEED

func recieveknockback(damagesourcepos, strengthx , strengthy):
	var knockbackdirection = damagesourcepos.direction_to(self.global_position)
	self.velocity = Vector2(strengthx,strengthy) * knockbackdirection
	jumps = 0
	statuses.append("hitstun")
	print(knockbackdirection)

#On attack hits, plays attack hit anims


func _on_attack_1_area_entered(area: Area2D) -> void:

	if !area.get_tree() == self.get_tree():
		$Otheranims.play("attack1hit")


func _on_hitbox_area_entered(area: Area2D) -> void:
	if !area.get_tree() == self.get_tree():
		print("njop")
