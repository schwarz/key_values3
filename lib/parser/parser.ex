defmodule KeyValues3.Parser.Helpers do
  @moduledoc false

  import NimbleParsec

  @encoding_version "e21c7f3c-8a33-41c5-9977-a76d3a32aa0d"
  @format_version "7412167c-06e9-4698-aff2-e63eb59037e7"

  def whitespace() do
    ascii_string([?\s, ?\t, ?\n, ?\r], min: 0)
  end

  def line_comment() do
    ignore(string("//"))
    |> repeat(
      lookahead_not(ascii_char([?\n]))
      |> utf8_char([])
    )
    |> ignore(ascii_char([?\n]))
    |> reduce({List, :to_string, []})
    |> map({String, :trim, []})
  end

  def block_comment() do
    ignore(string("/*"))
    |> repeat(
      lookahead_not(string("*/"))
      |> utf8_char([])
    )
    |> ignore(string("*/"))
    |> reduce({List, :to_string, []})
    |> map({String, :trim, []})
  end

  def int do
    optional(string("-"))
    |> ascii_string([?0..?9], min: 1)
    |> reduce({Enum, :join, [""]})
    |> map({String, :to_integer, []})
  end

  def float do
    optional(string("-"))
    |> ascii_string([?0..?9], min: 1)
    |> string(".")
    |> ascii_string([?0..?9], min: 1)
    |> reduce({Enum, :join, [""]})
    |> map({String, :to_float, []})
  end

  def bool_true() do
    string("true") |> replace(true)
  end

  def bool_false() do
    string("false") |> replace(false)
  end

  def bool do
    choice([bool_true(), bool_false()])
  end

  def header do
    ignore(string("<!-- kv3 encoding:text:version{"))
    |> string(@encoding_version)
    |> ignore(string("} format:generic:version{"))
    |> string(@format_version)
    |> ignore(string("} -->"))
  end

  # Added the quoted special case for: \"weapon_alternative_rmb+lmb_activate\"
  def key do
    choice([
      basic_key(),
      quoted_string()
    ])
  end

  def pairs_to_map(list, acc \\ [])

  def pairs_to_map([x, y | xs], acc), do: pairs_to_map(xs, [{x, y} | acc])
  def pairs_to_map(_, acc), do: Map.new(acc)

  def key_value_pair do
    key()
    |> ignore(whitespace())
    |> optional(ignore(string("=")))
    |> ignore(whitespace())
    |> parsec(:value)
  end

  def basic_key() do
    utf8_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 1)
  end

  # Valve uses simple quoted strings over multiple lines sometimes
  def quoted_string() do
    ignore(ascii_char([?\"]))
    |> repeat(
      lookahead_not(ascii_char([?\"]))
      |> utf8_char([])
    )
    |> ignore(ascii_char([?\"]))
    |> reduce({List, :to_string, []})
    |> map({String, :trim, []})
  end

  def multi_string() do
    ignore(ascii_string([?\"], 3))
    |> ignore(ascii_char([?\n]))
    |> repeat(
      lookahead_not(ascii_char([?\n]) |> ascii_string([?\"], 3))
      |> utf8_char([])
    )
    |> ignore(ascii_char([?\n]))
    |> ignore(ascii_string([?\"], 3))
    |> reduce({List, :to_string, []})
    |> map({String, :trim, []})
  end

  def value do
    choice([
      multi_string(),
      quoted_string(),
      float(),
      int(),
      bool(),
      parsec(:object),
      parsec(:list)
    ])
  end

  def flagged_value do
    utf8_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 1)
    |> ignore(string(":"))
    |> ignore(whitespace())
    |> concat(value())
    |> reduce({List, :to_tuple, []})
  end
end

defmodule KeyValues3.Parser do
  @moduledoc false

  import NimbleParsec
  import KeyValues3.Parser.Helpers

  # @known_kv3_flags [:resource, :resourcename, :resource_name, :panorama, :soundevent, :subclass]

  defparsecp(
    :object,
    ignore(string("{"))
    |> optional(
      times(
        ignore(whitespace())
        |> choice([key_value_pair(), ignore(line_comment()), ignore(block_comment())]),
        min: 0
      )
      |> reduce({:pairs_to_map, []})
    )
    |> ignore(whitespace())
    |> ignore(string("}"))
  )

  defparsecp(
    :list,
    ignore(string("["))
    |> label("list opening [")
    |> times(
      ignore(whitespace())
      |> choice([parsec(:value), ignore(line_comment()), ignore(block_comment())])
      |> ignore(whitespace())
      |> ignore(string(","))
      |> ignore(whitespace()),
      min: 0
    )
    |> optional(ignore(whitespace()))
    |> optional(parsec(:value))
    |> optional(ignore(whitespace()))
    |> ignore(string("]"))
    |> reduce({Enum, :into, [[]]})
  )

  defparsec(
    :value,
    choice([flagged_value(), value()])
    |> optional(ignore(whitespace()))
  )

  defparsec(
    :parse,
    ignore(header())
    |> ignore(whitespace())
    |> parsec(:value)
    |> ignore(whitespace())
  )

  if Mix.env() == :test do
    defparsec(:line_comment, line_comment())
    defparsec(:block_comment, block_comment())
  end
end
