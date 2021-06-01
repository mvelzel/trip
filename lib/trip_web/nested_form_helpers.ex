defmodule TripWeb.NestedFormHelpers do
  import Trip.ChangesetHelpers

	def cursor_for(%Phoenix.HTML.Form{} = form) do
    form.name
  end

  def cursor_for(%Phoenix.HTML.Form{} = form, assoc) do
    Phoenix.HTML.Form.input_name(form, assoc)
  end

  def add_nested(changeset, cursor, new_item_fn) do
    path = parse_cursor(cursor)
    new_item = new_item_fn.(List.last(path))

    put_nested(changeset, path, &(&1 ++ [new_item]))
  end

  def remove_nested(changeset, cursor) do
    original_path = parse_cursor(cursor)

    {path, [{assoc, index}]} = Enum.split(original_path, Enum.count(original_path) - 1)

    put_nested(
      changeset,
      path ++ [assoc],
      &reject_or_mark_entry_as_deleted(&1, index)
    )
  end

  def change_nested(changeset, cursor, field, value) do
    original_path = parse_cursor(cursor)

    case Enum.split(original_path, Enum.count(original_path) - 1) do
      {path, [{assoc, index}]} ->
        put_nested(changeset, path ++ [assoc],
          fn chs -> 
            chs
              |> List.update_at(index, &Ecto.Changeset.put_change(&1, field, value))
              |> Enum.map(&validate_changeset_general/1)
          end)
      {path, [rest]} ->
        put_nested(changeset, path ++ [rest],
          fn ch ->
            ch
            |> Ecto.Changeset.put_change(field, value)
            |> validate_changeset_general()
          end)
    end
  end

  def update_nested(changeset, cursor, field, update_fn) do
    original_path = parse_cursor(cursor)

    case Enum.split(original_path, Enum.count(original_path) - 1) do
      {path, [{assoc, index}]} ->
        put_nested(changeset, path ++ [assoc],
          fn chs -> 
            chs
              |> List.update_at(index, &Ecto.Changeset.put_change(&1, field, update_fn.(&1)))
              |> Enum.map(&validate_changeset_general/1)
          end)
      {path, [rest]} ->
        put_nested(changeset, path ++ [rest],
          fn ch ->
            ch
            |> Ecto.Changeset.put_change(field, update_fn.(ch))
            |> validate_changeset_general()
          end)
    end
  end

  def get_nested(changeset, cursor, field) do
    original_path = parse_cursor("#{cursor}[#{field}]")

    changeset
    |> get_nested_field(original_path)
  end

  defp parse_cursor(key) do
    subkey = :binary.part(key, 0, byte_size(key) - 1)

    case :binary.split(subkey, "[") do
      # assume the first path item is the name of the changeset
      [_root, nested] ->
        parse_cursor(nested, [], :binary.compile_pattern("]["))

      _ ->
        []
    end
  end

  defp parse_cursor(nil, acc, _pattern) do
    acc
  end

  defp parse_cursor(string, acc, pattern) do
    {assoc, rest} = cursor_string_parts(string, pattern)

    parse_cursor(
      # Assume an index is always after a association/embed
      String.to_atom(assoc),
      rest,
      acc,
      pattern
    )
  end

  defp parse_cursor(parent, nil, acc, _pattern) do
    acc ++ [parent]
  end

  defp parse_cursor(parent, string, acc, pattern) do
    {nested, rest} = cursor_string_parts(string, pattern)

    case parse_path_item(nested) do
      {:index, index} -> parse_cursor(rest, acc ++ [{parent, index}], pattern)
      {:assoc, assoc} -> parse_cursor(assoc, rest, acc ++ [parent], pattern)
    end
  end

  defp parse_path_item(string) do
    case Integer.parse(string) do
      {index, ""} -> {:index, index}
      _ -> {:assoc, String.to_atom(string)}
    end
  end

  defp cursor_string_parts(string, pattern) do
    case :binary.split(string, pattern) do
      [assoc, rest] -> {assoc, rest}
      [assoc] -> {assoc, nil}
    end
  end
end
