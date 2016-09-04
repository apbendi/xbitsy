defmodule Xbitsy.Tokenizer do

  def lex(source), do: do_lex(source, [])

  def do_lex(source = << first :: utf8, tail :: binary >>, acc) do
    if first == ?\s do
      {whitespace, remaining} = take_matching(source, &is_white?/1, "")
      do_lex(remaining, [whitespace | acc])
    else
      {identifier, remaining} = lex_ident(source, "")
      do_lex(remaining, [identifier | acc])
    end
  end

  def do_lex(<<>>, acc) do
    acc |> Enum.reverse
  end

  def take_matching(source = << first :: utf8, tail :: binary >>, matches?, acc) do
    cond do
      matches?.(first) -> take_matching(tail, matches?, << acc::binary, first::utf8 >>)
      true -> {acc, source}
    end
  end

  def take_matching(<<>>, _matches?, acc) do
    {acc, <<>>}
  end

  def lex_white(source = << first :: utf8, tail :: binary >>, acc) do
    cond do
      is_white?(first) -> lex_white(tail, << acc::binary, first::utf8 >>)
      true -> {acc, source}
    end
  end

  def lex_white(<<>>, acc) do
    {acc, <<>>}
  end

  def lex_ident(source = << first :: utf8, tail :: binary >>, acc) do
    cond do
      is_ident?(first) -> lex_ident(tail, << acc::binary, first::utf8 >>)
      true -> {acc, source}
    end
  end

  def lex_ident(<<>>, acc) do
    {acc, <<>>}
  end

  # MATCHERS
  def is_white?(char) when char == ?\s or char == ?\t or char == ?\n, do: true
  def is_white?(_char), do: false
  def is_ident?(char) when (char >= ?A and char <= ?Z) or (char >= ?a and char <= ?z), do: true
  def is_ident?(_char), do: false
end
