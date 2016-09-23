defmodule RunnerTest do
    use ExUnit.Case
    doctest Xbitsy

    @moduletag timeout: 1000

    import Xbitsy.Runner

    test "it should run the bitsy null program" do
        tree = %{kind: :program, block: %{kind: :block, statements: []}}

        {status, print_output} = run(tree)
        assert status == :ok
        assert print_output == []
    end

    test "it should run a program printing an integer literal" do
        tree = %{kind: :program, block: %{kind: :block, statements: [
          %{kind: :print, value: %{kind: :integer, value: "116"}}  
        ]}}

        {status, print_output} = run(tree)
        assert status == :ok
        assert print_output == ["116"]
    end
end