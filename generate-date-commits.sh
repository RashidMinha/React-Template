#!/usr/bin/env bash
set -euo pipefail

# Reusable date range (override via env vars or edit defaults)
START_DATE="${START_DATE:-2022-05-01}"
END_DATE="${END_DATE:-2023-01-31}"

# Around 12 commit-days per month for higher activity
COMMITS_PER_MONTH="${COMMITS_PER_MONTH:-12}"

# Branch/remote target
REMOTE_NAME="${REMOTE_NAME:-origin}"
REMOTE_BRANCH="${REMOTE_BRANCH:-main}"
DRY_RUN="${DRY_RUN:-0}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this script inside an existing git repository."
  exit 1
fi

is_gnu_date() {
  date --version >/dev/null 2>&1
}

to_epoch() {
  local d="$1"
  if is_gnu_date; then
    date -d "$d" +%s
  else
    date -j -f "%Y-%m-%d %H:%M:%S" "$d 00:00:00" "+%s"
  fi
}

from_epoch() {
  local e="$1"
  if is_gnu_date; then
    date -d "@$e" "+%Y-%m-%d"
  else
    date -r "$e" "+%Y-%m-%d"
  fi
}

date_field() {
  local d="$1"
  local fmt="$2"
  if is_gnu_date; then
    date -d "$d" "$fmt"
  else
    date -j -f "%Y-%m-%d %H:%M:%S" "$d 00:00:00" "$fmt"
  fi
}

first_of_month() {
  local d="$1"
  date_field "$d" "+%Y-%m-01"
}

next_month_first() {
  local d="$1"
  if is_gnu_date; then
    date -d "$(first_of_month "$d") +1 month" "+%Y-%m-01"
  else
    date -j -v+1m -f "%Y-%m-%d %H:%M:%S" "$(first_of_month "$d") 00:00:00" "+%Y-%m-01"
  fi
}

min_epoch() {
  local a="$1"
  local b="$2"
  if (( a < b )); then
    echo "$a"
  else
    echo "$b"
  fi
}

build_month_days() {
  local month_start="$1"
  local month_end_epoch="$2"
  local start_epoch
  start_epoch="$(to_epoch "$month_start")"

  local d_epoch="$start_epoch"
  local day
  local dow
  while (( d_epoch <= month_end_epoch )); do
    day="$(from_epoch "$d_epoch")"
    dow="$(date_field "$day" "+%u")" # 1..7 (Mon..Sun)
    if (( dow >= 1 && dow <= 5 )); then
      local dom
      dom="$(date_field "$day" "+%d")"
      dom=$((10#$dom))
      local week_idx=$(( (dom - 1) / 7 + 1 )) # 1..5
      case "$week_idx" in
        1) month_week1+=("$day") ;;
        2) month_week2+=("$day") ;;
        3) month_week3+=("$day") ;;
        4) month_week4+=("$day") ;;
        5) month_week5+=("$day") ;;
      esac
      month_all_days+=("$day")
    fi
    d_epoch=$(( d_epoch + 86400 ))
  done
}

pick_from_array_var() {
  local var_name="$1"
  eval "local size=\${#$var_name[@]}"
  if (( size == 0 )); then
    echo ""
    return 1
  fi
  local idx=$(( RANDOM % size ))
  eval "local picked=\${$var_name[$idx]}"
  eval "unset $var_name[$idx]"
  eval "$var_name=(\"\${$var_name[@]-}\")"
  echo "$picked"
}

array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

