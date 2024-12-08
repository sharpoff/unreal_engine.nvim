local M = {}

local engine_dir = nil

local vim = vim

-- TODO: make engine_dir required and fail if it nil
function M.setup(config)
    engine_dir = vim.fs.normalize(config.engine_dir) or nil
end

local function execute_cmd(cmd, cwd, on_exit, on_stdout, on_stderr)
    if not on_stdout then
        on_stdout = function(_, data, _)
            for _, v in ipairs(data) do
                if v and #v > 1 then
                    vim.print(v)
                end
            end
        end
    end

    if not on_stderr then
        on_stderr = function(_, data, _)
            for _, v in ipairs(data) do
                if v and #v > 1 then
                    vim.notify(v, vim.log.levels.ERROR)
                end
            end
        end
    end

    vim.fn.jobstart(
        cmd,
        {
            cwd = cwd,
            on_exit = on_exit,
            on_stdout = on_stdout,
            on_stderr = on_stderr,
        }
    )
end

-- TODO: add better output of compilation results
-- TODO: add other platforms

function M.generate(project)
    local cwd = vim.uv.cwd() .. '/'

    -- if project is not specified use current dir name as project
    if not project then
        project = vim.fs.basename(vim.uv.cwd())
    end

    local project_dir = cwd .. project .. '.uproject'

    local build_path = "/Engine/Build/BatchFiles/Linux/Build.sh"

    local cmd = "sh " .. engine_dir .. build_path .. " -mode=GenerateClangDatabase -project=" .. project_dir .. " -game -engine " .. project .. "Editor Development Linux"

    vim.notify("Generating compile_commands.json.", vim.log.levels.INFO)
    execute_cmd(cmd, cwd, function()
        -- move compile_commands from engine_dir to project directory
        -- TODO: check results of this operation
        os.rename(engine_dir .. "/compile_commands.json", cwd .. "compile_commands.json")
    end)
end

function M.build(project)
    local cwd = vim.uv.cwd() .. '/'

    -- if project is not specified use current dir name as project
    if not project then
        project = vim.fs.basename(vim.uv.cwd())
    end

    local project_dir = cwd .. project .. '.uproject'

    local build_path = "/Engine/Build/BatchFiles/Linux/Build.sh"

    local cmd = "sh " .. engine_dir .. build_path .. " -project=" .. project_dir .. " -game -engine " .. project .. "Editor Development Linux"

    vim.notify("Building project: " .. project, vim.log.levels.INFO)
    execute_cmd(cmd, cwd)
end

function M.run(project)
    local cwd = vim.uv.cwd() .. '/'

    -- if project is not specified use current dir name as project
    if not project then
        project = vim.fs.basename(vim.uv.cwd())
    end

    local project_dir = cwd .. project .. '.uproject'

    local editor_path = "/Engine/Binaries/Linux/UnrealEditor"

    local cmd = engine_dir .. "/" .. editor_path .. " -project=" .. project_dir .. " -skipcompile -game -engine " .. project .. "Editor Development Linux"

    vim.notify("Running project.", vim.log.levels.INFO)
    execute_cmd(cmd, cwd)
end

return M
