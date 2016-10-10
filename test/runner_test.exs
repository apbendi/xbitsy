defmodule RunnerTest do
    use ExUnit.Case
    doctest Xbitsy

    @moduletag timeout: 1000

    import Xbitsy.Runner
    import TreeBuilder

    test "it should run the bitsy null program" do
        {status, final_state} = run program []

        assert status == :ok
        assert final_state.prints == []
    end

    test "it should run a program printing an integer literal" do
        tree = program [print integer("116")]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["116"]
    end

    test "it should run a program printing multiple integer literals" do
        tree = program [print(integer "116"), print(integer "827"), print(integer "114")]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["116", "827", "114"]
    end

    test "it should run a program adding two integer literals" do
        tree = program [print addition(integer("116"), integer("827"))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["943"]
    end

    test "it should run a program subtracting two integer literals" do
        tree = program [print subtraction(integer("827"), integer("116"))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["711"]
    end

    test "it should run a program subtracting two integers from a third" do
        tree = program [print subtraction(subtraction(integer("10"), integer("2")), integer("1"))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["7"]
    end

    test "it should run a program multiplying two integers" do
        tree = program [print multiplication(integer("2"), integer("8"))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["16"]
    end

    test "it should run a program dividing two integers" do
        tree = program [print division(integer("8"), integer("2"))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["4"]
    end

    test "it should run a program performing the modulus of two integers" do
        tree = program [print modulus(integer("27"), integer("6"))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["3"]
    end

    test "it should run a program with parenthesized expression" do
        tree = program [print multiplication(integer("2"), addition(integer("1"), integer("6")))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["14"]
    end

    test "it should run a program that prints an expression using an unassigned expression" do
        tree = program [print multiplication(integer("2"), variable("new_var"))]
        {status, final_state} = run(tree)

        assert status == :ok
        assert final_state.prints == ["0"]
    end
end