build_commit_message() {
  local counter="$1"
  local ts="$2"
  local msg_prefixes=("refactor" "fix" "update" "improve" "cleanup" "tweak" "adjust" "polish" "rework" "optimize")
  local msg_areas=("build setup" "deployment script" "api handlers" "error handling" "logging flow" "config loading" "auth checks" "data validation" "ui feedback" "test coverage" "docs examples" "dependency wiring" "task runner" "startup routine" "response formatting")
  local msg_details=("for edge cases" "after review feedback" "to reduce noise" "for better stability" "to simplify maintenance" "to improve readability" "for consistent behavior" "to address flaky tests" "for safer defaults" "to unblock next steps" "for production parity" "to tighten checks" "to speed up local runs" "to match latest changes" "for cleaner output")
  local p_idx=$(( RANDOM % ${#msg_prefixes[@]} ))
  local a_idx=$(( RANDOM % ${#msg_areas[@]} ))
  local d_idx=$(( RANDOM % ${#msg_details[@]} ))
  local base_msg="${msg_prefixes[$p_idx]} ${msg_areas[$a_idx]} ${msg_details[$d_idx]}"
  local short_stamp="${ts//[-: ]/}"
  short_stamp="${short_stamp:8:6}"
  echo "$base_msg ($short_stamp-$counter)"
}

pick_commit_days_for_month() {
  local target="$1"
  selected_days=()
  local week_var
  for week_var in month_week1 month_week2 month_week3 month_week4 month_week5; do
    local picked=""
    picked="$(pick_from_array_var "$week_var")" || true
    if [[ -n "$picked" ]]; then
      selected_days+=("$picked")
    fi
    (( ${#selected_days[@]} >= target )) && break
  done
  if (( ${#selected_days[@]} < target )); then
    local available=("${month_all_days[@]}")
    local filtered=()
    local candidate
    for candidate in "${available[@]}"; do
      if ! array_contains "$candidate" "${selected_days[@]}"; then
        filtered+=("$candidate")
      fi
    done
    available=("${filtered[@]}")
    while (( ${#selected_days[@]} < target )) && (( ${#available[@]} > 0 )); do
      local extra
      extra="$(pick_from_array_var available)" || true
      [[ -n "$extra" ]] && selected_days+=("$extra")
    done
  fi
}

generate_chrono_timestamps() {
  chrono_timestamps=()
  local sorted_days=()
  while IFS= read -r day; do
    [[ -n "$day" ]] && sorted_days+=("$day")
  done < <(printf "%s\n" "${selected_days[@]}" | sort)

  local last_epoch=0
  local day
  for day in "${sorted_days[@]}"; do
    local counts=(1 2 3 5)
    local num_commits=${counts[$(( RANDOM % 4 ))]}
    local day_times=()
    for (( i=0; i<num_commits; i++ )); do
      local hour=$(( 9 + (RANDOM % 9) ))
      local minute=$(( RANDOM % 60 ))
      local second=$(( RANDOM % 60 ))
      day_times+=("$(printf "%02d:%02d:%02d" "$hour" "$minute" "$second")")
    done
    local sorted_times=()
    while IFS= read -r t; do
      [[ -n "$t" ]] && sorted_times+=("$t")
    done < <(printf "%s\n" "${day_times[@]}" | sort)

    for time in "${sorted_times[@]}"; do
      local ts="$day $time"
      local ts_epoch
      if is_gnu_date; then
        ts_epoch="$(date -d "$ts" +%s)"
      else
        ts_epoch="$(date -j -f "%Y-%m-%d %H:%M:%S" "$ts" "+%s")"
      fi
      if (( ts_epoch <= last_epoch )); then
        ts_epoch=$(( last_epoch + 1 ))
        if is_gnu_date; then
          ts="$(date -u -d "@$ts_epoch" "+%Y-%m-%d %H:%M:%S")"
        else
          ts="$(date -u -r "$ts_epoch" "+%Y-%m-%d %H:%M:%S")"
        fi
      fi
      last_epoch="$ts_epoch"
      chrono_timestamps+=("$ts")
    done
  done
}

start_epoch="$(to_epoch "$START_DATE")"
end_epoch="$(to_epoch "$END_DATE")"
current_month="$(first_of_month "$START_DATE")"
commit_counter=1
all_timestamps=()

while true; do
  current_month_epoch="$(to_epoch "$current_month")"
  (( current_month_epoch > end_epoch )) && break
  next_month="$(next_month_first "$current_month")"
  next_month_epoch="$(to_epoch "$next_month")"
  month_end_epoch=$(( next_month_epoch - 86400 ))
  month_start_epoch="$(to_epoch "$current_month")"
  if (( month_start_epoch < start_epoch )); then month_start_epoch="$start_epoch"; fi
  month_end_epoch="$(min_epoch "$month_end_epoch" "$end_epoch")"
  if (( month_start_epoch <= month_end_epoch )); then
    month_start_date="$(from_epoch "$month_start_epoch")"
    month_week1=(); month_week2=(); month_week3=(); month_week4=(); month_week5=()
    month_all_days=(); selected_days=(); chrono_timestamps=()
    build_month_days "$month_start_date" "$month_end_epoch"
    if (( ${#month_all_days[@]} > 0 )); then
      month_target="$COMMITS_PER_MONTH"
      if (( month_target > ${#month_all_days[@]} )); then month_target="${#month_all_days[@]}"; fi
      pick_commit_days_for_month "$month_target"
      generate_chrono_timestamps
      for ts in "${chrono_timestamps[@]}"; do all_timestamps+=("$ts"); done
    fi
  fi
  current_month="$next_month"
done

tmp_sorted_all_timestamps=()
while IFS= read -r ts; do
  [[ -n "$ts" ]] && tmp_sorted_all_timestamps+=("$ts")
done < <(printf "%s\n" "${all_timestamps[@]-}" | sort)
all_timestamps=("${tmp_sorted_all_timestamps[@]-}")

if (( ${#all_timestamps[@]} == 0 )); then
  echo "No eligible weekdays found between $START_DATE and $END_DATE."
  exit 0
fi

for ts in "${all_timestamps[@]}" ; do
  [[ -z "$ts" ]] && continue
  msg="$(build_commit_message "$commit_counter" "$ts")"
  if (( DRY_RUN == 1 )); then
    echo "[DRY_RUN] $msg @ $ts"
  else
    # Appending to activity.log to make it look "natural"
    echo "[$ts] Activity: $msg" >> activity.log
    git add activity.log
    GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts" git commit -m "$msg"
  fi
  commit_counter=$(( commit_counter + 1 ))
done

if (( DRY_RUN == 1 )); then
  echo "[DRY_RUN] Would push to $REMOTE_NAME/$REMOTE_BRANCH"
else
  git push "$REMOTE_NAME" "$REMOTE_BRANCH"
fi

echo "Done. Created $((commit_counter - 1)) commits from $START_DATE to $END_DATE."