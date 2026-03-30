function deviceList = get_enclosures_and_disks(input_string)

    %%% from ChatGPT
    
    % Regular expression to match 'Key : Value' pairs
    pattern = '(\w+)\s*:\s*(\\?.*?)(?=\s+\w+\s*:|$)';
    
    % Apply regular expression
    tokens = regexp(input_string, pattern, 'tokens');
    
    % Flatten and group into structs (1 per DeviceID group)
    numTokens = length(tokens);
    deviceList = {};
    currentDevice = struct();
    fieldCount = 0;
    
    for i = 1:numTokens
        key = strtrim(tokens{i}{1});
        value = strtrim(tokens{i}{2});
        
        if strcmp(key, 'DeviceID') && fieldCount > 0
            % Save the current group before starting a new one
            deviceList{end+1} = currentDevice;
            currentDevice = struct();
        end
    
        currentDevice.(key) = value;
        fieldCount = fieldCount + 1;
    end
    
    % Save the last device
    deviceList{end+1} = currentDevice;
    
    %%% end from ChatGPT
end