{ username, ... }:
/*
  Enables management of default applications for MIME types and file
  extensions through Home Manager. This allows you to set which applications
  should be used to open specific file types (e.g., PDFs, images, text files)
  and define default handlers for desktop environments or file managers.
*/
{
  home-manager.users.${username}.xdg.mimeApps = {
    enable = true;
  };
}
