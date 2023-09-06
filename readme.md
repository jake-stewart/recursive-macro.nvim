recursive macros
----------------

hit `q` to start recording, and `q` to end recording.
You can now hit `Q` to replay the macro.

Or, hit `q` to start recording, `2q` to begin recording a recursive macro,
`q` to end the recursive macro and continue recording the first macro,
and hit `Q` to replay the recursive macro. Finally, hit `q` to stop recording
the first macro.

The default registers used are `qwerty`, so 6 levels deep is supported. set your own registers if you want further depth.

### Setup

```lua
require("recursive-macros").setup()
```

or for more customisation:

```lua
require("recursive-macros").setup({
    registers = {"q", "w", "e", "r", "t", "y"},
    startMacro = "q",
    replayMacro = "Q",
})
```

