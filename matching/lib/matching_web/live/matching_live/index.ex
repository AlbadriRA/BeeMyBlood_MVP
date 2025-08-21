defmodule MatchingWeb.MatchingLive.Index do
  use MatchingWeb, :live_view

  alias Matching.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Recipient Matching
        <:subtitle>
          Select a recipient to start searching for compatible donors.
        </:subtitle>
      </.header>
      
      <div class="mb-4 flex gap-4">
        <label>
          Sort by
          <select phx-change="sort" name="sort" value={@sort_by} class="ml-2 border rounded px-2 py-1">
            <option value="name">Name</option>
            
            <option value="abo">Blood group</option>
          </select>
        </label>
      </div>
      
      <.table
        id="users"
        rows={@streams.users}
        row_click={fn {_id, user} -> JS.navigate(~p"/matching/#{user.id}") end}
      >
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        
        <:col :let={{_id, user}} label="ABO group">{user.abo}</:col>
        
        <:col :let={{_id, user}} label="Rh">{user.rh}</:col>
        
        <:action :let={{_id, user}}>
          <.link
            navigate={~p"/matching/#{user.id}"}
            aria-label={"Find a donor for #{user.name}"}
            class="inline-flex items-center gap-2 rounded-md border border-blue-600 px-3 py-2 text-sm font-semibold
                   text-blue-600 hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-600"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-4.35-4.35M10 18a8 8 0 100-16 8 8 0 000 16z"
              />
            </svg>
            Find donors
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    recipients = Accounts.list_recipients()

    {:ok,
     socket
     |> assign(:page_title, "User Matching")
     |> assign(:sort_by, "name")
     |> stream(:users, sort_recipients(recipients, "name"))}
  end

  @impl true
  def handle_event("sort", %{"sort" => sort_by}, socket) do
    recipients = Accounts.list_recipients()

    {:noreply,
     socket
     |> assign(:sort_by, sort_by)
     |> stream(:users, sort_recipients(recipients, sort_by), reset: true)}
  end

  defp sort_recipients(recipients, "name") do
    Enum.sort_by(recipients, & &1.name, :asc)
  end

  defp sort_recipients(recipients, "abo") do
    # Logical order of blood groups: O, A, B, AB
    abo_order = %{"O" => 1, "A" => 2, "B" => 3, "AB" => 4}
    # Depending on your Rh format (-/+)
    rh_order = %{"neg" => 1, "pos" => 2}

    Enum.sort_by(recipients, fn r ->
      {Map.get(abo_order, r.abo, 999), Map.get(rh_order, r.rh, 999)}
    end)
  end

  defp sort_recipients(recipients, _), do: recipients
end
