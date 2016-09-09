defmodule ParserTest do
  use ExUnit.Case
  doctest Xbitsy

  @moduletag timeout: 1000

  import Xbitsy.Parser

  # CONVENIENCE TOKEN BUILDERS
  defp start_tokens(), do: []
  defp finish_tokens(tokens), do: Enum.reverse(tokens)
  
  defp keyword(tokens, symbol), do: [{symbol, String.upcase to_string(symbol) } | tokens]
  defp kBEGIN(tokens), do: tokens |> keyword(:begin)
  defp kEND(tokens), do: tokens |> keyword(:end)

  defp whitespace(tokens, string), do: [{:whitespace, string} | tokens]
  defp newline(tokens), do: tokens |> whitespace("\n")

  # CONVENIENCE VALIDATORS
  defp is_error?({:error, <<"[ERROR]"::binary, _tail::binary>>}), do: true
  defp is_error?(_response), do: false

  test "throw error parsing a single keyword" do
      tokens = start_tokens |> kBEGIN |> finish_tokens

      result = parse(tokens)
      assert is_error?(result)
  end

  test "parse the bitsy null program" do
      tokens = start_tokens 
                    |> kBEGIN 
                    |> newline 
                    |> kEND 
               |> finish_tokens

      {status, _} = parse(tokens)
      assert status == :ok
  end

end