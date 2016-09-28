defmodule Xbitsy.Runner do
    
    def run({:ok, tree}), do: run(tree)
    def run({:error, message}), do: IO.puts message

    def run(_tree = %{kind: :program, block: %{kind: :block, statements: statement_list}}) do
        printed_output = run_statements(statement_list)
        {:ok, printed_output}
    end

    # RUN STATEMENT LIST

    defp run_statements(statement_list, printed_acc \\ [])

    defp run_statements([], printed_acc), do: printed_acc

    defp run_statements([first_statement | tail_statements], printed_acc) do
        {:ok, statement_kind} = Map.fetch(first_statement, :kind)

        statement_prints = 
        case statement_kind do
            :print -> do_print(first_statement)
            _ -> raise "Unexpected Kind of Statement: #{statement_kind}"
        end

        printed_acc = printed_acc |> append_prints(statement_prints)

        run_statements(tail_statements, printed_acc)
    end

    # DO STATEMENTS

    defp do_print(%{kind: :print, value: node}) do
        node_value = evaluate(node)
        IO.puts node_value
        ["#{node_value}"]
    end

    # EVALUATE EXPRESSIONS

    defp evaluate(%{kind: :integer, value: int_string}), do: int_string |> Integer.parse |> elem(0)
    defp evaluate(%{kind: :addition, left: left_node, right: right_node}) do
        [left_node, right_node]
            |> Enum.map(&evaluate/1)
            |> Enum.reduce(&(&1 + &2))
    end

    # HELPERS

    defp append_prints(acc, new_prints), do: List.flatten [acc | new_prints]
end