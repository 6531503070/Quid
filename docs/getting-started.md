---
sidebar_position: 2
---

# Getting Started

UID is a unique identifier (UID) generator for Roblox, supporting multiple formats and high-performance randomization. This guide will help you install, set up, and use UID in your Roblox projects.

## Installation

Add quid to your `wally.toml`:

```toml
quid = "6531503070/quid@1.0.0"
```

:::tip
If you're new to Wally, check out the [Wally installation guide](https://wally.run/install).
:::

## Basic Setup

Here's how to set up quid with a simple data structure:

```lua
local quid = require(path.to.quid)
local uid = quid.next()
```

## Quick Links

- [Introduction](./intro.md)
- [Getting Started](./getting-started.md)
- [API Reference](../api)
- [Moonwave](https://eryn.io/moonwave/docs/intro)
