defmodule Ecto.Filters do
  @moduledoc """
  Adds a macro `filter` and private function `apply_filter/2` to transform
  request params into ecto query expressions.

  ## Example
      use Ecto.Filters

      filter(:comment_body, fn query, value ->
        query
        |> join(:left, [p], c in assoc(p, :comments), as: :comments)
        |> where([comments: comments], ilike(comments.body, ^value))
      end)

      Post
      |> apply_filters(%{"filters" => %{"comment_body" => "some text"}})
      |> MyRepo.all()

      [%Post{title: "Ecto Filters"}, ...]

  """

  alias Ecto.Filters.Exception

  defmacro filter(key, fun) do
    quote line: __CALLER__.line do
      def filter_by(query, unquote(key), value) do
        if !is_atom(unquote(key)) do
          args = [key: unquote(key), value: value, query: query]
          raise Exception, type: :atom_key, args: args
        end

        unquote(fun).(query, value)
      end
    end
  end

  defmacro __using__(_) do
    quote location: :keep do
      import Ecto.Filters
      alias Ecto.Filters

      defp apply_filters(query, params, opts \\ []) do
        key = Keyword.get(opts, :key, :filters)

        params
        |> Filters.get_filter_params(key)
        |> Filters.build_query(__MODULE__, Ecto.Queryable.to_query(query), opts)
      end
    end
  end

  def build_query(filters, module, query, opts) do
    ignore_bad_filters = Keyword.get(opts, :ignore_bad_filters, false)

    Enum.reduce(filters, query, fn {key, value}, query ->
      try do
        apply(module, :filter_by, [query, to_atom(key), value])
      rescue
        error in FunctionClauseError ->
          args = [key: key, value: value, query: query, error: error]
          ignore_undefined_function(ignore_bad_filters, args)
      end
    end)
  end

  defp ignore_undefined_function(true, args), do: Keyword.get(args, :query)

  defp ignore_undefined_function(false, args) do
    raise Exception,
      type: :not_found,
      args: args
  end

  defp to_atom(key) when is_binary(key), do: String.to_existing_atom(key)
  defp to_atom(key) when is_atom(key), do: key

  defp to_atom(key) do
    raise Exception,
      type: :atom_or_binary_key,
      args: [key: key]
  end

  def get_filter_params(params, key) when is_list(params) do
    Keyword.get(params, key, [])
  end

  def get_filter_params(params, key) when is_map(params) do
    Map.get(params, key) || Map.get(params, Atom.to_string(key), [])
  end

  def get_filter_params(_, _), do: []
end
