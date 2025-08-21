defmodule MatchingWeb.TraitLiveTest do
  use MatchingWeb.ConnCase

  import Phoenix.LiveViewTest
  import Matching.AccountsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_trait(_) do
    trait = trait_fixture()

    %{trait: trait}
  end

  describe "Index" do
    setup [:create_trait]

    test "lists all traits", %{conn: conn, trait: trait} do
      {:ok, _index_live, html} = live(conn, ~p"/traits")

      assert html =~ "Listing Traits"
      assert html =~ trait.name
    end

    test "saves new trait", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/traits")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Trait")
               |> render_click()
               |> follow_redirect(conn, ~p"/traits/new")

      assert render(form_live) =~ "New Trait"

      assert form_live
             |> form("#trait-form", trait: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#trait-form", trait: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/traits")

      html = render(index_live)
      assert html =~ "Trait created successfully"
      assert html =~ "some name"
    end

    test "updates trait in listing", %{conn: conn, trait: trait} do
      {:ok, index_live, _html} = live(conn, ~p"/traits")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#traits-#{trait.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/traits/#{trait}/edit")

      assert render(form_live) =~ "Edit Trait"

      assert form_live
             |> form("#trait-form", trait: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#trait-form", trait: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/traits")

      html = render(index_live)
      assert html =~ "Trait updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes trait in listing", %{conn: conn, trait: trait} do
      {:ok, index_live, _html} = live(conn, ~p"/traits")

      assert index_live |> element("#traits-#{trait.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#traits-#{trait.id}")
    end
  end

  describe "Show" do
    setup [:create_trait]

    test "displays trait", %{conn: conn, trait: trait} do
      {:ok, _show_live, html} = live(conn, ~p"/traits/#{trait}")

      assert html =~ "Show Trait"
      assert html =~ trait.name
    end

    test "updates trait and returns to show", %{conn: conn, trait: trait} do
      {:ok, show_live, _html} = live(conn, ~p"/traits/#{trait}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/traits/#{trait}/edit?return_to=show")

      assert render(form_live) =~ "Edit Trait"

      assert form_live
             |> form("#trait-form", trait: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#trait-form", trait: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/traits/#{trait}")

      html = render(show_live)
      assert html =~ "Trait updated successfully"
      assert html =~ "some updated name"
    end
  end
end
