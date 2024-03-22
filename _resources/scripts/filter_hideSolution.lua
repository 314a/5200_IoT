-- Div mit "solution" werden nicht dargestellt

--Text mit folgendem Inhalt ersetzen
--local solutionText = 'Solution: Don\'t ask the professor'

function Div(el)
	if (el.classes[1] == "solution") then
		--local e = pandoc.Div(pandoc.Plain(solutionText))
		--e.attributes['custom-style'] = 'Solution'
		--return e
		return pandoc.Str('') -- return empty String
	end
end
--return {{Meta = showSolution}, {Div = hideSolutionDiv}}

