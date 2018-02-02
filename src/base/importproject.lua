---
-- importproject probably needs to be a container to play ball with groups & handle the mapping with multiple parents for projects without to much rework.
---

	local p = premake
	p.importproject = p.api.container("importproject", p.workspace)
	local importproject = p.importproject


---
-- No config data for now to make things easier.
---

	importproject.placeholder = true



	function importproject.new(prj)
		if type( prj ) == "table" then -- Assume it's a project table
			prj = prj.workspace.name .. "/" .. prj.name
		end

		local pos = prj:find( '/', 0, true )
		local impproj = p.container.new(importproject, prj:sub(pos + 1 ))
		impproj.project = prj

		if p.api.scope.group then -- Couldn't this just be deduced from looking at parent container when needed?
			impproj.group = p.api.scope.group.name
		else
			impproj.group = ""
		end
		return impproj
	end

	--
-- Return the relative path from the project to the specified file.
--
-- @param prj
--    The project object to query.
-- @param filename
--    The file path, or an array of file paths, to convert.
-- @return
--    The relative path, or array of paths, from the project to the file.
--

	function importproject.getProject(self)
		if type( self.project ) ~= "table" then
			local pos = self.project:find( '/', 0, true )
			local targetsln = nil
			if pos then
			local fndPrj = p.global.getWorkspace( self.project:sub(0, pos - 1) )
	--		print( "Name: " .. self.name:sub( pos + 1 ))
			fndPrj = workspace.getproject(fndPrj, self.project:sub( pos + 1 ) )
			if not fndPrj then
				error( "could not locate a solution with project '" .. self.project .. "' in it", 2)
			else
				return fndPrj
			end
			else
				for curSln in p.global.eachWorkspace() do
					local fndPrj = p.workspace.getproject( self.project )
					if fndPrj then
						return fndPrj
					end
				end
			end
			error( "could not locate a solution with project '" .. self.project .. "' in it", 2)
		else
			return self.project
		end
	end


	function importproject.getrelative(prj, filename)
		return project.getrelative( importproject.getProject( prj ), filename )
	end
