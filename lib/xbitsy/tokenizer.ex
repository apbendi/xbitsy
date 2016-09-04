defmodule Xbitsy.Tokenizer do

  def lex(source), do: do_lex(source, [])

  def do_lex(source = << first :: utf8, tail :: binary >>, acc) do
    {lexeme, remaining} = take_matching(source, matcher_for(first), "")
    do_lex(remaining, [lexeme | acc])
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

  def matcher_for(char) do
    cond do
      is_white?(char) -> &is_white?/1
      is_ident?(char) -> &is_ident?/1
      true -> raise "Illegal character #{char}"
    end
  end

  # MATCHERS
  def is_white?(char) when char == ?\s or char == ?\t or char == ?\n, do: true
  def is_white?(_char), do: false
  def is_ident?(char) when (char >= ?A and char <= ?Z) or (char >= ?a and char <= ?z), do: true
  def is_ident?(_char), do: false
end
