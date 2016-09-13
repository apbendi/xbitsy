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
        {_value, tail_tokens} = tokens |> match_extract(expected_type)
        tail_tokens
    end

    defp match_extract([], expected_type), do: raise "[ERROR] Unexpected end of tokens when expecting: #{expected_type}"
    defp match_extract([{current_type, value} | tail_tokens], expected_type) do
        if expected_type == current_type do
            tail_tokens = tail_tokens |> skip_over
            {value, tail_tokens}
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

    defp block([]), do: raise "[ERROR] Unterminated block"
    defp block(tokens = [{:end, _token_value} | _tail_tokens]), do: {tokens, %{kind: :block, statements: []}}
    defp block(tokens = [{token_type, token_value} | _tail_tokens]) do
         {tokens, _node} = case token_type do
            :loop -> loop(tokens)
            _ -> raise "[ERROR] Unexpected token in block #{token_value}"
        end

        block(tokens)
    end

    defp loop(tokens) do
        tokens = tokens |> match(:loop)
        {tokens, node} = tokens |> block
        tokens = tokens |> match(:end)
        
        {tokens, node}
    end
end