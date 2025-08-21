defmodule Matching.Repo do
  use Ecto.Repo,
    otp_app: :matching,
    adapter: Ecto.Adapters.SQLite3
end
