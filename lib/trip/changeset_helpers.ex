defmodule Trip.ChangesetHelpers do
  import Ecto.Changeset

	def validate_changeset_general(changeset) do
    type = changeset.data.__struct__
    changeset
    |> type.validate_changeset()
  end

	def maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset

  def maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end

  def conditional_validate(changeset, cond_fun, true_fun) do
    if cond_fun.(changeset) do
      true_fun.(changeset)
    else
      changeset
    end
  end

  def get_change_ensure(changeset, field) do
    {assoc_type, %{related: type, cardinality: card}} = changeset.types |> Map.get(field)

    case card do
      :many ->
        changeset
        |> Ecto.Changeset.get_change(
          field,
          changeset.data
          |> maybe_preload(assoc_type, field)
          |> Map.get(field)
          |> (fn
                nil -> struct(type, %{})
                field -> field
              end).()
          |> Enum.map(fn entry -> type.changeset(entry, %{}) end)
        )

      :one ->
        changeset
        |> Ecto.Changeset.get_change(
          field,
          changeset.data
          |> maybe_preload(assoc_type, field)
          |> Map.get(field)
          |> (fn
                nil -> struct(type, %{})
                field -> field
              end).()
          |> type.changeset(%{})
        )
    end
  end

  defp maybe_preload(data, :embed, _field), do: data
  defp maybe_preload(data, :assoc, field), do: data |> Trip.Repo.preload(field)

  defp traverse_nested(_changeset, [{_field, _index} | []], _merge_fn, _bottom_fn),
    do: raise("Bottom field cannot contain index!")

  defp traverse_nested(changeset, [field | []], merge_fn, bottom_fn) do
    entry =
      changeset
      |> bottom_fn.(field)

    changeset |> merge_fn.(field, entry, :one)
  end

  defp traverse_nested(changeset, [{field, index} | rest], merge_fn, bottom_fn) do
    %{cardinality: card} = changeset.types |> Map.get(field) |> field_info()
    intdex = ensure_intdex(index)

    case card do
      :many ->
        entries =
          changeset
          |> get_change_ensure(field)
          |> Enum.with_index()
          |> Enum.map(fn
            {ch, i} when i == intdex ->
              ch |> traverse_nested(rest, merge_fn, bottom_fn)

            {ch, _} ->
              ch
          end)

        changeset
        |> merge_fn.(field, entries, card)

      _ ->
        raise "Single cardinality assoc cannot have index!"
    end
  end

  defp traverse_nested(changeset, [field | rest], merge_fn, bottom_fn) do
    %{cardinality: card} = changeset.types |> Map.get(field) |> field_info()

    case card do
      :one ->
        entry =
          changeset
          |> get_change_ensure(field)
          |> traverse_nested(rest, merge_fn, bottom_fn)

        changeset
        |> merge_fn.(field, entry, card)

      _ ->
        raise "Many cardinality assoc must have index!"
    end
  end

  defp field_info({:assoc, info}), do: info
  defp field_info({:embed, info}), do: info

  def put_nested(changeset, path, bottom_fn) do
    traverse_nested(
      changeset,
      path,
      fn ch, field, entry, _card ->
        case Map.get(ch.types, field) do
          {:assoc, _} ->
            ch
            |> validate_changeset_general()
            |> Ecto.Changeset.put_assoc(field, entry)
          {:embed, _} ->
            ch
            |> validate_changeset_general()
            |> Ecto.Changeset.put_embed(field, entry)
        end
      end,
      fn ch, field ->
        ch
        |> get_change_ensure(field)
        |> bottom_fn.()
      end
    )
  end

  def get_nested_field(changeset, path) do
    changeset
    |> traverse_nested(
      path,
      fn
        _ch, _field, entry, :many ->
          entry
          |> Enum.find_value(fn
            %Ecto.Changeset{} -> nil
            val -> val
          end)

        _ch, _field, entry, :one ->
          entry
      end,
      &Ecto.Changeset.get_field/2
    )
  end

	def reject_or_mark_entry_as_deleted(entries, index) do
    intdex = ensure_intdex(index)

    entries
    |> Enum.with_index()
    |> Enum.reject(fn {%{data: entry}, i} -> is_nil(entry.id) && i == intdex end)
    |> Enum.map(fn
      {entry, i} when i == intdex ->
        entry |> Ecto.Changeset.put_change(:delete, true)

      {entry, _} ->
        entry
    end)
  end

	defp ensure_intdex(index) when is_binary(index) do
    String.to_integer(index)
  end

  defp ensure_intdex(index) do
    index
  end
end
