#! /bin/bash
# 音乐 当前播放/暂停曲目

tempfile=$(cd $(dirname $0);cd ..;pwd)/temp

this=_music
icon_color="^c#442266^^b#7879560x88^"
text_color="^c#442266^^b#7879560x99^"
signal=$(echo "^s$this^" | sed 's/_//')

[ ! "$(command -v mpc)" ] && echo command not found: mpc && exit

update() {
    sed -i '/^export '$this'=.*$/d' $tempfile
    if ! mpc status > /dev/null 2>&1; then
        return
    fi
    state=$(mpc status %state%)
    case "$state" in
        playing) icon=$(printf "\uf04b") ;;
        paused)  icon=$(printf "\uf04c") ;;
        *)       return ;;
    esac
    song=$(mpc current | sed "s/^\(.\{30\}\).*$/\1.../")
    [ -z "$song" ] && return

    icon=" $icon "
    text=" $song "

    printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> $tempfile
}

notify() {
    update
    [ ! "$song" ] && return
    notify-send -r 9527 "$icon Music" "$song"
}

click() {
    case "$1" in
        L) mpc toggle                                                 ;; # 播放/暂停
        M) mpc stop                                                   ;; # 停止
        R) notify                                                     ;; # 显示当前曲目
        D) notify                                                     ;;
    esac
}

case "$1" in
    click) click $2 ;;
    notify) notify ;;
    *) update ;;
esac