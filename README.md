[![Hex pm](https://img.shields.io/hexpm/v/key_values3.svg?style=flat)](https://hex.pm/packages/key_values3) [![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/key_values3/)

# KeyValues3

This library helps you turn [KeyValues3](https://developer.valvesoftware.com/wiki/KeyValues3) values into Elixir values.
KeyValues3 is a JSON-like file format used by Valve and Source engine games.

## Wrong Exit?

If the file you want to read looks something like this:

```
"SomeKey"
    {
        "someInt"    "52"
        "someString"    "hello"
    }
```
then you probably are looking at an older [KeyValues](https://developer.valvesoftware.com/wiki/KeyValues) version and need a [VDF parser](https://hex.pm/packages/vdf) instead.

## Installation

Add `key_values3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:key_values3, "~> 0.1.0"}
  ]
end
```

## Usage

``` elixir
iex(1)> KeyValues3.decode!("{m_strValue = \"0\"}")
%{"m_strValue" => "0"}
```

Full documentation can be found at https://hexdocs.pm/key_values3.
