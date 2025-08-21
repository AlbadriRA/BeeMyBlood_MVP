defmodule MatchingWeb.UserLive.Form do
  use MatchingWeb, :live_view

  alias Matching.Accounts
  alias Matching.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage user records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="user-form" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input
          field={@form[:abo]}
          type="select"
          label="Groupe sanguin (ABO)"
          options={["A", "B", "AB", "O"]}
        />
        <.input field={@form[:rh]} type="select" label="Rhésus" options={["+", "-"]} /><.input
          field={@form[:role]}
          type="select"
          label="Rôle"
          options={[
            {"Donor", "donor"},
            {"Recipient", "recipient"},
            {"Donor and recipient", "both"}
          ]}
        />

        <.input field={@form[:canton]} type="text" label="Canton" />

        <button
          id="dropdownSearchButton"
          data-dropdown-toggle="dropdownSearch"
          data-dropdown-placement="bottom"
          class="mb-4 text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center inline-flex items-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          type="button"
        >
          Dropdown search
          <svg
            class="w-2.5 h-2.5 ms-3"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 10 6"
          >
            <path
              stroke="currentColor"
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="m1 1 4 4 4-4"
            />
          </svg>
        </button>
        
    <!-- Dropdown menu -->
        <div
          id="dropdownSearch"
          class="z-10 hidden bg-white rounded-lg shadow-sm w-60 dark:bg-gray-700 "
        >
          <div class="p-3">
            <label for="input-group-search" class="sr-only">Search</label>
            <div class="relative">
              <div class="absolute inset-y-0 rtl:inset-r-0 start-0 flex items-center ps-3 pointer-events-none">
                <svg
                  class="w-4 h-4 text-gray-500 dark:text-gray-400"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 20 20"
                >
                  <path
                    stroke="currentColor"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
                  />
                </svg>
              </div>
              <input
                type="text"
                id="input-group-search"
                class="block w-full p-2 ps-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-600 dark:border-gray-500 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                placeholder="Search user"
              />
            </div>
          </div>
          <ul
            class="h-48 px-3 pb-3 overflow-y-auto text-sm text-gray-700 dark:text-gray-200"
            aria-labelledby="dropdownSearchButton"
          >
            <%= for {name, id} <- @all_traits do %>
              <li>
                <div class="flex items-center ps-2 rounded-sm hover:bg-gray-100 dark:hover:bg-gray-600">
                  <input
                    id={"checkbox-item-#{id}"}
                    type="checkbox"
                    name="user[trait_ids][]"
                    value={id}
                    checked={id in (@form[:trait_ids].value || [])}
                    class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded-sm focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-700 dark:focus:ring-offset-gray-700 focus:ring-2 dark:bg-gray-600 dark:border-gray-500"
                  />
                  <label
                    for={"checkbox-item-#{id}"}
                    class="w-full py-2 ms-2 text-sm font-medium text-gray-900 rounded-sm dark:text-gray-300"
                  >
                    {name}
                  </label>
                </div>
              </li>
            <% end %>
          </ul>

          <a
            href="#"
            class="flex items-center p-3 text-sm font-medium text-red-600 border-t border-gray-200 rounded-b-lg bg-gray-50 dark:border-gray-600 hover:bg-gray-100 dark:bg-gray-700 dark:hover:bg-gray-600 dark:text-red-500 hover:underline"
          >
            <svg
              class="w-4 h-4 me-2"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="currentColor"
              viewBox="0 0 20 18"
            >
              <path d="M6.5 9a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9ZM8 10H5a5.006 5.006 0 0 0-5 5v2a1 1 0 0 0 1 1h11a1 1 0 0 0 1-1v-2a5.006 5.006 0 0 0-5-5Zm11-3h-6a1 1 0 1 0 0 2h6a1 1 0 1 0 0-2Z" />
            </svg>
            Delete user
          </a>
        </div>

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save User</.button>
          <.button navigate={return_path(@return_to, @user)}>Cancel</.button>
        </footer>
      </.form>
      <script>
        document.addEventListener("DOMContentLoaded", function () {
        const searchInput = document.getElementById("input-group-search")
        const items = document.querySelectorAll("#dropdownSearch ul li")

        searchInput.addEventListener("input", function () {
          const search = this.value.toLowerCase()
          items.forEach((item) => {
            const label = item.querySelector("label").innerText.toLowerCase()
            if (label.includes(search)) {
              item.style.display = "block"
            } else {
              item.style.display = "none"
            }
          })
        })
        })
      </script>
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
    user = Accounts.get_user!(id) |> Matching.Repo.preload(:traits)
    # Préremplir trait_ids pour le champ virtuel
    user = %{user | trait_ids: Enum.map(user.traits, & &1.id)}
    all_traits = Accounts.list_traits()

    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user(user)))
    |> assign(:all_traits, Enum.map(all_traits, &{&1.name, &1.id}))
  end

  defp apply_action(socket, :new, _params) do
    user = %User{trait_ids: []}
    all_traits = Accounts.list_traits()

    socket
    |> assign(:page_title, "New User")
    |> assign(:user, user)
    |> assign(:form, to_form(Accounts.change_user(user)))
    |> assign(:all_traits, Enum.map(all_traits, &{&1.name, &1.id}))
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user(socket.assigns.user, user_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.live_action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _user), do: ~p"/users"
  defp return_path("show", user), do: ~p"/users/#{user}"
end
