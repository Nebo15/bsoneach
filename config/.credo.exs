%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: [
          "lib/mix",
          "lib/bson/binary_utils.ex", # TODO: https://github.com/rrrene/credo/issues/144
          "lib/bson/utils.ex", # TODO: https://github.com/rrrene/credo/issues/145
          "lib/bson/types/"
        ]
      },
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0}
      ]
    }
  ]
}
