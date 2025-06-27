---
sidebar_position: 2
---

# Getting Started

quid is a library for generating unique identifiers for entities. It is designed to be easy to use and understand, while providing a high level of security and performance.

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
