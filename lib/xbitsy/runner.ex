defmodule Xbitsy.Runner do

    # program state
    defstruct prints: [], var_vals: %{}
    
    def run({:ok, tree}), do: run(tree)
    def run({:error, message}), do: IO.puts message

    def run(_tree = %{kind: :program, statements: statement_list}) do
        final_state = empty_state 
                    |> run_statements(statement_list)

        {:ok, final_state}
    end

    # RUN STATEMENT LIST
    defp run_statements(state, []), do: state

    defp run_statements(state, [first_statement | tail_statements]) do
        {:ok, statement_kind} = Map.fetch(first_statement, :kind)

        statement_processor = 
        case statement_kind do
            :ifz        -> &do_if/2
            :ifp        -> &do_if/2
            :ifn        -> &do_if/2
            :print      -> &do_print/2
            :assignment -> &do_assignment/2
            _ -> raise "Unexpected Kind of Statement: #{statement_kind}"
        end

        state 
            |> statement_processor.(first_statement) 
            |> run_statements(tail_statements)
    end

    # DO STATEMENTS

    defp do_if(state, %{kind: if_type, test: test_node, statements: statements, else_statements: else_statements}) do
        node_value = evaluate(state, test_node)
        branch? = test_for_if(if_type)

        branch_statements = if branch?.(node_value) do
            statements
        else
            else_statements
        end

        state |> run_statements(branch_statements)
    end

    defp do_print(state, %{kind: :print, value: node}) do
        node_value = evaluate(state, node)
        IO.puts node_value

       state |> append_prints(["#{node_value}"])
    end

    defp do_assignment(state, %{kind: :assignment, variable: %{kind: :variable, name: var_name}, value: val_node}) do
       node_value = evaluate(state, val_node)
       state |> assign_var(var_name, node_value)  
    end

    # EVALUATE EXPRESSIONS

    defp evaluate(state, %{kind: :variable, name: var_name}) do
        variable_value = state.var_vals[var_name]

        case variable_value do
            nil -> 0
            _   -> variable_value 
        end
    end

    defp evaluate(_state, %{kind: :integer, value: int_string}), do: int_string |> Integer.parse |> elem(0) 
    defp evaluate(state, %{kind: :addition, left: left_node, right: right_node}), do: state |> evaluate_binary(left_node, right_node, &+/2)
    defp evaluate(state, %{kind: :subtraction, left: left_node, right: right_node}), do: state |> evaluate_binary(left_node, right_node, &-/2)
    defp evaluate(state, %{kind: :multiplication, left: left_node, right: right_node}), do: state |> evaluate_binary(left_node, right_node, &*/2)
    defp evaluate(state, %{kind: :division, left: left_node, right: right_node}), do: state |> evaluate_binary(left_node, right_node, &div/2)
    defp evaluate(state, %{kind: :modulus, left: left_node, right: right_node}), do: state |> evaluate_binary(left_node, right_node, &rem/2)

    defp evaluate_binary(state, left_node, right_node, operation) do
        [right_node, left_node]
            |> Enum.map(&(evaluate(state, &1)))
            |> Enum.reduce(operation)
    end

    # HELPERS

    defp empty_state(), do: %Xbitsy.Runner{}

    defp append_prints(state, new_prints) do
        put_in(state.prints, List.flatten [state.prints | new_prints])
    end

    defp assign_var(state, var_name, var_value) do
        put_in(state.var_vals, Map.put(state.var_vals, var_name, var_value))
    end

    defp test_for_if(type) do
        case type do
            :ifz -> fn n -> n == 0 end
            :ifn -> fn n -> n < 0 end
            :ifp -> fn n -> n > 0 end
            _    -> raise "Internal error: expecting an if conditional type but received #{type}"
        end
    end
end