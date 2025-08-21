defmodule MatchingWeb.TraitLive.Form do
  use MatchingWeb, :live_view

  alias Matching.Accounts
  alias Matching.Accounts.Trait

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage trait records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="trait-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Trait</.button>
          <.button navigate={return_path(@return_to, @trait)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    trait = Accounts.get_trait!(id)

    socket
    |> assign(:page_title, "Edit Trait")
    |> assign(:trait, trait)
    |> assign(:form, to_form(Accounts.change_trait(trait)))
  end

  defp apply_action(socket, :new, _params) do
    trait = %Trait{}

    socket
    |> assign(:page_title, "New Trait")
    |> assign(:trait, trait)
    |> assign(:form, to_form(Accounts.change_trait(trait)))
  end

  @impl true
  def handle_event("validate", %{"trait" => trait_params}, socket) do
    changeset = Accounts.change_trait(socket.assigns.trait, trait_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"trait" => trait_params}, socket) do
    save_trait(socket, socket.assigns.live_action, trait_params)
  end

  defp save_trait(socket, :edit, trait_params) do
    case Accounts.update_trait(socket.assigns.trait, trait_params) do
      {:ok, trait} ->
        {:noreply,
         socket
         |> put_flash(:info, "Trait updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, trait))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_trait(socket, :new, trait_params) do
    case Accounts.create_trait(trait_params) do
      {:ok, trait} ->
        {:noreply,
         socket
         |> put_flash(:info, "Trait created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, trait))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _trait), do: ~p"/traits"
  defp return_path("show", trait), do: ~p"/traits/#{trait}"
end
