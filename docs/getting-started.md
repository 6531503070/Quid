---
sidebar_position: 2
---

# Getting Started

Quid is a library for generating unique identifiers for entities. It is designed to be easy to use and understand, while providing a high level of security and performance.

## Installation

Add Quid to your `wally.toml`:

```toml
Quid = "6531503070/quid@1.0.0"
```

:::tip
If you're new to Wally, check out the [Wally installation guide](https://wally.run/install).
:::

## Basic Setup

Here's how to set up Quid with a simple data structure:

```lua
local Quid = require(path.to.quid)
local uid = Quid.next()
```

## Quick Links

- [Introduction](./intro.md)
- [Getting Started](./getting-started.md)
- [API Reference](../api)
- [Moonwave](https://eryn.io/moonwave/docs/intro)
