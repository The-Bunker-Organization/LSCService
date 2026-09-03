# LSCService

> [!IMPORTANT]
> **LSCService is currently in beta.**
>
> Please report bugs, issues, or unexpected behavior on our [Discord Server](https://canary.discord.com/invite/MvVBbftUYm).

## About

**LSCService** is a runtime **Script2Source** system for creating Lua script containers at runtime without requiring Roblox Studio.

The `MainModule` accepts a configuration table describing the source code, script type, parent, and optional `RunContext`. It then clones the appropriate internal script template and returns it as a `BaseScript`.

LSCService can create:

* `Script`
* `LocalScript`
* `ModuleScript`
* `vLuau`

The generated script receives the supplied source code through its `Source` attribute.

## Features

* Runtime creation of Lua script containers
* No Roblox Studio required at runtime
* Supports `Script`, `LocalScript`, and `ModuleScript`
* Supports the internal `vLuau` runtime
* Optional `RunContext` selection
* Optional parent assignment
* Returns the generated object as a `BaseScript`
* Uses an isolated/frozen function environment inside the module
* Rojo project that can be built as RBXM or RBXMX
* Currently in beta

## Installation

Download a prebuilt module from the [Releases](https://github.com/The-Bunker-Organization/LSCService/releases) page, or build the project yourself with Rojo.

After inserting the RBXM into your experience, require the `MainModule`.

```lua
local LSCService = require(path.to.MainModule)
```

You may also upload the resulting module and require it by asset ID:

```lua
local LSCService = require(670000)
```

Replace `670000` with the asset ID of your uploaded module.

## Usage

### Basic Script

Create a normal server `Script`:

```lua
local LSCService = require(path.to.MainModule)

local scriptObject = LSCService({
	source = [[
		print("Hello from LSCService!")
	]],

	type = "Script"
})

print(scriptObject.ClassName)
```

The result is a cloned `Script` instance.

### ModuleScript

```lua
local LSCService = require(path.to.MainModule)

local module = LSCService({
	source = [[
		return {
			Message = "Hello from a runtime ModuleScript"
		}
	]],

	type = "ModuleScript"
})

module.Parent = workspace
```

### LocalScript

```lua
local LSCService = require(path.to.MainModule)

local clientScript = LSCService({
	source = [[
		print("Hello from the client!")
	]],

	type = "LocalScript",
	runcontext = Enum.RunContext.Client,
	parent = game.StarterPlayer.StarterPlayerScripts
})
```

### Server RunContext

A `RunContext` can explicitly select the server or client template.

```lua
local serverScript = LSCService({
	source = [[
		print("Running as a server script")
	]],

	type = "Script",
	runcontext = Enum.RunContext.Server,
	parent = workspace
})
```

When `RunContext` is specified:

```text
Enum.RunContext.Client → ClientRunContext
Enum.RunContext.Server → ServerRunContext
```

### Parent Assignment

The `parent` field determines where the generated instance is placed.

```lua
local scriptObject = LSCService({
	source = "print('Hello')",
	type = "Script",
	parent = workspace
})
```

If `parent` is omitted or `nil`, the generated instance is returned without assigning a parent.

## vLuau

LSCService has a special `vLuau` mode.

```lua
local LSCService = require(path.to.MainModule)

local vm = LSCService("vLuau")
```

When called with the string `"vLuau"`, the module directly clones and returns the internal `_vLuau` instance.

This is different from the normal configuration-table interface.

## API

### `LSCService(config)`

Creates and returns a new script container.

```lua
local scriptObject = LSCService({
	source = "print('Hello!')",
	type = "Script",
	parent = workspace
})
```

#### Configuration

```lua
type config = {
	source: string,
	parent: Instance?,
	type: "Script" | "ModuleScript" | "LocalScript" | "vLuau",
	runcontext: Enum.RunContext?
}
```

| Property     | Type               | Required | Description                                                      |
| ------------ | ------------------ | -------- | ---------------------------------------------------------------- |
| `source`     | `string`           | Yes      | Source code stored in the generated script's `Source` attribute. |
| `parent`     | `Instance?`        | No       | Parent of the generated instance.                                |
| `type`       | `string`           | Yes*     | Determines which script template is cloned.                      |
| `runcontext` | `Enum.RunContext?` | No       | Selects the client/server run-context template.                  |

`parent` may be `nil`.

The current implementation also accepts the special string:

```lua
LSCService("vLuau")
```

which directly returns a cloned `vLuau` instance.

### `source`

The source code to associate with the generated script.

```lua
{
	source = [[
		print("Hello world")
	]],
	type = "Script"
}
```

The source is stored as:

```lua
scriptObject:GetAttribute("Source")
```

For example:

```lua
print(scriptObject:GetAttribute("Source"))
```

### `type`

Determines the base script template.

Supported values:

```text
Script
LocalScript
ModuleScript
vLuau
```

For normal configuration tables, the implementation selects the matching template from `script.scrs`.

If a client or server `runcontext` is specified, the corresponding `ClientRunContext` or `ServerRunContext` template takes precedence.

### `parent`

Optional Roblox `Instance` used as the generated script's parent.

```lua
{
	source = "print('Hello')",
	type = "Script",
	parent = workspace
}
```

If `parent` is `nil`, no parent is assigned.

### `runcontext`

Optional `Enum.RunContext` used to select a specific template.

```lua
runcontext = Enum.RunContext.Client
```

or:

```lua
runcontext = Enum.RunContext.Server
```

The implementation maps these to:

```text
Client → ClientRunContext
Server → ServerRunContext
```

If `runcontext` is omitted, the module attempts to use the template matching `type`.

## Return Value

For a normal configuration table, the function returns a cloned `BaseScript`.

```lua
local object = LSCService({
	source = "print('Hello')",
	type = "Script"
})

print(object.ClassName)
```

For:

```lua
LSCService("vLuau")
```

it returns a clone of the internal `vLuau` object instead.

## Building

LSCService uses a [Rojo](https://rojo.space/) project and can be built into either an **RBXM** or **RBXMX**.

### RBXM

```bash
rojo build default.project.json -o LSCService.rbxm
```

### RBXMX

```bash
rojo build default.project.json -o LSCService.rbxmx
```

Prebuilt files are available through the [Releases](https://github.com/The-Bunker-Organization/LSCService/releases) page.

## Project Structure

The module contains the internal script templates and `vLuau` runtime used by `MainModule`.

Conceptually:

```text
MainModule
├── scrs
│   ├── Script
│   ├── LocalScript
│   ├── ModuleScript
│   ├── ClientRunContext
│   └── ServerRunContext
└── _vLuau
```

The module clones these internal objects rather than constructing the script instances from scratch.

## Status

| Feature                   | Status            |
| ------------------------- | ----------------- |
| Rojo loader / RBXM module | 🟢 Available      |
| RBXMX build               | 🟢 Available      |
| Script creation           | 🟢 Available      |
| ModuleScript creation     | 🟢 Available      |
| LocalScript creation      | 🟢 Available      |
| RunContext selection      | 🟢 Available      |
| vLuau support             | 🟢 Available      |
| Argon build               | 🟡 In development |
| Stability                 | 🟡 Beta           |

## Contributing

Found a bug or have an improvement?

* Open an [issue](https://github.com/The-Bunker-Organization/LSCService/issues).
* Fork the repository and submit your changes.
* Discuss development and report bugs on the [Discord Server](https://canary.discord.com/invite/MvVBbftUYm).
* For urgent questions, contact **[thebunkerproject@waifu.club](mailto:thebunkerproject@waifu.club)**.

## License

LSCService is free and open-source software licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

You are free to use, modify, and redistribute the software under the terms of the license.

See the [LICENSE](LICENSE) file for the full license text.
