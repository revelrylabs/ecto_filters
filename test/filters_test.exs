defmodule Ecto.FiltersTest do
  use ExUnit.Case
  import Ecto.Query
  use Ecto.Filters

  defmodule Post do
    use Ecto.Schema

    schema "posts" do
      field(:title, :string)
      field(:published, :boolean)
      has_many(:comments, Comment)
    end
  end

  defmodule Comment do
    use Ecto.Schema

    schema "comments" do
      field(:body, :string)
    end
  end

  filter(:title, &where(&1, title: ^&2))
  filter(:comment_body, fn query, value ->
    query
    |> join(:left, [p], c in assoc(p, :comments), as: :comments)
    |> where([comments: comments], ilike(comments.body, ^value))
  end)

  def filter_by(query, :published, value) do
    where(query, published: ^value)
  end

  @title_query %{wheres: [%{params: [{"test", {0, :title}}]}]}

  describe "ecto filters" do
    test "works with schema struct or Ecto.Query" do
      assert @title_query = apply_filters(Post, filters: [title: "test"])
      assert @title_query = apply_filters(from(post in Post), filters: [title: "test"])
    end

    test "accepts keyword lists" do
      assert @title_query = apply_filters(Post, filters: [title: "test"])
    end

    test "accepts atomized map" do
      assert @title_query = apply_filters(Post, %{filters: %{title: "test"}})
    end

    test "accepts atomized map of keyword lists" do
      assert @title_query = apply_filters(Post, %{filters: [title: "test"]})
    end

    test "accepts string keys" do
      assert @title_query = apply_filters(Post, %{"filters" => %{"title" => "test"}})
    end

    test "filters must be in filters key" do
      assert %{wheres: []} = apply_filters(Post, title: "test")
    end

    test "does not error when undefined filters are passed" do
      try do
        apply_filters(Post, filters: [is_not_defined: true])
      rescue
        Ecto.Filters.Exception ->
          assert true
      end

      assert %Ecto.Query{} =
               apply_filters(Post, [filters: [is_not_defined: true]], ignore_bad_filters: true)
    end

    test "filters key is not required" do
      assert apply_filters(Post, %{}) == from(post in Post)
      assert apply_filters(Post, []) == from(post in Post)
      assert apply_filters(Post, nil) == from(post in Post)
    end

    test "filters key can be set" do
      assert @title_query = apply_filters(Post, %{test_key: %{title: "test"}}, key: :test_key)
    end

    test "apply_filters works with hardcoded functions" do
      assert %{wheres: [%{params: [true: {0, :published}]}]} =
               apply_filters(Post, %{filters: %{published: true}})
    end

    test "comment body filter works" do
      assert %{wheres: [%{params: [{"test", :string}]}]} = apply_filters(Post, filters: [comment_body: "test"])
    end
  end
end
