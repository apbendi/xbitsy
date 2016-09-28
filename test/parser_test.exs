defmodule ParserTest do
  use ExUnit.Case
  doctest Xbitsy

  @moduletag timeout: 1000

  import Xbitsy.Parser
  import TreeBuilder

  # CONVENIENCE TOKEN BUILDERS
  defp start_tokens(), do: []
  defp finish_tokens(tokens), do: Enum.reverse(tokens)
  
  defp keyword(tokens, symbol), do: [{symbol, String.upcase to_string(symbol) } | tokens]
  defp kBEGIN(tokens), do: tokens |> keyword(:begin)
  defp kEND(tokens), do: tokens |> keyword(:end)
  defp kLOOP(tokens), do: tokens |> keyword(:loop)
  defp kPRINT(tokens), do: tokens |> keyword(:print)

  defp whitespace(tokens, string), do: [{:whitespace, string} | tokens]
  defp newline(tokens), do: tokens |> whitespace("\n")
  defp space(tokens), do: tokens |> whitespace(" ")
  defp tab(tokens), do: tokens |> whitespace("\t")

  defp comment(tokens, string), do: [{:comment, "{#{string}}"} | tokens]
  defp variable(tokens, string), do: [{:variable, string} | tokens]
  defp integer(tokens, string), do: [{:integer, string} | tokens]

  defp opAssignment(tokens), do: [{:assignment, "="} | tokens]
  defp opAdd(tokens), do: [{:addition, "+"} | tokens]
  defp opSubtract(tokens), do: [{:subtraction, "-"} | tokens]

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

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program(empty_block)
  end

  test "parse the bitsy null program with comments" do
      tokens = start_tokens
                    |> comment("Opening comment") |> newline
                    |> kBEGIN |> newline |> comment("A comment\nIn the middle") |> newline
                    |> kEND |> space |> comment("A comment at the end!")
                |> finish_tokens
     
    {status, tree} = parse(tokens)
    assert status == :ok
    assert tree == program(empty_block)
  end

  test "parse a bitsy program with a loop" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> kLOOP |> newline
                    |> tab |> kEND |> newline
                    |> kEND
                |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program(block([empty_loop]))
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

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program block [ loop block [empty_loop] ]
  end

  test "parse a bitsy program with an int literal assignment" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> variable("foo") |> opAssignment |> integer("42")
                    |> kEND
               |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program block [assignment("foo", integer "42")]
  end

  test "parse a bitsy program with the addtion of three int literals" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> variable("bar") |> opAssignment 
                    |> integer("116") |> opAdd |> integer("827") |> opAdd |> integer("42") |> newline
                    |> kEND
              |> finish_tokens
      

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program block [assignment("bar", addition(integer("116"), addition(integer("827"), integer("42"))))]
  end

  test "parse a bitsy program with the addtion and subtraction of three int literals" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> variable("bar") |> opAssignment 
                    |> integer("116") |> opAdd |> integer("827") |> opSubtract |> integer("42") |> newline
                    |> kEND
              |> finish_tokens
      

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program block [assignment("bar", addition(integer("116"), subtraction(integer("827"), integer("42"))))]
  end

  test "parse a bitsy program that prints an integer literal" do
      tokens = start_tokens
                |> kBEGIN |> newline
                |> tab |> kPRINT |> space |> integer("116") |> newline
                |> kEND
            |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program block [print integer("116")]
  end

  test "parse a bitsy program that prints a subtraction of integer literals" do
      tokens = start_tokens
                |> kBEGIN |> newline
                |> tab |> kPRINT |> space |> integer("827") |> space |> opSubtract |> space |> integer("116") |> newline
                |> kEND
            |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program block [print subtraction(integer("827"), integer("116"))]
  end
end
