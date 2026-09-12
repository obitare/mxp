///|
/// A parsed `mxp` command-line invocation.
pub(all) enum Command {
  New(template~ : @templates.TemplateId, name~ : String)
  List
  Help
} derive(Eq, Debug)

///|
/// Error raised for invalid command lines or project names.
pub(all) suberror CliError {
  UnknownTemplate(name~ : String)
  InvalidProjectName(name~ : String)
  MissingArguments(hint~ : String)
} derive(Eq, Debug)

///|
pub impl Show for CliError with fn output(self, logger) {
  match self {
    UnknownTemplate(name~) => logger <+ "unknown template \"\{name}\""
    InvalidProjectName(name~) => logger <+ "invalid project name \"\{name}\""
    MissingArguments(hint~) => logger <+ "\{hint}"
  }
}

///|
/// Parse raw command-line arguments (without the program name) into a
/// [Command]. Raises [CliError] with a usage hint when the shape is wrong.
///
/// # Example
/// ```mbt check
/// test {
///   let cmd = @cli.parse_command(["new", "chrome-basic", "demo"])
///   debug_inspect(
///     cmd,
///     content=(
///       #|New(template=ChromeBasic, name="demo")
///     ),
///   )
/// }
/// ```
pub fn parse_command(args : Array[String]) -> Command raise CliError {
  match args {
    [] => Help
    ["help"] | ["--help"] | ["-h"] => Help
    ["list"] => List
    ["new", template_name, project_name] => {
      guard @templates.TemplateId::from_name(template_name) is Some(template) else {
        raise CliError::UnknownTemplate(name=template_name)
      }
      validate_project_name(template, project_name)
      New(template~, name=project_name)
    }
    ["new", ..] =>
      raise CliError::MissingArguments(
        hint="usage: mxp new <template> <project-name>",
      )
    _ => raise CliError::MissingArguments(hint="usage: mxp <new|list|help> ...")
  }
}

///|
/// Validate a project name for the given template. VSCode requires its
/// identifier rules; both templates reject path separators and empty
/// names so the generated directory stays predictable.
pub fn validate_project_name(
  template : @templates.TemplateId,
  name : String,
) -> Unit raise CliError {
  let valid = match template {
    VsCodeBasic => @mxp_core.is_vscode_id(name)
    ChromeBasic => {
      let nonempty = name.length() > 0
      let chars_ok = name.all(c => {
        c is ('a'..='z' | 'A'..='Z' | '0'..='9' | '-' | '_')
      })
      nonempty && chars_ok
    }
  }
  if !valid {
    raise CliError::InvalidProjectName(name~)
  }
}
