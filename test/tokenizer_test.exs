defmodule TokenizerTest do
  use ExUnit.Case
  doctest Xbitsy

  @moduletag timeout: 1000

  import Xbitsy.Tokenizer

  test "lex the letter B" do
    assert lex("BB") == ["BB"]
  end

  test "lex the BEGIN keyword" do
    assert lex("BEGIN") == ["BEGIN"]
  end

  test "lex the END keyword" do
    assert lex("END") == ["END"]
  end

  test "lex a space" do
    assert lex("  ") == ["  "]
  end

  test "lex a series of spaces" do
    assert lex("    ") == ["    "]
  end

  test "lex the bitsy null program" do
    assert lex("BEGIN END") == ["BEGIN", " ", "END"]
  end

  test "lex a variable name" do
    assert lex("BEGIN var END") == ["BEGIN", " ", "var", " ", "END"]
  end

  test "lex a number" do
    assert lex("116") == ["116"]
  end

  test "lex two numbers" do
    assert lex("116 827") == ["116", " ", "827"]
  end

  test "lex a number in a program" do
    assert lex("BEGIN x 42 \tEND") == ["BEGIN", " ", "x", " ", "42", " \t", "END"]
  end

  test "lex an operator" do
    assert lex("=") == ["="]
  end

  test "lex a series of operators" do
    assert lex("= + - * % /") == ["=", " ", "+", " ", "-", " ", "*", " ", "%", " ", "/"]
  end

  test "lex an assignment with math in a program" do
    assert lex("BEGIN x=42 + 2*2 \tEND") == ["BEGIN", " ", "x", "=", "42", " ", "+", " ", "2", "*", "2", " \t", "END"]
  end

  test "lex an open paren" do
    assert lex("(") == ["("]
  end

  test "lex a close paren" do
    assert lex(")") == [")"]
  end

  test "lex a series of parens" do
    assert lex("()(()) )(") == ["(", ")", "(", "(", ")", ")", " ", ")", "("]
  end

  test "lex parens in a mathematical statement" do
    assert lex("x=2*((1 + 1) - 42)") == ["x", "=", "2", "*", "(", "(", "1", " ", "+", " ", "1", ")", " ", "-", " ", "42", ")"] 
  end

  test "lex a comment" do
    assert lex("{ Hello Comment }") == ["{ Hello Comment }"]
  end

  test "lex comments in a program" do
    assert lex("{ hi }BEGIN\n\tPRINT42\n{ prints forty two}\nEND\n\n{ /FIN }") == ["{ hi }", "BEGIN", "\n\t", "PRINT", "42", "\n", "{ prints forty two}", "\n", "END", "\n\n", "{ /FIN }"]
  end

  test "tokenize the BEGIN keyword" do
    assert tokenize("BEGIN") == [{:begin, "BEGIN"}]
  end

  test "tokenize the Bitsy null program" do
    assert tokenize("BEGIN\nEND") == [{:begin, "BEGIN"}, {:whitespace, "\n"}, {:end, "END"}]
  end

  test "tokenize a series of keywords" do
    tokens = [
              {:begin, "BEGIN"}, {:whitespace, "\n"},
              {:ifz, "IFZ"}, {:whitespace, "\n"},
              {:else, "ELSE"}, {:whitespace, "\n"},
              {:end, "END"}, {:whitespace, "\n"},
              {:loop, "LOOP"}, {:whitespace, "\n"},
              {:end, "END"}, {:whitespace, "\n"},
              {:ifp, "IFP"}, {:whitespace, "\n"},
              {:end, "END"}, {:whitespace, "\n"},
              {:ifn, "IFN"}, {:whitespace, "\n"},
              {:end, "END"}, {:whitespace, "\n"},
              {:print, "PRINT"}, {:whitespace, "\n"},
              {:read, "READ"}, {:whitespace, "\n"},
              {:end, "END"}, {:whitespace, "\n"},
             ]
    assert tokenize("BEGIN\nIFZ\n\ELSE\nEND\nLOOP\nEND\nIFP\nEND\nIFN\nEND\nPRINT\nREAD\nEND\n") == tokens
  end

  test "tokenize an assignment operator" do
    assert tokenize("=") == [{:assignment, "="}]
  end

  test "tokenize a series of operators" do
    tokens = [
              {:assignment, "="}, {:whitespace, " "},
              {:addition, "+"}, {:whitespace, " "},
              {:subtraction, "-"}, {:whitespace, " "},
              {:division, "/"}, {:whitespace, " "},
              {:modulus, "%"}, {:whitespace, " "},
              {:multiplication, "*"}
             ]
    assert tokenize("= + - / % *") == tokens
  end

  test "tokenize an open and closed paren" do
    assert tokenize("()") == [{:paren_open, "("}, {:paren_close, ")"}]
  end

  test "tokenize a series of parens" do
    tokens = [
      {:paren_open, "("},
      {:paren_open, "("},
      {:paren_close, ")"},
      {:paren_close, ")"},
      {:paren_close, ")"},
      {:whitespace, " "},
      {:paren_close, ")"},
      {:paren_open, "("},
      {:whitespace, " "},
      {:paren_open, "("},
      {:paren_close, ")"},
    ]
    assert tokenize("(())) )( ()") == tokens
  end
end
