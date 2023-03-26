extends Label

var playerData;

func _ready():
	playerData = get_node("/root/PlayerData");
	self.text = (str(playerData.health));
	
func updateHp(hp):
	self.text = (str(playerData.health));
