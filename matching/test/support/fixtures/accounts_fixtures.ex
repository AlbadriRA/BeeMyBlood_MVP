defmodule Matching.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Matching.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name"
      })
      |> Matching.Accounts.create_user()

    user
  end

  @doc """
  Generate a trait.
  """
  def trait_fixture(attrs \\ %{}) do
    {:ok, trait} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Matching.Accounts.create_trait()

    trait
  end
end
