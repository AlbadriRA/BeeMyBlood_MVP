defmodule MatchingWeb.UserLive.Show do
  use MatchingWeb, :live_view

  alias Matching.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        User {@user.id}
        <:subtitle>This is a user record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/users"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/users/#{@user}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit user
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@user.name}</:item>
        <:item title="Email">{@user.email}</:item>
        <:item title="Abo">{@user.abo}</:item>
        <:item title="Rh">{@user.rh}</:item>
        <:item title="Rôle">{to_string(@user.role)}</:item>

        <:item title="Canton">{@user.canton}</:item>
        <:item title="Traits">
          <div class="relative">
            <button
              type="button"
              onclick="document.getElementById('show-user-traits-dropdown').classList.toggle('hidden')"
              class="text-white bg-blue-600 hover:bg-blue-700 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 text-center inline-flex items-center"
            >
              Voir les traits
              <svg
                class="w-2.5 h-2.5 ml-2"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 10 6"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M1 1l4 4 4-4"
                />
              </svg>
            </button>

            <div
              id="show-user-traits-dropdown"
              class="absolute mt-2 z-10 hidden w-64 max-h-60 overflow-y-auto bg-white rounded shadow dark:bg-gray-700 border dark:border-gray-600"
            >
              <div class="p-3">
                <label for="search-traits-show" class="sr-only">Search</label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                    <svg
                      class="w-4 h-4 text-gray-500 dark:text-gray-400"
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
                    id="search-traits-show"
                    class="block w-full p-2 pl-10 text-sm text-gray-900 border border-gray-300 rounded-lg bg-gray-50 focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-600 dark:border-gray-500 dark:placeholder-gray-400 dark:text-white"
                    placeholder="Rechercher un trait"
                  />
                </div>
              </div>

              <ul
                class="px-3 pb-3 text-sm text-gray-700 dark:text-gray-200"
                id="show-user-traits-list"
              >
                <%= for trait <- @user.traits do %>
                  <li class="py-1 px-2 hover:bg-gray-100 dark:hover:bg-gray-600 rounded">
                    {trait.name}
                  </li>
                <% end %>
              </ul>
            </div>
          </div>

          <script>
            document.addEventListener("DOMContentLoaded", function () {
              const searchInput = document.getElementById("search-traits-show")
              const items = document.querySelectorAll("#show-user-traits-list li")

              searchInput.addEventListener("input", function () {
                const search = this.value.toLowerCase()
                items.forEach((item) => {
                  const text = item.innerText.toLowerCase()
                  item.style.display = text.includes(search) ? "block" : "none"
                })
              })
            })
          </script>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user =
      Accounts.get_user!(id)
      |> Matching.Repo.preload(:traits)

    {:ok,
     socket
     |> assign(:page_title, "Show User")
     |> assign(:user, user)}
  end
end
