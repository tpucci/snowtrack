defmodule SnowtrackWeb.Components.SubmitBtn do
  @moduledoc false

  use SnowtrackWeb, :component

  @default_class "group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"

  def submitbtn(assigns) do
    assigns = assigns |> assign_new(:class, fn -> @default_class end)

    ~H"""
    <%= submit class: @class, phx_disable_with: @label_disable_with do %>
      <%= if Map.has_key?(assigns, :icon) do %>
        <span class="absolute left-0 inset-y-0 flex items-center pl-3">
          <%= component(@icon, class: "h-5 w-5 text-primary-500 group-hover:text-primary-300") %>
        </span>
      <% end %>
      <%= @label %>
    <% end %>
    """
  end
end
