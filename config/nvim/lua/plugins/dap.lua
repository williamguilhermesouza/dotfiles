return {
  {
    "mfussenegger/nvim-dap",
    ft = { "cs" },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Start/Continue",
      },
      {
        "<S-F5>",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: Stop",
      },
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle breakpoint",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step into",
      },
      {
        "<S-F11>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step out",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: Toggle UI",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Debug: Toggle REPL",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason").setup()
      require("mason-nvim-dap").setup({
        ensure_installed = { "netcoredbg" },
        automatic_installation = true,
        handlers = {},
      })

      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      local function get_netcoredbg_path()
        local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
        local mason_root = vim.fs.joinpath(vim.fn.stdpath("data"), "mason")
        local package_exe = is_windows
          and vim.fs.joinpath(mason_root, "packages", "netcoredbg", "netcoredbg", "netcoredbg.exe")
          or vim.fs.joinpath(mason_root, "packages", "netcoredbg", "netcoredbg", "netcoredbg")

        if vim.fn.executable(package_exe) == 1 then
          return package_exe
        end

        local path = vim.fn.exepath("netcoredbg")
        if path ~= "" then
          return path
        end

        local mason_bin = vim.fs.joinpath(mason_root, "bin", is_windows and "netcoredbg.exe" or "netcoredbg")
        if vim.fn.executable(mason_bin) == 1 then
          return mason_bin
        end

        error("netcoredbg was not found. Install it with :MasonInstall netcoredbg or :DapInstall netcoredbg")
      end

      local function read_file(path)
        local lines = vim.fn.readfile(path)
        if vim.v.shell_error ~= 0 then
          return nil
        end

        return table.concat(lines, "\n")
      end

      local function parse_csproj(csproj)
        local content = read_file(csproj)
        if not content then
          return nil
        end

        local assembly_name = content:match("<AssemblyName>(.-)</AssemblyName>")
        local target_framework = content:match("<TargetFramework>(.-)</TargetFramework>")
        if not target_framework then
          local frameworks = content:match("<TargetFrameworks>(.-)</TargetFrameworks>")
          if frameworks then
            target_framework = vim.split(frameworks, ";", { plain = true })[1]
          end
        end

        local output_type = content:match("<OutputType>(.-)</OutputType>")

        return {
          assembly_name = assembly_name or vim.fs.basename(csproj):gsub("%.csproj$", ""),
          target_framework = target_framework,
          output_type = output_type and output_type:lower() or nil,
          project_dir = vim.fs.dirname(csproj),
          project_file = csproj,
        }
      end

      local function is_executable_project(project)
        return project and (project.output_type == "exe" or project.output_type == "winexe")
      end

      local function dll_candidates(project)
        if not project then
          return {}
        end

        local candidates = {}
        if project.target_framework then
          table.insert(
            candidates,
            vim.fs.joinpath(
              project.project_dir,
              "bin",
              "Debug",
              project.target_framework,
              project.assembly_name .. ".dll"
            )
          )
        end

        vim.list_extend(
          candidates,
          vim.fn.glob(
            vim.fs.joinpath(project.project_dir, "bin", "Debug", "**", project.assembly_name .. ".dll"),
            false,
            true
          )
        )

        return candidates
      end

      local function first_readable(paths)
        for _, path in ipairs(paths) do
          if vim.fn.filereadable(path) == 1 then
            return path
          end
        end
      end

      local function workspace_executable_projects(root)
        local csprojs = vim.fn.glob(vim.fs.joinpath(root, "**", "*.csproj"), false, true)
        local projects = {}

        for _, csproj in ipairs(csprojs) do
          local project = parse_csproj(csproj)
          if is_executable_project(project) then
            table.insert(projects, project)
          end
        end

        return projects
      end

      local function prompt_for_dll(default_path)
        return vim.fn.input("Path to dll: ", default_path, "file")
      end

      local function detect_dll()
        local buffer_name = vim.api.nvim_buf_get_name(0)
        local start_dir = buffer_name ~= "" and vim.fs.dirname(buffer_name) or vim.fn.getcwd()
        local csproj = vim.fs.find(function(name)
          return name:match("%.csproj$") ~= nil
        end, { path = start_dir, upward = true })[1]

        local default_path = vim.fn.getcwd()

        if csproj then
          local project = parse_csproj(csproj)
          local project_dll = first_readable(dll_candidates(project))
          if project_dll and is_executable_project(project) then
            return project_dll
          end

          if project_dll then
            default_path = project_dll
          end
        end

        for _, project in ipairs(workspace_executable_projects(vim.fn.getcwd())) do
          local dll = first_readable(dll_candidates(project))
          if dll then
            return dll
          end
        end

        local fallback_matches = vim.fn.glob(
          vim.fs.joinpath(vim.fn.getcwd(), "bin", "Debug", "**", "*.dll"),
          false,
          true
        )
        if #fallback_matches > 0 then
          default_path = fallback_matches[1]
        end

        return prompt_for_dll(default_path)
      end

      dap.adapters.netcoredbg = {
        type = "executable",
        command = get_netcoredbg_path(),
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "netcoredbg",
          name = "Launch .NET",
          request = "launch",
          program = detect_dll,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          justMyCode = false,
        },
      }
    end,
  },
}
