defmodule Xbitsy.Runner do
    
    def run(_tree = %{kind: :program, block: %{kind: :block, statements: statement_list}}) do
        printed_output = run_statements(statement_list)
        {:ok, printed_output}
    end

    defp run_statements(statement_list, printed_acc \\ [])
    defp run_statements([], printed_acc), do: printed_acc
end