page :strona do
  process = place "process", { name: :name, valid: :valid? }
    done = place "done"

    transition "work" do
      input process
      output done do
    end
  end
end