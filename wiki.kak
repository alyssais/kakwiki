define-command select-outermost-bracket-group %{
    try %{
        execute-keys "<a-a>["
        select-outermost-bracket-group
    }
}

define-command goto-wiki %{
     select-outermost-bracket-group
     try %{ execute-keys %{s\[\[.*\]\]<ret>} }

     %sh{
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
  %sh{
    if [ -f ~/wiki/index.wiki ]; then
      printf "edit %%sh{echo %q}\n" ~/wiki/index.wiki
    else
      printf "ranger %q\n" ~/wiki
    fi
  }
}

add-highlighter shared/ regions -default content wiki \
    header1 '^=\h' '\h=$' '' \
    header '^==+\h' '\h==+$' '' \
    link '\[\[' '\]\]' '\[\[' \

add-highlighter shared/wiki/header1 fill title
add-highlighter shared/wiki/header1 regions -default boundaries outer \
    content '(?<=)[^=]' '(?==)' ''
add-highlighter shared/wiki/header1/outer/content ref wiki/content

add-highlighter shared/wiki/header fill header
add-highlighter shared/wiki/header regions -default boundaries outer \
    content '(?<=)[^=]' '(?==)' ''
add-highlighter shared/wiki/header/outer/content ref wiki/content

add-highlighter shared/wiki/link/ regions -default brackets outer \
    href '(?<=\[)[^\[]' '(?=\]\])|(?=\|)' '' \
    description '(?<=\|)' '(?=\]\])' ''
add-highlighter shared/wiki/link/outer/brackets fill link
add-highlighter shared/wiki/link/outer/href fill link
add-highlighter shared/wiki/link/outer/description ref wiki/content

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
