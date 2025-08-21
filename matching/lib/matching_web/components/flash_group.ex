# lib/matching_web/components/flash_group.ex
defmodule MatchingWeb.FlashGroup do
  use Phoenix.Component

  attr :flash, :map, default: %{}

  def flash_group(assigns) do
    ~H"""
    <div class="space-y-2 mt-4">
      <%= if @flash[:info] do %>
        <div class="bg-blue-100 text-blue-800 px-4 py-2 rounded">
          {@flash[:info]}
        </div>
      <% end %>
      
      <%= if @flash[:error] do %>
        <div class="bg-red-100 text-red-800 px-4 py-2 rounded">
          {@flash[:error]}
        </div>
      <% end %>
    </div>
    """
  end
end
