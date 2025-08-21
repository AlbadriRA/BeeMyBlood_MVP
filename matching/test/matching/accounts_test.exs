defmodule Matching.AccountsTest do
  use Matching.DataCase

  alias Matching.Accounts

  describe "users" do
    alias Matching.Accounts.User

    import Matching.AccountsFixtures

    @invalid_attrs %{name: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", email: "some email"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.email == "some email"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", email: "some updated email"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.email == "some updated email"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "traits" do
    alias Matching.Accounts.Trait

    import Matching.AccountsFixtures

    @invalid_attrs %{name: nil}

    test "list_traits/0 returns all traits" do
      trait = trait_fixture()
      assert Accounts.list_traits() == [trait]
    end

    test "get_trait!/1 returns the trait with given id" do
      trait = trait_fixture()
      assert Accounts.get_trait!(trait.id) == trait
    end

    test "create_trait/1 with valid data creates a trait" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Trait{} = trait} = Accounts.create_trait(valid_attrs)
      assert trait.name == "some name"
    end

    test "create_trait/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_trait(@invalid_attrs)
    end

    test "update_trait/2 with valid data updates the trait" do
      trait = trait_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Trait{} = trait} = Accounts.update_trait(trait, update_attrs)
      assert trait.name == "some updated name"
    end

    test "update_trait/2 with invalid data returns error changeset" do
      trait = trait_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_trait(trait, @invalid_attrs)
      assert trait == Accounts.get_trait!(trait.id)
    end

    test "delete_trait/1 deletes the trait" do
      trait = trait_fixture()
      assert {:ok, %Trait{}} = Accounts.delete_trait(trait)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_trait!(trait.id) end
    end

    test "change_trait/1 returns a trait changeset" do
      trait = trait_fixture()
      assert %Ecto.Changeset{} = Accounts.change_trait(trait)
    end
  end
end
