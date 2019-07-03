const OFFFINE_TIME_TEXT : String = "Nie byles w grze "
const REWARD_TEXT : String = "Otrzymales "
var offline_time_text_end : String


var time_to_end = 5.0

func offline_text(Offline_time):
	var time : float = Offline_time
	
	if time < 60:
		offline_time_text_end = " sekund"
	if time >= 60 and time < 3600:
		offline_time_text_end = " minut"
		time /= 60
	if time >= 3600:
		offline_time_text_end = " godzin"
		time /= 3600
		
	stepify(time,2)
	
	return String(OFFFINE_TIME_TEXT + String(time) + offline_time_text_end)

func reward_text(Offline_gold_reward, Offline_xp_reward):
	return String(REWARD_TEXT + String(Offline_gold_reward) + " golda i " + String(Offline_xp_reward) + " xp")