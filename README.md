# BSONEach

[![Deps Status](https://beta.hexfaktor.org/badge/all/github/Nebo15/bsoneach.svg)](https://beta.hexfaktor.org/github/Nebo15/bsoneach) [![Hex.pm Downloads](https://img.shields.io/hexpm/dw/bsoneach.svg?maxAge=3600)](https://hex.pm/packages/bsoneach) [![Latest Version](https://img.shields.io/hexpm/v/bsoneach.svg?maxAge=3600)](https://hex.pm/packages/bsoneach) [![License](https://img.shields.io/hexpm/l/bsoneach.svg?maxAge=3600)](https://hex.pm/packages/bsoneach) [![Build Status](https://travis-ci.org/Nebo15/bsoneach.svg?branch=master)](https://travis-ci.org/Nebo15/bsoneach) [![Coverage Status](https://coveralls.io/repos/github/Nebo15/bsoneach/badge.svg?branch=master)](https://coveralls.io/github/Nebo15/bsoneach?branch=master)

This module aims on reading large BSON files with low memory consumption. It provides single ```BSONEach.each(func)``` function that will read BSON file and apply callback function ```func``` to each parsed document.

File is read by 4096 byte chunks, BSONEach iterates over all documents till the end of file is reached.

## Performance

  * This module archives low memory usage (on my test environment it's constantly consumes 28.1 Mb on a 1.47 GB fixture with 1 000 000 BSON documents).
  * Correlation between file size and parse time is linear. (You can check it by running ```mix bench```).
  * BSONEach is CPU-bounded. Consumes 98% of CPU resources on my test environment.
  * (```time``` is not a best way to test this, but..) on large files BSONEach works almost 2 times faster comparing to loading whole file in memory and iterating over it:

    Generate a fixture:

    ```bash
    $ mix generate_fixture 1000000 test/fixtures/1000000.bson
    ```

    Run different task types:

    ```bash
    $ time mix print_read test/fixtures/1000000.bson
    mix print_read test/fixtures/1000000.bson  994.60s user 154.40s system 87% cpu 21:51.88 total
    ```

    ```bash
    $ time mix print_each test/fixtures/1000000.bson
    mix print_each test/fixtures/1000000.bson  583.67s user 66.86s system 75% cpu 14:27.26 total
    ```

  * Pass a file to BSONEach instead of streams, since streamed implementation works so much-much slower:

    ```bash
    $ mix bench
    Compiling 1 file (.ex)

    Settings:
      duration:      1.0 s

    ## EachBench
    [15:02:11] 1/10: read and iterate 1 document
    [15:02:12] 2/10: read and iterate 30 documents
    [15:02:15] 3/10: read and iterate 300 documents
    [15:02:18] 4/10: read and iterate 30_000 documents
    [15:02:21] 5/10: read and iterate 3_000 documents
    [15:02:23] 6/10: stream and iterate 1 document
    [15:02:26] 7/10: stream and iterate 30 documents
    [15:02:28] 8/10: stream and iterate 300 documents
    [15:02:30] 9/10: stream and iterate 30_000 documents
    [15:04:37] 10/10: stream and iterate 3_000 documents
    Finished in 151.93 seconds

    ## EachBench
    read and iterate 1 document               10000   140.63 µs/op
    stream and iterate 1 document             10000   190.69 µs/op
    read and iterate 30 documents              1000   2601.48 µs/op
    stream and iterate 30 documents             500   3198.02 µs/op
    read and iterate 300 documents              100   25354.27 µs/op
    stream and iterate 300 documents             50   41764.02 µs/op
    read and iterate 3_000 documents             10   252262.90 µs/op
    read and iterate 30_000 documents             1   2514610.00 µs/op
    stream and iterate 3_000 documents            1   6238468.00 µs/op
    stream and iterate 30_000 documents           1   126495171.00 µs/op
    ```

## Installation

It's available on [hex.pm](https://hex.pm/packages/bsoneach) and can be installed as project dependency:

  1. Add `bsoneach` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bsoneach, "~> 0.1.0"}]
    end
    ```

  2. Ensure `bsoneach` is started before your application:

    ```elixir
    def application do
      [applications: [:bsoneach]]
    end
    ```

## How to use

  1. Open file and pass iostream to a ```BSONEach.each(func)``` function:

    ```elixir
    "test/fixtures/300.bson" # File path
    |> File.open!([:read, :binary, :raw]) # Open file in :binary, :raw mode
    |> BSONEach.each(&process_bson_document/1) # Send IO.device to BSONEach.each function and pass a callback
    |> File.close # Don't forget to close referenced file
    ```

  2. Callback function should receive a struct:

    ```elixir
    def process_bson_document(%{} = document) do
      # Do stuff with a document
      IO.inspect document
    end
    ```

When you process large files its a good thing to process documents asynchronously, you can find more info [here](http://elixir-lang.org/docs/stable/elixir/Task.html).
