defmodule ExChangeRateWeb.ErrorView do
  use ExChangeRateWeb, :view

  alias ExChangeRateWeb.ErrorHelpers

  def render("400.json", %{changeset: changeset}) do
    Ecto.Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
  end

  def render("400.json", %{message: message}) do
    %{errors: %{reason: message}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
