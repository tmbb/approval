defmodule ApprovalTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  import Approval

  doctest Approval

  def clean_dir(dir) do
    for path <- File.ls!(dir) do
      if path != ".gitkeep" do
        dir
        |> Path.join(path)
        |> File.rm!()
      end
    end
  end

  # Tests in the same module run sequentially, so there won't be any race conditions.
  # We can reuse the same directory in different tests.

  test "creates a reference file if it doesn't exist" do
    # Make sure the output directory is empty
    clean_dir("test/support/sandbox")

    try do
      # Suppress logs
      capture_log(fn ->
        # Approve a test for which a reference doesn't exist
        approve snapshot: File.read!("test/support/image-test-reference.png"),
                reference: File.read!("test/support/sandbox/image-test-reference.png"),
                reviewed: false

        assert File.exists?("test/support/sandbox/image-test-reference.png")
      end)
    after
      # Make sure we clean up the directory, no matter what happens
      # (it's cleaner that way)
      clean_dir("test/support/sandbox")
    end
  end

  test "an approval test with a reference that doesn't exist raises a warning" do
    # Make sure the output directory is empty
    clean_dir("test/support/sandbox")

    try do
      # Suppress logs
      log_message =
        capture_log(fn ->
          # Approve a test for which a reference doesn't exist
          approve snapshot: File.read!("test/support/image-test-reference.png"),
                  reference: File.read!("test/support/sandbox/image-test-reference.png"),
                  reviewed: false

          assert File.exists?("test/support/sandbox/image-test-reference.png")
        end)

      assert log_message =~ "[warning]"
      assert log_message =~ "must be reviewed"
      assert log_message =~ "test/support/sandbox/image-test-reference.png"
    after
      # Make sure we clean up the directory, no matter what happens
      # (it's cleaner that way)
      clean_dir("test/support/sandbox")
    end
  end

  test "when the test has been reviewed, it passes when the snapshot matches the reference" do
    # Approve a test for which a reference doesn't exist
    approve snapshot: File.read!("test/support/image-test-reference.png"),
            reference: File.read!("test/support/image-test-reference.png"),
            reviewed: true
  end

  test "when the test has not been reviewed, it always fails (case 1: snapshot matches reference)" do
    assert_raise(Approval.ApprovalError, fn ->
      capture_log(fn ->
        approve snapshot: File.read!("test/support/image-test.png"),
                reference: File.read!("test/support/image-test-reference.png"),
                reviewed: false
      end)
    end)
  end

  test "when the test has not been reviewed, it always fails (case 2: snapshot doesn't match reference)" do
    clean_dir("test/support/sandbox")

    try do
      File.cp!(
        "test/support/image-test-wrong.png",
        "test/support/sandbox/image-test-wrong.png"
      )

      # The following will raise, but we will catch the exception and continue
      assert_raise(Approval.ApprovalError, fn ->
        approve snapshot: File.read!("test/support/sandbox/image-test-wrong.png"),
                reference: File.read!("test/support/image-test-reference.png"),
                reviewed: true
      end)
    after
      # Clean up the .diff.html
      clean_dir("test/support/sandbox")
    end
  end

  test "when the test has been reviewed and the snapshot matches the reference, the test passes" do
    approve snapshot: File.read!("test/support/image-test-snapshot.png"),
            reference: File.read!("test/support/image-test-reference.png"),
            reviewed: true
  end

  test "when the test has been reviewed and the snapshot matches the reference, the test fails" do
    assert_raise(Approval.ApprovalError, fn ->
      approve snapshot: File.read!("test/support/sandbox/image-test-wrong.png"),
              reference: File.read!("test/support/image-test-reference.png"),
              reviewed: true
    end)
  end

  test "if the snapshot doesn't match the reference, a *.diff.html file is generated" do
    clean_dir("test/support/sandbox")

    try do
      File.cp!(
        "test/support/image-test-wrong.png",
        "test/support/sandbox/image-test-wrong.png"
      )

      # The following will raise, but we will catch the exception and continue
      assert_raise(Approval.ApprovalError, fn ->
        approve snapshot: File.read!("test/support/sandbox/image-test-wrong.png"),
                reference: File.read!("test/support/image-test-reference.png"),
                reviewed: true
      end)

      assert File.exists?("test/support/sandbox/image-test-wrong.png" <> ".diff.html")
    after
      clean_dir("test/support/sandbox")
    end
  end

  test "The generated *.diff.html file contains the right HTML, CSS and JS" do
    clean_dir("test/support/sandbox")

    try do
      File.cp!(
        "test/support/image-test-wrong.png",
        "test/support/sandbox/image-test-wrong.png"
      )

      # The following will raise, but we will catch the exception and continue
      assert_raise(Approval.ApprovalError, fn ->
        approve snapshot: File.read!("test/support/sandbox/image-test-wrong.png"),
                reference: File.read!("test/support/image-test-reference.png"),
                reviewed: true
      end)

      diff_file = "test/support/sandbox/image-test-wrong.png" <> ".diff.html"

      html = File.read!(diff_file)

      assert html =~ "<title>Approval - Image Comparison</title>"

      assert html =~ "<style>"
      assert html =~ "<script>"

      assert html =~ "<h2>Approval - Image Comparison</h2>"
      assert html =~ "<td><strong>Reference</strong></td>"
      assert html =~ "<td><strong>Difference</strong></td>"
      assert html =~ "<td><strong>Snapshot</strong></td>"

      assert html =~ "resemble.outputSettings"
      assert html =~ "transparency: 0.3"
      assert html =~ "outputDiff: true"
      assert html =~ "resemble(refFile).compareTo(snapFile)"
      assert html =~ ~S[var refImg = document.getElementById("reference");]
      assert html =~ ~S[var diffImg = document.getElementById("diff");]
      assert html =~ ~S[var snapImg = document.getElementById("snapshot");]
    after
      clean_dir("test/support/sandbox")
    end
  end
end
