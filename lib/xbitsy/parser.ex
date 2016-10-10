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
        {tokens, statements} = tokens |> block
        tokens |> match(:end)

        tree = %{kind: :program, statements: statements}
        
        {:ok, tree}
    end

    defp block(tokens, statements \\ [])
    defp block([], _statements), do: raise "[ERROR] Unterminated block"
    defp block(tokens = [{:end, _token_value} | _tail_tokens], statements), do: {tokens, Enum.reverse(statements)} # Can/should we DRY this?
    defp block(tokens = [{:else, _token_value} | _tail_tokens], statements), do: {tokens, Enum.reverse(statements)}
    defp block(tokens = [{token_type, token_value} | _tail_tokens], statements) do
         {tokens, node} = case token_type do
            :ifz      -> if_statement(tokens)
            :ifp      -> if_statement(tokens)
            :ifn      -> if_statement(tokens)
            :loop     -> loop(tokens)
            :break    -> break(tokens)
            :print    -> print(tokens)
            :variable -> assignment(tokens)
            _ -> raise "[ERROR] Unexpected token in block #{token_value}"
        end

        block(tokens, [node | statements])
    end

    defp if_statement(tokens = [{if_type, _} | _tail_tokens]) when if_type == :ifz or if_type == :ifn or if_type == :ifp do
        tokens = tokens |> match(if_type)
        {tokens, exp_node} = tokens |> expression
        {tokens, conditional_statements} = tokens |> block
        {tokens, else_statements} = tokens |> else_statement
        tokens = tokens |> match(:end)

        {tokens, %{kind: if_type, test: exp_node, statements: conditional_statements, else_statements: else_statements}}
    end

    defp else_statement(tokens = [{next_type, _} | _tail_tokens]) do
        if :else == next_type do
            tokens = tokens |> match(:else)
            tokens |> block 
        else
            {tokens, []}
        end
    end

    defp loop(tokens) do
        tokens = tokens |> match(:loop)
        {tokens, statements} = tokens |> block
        tokens = tokens |> match(:end)
        
        {tokens, %{kind: :loop, statements: statements}}
    end

    defp break(tokens) do
        tokens = tokens |> match(:break)
        {tokens, %{kind: :break}}
    end

    defp print(tokens) do
        tokens = tokens |> match(:print)
        {tokens, exp_node} = tokens |> expression

        {tokens, %{kind: :print, value: exp_node}}
    end

    defp assignment(tokens) do
        {tokens, var_name} = tokens |> match_extract(:variable)
        tokens = tokens |> match(:assignment)
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
        {tokens, node} = tokens |> signed_factor
        binary_mul_op(tokens, node)
    end

    defp binary_mul_op(tokens = [{next_type, _next_value} | _tail_tokens], left_node) 
            when next_type == :multiplication or next_type == :division or next_type == :modulus do                
        {tokens, right_node} = tokens |> match(next_type) |> factor
        new_node = %{kind: next_type, left: left_node, right: right_node}
        binary_mul_op(tokens, new_node)
    end

    defp binary_mul_op(tokens, left_node), do: {tokens, left_node}

    defp signed_factor(tokens = [ {next_type, _next_value} | _tail_tokens]) do
        case next_type do
            :subtraction ->
                {tokens, factor_node} = tokens |> match(:subtraction) |> factor
                negate_node = %{kind: :subtraction, left: %{kind: :integer, value: "0"}, right: factor_node}
                {tokens, negate_node}
            :addition ->
                tokens |> match(:addition) |> factor
            _ -> 
                tokens |> factor
        end
    end

    defp factor(tokens = [{next_type, _next_value} | _tail_tokens]) do
        case next_type do
            :integer ->
                {tokens, integer} = tokens |> match_extract(:integer)
                node = %{kind: :integer, value: integer}
                {tokens, node}
            :variable ->
                {tokens, var_name} = tokens |> match_extract(:variable)
                node = %{kind: :variable, name: var_name}
                {tokens, node}
            :paren_open ->
                {tokens, node} = tokens |> match(:paren_open) |> expression
                tokens = tokens |> match(:paren_close)
                {tokens, node}
            _ ->
                raise "[ERROR] Unexpected token in expression; received #{next_type}"
        end
    end
end