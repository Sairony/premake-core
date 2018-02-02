
for _, pm in ipairs( os.matchfiles( "projects/" .. fold .. "/*premake.lua" ) ) do
	print( pm )
	dofile( pm )
end

print("Begin fixup")

local allProjs = {}
for sln in premake.global.eachSolution() do -- Iterate over every solution
	solution( sln.name ) -- Activate it
	for _, prj in ipairs( sln.projects ) do -- Now iterate over every project within that solution
		if prj.solution == sln then -- Skip external projects (  possible to import the same project into multiple solutions )
			allProjs[#allProjs + 1] = prj
			project( prj.name )
			configuration{ "*App" } -- Used to also target DLLs, shouldn't probably?
				targetdir( "bin/" .. prj.name ) -- All application variants should be output to the bin folder followed by the project name
			configuration{"WindowedApp"}
				entrypoint 'WinMain'
		end
	end 
	for _, cfg in  ipairs(sln.configurations) do -- Now lets cover all configurations{}
		for _, plat in ipairs(sln.platforms) do -- Combined with platforms{}
			for _, prj in ipairs(sln.projects) do -- We need to iterate at project level as well to activate the project
				if prj.solution == sln then -- Skip external projects
					local lib_path = path.join( "lib" , cfg .. plat )
					project( prj.name ) -- Activate project so that location() gives us the correct info
					configuration { cfg, plat } -- Activate the config / platform combo
						libdirs { lib_path } -- And set the library search folder
						objdir( "obj/" .. prj.name .. "/" .. cfg .. plat ) -- Also create a folder inside that project for object files
					configuration { "*Lib", cfg, plat } -- All projects which output a library of some sort ( could be either dynamic or static )
						targetdir( lib_path ) -- Set the library output path
				end
			end
		end
	end
end
solution "ALL"
	location "sln"
	for _, prj in ipairs( allProjs ) do
		importproject( prj )
	end
print( "Fixup done" )