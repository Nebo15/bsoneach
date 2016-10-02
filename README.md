# BSONEach

[![Deps Status](https://beta.hexfaktor.org/badge/all/github/Nebo15/bsoneach.svg)](https://beta.hexfaktor.org/github/Nebo15/bsoneach) [![Hex.pm Downloads](https://img.shields.io/hexpm/dw/bsoneach.svg?maxAge=3600)](https://hex.pm/packages/bsoneach) [![Latest Version](https://img.shields.io/hexpm/v/bsoneach.svg?maxAge=3600)](https://hex.pm/packages/bsoneach) [![License](https://img.shields.io/hexpm/l/bsoneach.svg?maxAge=3600)](https://hex.pm/packages/bsoneach) [![Build Status](https://travis-ci.org/Nebo15/bsoneach.svg?branch=master)](https://travis-ci.org/Nebo15/bsoneach) [![Coverage Status](https://coveralls.io/repos/github/Nebo15/bsoneach/badge.svg?branch=master)](https://coveralls.io/github/Nebo15/bsoneach?branch=master)

This module aims on reading large BSON files with low memory consumption. It provides single ```BSONEach.each(func)``` function that will read BSON file and apply callback function ```func``` to each parsed document.

File is read by 4096 byte chunks, BSONEach iterates over all documents till the end of file is reached.

Also you can use ```BSONEach.stream(path)``` if you want to read file as IO stream, which is useful when you use GenStage behavior.

## Performance

  * This module archives low memory usage (on my test environment it's constantly consumes 28.1 Mb on a 1.47 GB fixture with 1 000 000 BSON documents).
  * Correlation between file size and parse time is linear. (You can check it by running ```mix bench```).

    ```
    $ mix bench
    Settings:
      duration:      1.0 s

    ## IterativeBench
    [17:36:14] 1/8: read and iterate 1 document
    [17:36:16] 2/8: read and iterate 30 documents
    [17:36:18] 3/8: read and iterate 300 documents
    [17:36:20] 4/8: read and iterate 30_000 documents
    [17:36:21] 5/8: read and iterate 3_000 documents
    ## StreamBench
    [17:36:22] 6/8: stream and iterate 300 documents
    [17:36:24] 7/8: stream and iterate 30_000 documents
    [17:36:25] 8/8: stream and iterate 3_000 documents

    Finished in 13.19 seconds

    ## IterativeBench
    benchmark name                       iterations   average time
    read and iterate 1 document              100000   15.54 µs/op
    read and iterate 30 documents             50000   22.63 µs/op
    read and iterate 300 documents              100   13672.39 µs/op
    read and iterate 3_000 documents             10   127238.70 µs/op
    read and iterate 30_000 documents             1   1303975.00 µs/op
    ## StreamBench
    benchmark name                       iterations   average time
    stream and iterate 300 documents            100   14111.38 µs/op
    stream and iterate 3_000 documents           10   142093.60 µs/op
    stream and iterate 30_000 documents           1   1429789.00 µs/op
    ```

  * It's better to pass a file to BSONEach instead of stream, since streamed implementation works so much slower.
  * BSONEach is CPU-bounded. Consumes 98% of CPU resources on my test environment.
  * (```time``` is not a best way to test this, but..) on large files BSONEach works almost 2 times faster comparing to loading whole file in memory and iterating over it:

    Generate a fixture:

    ```bash
    $ mix generate_fixture 1000000 test/fixtures/1000000.bson
    ```

    Run different task types:

    ```bash
    $ time mix count_read test/fixtures/1000000.bson
    Compiling 2 files (.ex)
    "Done parsing 1000000 documents."
    mix print_read test/fixtures/1000000.bson  59.95s user 5.69s system 99% cpu 1:05.74 total
    ```

    ```bash
    $ time mix count_stream test/fixtures/1000000.bson
    Compiling 2 files (.ex)
    Generated bsoneach app
    "Done parsing 1000000 documents."
    mix count_stream test/fixtures/1000000.bson  45.37s user 2.74s system 102% cpu 46.876 total
    ```

  * This implementation works faster than [timkuijsten/node-bson-stream](https://github.com/timkuijsten/node-bson-stream) NPM package (we comparing with Node.js on file with 30k documents):

    ```bash
    $ time mix count_stream test/fixtures/30000.bson
    "Done parsing 30000 documents."
    mix count_stream test/fixtures/30000.bson  1.75s user 0.35s system 114% cpu 1.839 total
    ```

    ```bash
    $ time node index.js
    Read 30000 documents.
    node index.js  2.09s user 0.05s system 100% cpu 2.139 total
    ```

## Installation

It's available on [hex.pm](https://hex.pm/packages/bsoneach) and can be installed as project dependency:

  1. Add `bsoneach` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bsoneach, "~> 0.3.2"}]
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
    |> BSONEach.File.open # Open file in :binary, :raw, :read_ahead modes
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

## Thanks

I want to thank to @ericmj for his MongoDB driver. All code that encodes and decodes to with BSON was taken from his repo.
