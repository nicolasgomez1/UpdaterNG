UpdaterNG = ({});

UpdaterNG.UpdateDownload = function(URL)
	local function DownloadCheckMethod(Url, Path)
		if(String.Left(Url, 5) == "https")then
			HTTP.DownloadSecure(Url, Path, MODE_BINARY, 1, 443, nil, nil, UpdaterNG.DownloadCallback);
		else
			HTTP.Download(Url, Path, MODE_BINARY, 1, 80, nil, nil, UpdaterNG.DownloadCallback);
		end
	end
	
	if(URL == "" or URL == nil)then
		return false, "Error, You must define link to patch.";
	else
		if(HTTP.TestConnection(URL, 20, 80, nil, nil) == false)then
			return false, "Error, Unable to connect to patch file.";
		else
			DownloadCheckMethod(URL, _SourceFolder.."\\update.zip");
			return true, "Update Downloaded.";
		end
	end
end

UpdaterNG.ApplyUpdate = function()
	Zip.Extract(_SourceFolder.."\\update.zip", {"*.*"}, _SourceFolder, true, true, "", ZIP_OVERWRITE_ALWAYS, UpdaterNG.ZipExtractCallback);
	local ZipError = Application.GetLastError();
	if(ZipError ~= 0)then
		return false, "Error, "..tblErrorMessages[ZipError];
	else
		File.Delete(_SourceFolder.."\\update.zip", false, false, false, nil);
		local Filename = (String.Left(_SourceFilename, String.Length(_SourceFilename)-4));
		TextFile.WriteFromString(_SourceFolder.."\\Updater.bat", [[
			:Repeat
			del "]]..Filename..[[.exe"
			if exist "]]..Filename..[[.exe" goto Repeat
			move "]]..Filename..[[.exe.new" "]]..Filename..[[.exe"
			
			:Repeat
			del "]]..Filename..[[.cdd"
			if exist "]]..Filename..[[.cdd" goto Repeat
			move "]]..Filename..[[.cdd.new" "]]..Filename..[[.cdd"
			
			start /NORMAL ]]..Filename..".exe"..[[
			del "Updater.bat"
		]], false);
		
		File.Run(_SourceFolder.."\\Updater.bat", "", "", SW_SHOWNORMAL, false);
		Window.Close(Application.GetWndHandle(), CLOSEWND_TERMINATE);	
	end
end

UpdaterNG.CheckUpdates = function(DataLink, LocalVersion)
	local ReadyToCheck = (false);
	
	local function DelimitedToTable(String, Delimiter)
		if not(Delimiter or #Delimiter < 1)then
			return nil;
		end
	
		local tbl = ({});
		local sa = (String);
		local sD = ("");
		local nP = string.find(sa, Delimiter, 1, true);
	
		while(nP)do
			sD = string.sub(sa, 1, nP-1);
			table.insert(tbl, #tbl+1, sD);
			sa = string.sub(sa, nP+1, -1);
			nP = string.find(sa, Delimiter, 1, true);
		end
	
		if(sa ~= "")then
			Table.Insert(tbl, #tbl+1, sa)
		end
	
		return tbl;
	end
	
	local function SubmitCheckMethod(Url)
		if(String.Left(Url, 5) == "https")then
			return HTTP.SubmitSecure(Url, {}, SUBMITWEB_GET, 20, 443, nil, nil);
		else
			return HTTP.Submit(Url, {}, SUBMITWEB_GET, 20, 80, nil, nil);
		end
	end
	
	if(DataLink == "" or DataLink == nil)then
		return false, "Error, You must define link to information file.";
	else
		ReadyToCheck = (true);
	end
	
	if(LocalVersion == "" or LocalVersion == nil)then
		return false, "Error, You must define local version.";
	else
		ReadyToCheck = (true);
	end
	
	if(ReadyToCheck == false)then
		return false, "Error, cannot continue.";
	else
		if(HTTP.TestConnection(DataLink, 20, 80, nil, nil) == false)then
			return false, "Error, Unable to connect to information file.";
		else
			local UpdaterData = SubmitCheckMethod(DataLink);
			if(UpdaterData == "")then
				return false, "Error, Information file is empty.";
			else
				local Version	= (nil);
				local PatchLink = (nil);
				
				for _, Line in pairs(DelimitedToTable(UpdaterData, "\n")) do
					local Parse 	= DelimitedToTable(Line, "=");
					local Variable	= (Parse[1]);
					local Value 	= (Parse[2]);
					
					if(Variable == "Version")then
						Version = (Value);
					end
					
					if(Variable == "Patch")then
						PatchLink = (Value);
					end
				end

				if(Version == "\r" or Version == nil)then
					return false, "Error, Variable 'Version' is missing in info file or variable is empty.";
				end
				
				if(PatchLink == "\r" or PatchLink == nil)then
					return false, "Error, Variable 'Patch' is missing in info file or variable is empty.";
				end
				
				if(Version ~= nil and PatchLink ~= nil)then
					if(tonumber(LocalVersion) < tonumber(Version))then
						return true, Version, PatchLink;
					elseif(tonumber(LocalVersion) == tonumber(Version))then
						return false, "Application Updated";
					end
				else
					return nil, "Error, cannot continue.";
				end
			end
		end
	end
end
