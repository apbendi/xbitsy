defmodule Xbitsy.Tokenizer do

  def lex(source), do: do_lex(source, [])

  def do_lex(source = << first :: utf8, tail :: binary >>, acc) do
    if first == ?\s do
      {whitespace, remaining} = lex_white(source, "")
      do_lex(remaining, [whitespace | acc])
    else
      {identifier, remaining} = lex_ident(source, "")
      do_lex(remaining, [identifier | acc])
    end
  end

  def do_lex(<<>>, acc) do
    acc |> Enum.reverse
  end

  def lex_white(source = << first :: utf8, tail :: binary >>, acc) do
    case first do
      ?\s -> lex_white(tail, << acc::binary, first::utf8 >>)
      _ -> {acc, source}
    end
  end

  def lex_white(<<>>, acc) do
    {acc, <<>>}
  end

  def lex_ident(source = << first :: utf8, tail :: binary >>, acc) do
    cond do
      is_ident(first) -> lex_ident(tail, << acc::binary, first::utf8 >>)
      true -> {acc, source}
    end
  end

  def lex_ident(<<>>, acc) do
    {acc, <<>>}
  end

  def is_ident(char) when char >= ?A and char <= ?Z, do: true
  def is_ident(_char), do: false
end
