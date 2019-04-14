defmodule EctoFiltersTest.WithoutFilters do
  use ExUnit.Case

  import Ecto.Query, warn: false
  use EctoFilters

  defmodule Post do
    use Ecto.Schema
    schema "post" do
      field(:name, :utc_datetime)
    end
  end

  defp query, do: from(post in Post)

  describe "apply_filters" do
    test "with empty filters" do
      assert %Ecto.Query{} = apply_filters(query(), %{})
    end

    test "with name filter" do
      query = apply_filters(query(), %{"q" => %{"name" => "Joe"}})
      assert [%Ecto.Query.BooleanExpr{params: [{"Joe", {0, :name}}]}] = query.wheres
    end
  end
end
