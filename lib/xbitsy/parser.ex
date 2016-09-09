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

    defp match([], expected_type), do: raise "[ERROR] Unexpected end of tokens when expecting: #{expected_type}"

    defp match([{current_type, value} | tail_tokens], expected_type) do
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
        {_, tokens} = tokens |> match(:begin)
        {_, tokens} = tokens |> match(:end)
        {:ok, nil}
    end
end