defmodule RunnerTest do
    use ExUnit.Case
    doctest Xbitsy

    @moduletag timeout: 1000

    import Xbitsy.Runner
    import TreeBuilder

    test "it should run the bitsy null program" do
        {status, print_output} = run program empty_block

        assert status == :ok
        assert print_output == []
    end

    test "it should run a program printing an integer literal" do
        tree = program block [print integer("116")]
        {status, print_output} = run(tree)

        assert status == :ok
        assert print_output == ["116"]
    end

    test "it should run a program printing multiple integer literals" do
        tree = program block [print(integer "116"), print(integer "827"), print(integer "114")]
        {status, print_output} = run(tree)

        assert status == :ok
        assert print_output == ["116", "827", "114"]
    end

    test "it should run a program adding two integer literals" do
        tree = program block [print addition(integer("116"), integer("827"))]
        {status, print_output} = run(tree)

        assert status == :ok
        assert print_output == ["943"]
    end

    test "it should run a program subtracting two integer literals" do
        tree = program block [print subtraction(integer("827"), integer("116"))]
        {status, print_output} = run(tree)

        assert status == :ok
        assert print_output == ["711"]
    end

    test "it should run a program subtracting two integers from a third" do
        tree = program block [print subtraction(integer("10"), subtraction(integer("2"), integer("1")))]
        {status, print_output} = run(tree)

        IO.inspect tree

        assert status == :ok
        assert print_output == ["7"]
    end
end