input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
MODEL=$(echo "$input" | jq -r '.model.display_name // ""')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOK_RAW=$(echo "$input" | jq -r '
  (.context_window.total_input_tokens // 0) +
  (.context_window.total_output_tokens // 0)
')

home_dir="$HOME"
display_dir="${cwd/#$home_dir/\~}"
IFS='/' read -ra parts <<< "$display_dir"
n=${#parts[@]}
if (( n > 3 )); then
  display_dir="…/${parts[n-2]}/${parts[n-1]}/${parts[n]}"
fi

git_branch=""
git_dirty=""
if git_top=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null); then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
               || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  git_dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | head -1)
fi

BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

dir_fg='\033[38;2;181;137;0m'        # yellow  #b58900
git_fg='\033[38;2;42;161;152m'       # cyan    #2aa198
git_dirty_fg='\033[38;2;220;50;47m'  # red     #dc322f
meta_fg='\033[38;2;88;110;117m'      # base01  #586e75
tok_fg='\033[38;2;131;148;150m'      # base1   #839496
reset='\033[0m'

out=""
out+=$(printf "${dir_fg}${display_dir}${reset}")

if [ -n "$git_branch" ]; then
  out+=$(printf " ${git_fg} ${git_branch}${reset}")
  if [ -n "$git_dirty" ]; then
    out+=$(printf "${git_dirty_fg}*${reset}")
  fi
fi

TOK_FMT=""
if [ "$TOK_RAW" -ge 1000 ] 2>/dev/null; then
  TOK_FMT=$(awk -v t="$TOK_RAW" 'BEGIN {
    v = t / 1000
    s = sprintf("%.1f", v)
    sub(/\.0$/, "", s)
    print s "k"
  }')
else
  TOK_FMT="${TOK_RAW}"
fi

[ -n "$MODEL" ] && out+=$(printf "${meta_fg}  [${MODEL}] ${BAR} ${PCT}%% ${reset}${tok_fg}| ${TOK_FMT} tok${reset}")

printf '%s' "$out"
