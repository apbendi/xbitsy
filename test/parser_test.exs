defmodule ParserTest do
  use ExUnit.Case
  doctest Xbitsy

  @moduletag timeout: 1000

  import Xbitsy.Parser

  defp is_error?({:error, <<"[ERROR]"::binary, tail::binary>>}), do: true
  defp is_error?(_response), do: false

  test "throw error parsing a single keyword" do
      tokens = [{:begin, "BEGIN"}]
      result = parse(tokens)
      
      assert is_error?(result)
  end

  test "parse the bitsy null program" do
      tokens = [{:begin, "BEGIN"}, {:whitespace, "\n"}, {:end, "END"}]
      {status, _} = parse(tokens)
      assert status == :ok
  end

end