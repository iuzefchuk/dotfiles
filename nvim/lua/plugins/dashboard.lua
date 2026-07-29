return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard = opts.dashboard or {}
    opts.dashboard.width = 48
    opts.dashboard.preset = opts.dashboard.preset or {}
    opts.dashboard.preset.header = [==[
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
    opts.dashboard.sections = {
      { section = "header" },
    }
  end,
}
