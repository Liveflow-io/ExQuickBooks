defmodule ExQuickBooks.API.ChangeDataCapture do
  @moduledoc """
  Functions for interacting with the Change Data Capture API

  This module directly implements operations from the official API:
  <https://developer.intuit.com/app/developer/qbo/docs/learn/explore-the-quickbooks-online-api/change-data-capture>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.Credentials

  @spec get_changes(
          Credentials.t(),
          String.t() | [String.t()],
          String.t() | DateTime.t() | NaiveDateTime.t(),
          keyword()
        ) ::
          {:ok, json_map} | {:error, any}
  def get_changes(credentials, entities, changed_since, opts \\ []) do
    credentials
    |> make_request(
      :get,
      "cdc",
      "",
      nil,
      Keyword.merge(opts,
        params: [
          {"entities", prepare_entities(entities)},
          {"changedSince", prepare_changed_since(changed_since)}
        ]
      )
    )
    |> sign_request(credentials)
    |> send_json_request()
  end

  defp prepare_entities("" <> entities_string), do: entities_string
  defp prepare_entities(["" <> _ | _] = entities), do: Enum.join(entities, ",")

  defp prepare_changed_since(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_iso8601(datetime)
  defp prepare_changed_since(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
  defp prepare_changed_since("" <> iso_datetime), do: iso_datetime
end
