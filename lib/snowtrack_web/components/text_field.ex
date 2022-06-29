defmodule SnowtrackWeb.Components.TextField do
  use SnowtrackWeb, :component

  @default_class "appearance-none relative block w-full px-3 py-2 border border-background-50/[0.1] placeholder-background-500 text-white rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 text-sm bg-background-800"

  def textfield(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> @default_class end)
      |> assign_new(:debounce, fn -> nil end)

    ~H"""
    <div>
      <%= label(@form, @field, @label, class: "sr-only") %>
      <%= case @field_type do %>
        <% :email -> %>
          <%= email_input(@form, @field,
            required: true,
            phx_debounce: @debounce,
            class: @class,
            placeholder: @placeholder
          ) %>
        <% :password -> %>
          <%= password_input(@form, @field,
            required: true,
            phx_debounce: @debounce,
            class: @class,
            placeholder: @placeholder,
            value: input_value(@form, @field)
          ) %>
      <% end %>
      <%= error_tag(@form, @field) %>
    </div>
    """
  end
end
