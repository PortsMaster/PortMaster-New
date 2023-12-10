
LangChanger = {}

LangChanger.langChangeProcs = {}

function LangChanger.LoadLanguage()
	--Log("LoadLanguage() ", CONFIG.language)
	dofile("config/languages/"..CONFIG.language..".lua")
	
	for k,v in pairs(LangChanger.langChangeProcs) do
		v:onLangChange()
	end
end

function LangChanger.Register(who)
	--Log("LangChanger.Register ", who)
	if not who then 
		Log(debug.traceback())
	end
	if who.onLangChange and type(who.onLangChange) == "function" then
		LangChanger.langChangeProcs[who] = who
	end
end

function LangChanger.Unregister(who)
	--Log("LangChanger.Unregister ", who)
	LangChanger.langChangeProcs[who] = nil
end

