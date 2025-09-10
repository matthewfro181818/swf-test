function table.contains(t, v)
	for k,vv in pairs(t) do
		if v == vv then
			return true
		end
	end
end