defmodule Membrane.Pcap.Source.PipelineTest do
  use ExUnit.Case, async: false

  alias Membrane.Testing.{Pipeline, Sink}
  import Membrane.Testing.Assertions

  @tag time_consuming: true
  test "Pipeline does not crash when parsing small rtp stream" do
    expected_count = 6_227
    file = "test/support/fixtures/demo.pcap"
    process_file(file, expected_count)
  end

  #! Requires Git Large File Storage
  #! `brew install git-lfs`
  #! then clone this repo to download files
  @tag time_consuming: true
  test "Pipeline does not crash when parsing big RTP Stream" do
    expected_count = 47_942
    file = "test/support/fixtures/rtp_video_stream.pcap"
    process_file(file, expected_count)
  end

  defp process_file(file, expected_packets) do
    options = %Pipeline.Options{
      elements: [
        source: %Membrane.Pcap.Source{path: file},
        sink: %Sink{}
      ]
    }

    {:ok, pid} = Pipeline.start_link(options)

    assert_pipeline_playback_changed(pid, :prepared, :playing)

    Enum.each(1..expected_packets, fn _el ->
      assert_sink_buffer(pid, :sink, %Membrane.Buffer{})
    end)

    Membrane.Pipeline.terminate(pid, blocking?: true)
  end
end
