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
  defp opMultiply(tokens), do: [{:multiplication, "*"} | tokens]
  defp opDivide(tokens), do: [{:division, "/"} | tokens]
  defp opModulus(tokens), do: [{:modulus, "%"} | tokens]

  defp paren_open(tokens), do: [{:paren_open, "("} | tokens]
  defp paren_close(tokens), do: [{:paren_close, ")"} | tokens]

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
      assert tree == program []
  end

  test "parse the bitsy null program with comments" do
      tokens = start_tokens
                    |> comment("Opening comment") |> newline
                    |> kBEGIN |> newline |> comment("A comment\nIn the middle") |> newline
                    |> kEND |> space |> comment("A comment at the end!")
                |> finish_tokens
     
    {status, tree} = parse(tokens)
    assert status == :ok
    assert tree == program []
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
      assert tree == program [empty_loop]
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
      assert tree == program [ loop [empty_loop] ]
  end

  test "parse a bitsy program with an int literal assignment" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> variable("foo") |> opAssignment |> integer("42")
                    |> kEND
               |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [assignment("foo", integer "42")]
  end

  test "parse a bitsy program with the addtion of three int literals" do
      tokens = start_tokens
                    |> kBEGIN |> newline
                    |> tab |> variable("bar") |> opAssignment 
                    |> integer("116") |> opAdd |> integer("827") |> opAdd |> integer("42") |> newline # 116 + 827 + 42
                    |> kEND
              |> finish_tokens
      

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [assignment("bar", addition(addition(integer("116"), integer("827")), integer("42")))]
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
      assert tree == program [assignment("bar", subtraction(addition(integer("116"), integer("827")), integer("42")))]
  end

  test "parse a bitsy program that prints an integer literal" do
      tokens = start_tokens
                |> kBEGIN |> newline
                |> tab |> kPRINT |> space |> integer("116") |> newline
                |> kEND
            |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [print integer("116")]
  end

  test "parse a bitsy program that prints a subtraction of integer literals" do
      tokens = start_tokens
                |> kBEGIN |> newline
                |> tab |> kPRINT |> space |> integer("827") |> space |> opSubtract |> space |> integer("116") |> newline
                |> kEND
            |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [print subtraction(integer("827"), integer("116"))]
  end

  test "parse a bitsy program that prints the multiplication of integer literals" do
      tokens = start_tokens
                |> kBEGIN |> newline
                |> tab |> kPRINT |> space |> integer("2") |> space |> opMultiply |> integer("7") |> newline
                |> kEND
            |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [print multiplication(integer("2"), integer("7"))]
  end

  test "parse a bitsy program that prints the division of integer literals" do
      tokens = start_tokens
                |> kBEGIN |> newline
                |> kPRINT |> tab |> integer("116") |> opDivide |> integer("2") |> newline
                |> kEND
            |> finish_tokens
      
      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [print division(integer("116"), integer("2"))]
  end

  test "parse a bitsy program that prints the modulus of integer literals" do
      tokens = start_tokens
            |> kBEGIN |> newline
            |> tab |> kPRINT |> space |> integer("27") |> space |> opModulus |> space |> integer("6") |> newline
            |> kEND
        |> finish_tokens

     {status, tree} = parse(tokens)
     assert status == :ok
     assert tree == program [print modulus(integer("27"), integer("6"))]
  end

  test "parse a bitsy program that prints a negative integer literal" do
      tokens = start_tokens
            |> kBEGIN |> space |> kPRINT |> space |> opSubtract |> integer("54") |> space |> kEND
            |> finish_tokens
      
      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [print subtraction(integer("0"), integer("54"))]
  end

  test "parse a bitsy program with a parenthesized expression" do
      tokens = start_tokens
            |> kBEGIN |> newline
            |> tab |> kPRINT |> space |> integer("2") |> opMultiply 
            |> paren_open |> integer("1") |> opAdd |> integer("6") |> paren_close |> newline
            |> kEND
        |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [print multiplication(integer("2"), addition(integer("1"), integer("6")))]
  end

  test "parse a bitsy program adding a variable to an integer" do
      tokens = start_tokens
            |> kBEGIN |> newline
            |> tab |> kPRINT |> space |> integer("2") |> opAdd |> variable("x") |> newline
            |> kEND
        |> finish_tokens

      {status, tree} = parse(tokens)
      assert status == :ok
      assert tree == program [print addition(integer("2"), variable("x"))]
  end
end
