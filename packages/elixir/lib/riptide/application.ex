defmodule Riptide.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Riptide.Subscribe, []}
      # Starts a worker by calling: Riptide.Worker.start_link(arg)
      # {Riptide.Worker, arg}
      # {Riptide.Websocket.Server, %{}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Riptide.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
