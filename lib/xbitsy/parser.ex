defmodule Xbitsy.Parser do
    
    def parse(tokens) do
        tokens |>
            program
    end

    # UTILS

    defp match([{current_type, value} | tail_tokens], expected_type) do
        if expected_type == current_type do
            {value, tail_tokens}
        else
            raise "[ERROR] Expecting #{expected_type} token but received #{current_type}"
        end
    end

    defp match([], expected_type), do: raise "[ERROR] Unexpected end of tokens when expecting: #{expected_type}"

    # RECURSIVE DESCENT

    defp program(tokens) do
        try do
            {_, tokens} = tokens |> match(:begin)
            {_, tokens} = tokens |> match(:whitespace)
            {_, tokens} = tokens |> match(:end)
            {:ok, nil}
        rescue
            e in RuntimeError -> {:error, e.message}
        end
    end
end