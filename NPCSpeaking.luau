-- very basic and simple npc auto chat thingie
local head = script.Parent

local randomChats = {
	"i sure do hope i get picked and get eaten!",
	"you've got to listen to me.. there's a truth.. a very improtant truth... you need to g- nvm almost formulated a thought there",
	"IM A SENTIENT BURGER BABY!",
	"buy our stuff pls we need the robux",
	"do you ever wonder what is beyond our cosmos? beyond the ever growing infinitely large universe? i don't",
	"i want to grow legs and run a marathon :(",
	"do i feel pain? nah",
	"this game has cool and funny easter eggs, make sure u find them, gl",
	"i never truly understood why there are letters in math, c'mon bro |a×b = ab| & |2a×b = 2ab|?? this has to be a practical joke.. right?",
	"want a chewed piece of gum? check under this spot, and yes, I'm giving it for free :)",
	"what does the term 'oil it up' mean??",
	"I'm still amazed by it",
	"bacontoast? more like.. bakingoats! bazinga!!",
	"'developing is hard 💔💔💔' - said by some bad developer",
	"did you can explain this?",
	"erm what the actual flip is going on here???",
	"i put that gum under the shelf :)",
	"HELP THEY WANT IT THEY ARE AQUIRING OPWOER HELP PLS DONT LET TH",
	"what if you could hear colour and taste rainbows? wouldn't that be cool",
	"there is a spinning jerma easter egg somewhere around the map 😱😱"
}

while task.wait(math.random(60, 300)) do
	local Last
	local Message = randomChats[math.random(1, #randomChats)]
	if Message ~= Last then
		game:GetService("Chat"):Chat(head, Message, "White")
		Last = Message
	end
end
