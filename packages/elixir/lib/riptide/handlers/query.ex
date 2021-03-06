defmodule Riptide.Handler.Query do
  @moduledoc false
  use Riptide.Handler

  def handle_call("riptide.query", query, state) do
    layers = Riptide.Query.flatten(query)

    query =
      Enum.reduce(layers, %{}, fn {path, opts}, collect -> Dynamic.put(collect, path, opts) end)

    case Riptide.query(query, state) do
      {:error, msg} ->
        {:error, msg, state}

      {:ok, result} ->
        Enum.each(layers, fn {path, opts} ->
          if opts[:subscribe] === true do
            Riptide.Subscribe.watch(path)
          end
        end)

        {:reply,
         layers
         |> Enum.reduce(Riptide.Mutation.new(result), fn {path, opts}, collect ->
           case opts == %{} do
             true -> Riptide.Mutation.put_delete(collect, path)
             false -> collect
           end
         end), state}
    end
  end
end
