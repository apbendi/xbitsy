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
  defp kLOOP(tokens), do: tokens |> keyword(:loop)

  defp whitespace(tokens, string), do: [{:whitespace, string} | tokens]
  defp newline(tokens), do: tokens |> whitespace("\n")
  defp space(tokens), do: tokens |> whitespace(" ")
  defp tab(tokens), do: tokens |> whitespace("\t")

  defp comment(tokens, string), do: [{:comment, "{#{string}}"} | tokens]

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

  test "parse the bitsy null program with comments" do
      tokens = start_tokens
                    |> comment("Opening comment") |> newline
                    |> kBEGIN |> newline |> comment("A comment\nIn the middle") |> newline
                    |> kEND |> space |> comment("A comment at the end!")
                |> finish_tokens
     
     assert parse(tokens) == {:ok, nil}
  end

  test "parse a bitsy program with a loop" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> kLOOP |> newline
                    |> tab |> kEND |> newline
                    |> kEND
                |> finish_tokens

      assert parse(tokens) == {:ok, nil}
  end

  test "parse a bitsy program with a nested loop" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> kLOOP |> newline
                    |> tab |> tab |> kLOOP |> newline
                    |> tab |> tab |> kEND |> newline
                    |> tab |> kEND |> newline
                    |> kEND
                |> finish_tokens

      assert parse(tokens) == {:ok, nil}
  end
end
