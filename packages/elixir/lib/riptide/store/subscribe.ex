defmodule Riptide.Subscribe do
  @moduledoc false

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {:pg, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def watch(path), do: watch(path, self())

  def watch(path, pid) do
    group = group(path)

    cond do
      member?(group, pid) ->
        :ok

      true ->
        :pg.join(group, pid)
    end
  end

  def member?(group, pid), do: pid in :pg.get_members(group)

  # TODO: This could have a better implementation
  @spec broadcast_mutation(Riptide.Mutation.t()) :: :ok
  def broadcast_mutation(mut) do
    mut
    |> Riptide.Mutation.layers()
    |> Stream.flat_map(fn {path, value} ->
      Stream.concat([
        [{path, Riptide.Mutation.inflate(path, value)}],
        value.delete
        |> Stream.filter(fn {_, value} -> value === 1 end)
        |> Stream.map(fn {key, _} ->
          {path ++ [key], Riptide.Mutation.put_delete(path ++ [key])}
        end)
      ])
    end)
    |> Enum.group_by(fn {path, _mut} -> path end, fn {_, mut} -> mut end)
    |> Enum.map(fn {path, muts} ->
      {path,
       muts
       |> Enum.reduce(Riptide.Mutation.new(), fn collect, item ->
         %Riptide.Mutation{
           merge: Dynamic.combine(collect.merge, item.merge),
           delete: Dynamic.combine(collect.delete, item.delete)
         }
       end)}
    end)
    |> Enum.each(fn {path, value} ->
      members =
        path
        |> group()
        |> :pg.get_members()

      Enum.map(members, fn pid -> send(pid, {:mutation, value}) end)
    end)
  end

  def group(path) do
    {__MODULE__, path}
  end
end
