defmodule Schedule do
	@type element :: {any, any}
  @type t :: list(element)

  @spec union :: t
  def union, do: []

  @spec union(t, t) :: t
  def union(as, bs) do
    Enum.concat(as, bs)
    |> _union_intervals
  end

  @spec intersection :: t
  def intersection, do: [{nil, nil}]

  @spec intersection(t, t) :: t
  def intersection(as, bs) do
    _intersection([], as, bs)
    |> _remove_empty_intervals
  end

  @spec complement(t) :: t
  def complement(as) do
    _complement([], as)
  end

  @spec schedule(t) :: t
  def schedule(as) do
    as
    |> _adjust_start_stop
    |> _remove_empty_intervals
    |> _union_intervals
  end

	@spec reduce(t) :: t
	def reduce([]) do
		[]
	end
	def reduce(as) do
		element = 
				Enum.reduce(as,
					fn {a_start, a_stop}, {acc_start, acc_stop} ->
						{_lower_start(a_start, acc_start), _greater_stop(a_stop, acc_stop)}
					end)
		[element]
	end

  defp _union_intervals(as) do
    as
    |> _sort_by_start
    |> _union_overlapping
  end

  defp _remove_empty_intervals(as) do
    Enum.filter(as, fn {start, stop} -> not _equal(start, stop) end)
  end

  defp _adjust_start_stop(as) do
    Enum.map(as, fn {a, b} -> if _less_or_equal(a, b), do: {a, b}, else: {b, a} end)
  end

  defp _sort_by_start(as) do
    Enum.sort(as, fn a, b -> _start_less_or_equal(a, b) end)
  end

  defp _union_overlapping(as) do
    as
    |> _reduce_union
    |> _reverse_reduced
  end

  defp _element_union({a_start, a_stop}, {b_start, b_stop}) do
    {_lower_start(a_start, b_start), _greater_stop(a_stop, b_stop)}
  end

  defp _reduce_union(as) do
    Enum.reduce(as, {nil, []},
      fn
        element, {nil, result} -> {element, result}
        element, {acc, result} ->
          if _intersect? acc, element do
            {_element_union(acc, element), result}
          else
            {element, [acc | result]}
          end
      end)
  end
  
  defp _reverse_reduced({nil, result}), do: Enum.reverse(result)
  defp _reverse_reduced({acc, result}), do: Enum.reverse(result, [acc])

  defp _lower_start(a_start, b_start) do
    case {a_start, b_start} do
      {nil, _} -> nil
      {_, nil} -> nil
      {a, b} when a <= b -> a
      _ -> b_start
    end
  end

  defp _greater_start(a_start, b_start) do
    case {a_start, b_start} do
      {nil, b} -> b
      {a, nil} -> a
      {a, b} when a <= b -> b
      _ -> a_start
    end
  end

  defp _lower_stop(a_stop, b_stop) do
    case {a_stop, b_stop} do
      {nil, b} -> b
      {a, nil} -> a
      {a, b} when a <= b -> a
      _ -> b_stop
    end
  end
  
  defp _greater_stop(a_stop, b_stop) do
    case {a_stop, b_stop} do
      {nil, _} -> nil
      {_, nil} -> nil
      {a, b} when a <= b -> b
      _ -> a_stop
    end
  end

  defp _intersect?({a_start, a_stop}, {b_start, b_stop}) do
    _less_or_equal(a_start, b_stop) and _less_or_equal(b_start, a_stop)
  end

  defp _less_or_equal(start, stop) do
    case {start, stop} do
      {nil, _} -> true
      {_, nil} -> true
      {a, b} -> a <= b
    end
  end

  defp _equal(nil, nil), do: false
  defp _equal(start, stop), do: start == stop

  defp _start_less_or_equal({a_start, _}, {b_start, _}) do
    case {a_start, b_start} do
      {nil, _} -> true
      {_, nil} -> false
      {a, b} -> a <= b
    end
  end

  defp _stop_less_or_equal({_, a_stop}, {_, b_stop}) do
    case {a_stop, b_stop} do
      {_, nil} -> true
      {nil, _} -> false
      {a, b} -> a <= b
    end
  end

  defp _intersection(acc, [], _bs), do: Enum.reverse(acc)
  defp _intersection(acc, _as, []), do: Enum.reverse(acc)
  defp _intersection(acc, [a | as], [b | bs]) do
    new_acc =
      if _intersect? a, b do
        [_element_intersection(a, b) | acc]
      else
        acc
      end
    if _stop_less_or_equal a, b do
      _intersection(new_acc, as, [b | bs])
    else
      _intersection(new_acc, [a | as], bs)
    end
  end
  
  defp _element_intersection({a_start, a_stop}, {b_start, b_stop}) do
    {_greater_start(a_start, b_start), _lower_stop(a_stop, b_stop)}
  end

  defp _complement([], []), do: [{nil, nil}]
  defp _complement(acc, []), do: Enum.reverse(acc)
  defp _complement([], [a | []]) do
    case a do
      {nil, nil} -> []
      {nil, stop} -> [{stop, nil}]
      {start, stop} -> [{nil, start}, {stop, nil}]
    end
  end
  defp _complement(acc, [a | []]) do
    case a do
      {_, nil} -> Enum.reverse(acc)
      {_, stop} -> _complement([{stop, nil} | acc], [])
    end
  end
  defp _complement([], [a1 | [a2 | as]]) do
    case {a1, a2} do
      {{nil, a1_stop}, {a2_start, _}} ->
        _complement([{a1_stop, a2_start}], [a2 | as])
      {{a1_start, a1_stop}, {a2_start, _}} ->
        _complement([{a1_stop, a2_start}, {nil, a1_start}], [a2 | as])
    end
  end
  defp _complement(acc, [a1 | [a2 | as]]) do
    case {a1, a2} do
      {{_, a1_stop}, {a2_start, _}} ->
        _complement([{a1_stop, a2_start} | acc], [a2 | as])
    end
  end

end
