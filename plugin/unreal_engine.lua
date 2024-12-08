if 1 ~= vim.fn.has "nvim-0.9.0" then
  vim.api.nvim_err_writeln "ue.nvim requires nvim version 0.9.0"
  return
end

if vim.g.loaded_unreal_engine == 1 then
  return
end
vim.g.loaded_unreal_engine = 1

vim.api.nvim_create_user_command('UEGen', function(opts)
    require('unreal_engine').generate(opts.fargs[1])
end, { nargs = '*' })

vim.api.nvim_create_user_command('UEBuild', function(opts)
    require('unreal_engine').build(opts.fargs[1])
end, { nargs = '*' })

vim.api.nvim_create_user_command('UERun', function(opts)
    require('unreal_engine').run(opts.fargs[1])
end, { nargs = '*' })
