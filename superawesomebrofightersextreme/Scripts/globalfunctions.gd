extends Node
signal leftclickfinished

func applyforce(veloc,force):
	if veloc.x >= 0 :
		veloc += force
	else:
		veloc -= force


	return veloc


var statuses = ["immobile","slow","hitstun"]
