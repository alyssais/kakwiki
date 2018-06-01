define-command select-outermost-bracket-group %{
    try %{
        execute-keys "<a-a>["
        select-outermost-bracket-group
    }
}

define-command goto-wiki %{
     select-outermost-bracket-group
     execute-keys %{s\[\[.*\]\]<ret>}
     execute-keys %{HH<a-;>LL<a-;>}

     edit %sh{
         case "$kak_selection" in
           */) path="$PWD/wiki$kak_selection.wiki" ;;
           *) path="$(dirname "$kak_buffile")/$kak_selection.wiki" ;;
         esac;
         echo "$path";
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

hook -group wiki-highlight global WinSetOption filetype=(?!ini).* %{
    unmap window normal <ret>
    remove-highlighter window/wiki
}
