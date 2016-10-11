defmodule Xbitsy.CLI do

    import Xbitsy.Tokenizer
    import Xbitsy.Parser
    import Xbitsy.Runner

    def run_bitsy(argv) do
        argv
            |> read_bitsy_source
            |> tokenize
            |> parse
            |> run
    end

    defp read_bitsy_source(path) do
        case File.read(path) do
            {:ok, body} -> body
            {:error, reason} -> 
                IO.puts "[ERROR] Failed to read file #{path}, reason: #{reason}"
                System.halt(-1)
        end
    end
end
