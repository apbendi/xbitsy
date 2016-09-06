defmodule Xbitsy.Tokenizer do

  def tokenize(source) do
    source
      |> lex
      |> Enum.map(&to_token/1)
  end

  # KEYWORDS
  defp to_token("BEGIN"),  do: {:begin, "BEGIN"}
  defp to_token("END"),    do: {:end, "END"}
  defp to_token("IFP"),    do: {:ifp, "IFP"}
  defp to_token("IFZ"),    do: {:ifz, "IFZ"}
  defp to_token("IFN"),    do: {:ifn, "IFN"}
  defp to_token("ELSE"),   do: {:else, "ELSE"}
  defp to_token("LOOP"),   do: {:loop, "LOOP"}
  defp to_token("PRINT"),  do: {:print, "PRINT"}
  defp to_token("READ"),   do: {:read, "READ"}

  # OPERATORS
  defp to_token("="), do: {:assignment, "="}
  defp to_token("+"), do: {:addition, "+"}
  defp to_token("-"), do: {:subtraction, "-"}
  defp to_token("/"), do: {:division, "/"}
  defp to_token("%"), do: {:modulus, "%"}
  defp to_token("*"), do: {:multiplication, "*"}

  # PARENS
  defp to_token("("), do: {:paren_open, "("}
  defp to_token(")"), do: {:paren_close, ")"}

  defp to_token(lexeme = <<first::utf8, _tail::binary>>) do
    cond do
      ?{ == first      -> {:comment, lexeme}
      is_white?(first) -> {:whitespace, lexeme}
      is_ident?(first) -> {:variable, lexeme}
      is_num?(first)   -> {:integer, lexeme}
      true             -> raise "Unexpected lexical symbol: #{lexeme}"
    end
  end

  def lex(source), do: do_lex(source, [])

  defp do_lex(<<?(::utf8, tail::binary>>, acc), do: do_lex(tail, ["(" | acc])
  defp do_lex(<<?)::utf8, tail::binary>>, acc), do: do_lex(tail, [")" | acc])

  defp do_lex(source = <<first::utf8, _tail::binary>>, acc) do
    {lexeme, remaining} = case first do
        ?{ -> source |> take_comment("")
        _  -> source |> take_matching(matcher_for(first), "")
      end 
    do_lex(remaining, [lexeme | acc])
  end

  defp do_lex("", acc) do
    acc |> Enum.reverse
  end

  defp take_matching(source = <<first::utf8, tail::binary>>, matches?, acc) do
    if matches?.(first) do
      tail |> take_matching(matches?, << acc::binary, first::utf8>>)
    else
     {acc, source}
    end
  end

  defp take_matching("", _matches?, acc) do
    {acc, ""}
  end

  defp take_comment(<<?}::utf8, tail::binary >>, acc), do: {<<acc::binary, ?}::utf8>>, tail}
  defp take_comment(<<first::utf8, tail::binary >>, acc) do
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
