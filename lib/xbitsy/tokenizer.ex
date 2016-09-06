defmodule Xbitsy.Tokenizer do

  def tokenize(source) do
    source
      |> lex
      |> Enum.map(&to_token/1)
  end

  # KEYWORDS
  def to_token("BEGIN"),  do: {:begin, "BEGIN"}
  def to_token("END"),    do: {:end, "END"}
  def to_token("IFP"),    do: {:ifp, "IFP"}
  def to_token("IFZ"),    do: {:ifz, "IFZ"}
  def to_token("IFN"),    do: {:ifn, "IFN"}
  def to_token("ELSE"),   do: {:else, "ELSE"}
  def to_token("LOOP"),   do: {:loop, "LOOP"}
  def to_token("PRINT"),  do: {:print, "PRINT"}
  def to_token("READ"),   do: {:read, "READ"}

  # OPERATORS
  def to_token("="), do: {:assignment, "="}
  def to_token("+"), do: {:addition, "+"}
  def to_token("-"), do: {:subtraction, "-"}
  def to_token("/"), do: {:division, "/"}
  def to_token("%"), do: {:modulus, "%"}
  def to_token("*"), do: {:multiplication, "*"}

  # PARENS
  def to_token("("), do: {:paren_open, "("}
  def to_token(")"), do: {:paren_close, ")"}

  def to_token(lexeme = <<first::utf8, _tail::binary>>) do
    cond do
      is_white?(first) -> {:whitespace, lexeme}
      true -> raise "Unexpected lexical symbol: #{lexeme}"
    end
  end

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

  defp do_lex("", acc) do
    acc |> Enum.reverse
  end

  defp take_matching(source = << first :: utf8, tail :: binary >>, matches?, acc) do
    if matches?.(first) do
      tail |> take_matching(matches?, << acc::binary, first::utf8 >>)
    else
     {acc, source}
    end
  end

  defp take_matching("", _matches?, acc) do
    {acc, ""}
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
