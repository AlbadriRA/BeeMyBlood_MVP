defmodule Matching.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Matching.Repo

  alias Matching.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def list_recipients do
    import Ecto.Query
    alias Matching.Accounts.User
    alias Matching.Repo

    from(u in User, where: u.role in ^[:recipient, :both])
    |> Repo.all()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Matching.Accounts.Trait

  @doc """
  Returns the list of traits.

  ## Examples

      iex> list_traits()
      [%Trait{}, ...]

  """
  def list_traits do
    Repo.all(Trait)
  end

  @doc """
  Gets a single trait.

  Raises `Ecto.NoResultsError` if the Trait does not exist.

  ## Examples

      iex> get_trait!(123)
      %Trait{}

      iex> get_trait!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trait!(id), do: Repo.get!(Trait, id)

  @doc """
  Creates a trait.

  ## Examples

      iex> create_trait(%{field: value})
      {:ok, %Trait{}}

      iex> create_trait(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trait(attrs) do
    %Trait{}
    |> Trait.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trait.

  ## Examples

      iex> update_trait(trait, %{field: new_value})
      {:ok, %Trait{}}

      iex> update_trait(trait, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trait(%Trait{} = trait, attrs) do
    trait
    |> Trait.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a trait.

  ## Examples

      iex> delete_trait(trait)
      {:ok, %Trait{}}

      iex> delete_trait(trait)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trait(%Trait{} = trait) do
    Repo.delete(trait)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trait changes.

  ## Examples

      iex> change_trait(trait)
      %Ecto.Changeset{data: %Trait{}}

  """
  def change_trait(%Trait{} = trait, attrs \\ %{}) do
    Trait.changeset(trait, attrs)
  end
end
