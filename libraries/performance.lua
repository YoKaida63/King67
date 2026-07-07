--Kingify performence.lua so tuff gng
   
local Performance: table = {};
Performance.__index = Performance;

function Performance.new(args: table | nil, nocachearray: boolean | nil): table
    assert(args == nil or typeof(args) == 'table', `table expected for Argument #1, got {typeof(args)}.`);
    local args: table = args or {};
    local mode: number = 1;
    local iter: number = 0;
    local array: table = setmetatable({}, {});
    local meta: table = getmetatable(array);
    local onclean: table = {};
    
    local cleanerevent: table = setmetatable({}, {
        __index = {
            Fire = function(self: table, ...)
                for _, v in onclean do 
                    task.spawn(v, ...)
                end
            end,
            Connect = function(self: table, func: () -> (any))
                local pos: number = #onclean + 1;
                assert(typeof(func) == 'function', `function expected for argument #1, got {typeof(func)}`);
                onclean[pos] = func;
                return setmetatable({}, {
                    __index = {
                        Connected = true,
                        Disconnect = function(self: table)
                            onclean[pos] = nil;
                            self.Connected = false;
                        end
                    }
                });
            end,
            Wait = function(self: table)
                local waitargs: table = {};
                local argsfetched: boolean = false;
                local pos: number = #onclean + 1;
                onclean[pos] = function(...)
                    waitargs = {(...)};
                    argsfetched = true;
                end;
                repeat task.wait() until argsfetched;
                onclean[pos] = nil;
                return unpack(waitargs)
            end
        }
    });

    local cachearray: table = nocachearray and setmetatable({}, {}) or Performance.new(nil, true);
    
    -- OPTIMIZATION 1: Use os.clock() (much faster than tick) and throttle updates to once per second
    getmetatable(cachearray).__index = function(self: table, index: any)
        local val = rawget(self, index)
        if val ~= nil then
            if os.clock() - val > 1 then
                rawset(self, index, os.clock())
            end
            return val
        end
        local t = os.clock()
        rawset(self, index, t)
        return t
    end;

    meta.__index = function(self: table, index: string?)
        local data: any = rawget(self, index);
        if data ~= nil then 
            return data
        end; 
        return meta[index]
    end;

    meta.oncleanevent = cleanerevent;

    meta.setcleanermode = function(self: table, enum: number, args: table | nil)
        assert(args == nil or typeof(args) == 'table', `table expected for Argument #2, got {typeof(args)}.`);
        mode = enum;
    end;

    meta.len = function(self: table): number
        local iter: number = 0;
        for _ in array do
            iter += 1 
        end;
        return iter
    end;

    meta.clear = function(self: table, func: (object: any, index: any) -> ()?)
        assert(func == nil or typeof(func) == 'function', `function expected for argument #1, got {typeof(func)}`);
        for i,v in array do 
            array[i] = nil;
            if func then 
                task.spawn(func, v, i);
            end;
        end;
        table.clear(cachearray);
    end;

    meta.getplainarray = function(self: table)
        local tab: table = {};
        for _, v in array do
            table.insert(tab, v)
        end;
        return tab
    end;

    meta.shutdown = function(self: table)
        self:clear();
        pcall(task.cancel, cleanerthread);
        cleanerthread = nil;
        table.clear(meta);
        table.clear(onclean);
        onclean = nil;
    end;

    -- OPTIMIZATION 2: Chunked loop so it doesn't freeze the game when the table gets huge
    local cleanerthread: thread = task.spawn(function()
        local jobdelay = args.jobdelay and tonumber(args.jobdelay) or 5
        local chunkSize = 500 -- Process max 500 items per frame
        repeat 
            local processed = 0
            for i: Instance | number?, v: Instance? in array do
                processed += 1
                iter += 1;
                
                if mode == 1 and (typeof(v) == 'Instance' and v.Parent == nil or typeof(i) == 'Instance' and i.Parent == nil) then 
                    array[i] = nil;
                    cachearray[i] = nil;
                    cleanerevent:Fire(v, i);
                elseif mode == 2 and iter > (args.maxamount and tonumber(args.maxamount) or 4000) then 
                    array[i] = nil;
                    cachearray[i] = nil;
                    if args.purge then 
                        table.clear(array)
                        table.clear(cachearray)
                        cleanerevent:Fire();
                    else
                        cleanerevent:Fire(v, i);
                    end;
                elseif mode == 3 and cachearray[i] and (os.clock() - cachearray[i]) >= (args.maxdir and tonumber(args.maxdir) or 60) then 
                    array[i] = nil;
                    cachearray[i] = nil;
                    cleanerevent:Fire(v, i);
                end;
                
                -- Yield to the next frame if we hit the chunk limit to keep FPS high
                if processed >= chunkSize then
                    task.wait()
                    processed = 0
                end
            end;
            task.wait(mode == 3 and 0 or jobdelay);
        until false;
    end);

    return array
end;

if getgenv then 
    getgenv().Performance = Performance 
end;

return Performance
