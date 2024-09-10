let inputs = import "./nickel.lock.ncl" in
let organist = inputs.organist in

organist.OrganistExpression
& {
  Schema,
  config | Schema
    = {
      shells = organist.shells.Bash,

      shells.build = {
        packages = {},
      },

      shells.dev = {
        packages = {
            elixir = organist.import_nix "nixpkgs#elixir_1_17"
        },
      },
    },
}
  | organist.modules.T
