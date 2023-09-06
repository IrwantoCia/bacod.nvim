# ABOUT
This plugin is used for generating test case using chat gpt api. 

Currently this plugin only support generating 1 test case at the time.

I created this plugin for learning purpose only, so use with your own risk.

# INSTALLATION
  -   Packer

    use "irwantocia/bacod.nvim"

# SETUP
``` 
require "bacod".setup([your_chatgpt4_api_key])

-- set your kebinding
vim.keymap.set("n", "<leader>xs", "<cmd>lua require('bacod').call_gpt()<cr>")
```

# HOW TO USE
1. Block the function you want to generate test
2. Escape to command mode
3. Execute `lua require('bacod').call_gpt()` or the keybinding you already set
4. It will take a moment to generate the code
5. The code will be displayed in a new scratch vertical split buffer

# TODO
1. add test case
2. convert the response to be stream message so we don't need to wait for the generation to be done to see the result
