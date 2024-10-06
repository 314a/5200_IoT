-- Stile anwenden auf Latex und docx bei Div elementen
-- https://jmablog.com/post/pandoc-filters/
-- Da die Lua Filter in einer definierten Reihenfolge abgearbeitet werden
-- muss im return statement die Reihenfolge gesetzt werden
-- siehe: https://pandoc.org/lua-filters.html Replacing placeholders with their metadata value

-- Word Style im Word template definieren

-- Stile für die Boxen in Latex tcolorbox definieren 
-- https://tex.stackexchange.com/questions/443755/how-to-customize-color-in-tcolorbox-having-counter
-- Stick Notes mit TIKZ picture https://tex.stackexchange.com/questions/159679/sticky-notes-image, https://tex.stackexchange.com/questions/22873/tikzpicture-with-overlay-takes-up-space
local latexDefinitions = [[
%\@ifpackageloaded{igeo}{}{
%	\usepackage[]{igeo}%check if option can be reset
%}
\definecolor{colShade}{HTML}{DCE6EB}% shade color - usually light grey 
\definecolor{colPrimary}{HTML}{227FA6} 
\definecolor{colSecondary}{HTML}{6E986A}      
\definecolor{colTertiary}{HTML}{CE8243}  
]] 

-- erweitert die header-includes um die tcolorbox style definitionen für latex
-- unklar warum der Ansatz der Funktion add_header_includes in first-line-indent.lua
-- nicht funktioniert.
-- https://github.com/pandoc/lua-filters/blob/master/first-line-indent/first-line-indent.lua
function headerIncludeOld(meta) -- pandoc 2.14.2
	if meta['header-includes'] then
		if meta['header-includes'].t == 'MetaList' then
			-- print("extend") -- yaml enthält header-includes
			table.insert(meta['header-includes'],pandoc.MetaBlocks(pandoc.RawBlock('latex', latexDefinitions)))
		else
			-- print("insert") -- yaml enthält keine header-includes
			table.insert(meta['header-includes'],pandoc.MetaBlocks(pandoc.RawBlock('latex', latexDefinitions)))
		end
	end
	return meta	
