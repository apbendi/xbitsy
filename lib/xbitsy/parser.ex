defmodule Xbitsy.Parser do
    
    def parse(tokens) do
        try do
            tokens
                |> skip_over 
                |> program
        rescue
            e in RuntimeError -> {:error, e.message}
        end
    end

    # UTILITY FUNCTIONS

    defp match(tokens, expected_type) do
        {tail_tokens, _value} = tokens |> match_extract(expected_type)
        tail_tokens
    end

    defp match_extract([], expected_type), do: raise "[ERROR] Unexpected end of tokens when expecting: #{expected_type}"
    defp match_extract([{current_type, value} | tail_tokens], expected_type) do
        if expected_type == current_type do
            tail_tokens = tail_tokens |> skip_over
            {tail_tokens, value}
        else
            raise "[ERROR] Expecting #{expected_type} token but received #{current_type}"
        end
    end

    defp skip_over([{:whitespace, _} | tail_tokens]), do: skip_over(tail_tokens)
    defp skip_over([{:comment, _}    | tail_tokens]), do: skip_over(tail_tokens)
    defp skip_over(tokens),  do: tokens

    # RECURSIVE DESCENT

    defp program(tokens) do
        tokens = tokens |> match(:begin)
        {tokens, node} = tokens |> block
        tokens |> match(:end)

        tree = %{kind: :program, block: node}
        
        {:ok, tree}
    end

    defp block(tokens, statements \\ [])
    defp block([], _statements), do: raise "[ERROR] Unterminated block"
    defp block(tokens = [{:end, _token_value} | _tail_tokens], statements), do: {tokens, %{kind: :block, statements: Enum.reverse(statements)}}
    defp block(tokens = [{token_type, token_value} | _tail_tokens], statements) do
         {tokens, node} = case token_type do
            :loop     -> loop(tokens)
            :variable -> assignment(tokens)
            :print    -> print(tokens)
            _ -> raise "[ERROR] Unexpected token in block #{token_value}"
        end

        block(tokens, [node | statements])
    end

    defp loop(tokens) do
        tokens = tokens |> match(:loop)
        {tokens, node} = tokens |> block
        tokens = tokens |> match(:end)
        
        {tokens, %{kind: :loop, block: node}}
    end

    defp print(tokens) do
        tokens = tokens |> match(:print)
        {tokens, exp_node} = tokens |> expression

        {tokens, %{kind: :print, value: exp_node}}
    end

    defp assignment(tokens) do
        {tokens, var_name} = tokens |> match_extract(:variable)
        tokens = tokens |> match(:assignment)
        #{tokens, integer} = tokens |> match_extract(:integer)
        {tokens, exp_node} = tokens |> expression
        
        node = %{kind: :assignment, variable: %{kind: :variable, name: var_name}, value: exp_node}
        {tokens,  node}
    end

    defp expression(tokens = [{_token_type, _token_value} | _tail_tokens]) do
        {tokens, node} = tokens |> term
        binary_add_op(tokens, node)
    end

    defp binary_add_op(tokens = [{next_type, _next_value} | _tail_tokens], left_node) when next_type == :addition or next_type == :subtraction do
        {tokens, right_node} = tokens |> match(next_type) |> term
        new_node = %{kind: next_type, left: left_node, right: right_node}
        binary_add_op(tokens, new_node)
    end

    defp binary_add_op(tokens, left_node), do: {tokens, left_node}

    defp term(tokens) do
        {tokens, integer} = tokens |> match_extract(:integer)
        node = %{kind: :integer, value: integer}

        {tokens, node}
    end
end