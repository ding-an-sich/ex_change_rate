{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.configure(capture_log: true)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(ExChangeRate.Repo, :manual)

Mox.defmock(TeslaMock, for: Tesla.Adapter)
