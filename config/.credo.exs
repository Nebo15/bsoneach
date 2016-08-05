%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: ["lib/mix/tasks"]
      },
      checks: [
        {Credo.Check.Design.TagTODO, exit_status: 0}
      ]
    }
  ]
}
