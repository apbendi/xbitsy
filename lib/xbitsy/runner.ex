defmodule Xbitsy.Runner do

    defstruct prints: [] # program state
    
    def run({:ok, tree}), do: run(tree)
    def run({:error, message}), do: IO.puts message

    def run(_tree = %{kind: :program, statements: statement_list}) do
        final_state = run_statements(statement_list)
        {:ok, final_state.prints}
    end

    # RUN STATEMENT LIST

    defp run_statements(statement_list, state \\ %Xbitsy.Runner{})

    defp run_statements([], state), do: state

    defp run_statements([first_statement | tail_statements], state) do
        {:ok, statement_kind} = Map.fetch(first_statement, :kind)

        state = 
        case statement_kind do
            :print -> do_print(first_statement, state)
            _ -> raise "Unexpected Kind of Statement: #{statement_kind}"
        end

        run_statements(tail_statements, state)
    end

    # DO STATEMENTS

    defp do_print(%{kind: :print, value: node}, state) do
        node_value = evaluate(node)
        IO.puts node_value

       state |> append_prints(["#{node_value}"])
    end

    # EVALUATE EXPRESSIONS

    defp evaluate(%{kind: :integer, value: int_string}), do: int_string |> Integer.parse |> elem(0)
    defp evaluate(%{kind: :variable, name: _var_name}), do: 0 
    defp evaluate(%{kind: :addition, left: left_node, right: right_node}), do: evaluate_binary(left_node, right_node, &+/2)
    defp evaluate(%{kind: :subtraction, left: left_node, right: right_node}), do: evaluate_binary(left_node, right_node, &-/2)
    defp evaluate(%{kind: :multiplication, left: left_node, right: right_node}), do: evaluate_binary(left_node, right_node, &*/2)
    defp evaluate(%{kind: :division, left: left_node, right: right_node}), do: evaluate_binary(left_node, right_node, &div/2)
    defp evaluate(%{kind: :modulus, left: left_node, right: right_node}), do: evaluate_binary(left_node, right_node, &rem/2)

    defp evaluate_binary(left_node, right_node, operation) do
        [right_node, left_node]
            |> Enum.map(&evaluate/1)
            |> Enum.reduce(operation)
    end

    # HELPERS

    defp append_prints(state, new_prints) do
        put_in(state.prints, List.flatten [state.prints | new_prints])
    end
end