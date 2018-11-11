defmodule Toby.Views.Process do
  import ExTermbox.Constants, only: [attribute: 1, color: 1]
  import ExTermbox.Renderer.View

  import Toby.Formatting, only: [format_func: 1]

  alias Toby.Views.StatusBar

  @style_header %{
    attributes: [attribute(:bold)]
  }

  @style_selected %{
    color: color(:black),
    background: color(:white)
  }

  def render(%{processes: processes, selected_index: selected_idx}) do
    processes =
      processes
      |> Enum.with_index()
      |> Enum.map(fn {proc, idx} -> Map.merge(proc, %{selected: idx == selected_idx}) end)

    status_bar = StatusBar.render(%{selected: :process})

    view(bottom_bar: status_bar) do
      panel(title: "Processes", height: :fill) do
        table do
          [header_row() | process_rows(processes)]
        end
      end
    end
  end

  defp header_row do
    table_row(@style_header, [
      "PID",
      "Name or Initial Func",
      "Reds",
      "Memory",
      "MsgQ",
      "Current Function"
    ])
  end

  defp process_rows(processes) do
    processes |> Enum.map(&process_row/1)
  end

  defp process_row(process) do
    table_row(
      if(process.selected, do: @style_selected, else: %{}),
      [
        inspect(process.pid),
        name_or_initial_func(process),
        to_string(process.reductions),
        inspect(process.memory),
        to_string(process.message_queue_len),
        format_func(process.current_function)
      ]
    )
  end

  defp name_or_initial_func(process) do
    process
    |> Map.get_lazy(:registered_name, fn ->
      format_func(process.initial_call)
    end)
    |> to_string()
  end
end
