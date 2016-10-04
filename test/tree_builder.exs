defmodule TreeBuilder do
    def program(block), do: %{kind: :program, block: block}

    def block(statements), do: %{kind: :block, statements: statements}
    def empty_block(), do: block([])

    def loop(block), do: %{kind: :loop, block: block}
    def empty_loop(), do: loop(empty_block)

    def print(value_node), do: %{kind: :print, value: value_node}

    def variable(name), do: %{kind: :variable, name: name}
    def integer(value), do: %{kind: :integer, value: value}

    def assignment(var_name, value_node), do: %{kind: :assignment, variable: variable(var_name), value: value_node}

    def addition(left_node, right_node), do: %{kind: :addition, left: left_node, right: right_node}
    def subtraction(left_node, right_node), do: %{kind: :subtraction, left: left_node, right: right_node}
    def multiplication(left_node, right_node), do: %{kind: :multiplication, left: left_node, right: right_node}
    def division(left_node, right_node), do: %{kind: :division, left: left_node, right: right_node}
end