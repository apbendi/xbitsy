defmodule Xbitsy.Tokenizer do

  def lex(source), do: do_lex(source, [])

  defp do_lex(<< ?( :: utf8, tail :: binary >>, acc), do: do_lex(tail, ["(" | acc])
  defp do_lex(<< ?) :: utf8, tail :: binary >>, acc), do: do_lex(tail, [")" | acc])

  defp do_lex(source = << first :: utf8, _tail :: binary >>, acc) do
    {lexeme, remaining} = case first do
        ?{ -> source |> take_comment("")
        _  -> source |> take_matching(matcher_for(first), "")
      end 
    do_lex(remaining, [lexeme | acc])
  end

  defp do_lex(<<>>, acc) do
    acc |> Enum.reverse
  end

  defp take_matching(source = << first :: utf8, tail :: binary >>, matches?, acc) do
    cond do
      matches?.(first) -> tail |> take_matching(matches?, << acc::binary, first::utf8 >>)
      true -> {acc, source}
    end
  end

  defp take_matching(<<>>, _matches?, acc) do
    {acc, <<>>}
  end

  defp take_comment(<< ?}::utf8, tail::binary >>, acc), do: {<< acc::binary, ?}::utf8>>, tail}
  defp take_comment(<< first::utf8, tail::binary >>, acc) do
    take_comment(tail, << acc::binary, first::utf8 >>)  
  end

  defp matcher_for(char) do
    cond do
      is_white?(char)    -> &is_white?/1
      is_ident?(char)    -> &is_ident?/1
      is_num?(char)      -> &is_num?/1
      is_operator?(char) -> &is_operator?/1
      true               -> raise "Illegal character #{<<char>>}"
    end
  end

  # MATCHERS
  defp is_white?(char),    do: char == ?\s or char == ?\t or char == ?\n
  defp is_ident?(char),    do: (char >= ?A and char <= ?Z) or (char >= ?a and char <= ?z)
  defp is_num?(char),      do: char >= ?0 and char <= ?9
  defp is_operator?(char), do: char == ?= or char == ?* or char == ?/ or char == ?% or char == ?+ or char == ?-
end
