let print_version () =
  Printf.printf "The Merlin toolkit version %s, for Ocaml %s\n"
    My_config.version Sys.ocaml_version;
  exit 0

let print_version_num () =
  Printf.printf "%s\n" My_config.version;
  exit 0

let unexpected_argument s =
  failwith ("Unexpected argument: " ^ s)

module Make (Bootstrap : sig val _projectfind : string -> unit end) = struct
  include Main_args.Make_top_options (struct
    let set r () = r := true
    let clear r () = r := false

    include Bootstrap

    let _debug section =
      match Misc.rev_string_split section ~on:',' with
      | [ section ] ->
        begin try Logger.(monitor (Section.of_string section))
        with Invalid_argument _ -> () end
      | [ log_path ; section ] ->
        begin try
          let section = Logger.Section.of_string section in
          Logger.monitor ~dest:log_path section
        with Invalid_argument _ ->
          ()
        end
      | _ -> assert false

    let _real_paths = set Clflags.real_paths
    let _absname = set Location.absname
    let _I dir =
      let dir = Misc.expand_directory Config.standard_library dir in
      Clflags.include_dirs := dir :: !Clflags.include_dirs
    let _init s = Clflags.init_file := Some s
    let _labels = clear Clflags.classic
    let _no_app_funct = clear Clflags.applicative_functors
    let _nolabels = set Clflags.classic
    let _nostdlib = set Clflags.no_std_include
    let _principal = set Clflags.principal
    let _rectypes = set Clflags.recursive_types
    let _strict_sequence = set Clflags.strict_sequence
    let _unsafe = set Clflags.fast
    let _version () = print_version ()
    let _vnum () = print_version_num ()
    let _w s = Warnings.parse_options false s
    let _warn_error s = Warnings.parse_options true s
    let _warn_help = Warnings.help_warnings
    let _protocol = IO.select_frontend

    let _ignore_sigint () =
      try ignore (Sys.(signal sigint Signal_ignore))
      with Invalid_argument _ -> ()

    let anonymous s = unexpected_argument s
  end)
end
