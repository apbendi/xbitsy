defmodule RunnerTest do
    use ExUnit.Case
    doctest Xbitsy

    @moduletag timeout: 1000

    import Xbitsy.Runner

    test "it should run" do
        tree = %{kind: :program, block: %{kind: :block, statements: []}}

        {status, print_output} = run(tree)
        assert status == :ok
        assert print_output == []
    end
end