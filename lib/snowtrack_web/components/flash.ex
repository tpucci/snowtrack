defmodule SnowtrackWeb.Components.Flash do
  use SnowtrackWeb, :component

  import SnowtrackWeb.Components.Icon

  def flash(assigns) do
    {color, icon} =
      case assigns.kind do
        :info -> {"border-l-sky-600", &ic_info/1}
        :error -> {"border-l-red-700", &ic_error/1}
      end

    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div class="sticky top-0 max-w-screen-xl mx-auto z-10">
        <p
          class={
            "group absolute top-16 right-0 mx-4 animate-notify drop-shadow-lg pr-4 pl-2 py-2 bg-background-800 rounded-md border border-background-50/[0.1] border-l-4 #{color} text-gray-100 hover:text-gray-50 hover:bg-background-700 flex items-center cursor-pointer text-sm max-w-prose"
          }
          role="alert"
          phx-click="lv:clear-flash"
          phx-value-key={@kind |> Atom.to_string()}
        >
          <span class={"absolute -left-1 inset-y-1/4 border-l-4 rounded-md #{color} animate-ping"} />
          <%= component(icon, class: "h-6 w-6 mr-2 inline shrink-0") %>
          <%= live_flash(@flash, @kind) %>
          <.ic_close class="h-5 w-5 hidden group-hover:block absolute -right-3 -top-3" />
        </p>
      </div>
    <% end %>
    """
  end
end
