{ username, ... }:
/*
  Oh My Posh, a prompt theme engine for the shell. It allows creating highly
  customizable and informative prompts with support for Git, Kubernetes, time,
  status codes, and many other segments.
*/
{
  home-manager.users.${username} = {
    programs.oh-my-posh = {
      enable = true;
      settings = {
        console_title_template = "{{ .Shell }} in {{ .Folder }}";
        final_space = true;
        version = 3;
        blocks = [
          {
            alignment = "left";
            newline = true;
            type = "prompt";
            segments = [
              {
                background = "transparent";
                foreground = "blue";
                style = "plain";
                template = "{{ .Path }}";
                type = "path";
                properties = {
                  style = "full";
                };
              }
              {
                background = "transparent";
                foreground = "green";
                style = "plain";
                template = " {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>";
                type = "git";
                properties = {
                  branch_icon = "";
                  commit_icon = "@";
                  fetch_status = true;
                };
              }
            ];
          }
          {
            overflow = "hidden";
            type = "rprompt";
            segments = [
              {
                background = "transparent";
                foreground = "yellow";
                style = "plain";
                template = "{{ .FormattedMs }}";
                type = "executiontime";
                properties = {
                  threshold = 5000;
                };
              }
            ];
          }
          {
            alignment = "left";
            newline = true;
            type = "prompt";
            segments = [
              {
                background = "transparent";
                foreground_templates = [
                  "{{if gt .Code 0}}red{{end}}"
                  "{{if eq .Code 0}}magenta{{end}}"
                ];
                style = "plain";
                template = "❯";
                type = "text";
              }
            ];
          }
        ];
        secondary_prompt = {
          background = "transparent";
          foreground = "magenta";
          template = "❯❯ ";
        };
        transient_prompt = {
          background = "transparent";
          foreground_templates = [
            "{{if gt .Code 0}}red{{end}}"
            "{{if eq .Code 0}}magenta{{end}}"
          ];
          template = "❯ ";
        };
      };
    };
  };
}
