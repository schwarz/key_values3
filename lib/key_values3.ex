defmodule KeyValues3 do
  @moduledoc """
  A basic KeyValues3 (KV3) parser in pure Elixir.
  """

  @doc """
  Parses a KV3 value from `input`, skipping the typical header present in KV3 files.
  """
  def decode(input) do
    case KeyValues3.Parser.parse(input) do
      {:ok, result, _, _, _, _} ->
        {:ok, List.first(result)}

      {:error, _error, _, _, _, _} ->
        {:error, "failed to decode, create an issue on github if it shouldn't fail"}
    end
  end

  @doc """
  Parses a KV3 value from `input`, skipping the typical header present in KV3 files.

  Similar to decode/2 but raises in case of errors.
  """
  def decode!(input) do
    case decode(input) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  @doc """
    Parses a KV3 value from `input`.
  """
  def decode_value(input) do
    case KeyValues3.Parser.value(input) do
      {:ok, result, _, _, _, _} ->
        {:ok, List.first(result)}

      {:error, _error, _, _, _, _} ->
        {:error, "failed to decode, create an issue on github if it shouldn't fail"}
    end
  end

  @doc """
  Parses a KV3 value from `input`.

  Similar to decode_value/2 but raises in case of errors.
  """
  def decode_value!(input) do
    case decode_value(input) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end
end
