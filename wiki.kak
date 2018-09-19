define-command select-outermost-bracket-group %{
    try %{
        execute-keys "<a-a>["
        select-outermost-bracket-group
    }
}

define-command goto-wiki %{
     select-outermost-bracket-group
     try %{ execute-keys %{s\[\[.*\]\]<ret>} }

     evaluate-commands %sh{
       if href="$(expr "$kak_selection" : '\[\[\(.*\)\|' \
                   '|' "$kak_selection" : '\[\[\(.*\)\]\]')";
       then
         case "$href" in
           */) path="$PWD/wiki$href.wiki" ;;
           *) path="$(dirname "$kak_buffile")/$href.wiki" ;;
         esac;
         echo "edit %{$path}";
       else
         echo 'execute-keys <a-i>wi[[<esc>a]]<esc>HH';
       fi;
    }
}

define-command edit-wiki-index %{
  evaluate-commands %sh{
    if [ -f ~/wiki/index.wiki ] || ! command -v ranger >/dev/null; then
      printf "edit %%sh{echo %q}\n" ~/wiki/index.wiki
    else
      printf "ranger %q\n" ~/wiki
    fi
  }
}

hook global BufCreate .*\.wiki %{
    set-option buffer filetype wiki
}

hook -group wiki-highlight global WinSetOption filetype=wiki %{
    map window normal <ret> :goto-wiki<ret>
    add-highlighter window ref wiki
}

hook -group wiki-highlight global WinSetOption filetype=(?!wiki).* %{
    unmap window normal <ret>
    remove-highlighter window/wiki
}
