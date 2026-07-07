--[[

  $$$$$$$\                            $$\                           $$\    $$\                              
  $$  __$$\                           $$ |                          $$ |   $$ |                             
  $$ |  $$ | $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$\        $$ |   $$ |$$$$$$\   $$$$$$\   $$$$$$\  
  $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$ |$$  __$$\ $$  __$$\       \$$\  $$  |\____$$\ $$  __$$\ $$  __$$\ 
  $$  __$$< $$$$$$$$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|       \$$\$$  / $$$$$$$ |$$ /  $$ |$$$$$$$$ |
  $$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$   ____|$$ |              \$$$  / $$  __$$ |$$ |  $$ |$$   ____|
  $$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$ |               \$  /  \$$$$$$$ |$$$$$$$  |\$$$$$$$\ 
  \__|  \__| \_______|\__|  \__| \_______| \_______|\__|                \_/    \_______|$$  ____/  \_______|
                                                                                      $$ |                
                                                                                      $$ |                
                                                                                      \__|   
   A very sexy and overpowered vape mod created at Render Intents  
   /lib/ramcleaner.lua - SystemXVoid/BlankedVoid            
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]
   
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

    -- FIX 1: Use a lightweight metatable for the cache array instead of spawning a whole new Performance instance.
    -- This stops the massive thread leak that was slowing down your loading.
    local cachearray: table = setmetatable({}, {
        __index = function(self, index)
            local val = rawget(self, index)
            if val ~= nil then return val end
            local t = tick()
            rawset(self, index, t)
            return t
        end
    });

    local cleanerthread: thread = task.spawn(function()
        local jobdelay = args.jobdelay and tonumber(args.jobdelay) or 5;
        local maxamount = args.maxamount and tonumber(args.maxamount) or 4000;
        local maxdir = args.maxdir and tonumber(args.maxdir) or 60;
        
        repeat 
            -- FIX 2: Chunked iteration. Processes 1000 items per frame to prevent freezing/lag spikes.
            local processed = 0;
            local chunkSize = 1000;
            
            for i, v in array do
                processed += 1;
                iter += 1;
                
                if mode == 1 then
                    if (typeof(v) == 'Instance' and v.Parent == nil) or (typeof(i) == 'Instance' and i.Parent == nil) then 
                        array[i] = nil;
                        cachearray[i] = nil;
                        cleanerevent:Fire(v, i);
                    end;
                elseif mode == 2 then
                    if iter > maxamount then 
                        array[i] = nil;
                        cachearray[i] = nil;
                        if args.purge then 
                            table.clear(array);
                            table.clear(cachearray);
                            cleanerevent:Fire();
                        else
                            cleanerevent:Fire(v, i);
                        end;
                    end;
                elseif mode == 3 then
                    if (tick() - cachearray[i]) >= maxdir then 
                        array[i] = nil;
                        cachearray[i] = nil;
                        cleanerevent:Fire(v, i);
                        if args.purge then 
                            table.clear(array);
                            table.clear(cachearray);
                            cleanerevent:Fire();
                        end;
                    end;
                end;
                
                -- Yield to the next frame if we hit the chunk limit
                if processed >= chunkSize then
                    task.wait();
                    processed = 0;
                end
            end;
            task.wait(jobdelay);
        until false;
    end);

    meta.__index = function(self: table, index: string?)
        local data: any = rawget(self, index);
        if data ~= nil then 
            cachearray[index] = tick();
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
        assert(func == nil or typeof(func) == 'function', `function expected for argument #
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

    return array
end;

if getgenv then 
    getgenv().Performance = Performance 
end;

return Performance
