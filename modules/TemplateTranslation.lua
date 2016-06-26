local names = {'Infobox Slovenská obec', 'V jazyku'} -- list of support templates

local p = {}

function defaultize(args, ilist) -- set default values for output parameters
	local newargs = {}
	for _, v in ipairs(ilist) do
		if type(v) == 'table' and v[1] then
			if args[v[1]] then newargs[v[1]] = tostring(args[v[1]]) end
		else
			newargs[v] = tostring(args[v] or '')
		end
	end
	return newargs
end

function serialize(template, args, olist, options) -- convert array of output parameters to string representation
	local separator = '\n'
	if options.linear then separator = '' end
	local lastimplicitnumber
	if options.implicitnumbers then lastimplicitnumber = 0 end
	local out = '{{' .. template .. separator
	local argintro, itemintro
    if options.linear then argintro = '' end -- merely by convention and for convenience
	for _, u in ipairs(olist) do
		local v
		if type(u) == 'table' and u[1] then
			if args[u[1]] and args[u[1]] ~= '' then v = u[1] else v = nil end
		else
			v = u
		end
		if v and args[v] then
			if argintro ~= '' then itemintro = ' |' else itemintro = '|' end -- we check previous arg's whitespace and follow suit
			if options.implicitnumbers and type(v) == 'number' and v == lastimplicitnumber+1 then
				argintro = ''
				lastimplicitnumber = v
			else
				argintro = ' ' .. v .. ' = '
			end
			out = out .. itemintro .. argintro .. args[v]
			if argintro ~= '' then out = out .. separator end
		end
	end
	out = out .. '}}'
	return out
end

function call(frame, name) -- does the actual transformation by using the respective submodule
	local submodule = require ('Module:TemplateTranslation/' .. _G.language .. '/' .. name)
	local template, args, result = name, {}, nil
	if submodule then
		args = defaultize(frame.args, submodule.ikeys or {})
		if submodule['transform'] then result = submodule['transform'](frame, args) else result = nil end
	end
	if result then
		template = result[1] or template
		args = result[2] or args
	end
	return serialize(template, args, submodule.okeys or {}, submodule.options or {})
end

local name
for _, name in ipairs(names) do -- create an associative array of lambda functions, corresponding to one supported template each
	p[name] = function(frame)
		return call(frame, name)
	end
end

return p
