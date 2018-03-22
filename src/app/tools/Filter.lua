local Filter = {}

local words = nil

function Filter.input(str)
	if not words then
		words = require("app.hall.config.filterwords");
	end
	for i,v in ipairs(words) do
		str = str:gsub(v,"***");
	end

	return str;
end


return Filter