end
-- https://github.com/pandoc/lua-filters/blob/master/first-line-indent/first-line-indent.lua
-- https://github.com/pandoc/lua-filters/blob/master/track-changes/track-changes.lua
-- https://github.com/pandoc/lua-filters/blob/master/table-short-captions 
function headerInclude(meta) -- pandoc 2.17.1 doesn't work
	-- print('type of metavalue `author`:', pandoc.utils.type(meta.author))
	-- print('lua type',type(meta['header-includes']),'utils type',pandoc.utils.type(meta['header-includes']))
	-- add any exisiting meta['header-includes'] it could be a MetaList or a single String
	-- TODO  check if it works with a String
	if meta['header-includes'] then
		if pandoc.utils.type(meta['header-includes']) == 'List' then
			-- print("extend List")  -- yaml enthält header-includes
			-- old version 
			-- table.insert(meta['header-includes'],pandoc.MetaBlocks(pandoc.RawBlock('latex', latexDefinitions)))
			
			-- include first the latex definitions and then the definitions of the header includes, 
			-- such that color settings and the like can be overwritten in the yaml files 
			header_includes = pandoc.MetaList{}
			header_includes[#header_includes + 1] = pandoc.MetaBlocks{pandoc.RawBlock('latex', latexDefinitions)}
			header_includes[#header_includes + 1] = meta['header-includes']
			meta['header-includes'] = header_includes
		else
			-- print("create list") -- yaml enthält keine header-includes
			--header_includes:insert(meta['header-includes'])
			-- Creates a new MetaBlocks element, but further elements included by pandoc-crossref are being ignored.
			--meta['header-includes'] = pandoc.MetaBlocks(pandoc.RawBlock('latex', latexDefinitions))
			-- Hence the following ensures that further List Elements by pandoc-crossref are included
			header_includes = pandoc.MetaList{meta['header-includes']}
			header_includes[#header_includes + 1] = pandoc.MetaBlocks{pandoc.RawBlock('latex', latexDefinitions)}
			meta['header-includes'] = header_includes
		end
	end	
	return meta	
end


function styleDiv (elem)
  if (FORMAT:match 'docx' or FORMAT:match 'icml') then
  -- if FORMAT:match 'docx' then
    if elem.classes[1] == "info" then
      elem.attributes['custom-style'] = 'Info'
      return elem
	elseif elem.classes[1] == "summary" then
      elem.attributes['custom-style'] = 'Summary'
	  return elem
	elseif elem.classes[1] == "exercise" then
      elem.attributes['custom-style'] = 'Exercise'
	  return elem
 	elseif elem.classes[1] == "solution" then
      elem.attributes['custom-style'] = 'Solution'
	  return elem
 	elseif elem.classes[1] == "comment" then
      elem.attributes['custom-style'] = 'Comment'
	  return elem
 	elseif elem.classes[1] == "hint" then
      elem.attributes['custom-style'] = 'Hint'
	  return elem
 	elseif elem.classes[1] == "note" then
      elem.attributes['custom-style'] = 'Note'
	  return elem
 	elseif elem.classes[1] == "sticky" then
      elem.attributes['custom-style'] = 'Sticky'
	  return elem
    elseif elem.classes[1] == "sidenote" then
      elem.attributes['custom-style'] = 'Sidenote'
	  return elem
    elseif elem.classes[1] == "cheatsheet" then
      elem.attributes['custom-style'] = 'Cheatsheet'
	  return elem
    elseif elem.classes[1] == "commands" then
      elem.attributes['custom-style'] = 'Commands'
	  return elem
    elseif elem.classes[1] == "notebook" then
      elem.attributes['custom-style'] = 'Notebook'
	  return elem
    elseif elem.classes[1] == "typewriter" then
      elem.attributes['custom-style'] = 'Typewriter'
	  return elem
    elseif elem.classes[1] == "pullquote" then
      elem.attributes['custom-style'] = 'Pullquote'
	  return elem
    else
      return elem
    end 
  elseif FORMAT:match 'latex' then
    if elem.classes[1] == "info" then
      return {pandoc.RawBlock('latex', '\\begin{boxshade}{colPrimary}'),elem,pandoc.RawBlock('latex', '\\end{boxshade}')}
    elseif elem.classes[1] == "note" then
	  return {pandoc.RawBlock('latex', '\\begin{note}'),elem,pandoc.RawBlock('latex', '\\end{note}')}   -- boxshade  colShade
	elseif elem.classes[1] == "hint" then
      return {pandoc.RawBlock('latex', '\\begin{boxtitle}{Hinweis}{colPrimary}'),elem,pandoc.RawBlock('latex', '\\end{boxtitle}')}
    elseif elem.classes[1] == "comment" then
      return {pandoc.RawBlock('latex', '\\begin{boxshade}{colShade}'),elem,pandoc.RawBlock('latex', '\\end{boxshade}')}
    -- --elseif elem.classes[1] == "exercise" then
      -- --return {pandoc.RawBlock('latex', '\\begin{exercise-box}'),elem,pandoc.RawBlock('latex', '\\end{exercise-box}')}
    elseif elem.classes[1] == "exercise" then
      return {pandoc.RawBlock('latex', '\\begin{boxtitle}{Übung}{colPrimary}'),elem,pandoc.RawBlock('latex', '\\end{boxtitle}')}
    elseif elem.classes[1] == "summary" then
      return {pandoc.RawBlock('latex', '\\begin{boxtitle}{Zusammenfassung}{colTertiary}'),elem,pandoc.RawBlock('latex', '\\end{boxtitle}')}
    elseif elem.classes[1] == "solution" then
	  return {pandoc.RawBlock('latex', '\\begin{boxtitle}{Lösung}{colSecondary}'),elem,pandoc.RawBlock('latex', '\\end{boxtitle}')} 
    elseif elem.classes[1] == "sticky" then
	  return {pandoc.RawBlock('latex', '\\begin{sticky}'),elem,pandoc.RawBlock('latex', '\\end{sticky}')}
    elseif elem.classes[1] == "sidenote" then
	  return {pandoc.RawBlock('latex', '\\marginnote{'),elem,pandoc.RawBlock('latex', '}')}
    elseif elem.classes[1] == "typewriter" then
	  return {pandoc.RawBlock('latex', '\\begin{typewriter}'),elem,pandoc.RawBlock('latex', '\\end{typewriter}')}
    elseif elem.classes[1] == "cheatsheet" then
	  return {pandoc.RawBlock('latex', '\\begin{cheatsheet}[Glossary]'),elem,pandoc.RawBlock('latex', '\\end{cheatsheet}')}
    elseif elem.classes[1] == "commands" then
	  return {pandoc.RawBlock('latex', '\\begin{commands}[Commands]'),elem,pandoc.RawBlock('latex', '\\end{commands}')}
    elseif elem.classes[1] == "notebook" then
	  return {pandoc.RawBlock('latex', '\\begin{notebook}'),elem,pandoc.RawBlock('latex', '\\end{notebook}')}
    elseif elem.classes[1] == "pullquote" then
	  -- print("Stringify: ",pandoc.utils.stringify(elem)) -- prints the content of an elem 
	  --return {pandoc.RawBlock('latex', '\\begin{pullquote}'),elem,pandoc.RawBlock('latex', '\\end{pullquote}')} -- inserts newline breaking the pullquote
	  -- work around with no styling TODO
	  --return {pandoc.RawBlock('latex', '\\begin{pullquote}'),pandoc.utils.stringify(elem),pandoc.RawBlock('latex', '\\end{pullquote}')} 
	  --local txt =  '\\begin{pullquote}'..elem..'\\end{pullquote}'
	  return {pandoc.RawInline('latex', '\\begin{pullquote}'..pandoc.utils.stringify(elem)..'\\end{pullquote}')}
	  --return {pandoc.RawBlock('latex', txt)}

	else
      return elem
    end
  end   
end

-- define span element for xkcd figures inline or aside
-- [1. This is a xkcd figure]{.xkcd}
-- [2. This is a xkcd figure]{.xkcd data-latex="This is funny"} 
-- [3. This is a xkcd figure]{.xkcd .aside}

-- functions to include lines, grids functions of the sty file
-- [4]{.lines} -> latex: \lines{4}
-- [3]{.numberedlines data-latex="2"} -> latex: \numberedlines[2]{3}
-- [30]{.grid} -> latex: \grid{30}
-- [30]{.dottedgrid} -> dottedgrid: \dottedgrid{30}

function Span (el)
	if FORMAT:match 'latex' then
		local options = el.attributes['data-latex']
		if not options then
			options = ''
		else
			options = '[' .. options .. ']'
		end
		if el.classes:includes('xkcd') and  el.classes:includes('aside') then 
			--print("*** includes both:",pandoc.utils.stringify(el.classes[1])) 
			table.insert(el.content, 1, pandoc.RawInline('latex', '\\marginnote{\\xkcd' .. options .. '{'))
			table.insert(el.content, pandoc.RawInline('latex', '}}'))
		elseif el.classes:includes('xkcd') then 
			table.insert(el.content, 1, pandoc.RawInline('latex', '\\xkcd' .. options .. '{'))
			table.insert(el.content, pandoc.RawInline('latex', '}'))
			--print("*** includes one: ",pandoc.utils.stringify(el.classes[1])) 
		elseif el.classes:includes('important') then 
			table.insert(el.content, 1, pandoc.RawInline('latex', '\\important{'))
			table.insert(el.content, pandoc.RawInline('latex', '}'))
			--print("*** includes one: ",pandoc.utils.stringify(el.classes[1])) 		
		elseif el.classes:includes('lines') then 
			table.insert(el.content, 1, pandoc.RawInline('latex', '\\lines{'))
			table.insert(el.content, pandoc.RawInline('latex', '}')) 		
		elseif el.classes:includes('numberedlines') then 
			table.insert(el.content, 1, pandoc.RawInline('latex', '\\numberedlines' .. options .. '{'))
			table.insert(el.content, pandoc.RawInline('latex', '}')) 	
		elseif el.classes:includes('grid') then 
			table.insert(el.content, 1, pandoc.RawInline('latex', '\\grid{'))
			table.insert(el.content, pandoc.RawInline('latex', '}')) 		
		elseif el.classes:includes('dottedgrid') then 
			table.insert(el.content, 1, pandoc.RawInline('latex', '\\dottedgrid{'))
			table.insert(el.content, pandoc.RawInline('latex', '}')) 	
		end		

		return el.content
	end
end

return {{Meta = headerInclude}, {Div = styleDiv}, {Span = Span}}