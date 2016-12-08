defmodule AditApi.DocumentView do
  use AditApi.Web, :view

  def render("show.json", %{doc: doc}) do
    document_json(doc)
  end

  def document_json(doc) do
    %{
      ref: doc.ref
    }
  end
end
