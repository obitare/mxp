///|
/// Identifier of a bundled project template.
pub enum TemplateId {
  VsCodeBasic
  ChromeBasic
} derive(Eq, Debug)

///|
/// One file produced while scaffolding a new project. `path` is relative
/// to the generated project root and may contain one directory segment.
pub(all) struct TemplateFile {
  path : String
  content : String
} derive(Eq, Debug)

///|
/// CLI-facing name of the template (`mxp new <name>`).
pub fn TemplateId::name(self : Self) -> String {
  match self {
    VsCodeBasic => "vscode-basic"
    ChromeBasic => "chrome-basic"
  }
}

///|
/// All templates, in listing order.
pub fn TemplateId::all() -> Array[TemplateId] {
  [VsCodeBasic, ChromeBasic]
}

///|
/// Look up a template by its CLI-facing name.
pub fn TemplateId::from_name(name : String) -> TemplateId? {
  match name {
    "vscode-basic" => Some(VsCodeBasic)
    "chrome-basic" => Some(ChromeBasic)
    _ => None
  }
}

///|
/// Render the complete file list for a new project called `project_name`.
pub fn TemplateId::render(
  self : Self,
  project_name : String,
) -> Array[TemplateFile] {
  match self {
    VsCodeBasic => vscode_basic_files(project_name)
    ChromeBasic => chrome_basic_files(project_name)
  }
}

///|
fn file(path : String, content : String) -> TemplateFile {
  { path, content, }
}
