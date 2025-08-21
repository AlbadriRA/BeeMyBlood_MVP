defmodule MatchingWeb.MatchingLive.Show do
  use MatchingWeb, :live_view

  alias Matching.Accounts
  alias Matching.MatchingEngine
  alias Matching.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    reference =
      Accounts.get_user!(id)
      |> Repo.preload(:traits)

    matches = MatchingEngine.match(reference)

    {:ok,
     socket
     |> assign(:page_title, "Matching Results")
     |> assign(:reference, reference)
     |> assign(:matches, matches)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Matching Results
        <:subtitle>
          For <strong>{@reference.name}</strong> ({@reference.abo} {@reference.rh})
        </:subtitle>
      </.header>

    <!-- Recipient profile -->
      <div class="mb-6">
        <h3 class="text-lg font-semibold mb-2">Recipient Profile</h3>

        <div class="mb-2">
          <strong>Blood group:</strong> {@reference.abo} {@reference.rh}
        </div>

        <div>
          <strong>Minor antigens:</strong>
          <%= if @reference.traits != [] do %>
            <div class="flex flex-wrap gap-1 mt-1">
              <%= for trait <- @reference.traits do %>
                <span class="px-2 py-1 border rounded text-sm">
                  {trait.name}
                </span>
              <% end %>
            </div>
          <% else %>
            <span class="text-sm text-gray-500">No minor antigens specified</span>
          <% end %>
        </div>
      </div>

      <%= if @matches == [] do %>
        <div class="alert alert-warning">
          No compatible donor found
        </div>
      <% else %>
        <div class="mb-4">
          <p>{length(@matches)} compatible donor(s) found</p>
        </div>

        <.table id="matches" rows={@matches}>
          <:col :let={user} label="Name">{user.name}</:col>

          <:col :let={user} label="Email">{user.email}</:col>

          <:col :let={user} label="ABO">{user.abo}</:col>

          <:col :let={user} label="Rh">{user.rh}</:col>

          <:col :let={user} label="Canton">{user.canton}</:col>

          <:col :let={user} label="Minor Antigens">
            <%= if user.traits != [] do %>
              <div class="flex flex-wrap gap-1">
                <%= for trait <- user.traits do %>
                  <span class="px-2 py-1 border rounded text-xs">
                    {trait.name}
                  </span>
                <% end %>
              </div>
            <% else %>
              <span class="text-sm text-gray-500">-</span>
            <% end %>
          </:col>

          <:col :let={user} label="Score">{user.score_total}</:col>
        </.table>
      <% end %>

      <div class="mt-6">
        <.link
          navigate={~p"/matching"}
          class="inline-flex items-center gap-2 rounded-md border border-gray-600 px-3 py-2 text-sm font-semibold hover:bg-gray-50"
        >
          Back to recipient list
        </.link>
      </div>
    </Layouts.app>
    """
  end
end
