defmodule EctoFilters do
  @moduledoc """
  Adds function to transform request params into ecto query expressions.
  """

  @doc """

  ## Examples

      iex> apply_filters(Post, %{"q" => %{"title" => "Ecto Filters"}}) |> MyRepo.all()
      [%Post{title: "Ecto Filters"}, ...]
  """
  @callback apply_filters(queryable :: Ecto.Queryable.t(), params :: %{}) :: Ecto.Queryable.t()

  defmacro __using__(opts) do
    add_defaults = Keyword.get(opts, :add_defaults, true)

    quote do
      Module.put_attribute(__MODULE__, :add_defaults, unquote(add_defaults))

      defp apply_filters(original_query, params) do
        filters = create_filters(params)
        query = maybe_execute_filters(filters, original_query)
        if @add_defaults do
          maybe_apply_defaults(query, original_query, filters)
        else
          query
        end
      end

      defp maybe_execute_filters(filters, query) do
        Enum.reduce(filters, query, fn {key, value}, query ->
          try do
            apply(__MODULE__, :filter, [{key, value}, query])
          rescue
            _ -> query
          end
        end)
      end

      defp maybe_apply_defaults(query, original_query, filters) when query == original_query,
        do: Enum.reduce(filters, query, &defaults/2)

      defp maybe_apply_defaults(query, _, _), do: query

      defp condition_bools(filters) do
        Enum.map(filters, fn
          {key, "true"} -> {key, true}
          {key, "false"} -> {key, false}
          {key, value} -> {key, value}
        end)
      end

      defp filter_parameters(filters) do
        Enum.filter(filters, fn
          {_, nil} -> false
          {_, ""} -> false
          {key, value} -> true
          _ -> false
        end)
      end

      defp convert_string_keys(filters) do
        Enum.map(filters, fn
          {key, value} when is_binary(key) -> {String.to_existing_atom(key), value}
          {key, value} -> {key, value}
        end)
      end

      defp create_filters(%{"q" => parameters}) do
        parameters
        |> filter_parameters()
        |> condition_bools()
        |> convert_string_keys()
      end

      defp create_filters(_), do: []

      defp defaults({key, value}, query) do
        source = elem(query.from.source, 1)
        struct_keys = Map.keys(source.__struct__())

        if Enum.member?(struct_keys, key) do
          from(
            [c] in query,
            where: field(c, ^key) == ^value
          )
        else
          query
        end
      end

      defp defaults(_, query), do: query
    end
  end
end
