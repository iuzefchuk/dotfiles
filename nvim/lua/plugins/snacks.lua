local dashboard_header = [==[
          /                            )        
          (                             |\      
         /|                              \\     
        //                                \\    
       ///                                 \|   
      /( \                                  )\  
      \\  \_                               //)  
       \\  :\__                           ///   
        \\     )                         // \   
         \\:  /                         // |/   
          \\ / \                       //  \    
           /)   \   ___..-'           (|  \_|   
          //     /   _.'              \ \  \    
         /|       \ \________          \ | /    
        (| _ _  __/          '-.       ) /.'    
         \\ .  '-.__            \_    / / \     
          \\_'.     > --._ '.     \  / / /      
           \ \      \     \  \     .' /.'       
            \ \  '._ /     \ )    / .' |        
             \ \_     \_   |    .'_/ __/        
              \  \      \_ |   / /  _/ \_       
               \  \       / _.' /  /     \      
               \   |     /.'   / .'       '-,_  
                \   \  .'   _.'_/             \ 
   /\    /\      ) ___(    /_.'           \    |
  | _\__// \    (.'      _/               |    |
  \/_  __  /--'`    ,                   __/    /
  (_ ) /b)  \  '.   :            \___.-'_/ \__/ 
  /:/:  ,     ) :        (      /_.'__/-'|_ _ / 
 /:/: __/\ >  __,_.----.__\    /        (/(/(/  
(_(,_/V .'/--'    _/  __/ |   /                 
 VvvV  //`    _.-' _.'     \   \                
   n_n//     (((/->/        |   /               
   '--'         ~='          \  |               
                              | |_,,,           
                 snd          \  \  /           
                               '.__)            
]==]

local function plain_directories()
  vim.api.nvim_set_hl(0, "SnacksPickerDirectory", {})
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("config_plain_directories", { clear = true }),
      callback = function()
        vim.schedule(plain_directories)
      end,
    })
    vim.schedule(plain_directories)
  end,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    bufdelete = { enabled = true },
    explorer = { enabled = true },
    lazygit = { enabled = true },
    terminal = { enabled = true },
    dashboard = {
      enabled = true,
      width = 48,
      preset = { header = dashboard_header },
      sections = {
        { section = "header" },
      },
    },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          hidden = true,
          layout = {
            hidden = { "input" },
          },
        },
      },
    },
  },
}
