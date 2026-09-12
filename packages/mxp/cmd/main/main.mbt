///|
/// Entry point of the `mxp` CLI.
///
/// Commands:
/// - `mxp new <vscode-basic|chrome-basic> <project-name>` — scaffold a
///   new extension project in `./<project-name>`
/// - `mxp list` — list available templates
/// - `mxp help` — show usage
async fn main {
  let args = @env.args()
  let argv = match args {
    [_, .. rest] => rest
    _ => []
  }

  let command = @cli.parse_command(argv.to_owned()) catch {
    err => {
      println("mxp: \{err}")
      println("run `mxp help` for usage")
      return
    }
  }
  match command {
    @cli.Help => print_help()
    @cli.List =>
      for template in @templates.TemplateId::all() {
        println(template.name())
      }
    @cli.New(template~, name~) => {
      let files = template.render(name)
      if @fs.exists(name) {
        println(
          "mxp: directory \"\{name}\" already exists, refusing to overwrite",
        )
        return
      }
      scaffold(name, files)
      println(
        "created \{template.name()} project \"\{name}\" (\{files.length()} files)",
      )
      println("next: cd \{name} && moon build --target js --release")
    }
  }
}

///|
/// Write all template files under `dir`, creating directories as needed.
async fn scaffold(dir : String, files : Array[@templates.TemplateFile]) -> Unit {
  @fs.mkdir(dir, recursive=true)
  for file in files {
    let segments = file.path.split("/").collect()
    if segments.length() > 1 {
      let subdir = dir + "/" + segments[0].to_owned()
      if !@fs.exists(subdir) {
        @fs.mkdir(subdir, recursive=true)
      }
    }
    @fs.write_file(dir + "/" + file.path, file.content)
  }
}

///|
fn print_help() -> Unit {
  println("mxp — scaffold MoonBit-powered VSCode/Chrome extension projects")
  println("")
  println("usage:")
  println(
    "  mxp new <template> <project-name>   create a new extension project",
  )
  println("  mxp list                            list available templates")
  println("  mxp help                            show this help")
  println("")
  println("templates:")
  println(
    "  vscode-basic   minimal VSCode extension with MoonBit activation logic",
  )
  println(
    "  chrome-basic   Manifest V3 Chrome extension with a MoonBit service worker",
  )
}
