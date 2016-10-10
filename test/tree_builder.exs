defmodule TreeBuilder do
    def program(statements), do: %{kind: :program, statements: statements}

    def if(kind, test_node, statements, else_statements), do: %{kind: kind, test: test_node, statements: statements, else_statements: else_statements}
    def ifz(test_node, statements, else_statements \\ []), do: if(:ifz, test_node, statements, else_statements)
    def ifp(test_node, statements, else_statements \\ []), do: if(:ifp, test_node, statements, else_statements)
    def ifn(test_node, statements, else_statements \\ []), do: if(:ifn, test_node, statements, else_statements)
    def loop(statements), do: %{kind: :loop, statements: statements}
    def empty_loop(), do: loop([])
    def break(), do: %{kind: :break}

    def print(value_node), do: %{kind: :print, value: value_node}

    def variable(name), do: %{kind: :variable, name: name}
    def integer(value), do: %{kind: :integer, value: value}

    def assignment(var_name, value_node), do: %{kind: :assignment, variable: variable(var_name), value: value_node}

    def addition(left_node, right_node), do: %{kind: :addition, left: left_node, right: right_node}
    def subtraction(left_node, right_node), do: %{kind: :subtraction, left: left_node, right: right_node}
    def multiplication(left_node, right_node), do: %{kind: :multiplication, left: left_node, right: right_node}
    def division(left_node, right_node), do: %{kind: :division, left: left_node, right: right_node}
    def modulus(left_node, right_node), do: %{kind: :modulus, left: left_node, right: right_node}
end